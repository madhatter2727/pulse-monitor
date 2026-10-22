import Foundation
import Darwin

struct CoreGroup { let name: String; let prefix: String; let range: Range<Int> }
struct Proc { let name: String; let value: Double }

func sysctlInt(_ n: String) -> Int {
    var v: Int64 = 0; var s = MemoryLayout<Int64>.size
    if sysctlbyname(n, &v, &s, nil, 0) != 0 { return -1 }
    return s == 4 ? Int(Int32(truncatingIfNeeded: v)) : Int(v)
}
func sysctlStr(_ n: String) -> String? {
    var s = 0; guard sysctlbyname(n, nil, &s, nil, 0) == 0, s > 0 else { return nil }
    var b = [CChar](repeating: 0, count: s); sysctlbyname(n, &b, &s, nil, 0)
    return String(cString: b)
}

final class Stats: ObservableObject {
    @Published var cpu = 0.0
    @Published var user = 0.0
    @Published var sys = 0.0
    @Published var cores: [Double] = []
    @Published var history: [Double] = []
    @Published var groups: [CoreGroup] = []
        @Published var total = 0.0
    @Published var app = 0.0
    @Published var wired = 0.0
    @Published var compressed = 0.0
    @Published var cached = 0.0
    @Published var free = 0.0
    @Published var swapUsed = 0.0
    @Published var swapTotal = 0.0
    @Published var pressure = 1
    @Published var topCPU: [Proc] = []
    @Published var topMem: [Proc] = []
    private var prev: [[UInt32]] = []
    private var timer: Timer?
    private var tick = 0

    init() {
        total = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824
        // Apple Silicon: logical CPUs are numbered starting with the lowest perf level (efficiency) cluster.
        let n = sysctlInt("hw.nperflevels")
        var levels: [(String, Int)] = []
        if n > 0 { for i in 0..<n {
            let name = sysctlStr("hw.perflevel\(i).name") ?? "Level \(i)"
            levels.append((name, sysctlInt("hw.perflevel\(i).logicalcpu")))
        } }
        var start = 0; var gs: [CoreGroup] = []
        for (name, c) in levels.reversed() where c > 0 {
            gs.append(CoreGroup(name: "\(name) cores", prefix: String(name.prefix(1)), range: start..<start+c)); start += c
        }
        groups = gs.reversed()
        sample()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.sample() }
    }

    func sample() {
        sampleCPU(); sampleMem()
        if tick % 2 == 0 { sampleProcs() }
        tick += 1
    }

    private func sampleCPU() {
        var count: natural_t = 0; var info: processor_info_array_t?; var ic: mach_msg_type_number_t = 0
        guard host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &count, &info, &ic) == KERN_SUCCESS, let info else { return }
        var cur: [[UInt32]] = []
        for i in 0..<Int(count) {
            let b = Int(CPU_STATE_MAX) * i
            cur.append((0..<4).map { UInt32(bitPattern: info[b + $0]) })
        }
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(Int(ic) * MemoryLayout<integer_t>.stride))
        if prev.count == cur.count {
            var per: [Double] = []; var tu = 0.0, ts = 0.0, tt = 0.0
            for i in 0..<cur.count {
                let d = (0..<4).map { Double(cur[i][$0] &- prev[i][$0]) }
                let u = d[Int(CPU_STATE_USER)] + d[Int(CPU_STATE_NICE)], s = d[Int(CPU_STATE_SYSTEM)]
                let t = d.reduce(0, +)
                per.append(t > 0 ? (u + s) / t * 100 : 0); tu += u; ts += s; tt += t
            }
            cores = per
            user = tt > 0 ? tu / tt * 100 : 0; sys = tt > 0 ? ts / tt * 100 : 0; cpu = user + sys
            history.append(cpu); if history.count > 90 { history.removeFirst(history.count - 90) }
        } else { cores = Array(repeating: 0, count: cur.count) }
        prev = cur
        if groups.isEmpty { groups = [CoreGroup(name: "Cores", prefix: "C", range: 0..<cur.count)] }
    }

    private func sampleMem() {
        var s = vm_statistics64(); var c = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let r = withUnsafeMutablePointer(to: &s) { $0.withMemoryRebound(to: integer_t.self, capacity: Int(c)) { host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &c) } }
        guard r == KERN_SUCCESS else { return }
        let pg = Double(vm_kernel_page_size) / 1_073_741_824
        app = Double(Int64(s.internal_page_count) - Int64(s.purgeable_count)) * pg
        wired = Double(s.wire_count) * pg
        compressed = Double(s.compressor_page_count) * pg
        cached = Double(UInt64(s.external_page_count) + UInt64(s.purgeable_count)) * pg
        free = Double(s.free_count) * pg
        var sw = xsw_usage(); var sz = MemoryLayout<xsw_usage>.size
        if sysctlbyname("vm.swapusage", &sw, &sz, nil, 0) == 0 {
            swapUsed = Double(sw.xsu_used) / 1_073_741_824; swapTotal = Double(sw.xsu_total) / 1_073_741_824
        }
        let p = sysctlInt("kern.memorystatus_vm_pressure_level"); if p > 0 { pressure = p }
    }

    private func sampleProcs() {
        DispatchQueue.global(qos: .utility).async {
            let t = Process(); t.executableURL = URL(fileURLWithPath: "/bin/ps")
            t.arguments = ["-Axo", "pcpu=,rss=,comm="]
            let pipe = Pipe(); t.standardOutput = pipe; t.standardError = FileHandle.nullDevice
            do { try t.run() } catch { return }
            let data = pipe.fileHandleForReading.readDataToEndOfFile(); t.waitUntilExit()
            var rows: [(String, Double, Double)] = []
            for line in String(decoding: data, as: UTF8.self).split(separator: "\n") {
                let parts = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count == 3, let c = Double(parts[0]), let m = Double(parts[1]) else { continue }
                let name = friendlyName(String(parts[2]))
                rows.append((name, c, m / 1_048_576))
            }
            var agg: [String: (Double, Double)] = [:]
            for r in rows { let o = agg[r.0] ?? (0, 0); agg[r.0] = (o.0 + r.1, o.1 + r.2) }
            rows = agg.map { ($0.key, $0.value.0, $0.value.1) }
            let tc = rows.sorted { $0.1 > $1.1 }.prefix(10).map { Proc(name: $0.0, value: $0.1) }
            let tm = rows.sorted { $0.2 > $1.2 }.prefix(10).map { Proc(name: $0.0, value: $0.2) }
            DispatchQueue.main.async { self.topCPU = tc; self.topMem = tm }
        }
    }

    var used: Double { app + wired + compressed }
    var availablePct: Double { total > 0 ? min(100, (free + cached) / total * 100) : 0 }
}
