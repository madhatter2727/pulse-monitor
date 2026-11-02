# How Pulse works

## What it is
Pulse is a small Mac app that floats on top of your screen and shows how hard your Mac is working: the CPU (the Mac's "brain"), memory, and the top 10 apps using each.
It swaps cryptic system names for plain ones, like "iCloud sync" or "Screen drawing". It has no internet connection, no AI and no accounts.

## How it works: the parts
It's written in **Swift** (Apple's own programming language) with **SwiftUI** (Apple's toolkit for drawing windows and buttons).

- **`Package.swift`** is the recipe card. It tells Swift the app is called Pulse, needs macOS 14 or newer, and where the code lives.
- **`Sources/Pulse/main.swift`** is the picture frame. It creates the see-through panel that stays on top on every desktop, plus the heartbeat icon in the menu bar (Show Pulse, Expand / Collapse, Quit). It remembers where you dragged the panel and whether it was big or small.
- **`Sources/Pulse/Stats.swift`** is the meter reader:
  - **Every second** it asks macOS how busy each CPU core is (a core is one worker inside the brain; they're grouped into Performance and Efficiency cores). It also gets the memory split: App, Wired, Compressed, Cached files, Free, Swap, and the pressure light.
  - **Every 2 seconds** it runs `ps`, macOS's built-in list of everything running. It adds up items that share a name and keeps the top 10 by CPU and the top 10 by memory.
  - It keeps 90 seconds of CPU history for the little graph.
- **`Sources/Pulse/Names.swift`** is the translator. About 180 hand-written pairs turn system names into plain ones, for example `cloudd` → "iCloud sync" and `WindowServer` → "Screen drawing". Apple background processes that aren't on the list are grouped as **"Other macOS services"**. Unknown non-Apple programs get a tidied-up version of their own name.
- **`Sources/Pulse/Views.swift`** is the dashboard:
  - The **full view** has the core bars, a 90-second graph, the memory bar with its legend, the pressure light, and the two top-10 lists.
  - The **compact "pill"** has mini core bars, CPU % and memory used.
  - Bars turn from green to amber at 70%.
- **`build.sh`** is the assembly line (see below).
- **`.gitignore`** is the "don't pack" list. It keeps build outputs, videos and anything that looks like a secret out of GitHub.

## How to rebuild it
On the Mac, in `~/Projects/pulse-monitor`, run `./build.sh`. It:
1. compiles a release build (`swift build -c release`),
2. wraps it as **`~/Applications/Pulse.app`**,
3. writes its ID card (`Info.plist`, bundle ID `com.tara.pulse`, set to live in the menu bar with no Dock icon),
4. ad-hoc signs it. That's a homemade signature, so macOS lets it run on this Mac.

It needs macOS 14+ and Xcode Command Line Tools. When it's done, open `~/Applications/Pulse.app`.

## What's been tested
- Built and run on Tara's MacBook Air (October 2026). It grew from a top 5 to a top 10, then to about 180 friendly names, based on what was actually running there.
- There are no automated tests in the repo.

## What's unfinished or known issues
- **Ad-hoc signed only.** Another Mac, like the Mac mini, will show a warning on first open unless the app is rebuilt there.
- It doesn't start at login on its own.
- The names list is kept by hand. New apps show a tidied raw name, or fall into "Other macOS services", until someone adds them to `Names.swift`.
- `claude` maps to "Claude Code", so the Claude desktop app also shows up as "Claude Code". Likewise, `grok` maps to "Grok Build".
- The CPU numbers in the top list count per core, so one busy app can show more than 100%.
- The memory numbers per app are rough. Memory that apps share gets counted for each of them, so the top list can add up to more than the Mac's total.

## Pickup prompt
```
You're continuing Pulse, a private macOS app for Tara Hughes. Read HOW-IT-WORKS.md first.
Repo: github.com/madhatter2727/pulse-monitor (private, branch main). Local copy: ~/Projects/pulse-monitor on her Mac. Run `git pull` before changing anything.
Stack: Swift (tools 6.0, Swift 5 language mode), SwiftUI + AppKit, Swift Package Manager, macOS 14+. No dependencies, no network.
Files: Sources/Pulse/main.swift (floating panel + menu bar), Stats.swift (CPU/memory/process sampling), Names.swift (friendly names), Views.swift (UI).
Build and run: ./build.sh, then open ~/Applications/Pulse.app.
Rules: keep the repo private. Never commit .env files, keys, tokens or secrets. Keep build outputs and big media out (see .gitignore). Commit and push to main after each working stage and at the end. Update HOW-IT-WORKS.md when the parts change. Tara is non-technical: no Terminal steps for her, explain in plain words. Never delete anything on her Mac without her yes.
Task: <what to do next>
```

## Interview line
"Pulse reads the same CPU and memory counters Activity Monitor uses, refreshes them every second, and translates about 180 cryptic system process names into plain English, so you can see at a glance what's slowing your Mac down."
