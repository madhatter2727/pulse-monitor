import SwiftUI

let cGreen = Color(red: 0.56, green: 0.72, blue: 0.50)
let cAmber = Color(red: 0.85, green: 0.66, blue: 0.36)
let cRed = Color(red: 0.88, green: 0.42, blue: 0.40)
let cApp = Color(red: 0.55, green: 0.66, blue: 0.78)
let cWired = Color(red: 0.78, green: 0.64, blue: 0.45)
let cComp = Color(red: 0.70, green: 0.60, blue: 0.72)
let cCache = Color(white: 0.45)
let dim = Color.white.opacity(0.55)
let mono = Font.system(size: 12, design: .monospaced)
func barColor(_ v: Double) -> Color { v >= 70 ? cAmber : cGreen }
func g(_ v: Double) -> String { String(format: "%.1f G", max(0, v)) }

struct Bar: View {
    let v: Double; var h: CGFloat = 6
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.10))
                Capsule().fill(barColor(v)).frame(width: max(h, geo.size.width * min(1, v / 100)))
            }
        }.frame(height: h)
    }
}

struct MemBar: View {
    @ObservedObject var s: Stats; var h: CGFloat = 10
    var body: some View {
        GeometryReader { geo in
            let t = max(s.total, 0.001), w = geo.size.width
            HStack(spacing: 0) {
                cApp.frame(width: w * max(0, s.app) / t)
                cWired.frame(width: w * s.wired / t)
                cComp.frame(width: w * s.compressed / t)
                cCache.frame(width: w * min(s.cached, max(0, t - s.used)) / t)
                Color.white.opacity(0.08)
            }.clipShape(Capsule())
        }.frame(height: h)
    }
}

struct Spark: View {
    let data: [Double]
    var body: some View {
        GeometryReader { geo in
            Path { p in
                guard data.count > 1 else { return }
                let w = geo.size.width, h = geo.size.height
                for (i, v) in data.enumerated() {
                    let pt = CGPoint(x: w * CGFloat(i + 90 - data.count) / 89, y: h - h * CGFloat(min(100, v)) / 100)
                    i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                }
            }.stroke(cGreen, lineWidth: 1.4)
        }
    }
}

struct IconButton: View {
    let name: String; let action: () -> Void
    var body: some View {
        Button(action: action) { Image(systemName: name).font(.system(size: 11, weight: .semibold)).foregroundColor(dim).frame(width: 18, height: 18).contentShape(Rectangle()) }
            .buttonStyle(.plain)
    }
}

struct RootView: View {
    @ObservedObject var s: Stats
    @ObservedObject var ui: UIState
    var body: some View {
        Group { if ui.expanded { expanded } else { compact } }
            .foregroundColor(.white.opacity(0.92))
            .fixedSize()
    }

