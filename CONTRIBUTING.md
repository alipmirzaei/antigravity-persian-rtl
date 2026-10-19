# Contributing to Antigravity Persian RTL Suite

Thank you for your interest in improving Persian and Arabic RTL support for Google Antigravity! We welcome contributions from developers, designers, and typography enthusiasts.

---

## Code of Conduct

By participating in this project, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md). Please treat all contributors with respect and kindness.

---

## How Can I Contribute?

### 1. Reporting Bugs
Before creating an issue, please check existing issues to avoid duplicates. When opening a bug report, include:
- Your Operating System and version (e.g. Ubuntu 24.04, macOS Sonoma, Windows 11).
- Node.js version (`node -v`).
- Antigravity version.
- Exact steps to reproduce the issue.
- Screenshots or recordings illustrating the problem.
- Output of `fix-antigravity-rtl status`.

### 2. Suggesting Enhancements
Feature requests are welcome! Please open an issue explaining:
- The limitation or missing capability.
- How other tools or editors handle it.
- Your proposed solution or syntax improvement.

### 3. Pull Requests & Development Setup

1. **Fork the Repository**:
   Fork [alipmirzaei/antigravity-persian-rtl](https://github.com/alipmirzaei/antigravity-persian-rtl) on GitHub.

2. **Clone your fork**:
   ```bash
   git clone https://github.com/<your-username>/antigravity-persian-rtl.git
   cd antigravity-persian-rtl
   ```

3. **Create a Topic Branch**:
   ```bash
   git checkout -b feat/my-enhancement
   ```

4. **Development Invariants**:
   - **Zero External Dependencies**: All code in `bin/fix-antigravity-rtl.js` must strictly use Node.js standard library modules (`fs`, `path`, `http`, `os`, `child_process`). Do not introduce external npm dependencies.
   - **Performance Invariant**: Maintain zero-latency offline font resolution. Never introduce remote network requests during runtime.
   - **Safety Invariant**: Never degrade Monaco editor, terminal, or KaTeX formula behavior.

5. **Local Testing**:
   - Run the script manually: `node bin/fix-antigravity-rtl.js status`
   - Test toggle commands: `node bin/fix-antigravity-rtl.js off` / `on`
   - Test installation locally: `./install.sh`

6. **Commit & Push**:
   Use clear, conventional commit messages:
   ```bash
   git commit -m "feat: add support for custom font weights"
   git push origin feat/my-enhancement
   ```

7. **Submit a Pull Request**:
   Open a PR against the `main` branch. Provide a concise description of your changes and reference any related issues.
