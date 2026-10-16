#!/usr/bin/env node

/**
 * Antigravity Persian & RTL Enhancer
 * Cross-platform (Linux, macOS, Windows) zero-latency typography & RTL injector for Google Antigravity.
 * Powered by Chrome DevTools Protocol (CDP).
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const os = require('os');
const { execSync } = require('child_process');

function getPortFilePath() {
  const platform = process.platform;
  if (platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'Antigravity', 'DevToolsActivePort');
  } else if (platform === 'win32') {
    return path.join(process.env.APPDATA || path.join(os.homedir(), 'AppData', 'Roaming'), 'Antigravity', 'DevToolsActivePort');
  }
  return path.join(os.homedir(), '.config', 'Antigravity', 'DevToolsActivePort');
}

const PORT_FILE = getPortFilePath();

const CSS_STYLES = `
  /* 1. Local Vazirmatn Font Engine (Offline-First / Zero-Network) */
  @font-face {
    font-family: 'Vazirmatn';
    src: local('Vazirmatn'), local('Vazirmatn-Regular'), local('Vazirmatn Regular');
    font-weight: 400;
    font-style: normal;
    font-display: swap;
  }
  @font-face {
    font-family: 'Vazirmatn';
    src: local('Vazirmatn-Medium'), local('Vazirmatn Medium');
    font-weight: 500;
    font-style: normal;
    font-display: swap;
  }
  @font-face {
    font-family: 'Vazirmatn';
    src: local('Vazirmatn-SemiBold'), local('Vazirmatn SemiBold'), local('Vazirmatn-Bold'), local('Vazirmatn Bold');
    font-weight: 600 700;
    font-style: normal;
    font-display: swap;
  }

  /* 2. Universal Persian & UI Typography (Line-height optimized for Persian) */
  body, p, li, button, input, textarea, .whitespace-pre-wrap,
  [class*="message"], [class*="markdown"], [class*="prose"],
  [class*="conversation"], [class*="sidebar"], h1, h2, h3, h4 {
    font-family: "Vazirmatn", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
  }

  p, li, .whitespace-pre-wrap {
    line-height: 1.75 !important;
  }

  /* 3. SAFETY SHIELD: Monaco Code Editor Protection (Strictly LTR & Monospaced) */
  .monaco-editor, .monaco-editor *,
  .monaco-diff-editor, .monaco-diff-editor *,
  [class*="monaco-"] {
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: normal !important;
    font-family: "Ubuntu Sans Mono", "Ubuntu Mono", "Consolas", "Fira Code", monospace !important;
  }

  /* 4. SAFETY SHIELD: Terminal Protection (xterm.js strictly LTR) */
  .xterm, .xterm *, .terminal, .terminal *,
  [class*="terminal"], [class*="xterm"] {
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: normal !important;
    font-family: "Ubuntu Sans Mono", "Ubuntu Mono", "Consolas", "Fira Code", monospace !important;
  }

  /* 5. SAFETY SHIELD: KaTeX Math Protection */
  .katex, .katex *, .katex-display, .katex-display * {
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: normal !important;
  }

  /* 6. Inline Code & Pre-formatted Snippet Isolation */
  code, pre, kbd, samp, [class*="code-block"] {
    font-family: "Ubuntu Sans Mono", "Ubuntu Mono", "Consolas", "Fira Code", monospace !important;
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: isolate !important;
  }

  /* 7. Automatic Bidirectional Paragraph Resolution (UBA Rule P2) */
  p, li, .whitespace-pre-wrap, [class*="message-content"] {
    unicode-bidi: plaintext !important;
  }

  /* 8. Explicit and Automatic Right-to-Left Containers */
  [dir="rtl"], .rtl, [dir="auto"]:dir(rtl) {
    direction: rtl !important;
    text-align: right !important;
  }
  [dir="auto"]:dir(ltr) {
    direction: ltr !important;
    text-align: left !important;
  }
`;

const INJECT_SCRIPT = `
  (() => {
    function applyStyles() {
      let s = document.getElementById("antigravity-persian-rtl");
      if (!s) {
        s = document.createElement("style");
        s.id = "antigravity-persian-rtl";
        if (document.head) {
          document.head.appendChild(s);
        } else if (document.documentElement) {
          document.documentElement.appendChild(s);
        }
      }
      if (s) {
        s.textContent = ${JSON.stringify(CSS_STYLES)};
      }
    }

    function applyAutoDir(root) {
      if (!root || !root.querySelectorAll) return;
      const targets = root.querySelectorAll ? root.querySelectorAll('p, li, h1, h2, h3, h4, [class*="message"], textarea, input') : [];
      for (let i = 0; i < targets.length; i++) {
        const el = targets[i];
        if (el.closest && el.closest('.monaco-editor, .xterm, .terminal, .katex')) continue;
        if (!el.hasAttribute('dir')) {
          el.setAttribute('dir', 'auto');
          el.setAttribute('data-ag-rtl', '1');
        }
      }
    }

    applyStyles();
    if (document.body) applyAutoDir(document.body);

    if (!window._antigravityPersianObserver && document.body) {
      window._antigravityPersianObserver = new MutationObserver((mutations) => {
        for (const m of mutations) {
          for (const node of m.addedNodes) {
            if (node.nodeType === 1) {
              if (node.closest && node.closest('.monaco-editor, .xterm, .terminal, .katex')) continue;
              if (node.matches && node.matches('p, li, h1, h2, h3, h4, [class*="message"], textarea, input')) {
                if (!node.hasAttribute('dir')) {
                  node.setAttribute('dir', 'auto');
                  node.setAttribute('data-ag-rtl', '1');
                }
              }
              applyAutoDir(node);
            }
          }
        }
      });
      window._antigravityPersianObserver.observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", () => {
        applyStyles();
        if (document.body) applyAutoDir(document.body);
      });
    }
  })()
