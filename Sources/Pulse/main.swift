import AppKit
import SwiftUI

final class UIState: ObservableObject {
    @Published var expanded = UserDefaults.standard.object(forKey: "expanded") as? Bool ?? true
    var onToggle: () -> Void = {}; var onClose: () -> Void = {}
    func toggle() { expanded.toggle(); UserDefaults.standard.set(expanded, forKey: "expanded"); DispatchQueue.main.async { self.onToggle() } }
    func close() { onClose() }
}

final class Panel: NSPanel { override var canBecomeKey: Bool { true } }

final class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: Panel!; var item: NSStatusItem!
    let stats = Stats(); let ui = UIState()
    var host: NSHostingView<RootView>!

    func applicationDidFinishLaunching(_ n: Notification) {
        panel = Panel(contentRect: NSRect(x: 0, y: 0, width: 520, height: 600), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.level = .floating; panel.isOpaque = false; panel.backgroundColor = .clear; panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isMovableByWindowBackground = true; panel.hidesOnDeactivate = false
        let fx = NSVisualEffectView(); fx.material = .hudWindow; fx.blendingMode = .behindWindow; fx.state = .active
        fx.appearance = NSAppearance(named: .vibrantDark)
        fx.wantsLayer = true; fx.layer?.cornerRadius = 16; fx.layer?.masksToBounds = true
        fx.layer?.borderWidth = 0.5; fx.layer?.borderColor = NSColor.white.withAlphaComponent(0.15).cgColor
        host = NSHostingView(rootView: RootView(s: stats, ui: ui))
        host.translatesAutoresizingMaskIntoConstraints = false
        fx.addSubview(host)
        NSLayoutConstraint.activate([host.leadingAnchor.constraint(equalTo: fx.leadingAnchor), host.topAnchor.constraint(equalTo: fx.topAnchor)])
        panel.contentView = fx
        ui.onToggle = { [weak self] in self?.resize() }
        ui.onClose = { [weak self] in self?.panel.orderOut(nil) }
        resize()
        if let s = UserDefaults.standard.string(forKey: "topLeft") { panel.setFrameTopLeftPoint(NSPointFromString(s)) }
        else if let sc = NSScreen.main?.visibleFrame { panel.setFrameTopLeftPoint(NSPoint(x: sc.maxX - panel.frame.width - 24, y: sc.maxY - 24)) }
        NotificationCenter.default.addObserver(forName: NSWindow.didMoveNotification, object: panel, queue: .main) { [weak self] _ in
            guard let f = self?.panel.frame else { return }
            UserDefaults.standard.set(NSStringFromPoint(NSPoint(x: f.minX, y: f.maxY)), forKey: "topLeft")
        }
        resize()
        panel.orderFrontRegardless()

        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "waveform.path.ecg", accessibilityDescription: "Pulse")
        let m = NSMenu()
        let a = NSMenuItem(title: "Show Pulse", action: #selector(show), keyEquivalent: ""); a.target = self; m.addItem(a)
        let b = NSMenuItem(title: "Expand / Collapse", action: #selector(toggle), keyEquivalent: ""); b.target = self; m.addItem(b)
        m.addItem(.separator())
        m.addItem(NSMenuItem(title: "Quit Pulse", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = m
    }
    @objc func show() { panel.orderFrontRegardless() }
    @objc func toggle() { ui.toggle(); show() }
    func resize() {
        host.layoutSubtreeIfNeeded()
        let size = host.fittingSize
        let top = panel.frame.maxY, left = panel.frame.minX
        var f = NSRect(x: left, y: top - size.height, width: size.width, height: size.height)
        let sc = (panel.screen ?? NSScreen.main)?.visibleFrame ?? f
        f.origin.x = min(max(f.minX, sc.minX), sc.maxX - f.width)
        f.origin.y = min(max(f.minY, sc.minY), sc.maxY - f.height)
        panel.setFrame(f, display: true)
    }
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows f: Bool) -> Bool { show(); return true }
}

let app = NSApplication.shared
let d = AppDelegate(); app.delegate = d
app.setActivationPolicy(.accessory)
app.run()
