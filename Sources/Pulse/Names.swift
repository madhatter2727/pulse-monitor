import Foundation

private let exact: [String: String] = [
    "safari": "Safari", "claude": "Claude Code", "grok": "Grok Build", "osaurus": "Osaurus", "pulse": "Pulse",
    "cloudd": "iCloud sync", "bird": "iCloud sync", "fileproviderd": "iCloud sync", "cloudphotod": "iCloud Photos",
    "icloudwebd": "iCloud sync", "com.apple.clouddocs.iclouddrivefileprovider": "iCloud sync", "syncdefaultsd": "iCloud sync",
    "windowserver": "Screen drawing", "coreaudiod": "Sound", "audiomxd": "Sound", "systemsoundserverd": "Sound",
    "kernel_task": "macOS core", "launchd": "macOS startup", "logd": "System logs", "syslogd": "System logs",
    "logd_helper": "System logs", "aslmanager": "System logs",
    "nsurlsessiond": "Background downloads", "trustd": "Security checks", "securityd": "Security checks",
    "securityd_system": "Security checks", "secd": "Passwords & keychain", "syspolicyd": "App safety checks",
    "xprotect": "App safety checks", "xprotectd": "App safety checks", "xprotectservice": "App safety checks",
    "amfid": "App safety checks", "tccd": "Privacy permissions", "sandboxd": "App sandbox",
    "herdr": "Herdr (agent terminal)", "tmux": "Terminal sessions", "ghostty": "Ghostty", "terminal": "Terminal",
    "photoanalysisd": "Photos", "photolibraryd": "Photos", "mediaanalysisd": "Photo/video analysis",
    "softwareupdated": "Software updates", "suhelperd": "Software updates", "mobileassetd": "Software updates",
    "backupd": "Time Machine", "backupd-helper": "Time Machine",
    "bluetoothd": "Bluetooth", "bluetoothuserd": "Bluetooth", "airportd": "Wi-Fi", "wifid": "Wi-Fi",
    "wifianalyticsd": "Wi-Fi", "wifivelocityd": "Wi-Fi", "wifip2pd": "Wi-Fi", "wifiagent": "Wi-Fi",
    "locationd": "Location", "corelocationagent": "Location",
    "coreduetd": "Siri suggestions", "knowledge-agent": "Siri suggestions", "suggestd": "Siri suggestions",
    "proactived": "Siri suggestions", "duetexpertd": "Siri suggestions", "assistantd": "Siri", "siriinferenced": "Siri",
    "siriknowledged": "Siri", "siriactionsd": "Siri", "corespeechd": "Siri", "sirittsd": "Siri",
    "node": "Node app", "bun": "Bun app", "esbuild": "Node app", "python": "Python script", "python3": "Python script",
    "uv": "Python tools", "docker": "Docker", "ollama": "Ollama", "llama-server": "Local AI model",
    "code": "VS Code", "code helper": "VS Code", "code-sidecar": "Cline",
    "zsh": "Terminal shell", "-zsh": "Terminal shell", "bash": "Terminal shell", "-bash": "Terminal shell", "sh": "Terminal shell",
    "login": "Terminal shell", "ssh-agent": "SSH keys",
    "mds": "Spotlight search", "mds_stores": "Spotlight search", "mdworker": "Spotlight search", "mdworker_shared": "Spotlight search",
    "mdbulkimport": "Spotlight search", "mdsync": "Spotlight search", "mdwrite": "Spotlight search", "corespotlightd": "Spotlight search",
    "spotlight": "Spotlight search", "spotlightknowledged": "Spotlight search", "csimporter": "Spotlight search",
    "finder": "Finder", "dock": "Dock", "controlcenter": "Control Center", "notificationcenter": "Notifications",
    "usernoted": "Notifications", "systemuiserver": "Menu bar", "loginwindow": "Login & lock screen", "windowmanager": "Window manager",
    "cfprefsd": "Settings storage", "distnoted": "System messaging", "notifyd": "System messaging", "configd": "Network settings",
    "mdnsresponder": "Network lookups", "mdnsresponderhelper": "Network lookups", "apsd": "Push notifications",
    "powerd": "Power management", "thermalmonitord": "Temperature control", "runningboardd": "App lifecycle",
    "dasd": "Background task scheduler", "fseventsd": "File change tracking", "diskarbitrationd": "Disks",
    "apfsd": "Disks", "deleted": "Storage cleanup", "spindump": "Hang reports", "reportcrash": "Crash reports",
    "sharingd": "AirDrop & sharing", "rapportd": "Nearby devices", "identityservicesd": "Messages & FaceTime",
    "imagent": "Messages", "callservicesd": "Calls", "avconferenced": "FaceTime/calls", "maild": "Mail",
    "contactsd": "Contacts", "calaccessd": "Calendar", "remindd": "Reminders", "accountsd": "Accounts",
    "akd": "Apple Account", "appleaccountd": "Apple Account", "commerce": "App Store", "storekitagent": "App Store",
    "appstoreagent": "App Store", "installd": "App installs", "fontd": "Fonts", "fontworker": "Fonts",
    "routined": "Location", "searchpartyd": "Find My", "findmydeviced": "Find My",
    "mediaremoted": "Media controls", "triald": "Apple experiments", "biomed": "Usage history", "biomesyncd": "Usage history",
    "analyticsd": "Diagnostics", "symptomsd": "Network diagnostics", "watchdogd": "System watchdog",
    "intelligenceplatformd": "Apple Intelligence", "generativeexperiencesd": "Apple Intelligence",
    "modelmanagerd": "Apple Intelligence", "translationd": "Translation", "ps": "Pulse (process list)",
    "parsecd": "Siri suggestions", "lsd": "App registry", "launchservicesd": "App registry", "coreservicesd": "App registry",
    "pboard": "Clipboard", "visual studio code": "VS Code", "shipit": "App updater", "awk": "Terminal commands", "uniq": "Terminal commands", "chronod": "Widgets", "pmset": "Power management", "powerexperienced": "Power management",
    "grep": "Terminal commands", "sed": "Terminal commands", "sort": "Terminal commands", "head": "Terminal commands",
    "tr": "Terminal commands", "xurl": "Terminal commands", "workerd": "Node app", "media-indexer": "Media indexing",
    "airplayuiagent": "AirPlay", "airplayxpchelper": "AirPlay", "airdrop": "AirDrop & sharing", "nearbyd": "Nearby devices",
    "corebrightnessd": "Screen brightness", "biometrickitd": "Touch ID", "coreauthd": "Touch ID", "filevaultd": "FileVault",
    "keybagd": "Passwords & keychain", "trustedpeershelper": "Passwords & keychain", "applekeystored": "Passwords & keychain",
    "donotdisturbd": "Focus", "screentimeagent": "Screen Time", "usagetrackingagent": "Screen Time",
    "cameracaptured": "Camera", "appleh16camerad": "Camera", "uvcassistant": "Camera", "mscamerad-xpc": "Camera",
    "homed": "Home", "mapssyncd": "Maps", "com.apple.geod": "Maps", "geoanalyticsd": "Maps", "tipsd": "Tips",
    "itunescloudd": "Music", "amplibraryagent": "Music", "contactsdonationagent": "Contacts", "peopled": "Contacts",
    "naturallanguaged": "Apple Intelligence", "intelligencecontextd": "Apple Intelligence", "intelligenceflowd": "Apple Intelligence",
    "intelligencetasksd": "Apple Intelligence", "privatecloudcomputed": "Apple Intelligence", "modelcatalogd": "Apple Intelligence",
    "textunderstandingd": "Apple Intelligence", "mtlcompilerservice": "Graphics compiler", "spotlightknowledged.updater": "Spotlight search",
    "com.apple.notes.spotlightindexextension": "Notes", "universalaccessd": "Accessibility", "ollama runner": "Ollama",
]