`;

function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

const activeSockets = new Map();

async function attachToPage(page, silent = false) {
  if (activeSockets.has(page.id)) return true;

  return new Promise((resolve) => {
    try {
      const ws = new WebSocket(page.webSocketDebuggerUrl);
      activeSockets.set(page.id, ws);

      let msgId = 1;
      function send(method, params = {}) {
        if (ws.readyState !== WebSocket.OPEN) return;
        ws.send(JSON.stringify({ id: msgId++, method, params }));
      }

      ws.onopen = () => {
        // Evaluate immediately in current DOM
        send('Runtime.evaluate', { expression: INJECT_SCRIPT });

        // Ensure every new document/reload has the script compiled in before paint
        send('Page.enable');
        send('Page.addScriptToEvaluateOnNewDocument', { source: INJECT_SCRIPT });

        if (!silent) {
          console.log(`[✓] Injected Vazirmatn & RTL styles into: "${page.title || 'Antigravity Window'}"`);
        }
        resolve(true);
      };

      ws.onmessage = (event) => {
        try {
          const msg = JSON.parse(event.data);
          if (msg.method === 'Page.frameNavigated' || msg.method === 'Page.loadEventFired') {
            send('Runtime.evaluate', { expression: INJECT_SCRIPT });
          }
        } catch (_) {}
      };

      ws.onclose = () => {
        activeSockets.delete(page.id);
        resolve(false);
      };

      ws.onerror = () => {
        activeSockets.delete(page.id);
        resolve(false);
      };
    } catch (err) {
      activeSockets.delete(page.id);
      resolve(false);
    }
  });
}

async function checkAndInject(silent = false) {
  if (!fs.existsSync(PORT_FILE)) return 0;

  try {
    const lines = fs.readFileSync(PORT_FILE, 'utf8').trim().split('\n');
    const port = lines[0]?.trim();
    if (!port) return 0;

    const pages = await fetchJson(`http://127.0.0.1:${port}/json/list`);
    if (!Array.isArray(pages)) return 0;

    let count = 0;
    for (const page of pages) {
      if (page.type === 'page' && page.webSocketDebuggerUrl) {
        const ok = await attachToPage(page, silent);
        if (ok) count++;
      }
    }
    return count;
  } catch (_) {
    return 0;
  }
}

async function removeStylesFromWindows() {
  if (!fs.existsSync(PORT_FILE)) return;
  try {
    const lines = fs.readFileSync(PORT_FILE, 'utf8').trim().split('\n');
    const port = lines[0]?.trim();
    if (!port) return;

    const pages = await fetchJson(`http://127.0.0.1:${port}/json/list`);
    if (!Array.isArray(pages)) return;

    const CLEANUP_EXPR = `
      (() => {
        const s = document.getElementById("antigravity-persian-rtl");
        if (s) s.remove();
        if (window._antigravityPersianObserver) {
          window._antigravityPersianObserver.disconnect();
          window._antigravityPersianObserver = null;
        }
        document.querySelectorAll('[data-ag-rtl="1"]').forEach(el => {
          el.removeAttribute('dir');
          el.removeAttribute('data-ag-rtl');
        });
      })()
    `;

    for (const page of pages) {
      if (page.type === 'page' && page.webSocketDebuggerUrl) {
        await new Promise((resolve) => {
          try {
            const ws = new WebSocket(page.webSocketDebuggerUrl);
            ws.onopen = () => {
              ws.send(JSON.stringify({
                id: 999,
                method: 'Runtime.evaluate',
                params: { expression: CLEANUP_EXPR }
              }));
              setTimeout(() => {
                ws.close();
                resolve(true);
              }, 200);
            };
            ws.onerror = () => resolve(false);
            ws.onclose = () => resolve(false);
          } catch (_) {
            resolve(false);
          }
        });
      }
    }
  } catch (_) {}
}

