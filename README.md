# Antigravity Persian RTL & Vazirmatn Suite

> A zero-latency, cross-platform bidirectional (BiDi) text and typography engine for **Google Antigravity**, featuring native **Vazirmatn** font integration and XeLaTeX-grade mathematical formula isolation.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-brightgreen.svg)](#installation)
[![Font](https://img.shields.io/badge/Font-Vazirmatn-teal.svg)](https://github.com/rastikerdar/vazirmatn)
[![Latency](https://img.shields.io/badge/Latency-0ms%20(Offline%20First)-orange.svg)](#1-zero-latency--100-offline-first)
[![Safety](https://img.shields.io/badge/Safety-Monaco%20%26%20Terminal%20Protected-success.svg)](#2-built-in-safety-shields)
[![Persian Readme](https://img.shields.io/badge/Language-🇮🇷%20فارسی-green.svg)](README_FA.md)

---

## Overview: The Problem

Google Antigravity is a cutting-edge developer workspace built on Chromium and Electron. By default, the interface is configured for Left-to-Right (`LTR`) Latin text. When Persian, Arabic, or mixed RTL/LTR content is introduced:

1. **Punctuation Reversal**: Periods (`.`), colons (`:`), question marks (`؟`), and parentheses jump to the opposite side of the line.
2. **BiDi Text Scrambling**: English technical terms (package names, function calls, framework names) intermixed with Persian sentences cause words to reorder backwards.
3. **Improper System Fonts**: Operating systems fall back to generic, non-optimized fonts (like `DejaVu Sans` or `Arial`), hurting readability.
4. **Collateral Damage from Naive RTL Fixes**: Blanket CSS injection or user-scripts break the Monaco code editor (causing misaligned cursors and ruined indentation), invert `xterm.js` terminals, and scramble KaTeX formulas.

**Antigravity Persian RTL Suite** solves this through a non-invasive, 4-layer architecture inspired by the **XeLaTeX / xepersian** typesetting standard.

---

## Architectural Highlights

### 1. Zero-Latency & 100% Offline-First
- Font styles resolve strictly via local font mapping (`local('Vazirmatn')`).
- **No external Google Fonts CDN or network requests** are made at runtime.
- Immune to regional connectivity restrictions, CDN throttling, and sanctions. Network latency is **0ms**.

### 2. Built-in Safety Shields
- **Monaco Code Editor**: Explicitly protected with `direction: ltr !important`, `text-align: left !important`, and monospaced typography. Indentation, line numbers, diff views, and cursor placement remain 100% intact.
- **Integrated Terminal (`xterm.js`)**: Isolated from bidirectional reordering; CLI tools render in native LTR.
- **KaTeX Mathematical Isolation**: Inline formulas (`.katex`) are wrapped as atomic `inline-block` objects with strict `unicode-bidi: isolate !important`. Mathematical operators (`=`, `\le`, `*`, `()`, `[]`) never scramble inside RTL paragraphs. Display math (`$$...$$`) is cleanly centered.
- **Inline Code Isolation**: Code snippets within sentences behave like `\lr{...}` in XeLaTeX (`unicode-bidi: isolate !important`).

### 3. Dynamic Google Closure BiDi Ratio Heuristic
Standard HTML5 `dir="auto"` inspects only the first character. Prompts starting with an English keyword (e.g. `Docker رو چطور نصب کنم؟`) fail and collapse to LTR.
- We implement the **Google Closure 40% Ratio Threshold**: If Persian characters exceed 35% of directional characters, the block is classified as RTL.
- A lightweight, capture-phase event listener dynamically computes direction as you type into Antigravity's chat prompt.

### 4. Resilient & Update-Proof
- **No binary patching**: We never touch Antigravity's executable files or `app.asar`.
- Uses the official **Chrome DevTools Protocol (CDP)** via `Page.addScriptToEvaluateOnNewDocument`. The styles compile into Chromium frames before initial paint, surviving restarts, window switches, and application updates.

### 5. Ultra-Lightweight
- **Zero external npm dependencies**: Built entirely with Node.js standard libraries (`fs`, `path`, `http`, `os`, `child_process`).
- Background daemon consumes **~14MB RAM** and **0% CPU** in steady state.

---

## Installation

### Linux & macOS

Run the single-line installer in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/alipmirzaei/antigravity-persian-rtl/main/install.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/alipmirzaei/antigravity-persian-rtl.git
cd antigravity-persian-rtl
chmod +x install.sh
./install.sh
```

**The installer automatically:**
- Downloads and installs the Vazirmatn font locally if not already installed.
- Configures Linux `fontconfig` or macOS `~/Library/Fonts`.
- Sets up an automatic background daemon via `systemd --user` (Linux) or `LaunchAgent` (macOS).
- Deploys the `fix-antigravity-rtl` command to `~/.local/bin`.
- Adds Persian typography prompt guidelines to `~/.gemini/GEMINI.md`.

---

### Windows (PowerShell)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/alipmirzaei/antigravity-persian-rtl/main/windows/install.ps1 | iex
```

Or manually:

```powershell
git clone https://github.com/alipmirzaei/antigravity-persian-rtl.git
cd antigravity-persian-rtl
powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
```

---

## CLI Management & Controls

Once installed, the `fix-antigravity-rtl` command is available in your shell:

```bash
# Turn ON and immediately inject styles into open windows
fix-antigravity-rtl on

# Turn OFF and immediately revert to stock Antigravity styling
fix-antigravity-rtl off

# Toggle between ON and OFF
fix-antigravity-rtl toggle

# Check live daemon status, active port, and connected windows
fix-antigravity-rtl status
```

### Sample Status Output

```text
----------------------------------------------------
  Antigravity Persian RTL & Vazirmatn Status
----------------------------------------------------
[i] Platform: linux (x64)
[i] DevTools Port File: ~/.config/Antigravity/DevToolsActivePort
[✓] Antigravity is running (Active CDP Port: 34457)
[✓] Open UI Windows/Tabs: 1
    1. "Fixing Persian English Text Direction - antigravity-persian-rtl - Antigravity"
[i] Service Status: ● ON / ACTIVE (Daemon running)
----------------------------------------------------
Quick commands:
  fix-antigravity-rtl on      -> Turn ON & enable styles
  fix-antigravity-rtl off     -> Turn OFF & revert to default
  fix-antigravity-rtl toggle  -> Toggle ON / OFF
  fix-antigravity-rtl status  -> View live status
----------------------------------------------------
```

---

## Uninstallation

To completely remove the suite and restore system defaults:

### Linux & macOS
```bash
./uninstall.sh
```

### Windows
Delete `antigravity-persian-rtl.vbs` from your Windows `Startup` folder.

---

## Documentation & Community

- 📖 [Technical Architecture & Module Guide](CODE_DOCUMENTATION.md)
- 💡 [Design Philosophy & Engineering Constraints](DESIGN_PHILOSOPHY.md)
- 🤝 [Contributing Guidelines](CONTRIBUTING.md)
- 🔒 [Security Policy & Vulnerability Disclosure](SECURITY.md)
- 📜 [Code of Conduct](CODE_OF_CONDUCT.md)
- 🇮🇷 [Persian Guide (راهنمای فارسی)](README_FA.md)

---

## License & Credits

- This project is open-sourced under the [MIT License](LICENSE).
- Typography powered by the **Vazirmatn** font by the late Saber Rastikerdar, licensed under the Open Font License (OFL).