    var compact: some View {
        HStack(spacing: 10) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(s.cores.enumerated()), id: \.offset) { _, v in
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 1).fill(Color.white.opacity(0.10))
                        RoundedRectangle(cornerRadius: 1).fill(barColor(v)).frame(height: max(2, 16 * v / 100))
                    }.frame(width: 4, height: 16)
                }
            }
            Text(String(format: "%3.0f%%", s.cpu)).font(.system(size: 13, weight: .semibold, design: .monospaced))
            MemBar(s: s, h: 5).frame(width: 54)
            Text(String(format: "%.1f G", s.used)).font(.system(size: 13, design: .monospaced))
            IconButton(name: "chevron.down") { ui.toggle() }
            IconButton(name: "xmark") { ui.close() }
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
    }

    func coreCell(_ g: CoreGroup, _ i: Int) -> some View {
        let v = i < s.cores.count ? s.cores[i] : 0
        return HStack(spacing: 8) {
            Text("\(g.prefix)\(i - g.range.lowerBound + 1)").font(mono).foregroundColor(dim).frame(width: 28, alignment: .leading)
            Bar(v: v)
            Text(String(format: "%.0f%%", v)).font(mono).frame(width: 38, alignment: .trailing)
        }
    }

    var expanded: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("CPU").font(.system(size: 16, weight: .semibold))
                Text(String(format: "%.0f%%", s.cpu)).font(.system(size: 16, weight: .semibold, design: .monospaced))
                Text(String(format: "user %.0f%%  sys %.0f%%", s.user, s.sys)).font(mono).foregroundColor(dim).padding(.leading, 18)
                Spacer()
                IconButton(name: "chevron.up") { ui.toggle() }
                IconButton(name: "xmark") { ui.close() }
            }
            ForEach(s.groups, id: \.name) { gr in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(gr.name).font(.system(size: 13, weight: .semibold))
                        Spacer()
                        let vals = gr.range.map { $0 < s.cores.count ? s.cores[$0] : 0 }
                        Text(String(format: "%d × · avg %.0f%%", vals.count, vals.reduce(0, +) / Double(max(1, vals.count)))).font(mono).foregroundColor(dim)
                    }
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible())], spacing: 5) {
                        ForEach(Array(gr.range), id: \.self) { i in coreCell(gr, i) }
                    }
                }
            }
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.05))
                Text("90 s").font(.system(size: 11, design: .monospaced)).foregroundColor(dim).padding(6)
                Spark(data: s.history).padding(.top, 24).padding(.horizontal, 4).padding(.bottom, 6)
            }.frame(height: 62)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Memory").font(.system(size: 16, weight: .semibold)); Spacer()
                    Text(String(format: "%.1f G of %.0f G really used", s.used, s.total)).font(.system(size: 12)).foregroundColor(.white.opacity(0.8))
                }
                MemBar(s: s)
                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 4) { legend(cApp, "App", g(s.app)); legend(cWired, "Wired", g(s.wired)); legend(cComp, "Compressed", g(s.compressed)) }
                    VStack(spacing: 4) { legend(cCache, "Cached files", g(s.cached)); legend(nil, "Free", g(s.free))
                        legend(.clear, "Swap used", String(format: "%.1f/%.1f G", s.swapUsed, s.swapTotal)) }
                }
                HStack(spacing: 6) {
                    Text("Pressure").foregroundColor(dim)
                    let (pc, pt): (Color, String) = s.pressure >= 4 ? (cRed, "Critical") : s.pressure == 2 ? (cAmber, "Warning") : (cGreen, "Normal")
                    Circle().fill(pc).frame(width: 7, height: 7)
                    Text(pt).fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "cached is reclaimable · %.0f%% available", s.availablePct)).foregroundColor(dim)
                }.font(.system(size: 12)).padding(.top, 2)
            }
            HStack(alignment: .top, spacing: 24) {
                procList("Top CPU", s.topCPU) { String(format: "%.1f%%", $0) }
                procList("Top memory", s.topMem) { String(format: "%.1f G", $0) }
            }
        }
        .padding(18).frame(width: 520)
    }

    func legend(_ c: Color?, _ name: String, _ val: String) -> some View {
        HStack(spacing: 6) {
            if let c { RoundedRectangle(cornerRadius: 2).fill(c).frame(width: 9, height: 9) }
            else { RoundedRectangle(cornerRadius: 2).stroke(Color.white.opacity(0.7), lineWidth: 1).frame(width: 9, height: 9) }
            Text(name).font(.system(size: 13)); Spacer()
            Text(val).font(mono)
        }
    }

    func procList(_ title: String, _ list: [Proc], _ f: @escaping (Double) -> String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 13, weight: .semibold)).padding(.bottom, 2)
            ForEach(0..<10, id: \.self) { i in
                let p = i < list.count ? list[i] : nil
                HStack { Text(p?.name ?? " ").font(.system(size: 12)).lineLimit(1).truncationMode(.tail); Spacer(); Text(p.map { f($0.value) } ?? " ").font(mono) }
            }
        }.frame(maxWidth: .infinity)
    }
}