function isServiceActive() {
  if (process.platform === 'linux') {
    try {
      const out = execSync('systemctl --user is-active antigravity-rtl.service 2>/dev/null || true').toString().trim();
      return out === 'active';
    } catch (_) {
      return false;
    }
  } else if (process.platform === 'darwin') {
    try {
      const out = execSync('launchctl list | grep com.antigravity.persian || true').toString().trim();
      return out.length > 0;
    } catch (_) {
      return false;
    }
  }
  return false;
}

async function turnOff() {
  console.log('[*] Stopping Antigravity Persian RTL background service...');
  if (process.platform === 'linux') {
    try {
      execSync('systemctl --user stop antigravity-rtl.service 2>/dev/null || true');
    } catch (_) {}
  } else if (process.platform === 'darwin') {
    try {
      const plist = path.join(os.homedir(), 'Library', 'LaunchAgents', 'com.antigravity.persian.plist');
      execSync(`launchctl unload "${plist}" 2>/dev/null || true`);
    } catch (_) {}
  }

  console.log('[*] Removing RTL styles from active Antigravity windows...');
  await removeStylesFromWindows();
  console.log('[✓] Antigravity Persian RTL is now OFF. Reverted to default styles.');
}

async function turnOn() {
  console.log('[*] Starting Antigravity Persian RTL background service...');
  if (process.platform === 'linux') {
    try {
      execSync('systemctl --user start antigravity-rtl.service 2>/dev/null || true');
    } catch (_) {}
  } else if (process.platform === 'darwin') {
    try {
      const plist = path.join(os.homedir(), 'Library', 'LaunchAgents', 'com.antigravity.persian.plist');
      execSync(`launchctl load -w "${plist}" 2>/dev/null || true`);
    } catch (_) {}
  }

  console.log('[*] Injecting Vazirmatn & RTL styles into active windows...');
  const count = await checkAndInject(false);
  await wait(1000);
  console.log(`[✓] Antigravity Persian RTL is now ON. Styles active on ${count} page(s).`);
}

async function toggle() {
  if (isServiceActive()) {
    await turnOff();
  } else {
    await turnOn();
  }
}

async function showStatus() {
  console.log('----------------------------------------------------');
  console.log('  Antigravity Persian RTL & Vazirmatn Status');
  console.log('----------------------------------------------------');
  console.log(`[i] Platform: ${process.platform} (${os.arch()})`);
  console.log(`[i] DevTools Port File: ${PORT_FILE}`);

  const portExists = fs.existsSync(PORT_FILE);
  if (!portExists) {
    console.log('[!] Antigravity is NOT currently running.');
  } else {
    const lines = fs.readFileSync(PORT_FILE, 'utf8').trim().split('\n');
    const port = lines[0]?.trim();
    console.log(`[✓] Antigravity is running (Active CDP Port: ${port})`);

    try {
      const pages = await fetchJson(`http://127.0.0.1:${port}/json/list`);
      const pageWindows = pages.filter(p => p.type === 'page');
      console.log(`[✓] Open UI Windows/Tabs: ${pageWindows.length}`);
      pageWindows.forEach((p, idx) => {
        console.log(`    ${idx + 1}. "${p.title || 'Untitled'}"`);
      });
    } catch (e) {
      console.log(`[!] Failed to connect to DevTools port: ${e.message}`);
    }
  }

  // Check background service on Linux / macOS
  const active = isServiceActive();
  console.log(`[i] Service Status: ${active ? '● ON / ACTIVE (Daemon running)' : '○ OFF / INACTIVE'}`);
  console.log('----------------------------------------------------');
  console.log('Quick commands:');
  console.log('  fix-antigravity-rtl on      -> Turn ON & enable styles');
  console.log('  fix-antigravity-rtl off     -> Turn OFF & revert to default');
  console.log('  fix-antigravity-rtl toggle  -> Toggle ON / OFF');
  console.log('  fix-antigravity-rtl status  -> View live status');
  console.log('----------------------------------------------------');
}

async function main() {
  const args = process.argv.slice(2);

  if (args.includes('status')) {
    await showStatus();
    process.exit(0);
  }

  if (args.includes('off') || args.includes('stop') || args.includes('disable')) {
    await turnOff();
    process.exit(0);
  }

  if (args.includes('on') || args.includes('start') || args.includes('enable')) {
    await turnOn();
    process.exit(0);
  }

  if (args.includes('toggle')) {
    await toggle();
    process.exit(0);
  }

  if (args.includes('--daemon') || args.includes('-d')) {
    console.log('[*] Antigravity Persian RTL Daemon started. Monitoring Antigravity windows...');
    while (true) {
      await checkAndInject(true);
      await wait(2000);
    }
  }

  // One-shot injection
  if (!fs.existsSync(PORT_FILE)) {
    console.log('[!] Antigravity is not currently running.');
    process.exit(0);
  }

  const count = await checkAndInject(false);
  await wait(1000);
  console.log(`[✓] Completed: Vazirmatn & RTL styles verified on ${count} page(s).`);
  process.exit(0);
}

main().catch(err => {
  console.error('[✗] Error:', err.message);
  process.exit(1);
});