private func prettify(_ raw: String) -> String {
    var s = raw
    for p in ["com.apple.", "com."] where s.lowercased().hasPrefix(p) { s = String(s.dropFirst(p.count)) }
    if let last = s.split(separator: ".").last, s.contains(".") { s = String(last) }
    for suf in ["XPCService", "Service", "Helper", "helper", "Agent", "agent", "Extension", "Daemon", "XPC"] where s.hasSuffix(suf) && s.count > suf.count + 2 {
        s = String(s.dropLast(suf.count)); break
    }
    s = s.trimmingCharacters(in: CharacterSet(charactersIn: "_-. "))
    if s.hasSuffix("d") && s.count > 3 && s == s.lowercased() { s = String(s.dropLast()) }
    // split camelCase, underscores, dashes
    var out = ""; var prev: Character = " "
    for c in s {
        if c == "_" || c == "-" || c == "." { out.append(" "); prev = " "; continue }
        if c.isUppercase && prev.isLowercase { out.append(" ") }
        out.append(c); prev = c
    }
    let words = out.split(separator: " ").map { w -> String in
        w.first!.isUppercase ? String(w) : w.prefix(1).uppercased() + w.dropFirst()
    }
    let r = words.joined(separator: " ")
    return r.isEmpty ? raw : r
}

func friendlyName(_ path: String) -> String {
    if path.hasPrefix("npm ") || path.hasPrefix("npx ") { return "Node app" }
    if path.hasPrefix("Core Audio Driver") { return "Sound" }
    let exe = (path as NSString).lastPathComponent
    let l = exe.lowercased()
    if l.contains("webkit.webcontent") || l.contains("webkit.networking") || l.contains("webkit.gpu") || l.hasPrefix("com.apple.safari") || l.hasPrefix("safari") { return "Safari" }
    if l.hasPrefix("notion") { return "Notion" }
    if l.hasPrefix("grok bot") { return "Grok Bot" }
    if l.hasPrefix("mdworker") { return "Spotlight search" }
    if l.hasPrefix("python") { return "Python script" }
    if l.hasPrefix("osaurus") { return "Osaurus" }
    if l.hasPrefix("docker") || l.hasPrefix("com.docker") { return "Docker" }
    if l.contains("crashpad_handler") { return "Crash reports" }
    if l.hasPrefix("wallpaper") { return "Wallpaper" }
    if l.hasSuffix("widgetextension") || l.contains("widget") { return "Widgets" }
    if l.contains("thumbnailextension") { return "File previews" }
    if l.hasPrefix("xprotect") { return "App safety checks" }
    if path.contains("/Cline.app/") { return "Cline" }
    if let m = exact[l] { return m }
    for comp in path.split(separator: "/") where comp.hasSuffix(".app") {
        let name = String(comp.dropLast(4))
        if let m = exact[name.lowercased()] { return m }
        let userApp = path.hasPrefix("/Applications/") || path.hasPrefix("/System/Applications/") || path.contains("/Users/")
            || ["Finder", "Dock", "Spotlight", "ControlCenter", "Terminal", "Ask My Mac"].contains(name)
        return userApp ? name : "Other macOS services"
    }
    if let r = exe.range(of: " Helper") { let b = String(exe[..<r.lowerBound]); return exact[b.lowercased()] ?? b }
    if path.hasPrefix("/System/") || path.hasPrefix("/usr/") || path.hasPrefix("/sbin/") || path.hasPrefix("/Library/Apple/") || path.hasPrefix("/bin/") || !path.contains("/") && (l.hasSuffix("d") || l.hasPrefix("com.apple.")) {
        return "Other macOS services"
    }
    return prettify(exe)
}
