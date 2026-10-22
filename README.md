# Pulse

A small macOS menu-bar app that shows CPU use per core, memory in plain terms, a memory-pressure light, and the top 10 apps by CPU and memory, with friendly names instead of system process names. It has a full view and a compact "pill" view you can drag anywhere; the heartbeat icon in the menu bar reopens it.

## Rebuild

```bash
./build.sh
```

Builds with Swift Package Manager (`swift build -c release`) and installs the app to `~/Applications/Pulse.app` (ad-hoc signed). Requires macOS 14+ and Xcode command line tools.
