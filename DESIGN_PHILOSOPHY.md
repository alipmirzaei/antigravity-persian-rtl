# Design Philosophy & Architectural Decisions

This document outlines the core engineering philosophy, architectural rationale, and non-negotiable invariants behind the **Antigravity Persian RTL & Vazirmatn Suite**.

---

## 1. Problem Statement

Google Antigravity is a modern, developer-centric agentic AI workspace built on top of Chromium and Electron. Out of the box:
- The UI defaults to `direction: ltr` with generic system font fallbacks (`DejaVu Sans` or `Arial`).
- Punctuation marks (periods, colons, question marks) in Persian sentences jump across the line.
- Technical English terms (like package names or code tokens) reverse adjacent Persian syntax.
- Naive attempts to fix this (such as applying `* { direction: rtl }` or user-scripts) cause catastrophic collateral damage: they break Monaco code editor indentation, corrupt cursor selection, invert terminal emulators (`xterm.js`), and scramble KaTeX formulas.

---

## 2. Core Invariants & Design Principles

### Principle 1: First, Do No Harm (Strict Isolation Shields)
An IDE's primary duty is code integrity. Under no circumstance should a Persian typography fix interfere with code writing or terminal execution.
- **Monaco Editor Shield**: Monaco relies on exact pixel measurements for character rendering and cursor placement. It is explicitly locked to `direction: ltr !important`, `text-align: left !important`, and monospace typography.
- **Terminal Shield**: Terminal emulators (`xterm.js`) are strictly isolated from bidirectional transformations.
- **KaTeX Shield**: Math equations are wrapped as atomic inline-block objects, preventing mathematical operators (`=`, `\le`, `*`, `()`) from being reordered by outer RTL sentences.

### Principle 2: Zero-Latency & 100% Offline-First
Iranian ISPs and regional developers face severe connectivity disruptions, CDN throttling, and sanctions.
- **No External CDNs**: We never load fonts from `fonts.googleapis.com` or external CDNs.
- **Local Font Engine**: Styles resolve strictly against `local('Vazirmatn')`. All TTF font weights are installed locally in the user's OS font directories (`~/.local/share/fonts`, `~/Library/Fonts`, `%LOCALAPPDATA%\Microsoft\Windows\Fonts`).
- **Network Latency = 0ms**: All typography renders instantaneously from local RAM and disk cache.

### Principle 3: Non-Invasive & Update-Resilient
Many Electron modification tools require unpacking `app.asar` or modifying installed binary files. This approach is brittle:
- Every application auto-update wipes out modified files.
- Modifying binaries risks signature corruption and security warnings.
- **Our Approach**: We utilize the official **Chrome DevTools Protocol (CDP)** exposed by Chromium (`DevToolsActivePort`). The injection script is compiled into the frame before DOM paint via `Page.addScriptToEvaluateOnNewDocument`. It survives application restarts, workspace switches, and software updates without ever modifying a single binary on disk.

### Principle 4: Beyond Naive `dir="auto"` (Google Closure Ratio Heuristic)
Standard HTML5 `dir="auto"` relies on the "First Strong Character" rule. When a developer types:
```text
Docker رو چجوری روی سرور نصب کنم؟
```
Naive `dir="auto"` inspects the first character (`D`), assumes the sentence is English, and renders the entire prompt LTR, flipping the question mark.
- We implement the **Google Closure 40% Ratio Threshold**: If Persian characters exceed 35% of directional letters, the block is classified as RTL.
- Capture-phase dynamic event listeners monitor user typing in real time, switching orientation dynamically as sentences develop.

---

## 3. Trade-offs & Limitations

| Decision | Chosen Solution | Trade-off / Rationale |
| :--- | :--- | :--- |
| **Daemon vs On-Demand** | Background daemon (`systemd` / `LaunchAgent` / `Startup`) | Consumes ~14MB of RAM, but ensures 100% seamless, invisible startup without requiring the user to manually trigger a CLI tool every time Antigravity opens. |
| **Inline Math Wrapping** | `display: inline-block` | Prevents long formulas from soft-wrapping mid-equation, but guarantees 100% mathematical symbol integrity without bracket inversion. |
| **Pure Node.js Standard Library** | No `npm install` required | Avoids `node_modules` bloat, supply-chain vulnerabilities, and compilation issues on minimal systems. |
