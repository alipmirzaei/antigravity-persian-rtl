#!/usr/bin/env node

/**
 * Antigravity Persian & RTL Enhancer
 * Connects to Antigravity's active Chromium/Electron DevTools instance
 * and injects native RTL and Vazirmatn typography styles persistently.
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const os = require('os');

const PORT_FILE = path.join(os.homedir(), '.config', 'Antigravity', 'DevToolsActivePort');

const CSS_STYLES = `
  /* Vazirmatn Font & Universal Typography */
  @import url('https://fonts.googleapis.com/css2?family=Vazirmatn:wght@300;400;500;600;700&display=swap');

  /* Apply Vazirmatn to all UI text elements and chat bubbles */
  body, p, li, button, input, textarea, .whitespace-pre-wrap,
  [class*="message"], [class*="markdown"], [class*="prose"],
  [class*="conversation"], [class*="sidebar"] {
    font-family: "Vazirmatn", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
  }

  /* XeLaTeX-style BiDi isolation for inline code & pre blocks */
  code, pre, kbd, samp, [class*="code-block"] {
    font-family: "Ubuntu Sans Mono", "Ubuntu Mono", "Fira Code", monospace !important;
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: isolate !important;
  }

  /* Automatic bidirectional paragraph resolution (UBA rule P2) */
  p, li, .whitespace-pre-wrap, [class*="message-content"] {
    unicode-bidi: plaintext !important;
  }

  /* Explicit Right-to-Left containers */
  [dir="rtl"], .rtl {
    direction: rtl !important;
    text-align: right !important;
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
    applyStyles();
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", applyStyles);
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

async function attachToPage(page) {
  if (activeSockets.has(page.id)) return;

  try {
    const ws = new WebSocket(page.webSocketDebuggerUrl);
    activeSockets.set(page.id, ws);

    let msgId = 1;
    function send(method, params = {}) {
      if (ws.readyState !== WebSocket.OPEN) return;
      ws.send(JSON.stringify({ id: msgId++, method, params }));
    }

    ws.onopen = () => {
      // 1. Evaluate immediately in the active document
      send('Runtime.evaluate', { expression: INJECT_SCRIPT });

      // 2. Ensure every subsequent navigation or reload automatically gets the script
      send('Page.enable');
      send('Page.addScriptToEvaluateOnNewDocument', { source: INJECT_SCRIPT });

      console.log(`[✓] Injected Vazirmatn & RTL styles into: "${page.title || 'Window'}"`);
    };

    ws.onmessage = (event) => {
      try {
        const msg = JSON.parse(event.data);
        // Re-inject if frame navigates or DOM loads
        if (msg.method === 'Page.frameNavigated' || msg.method === 'Page.loadEventFired') {
          send('Runtime.evaluate', { expression: INJECT_SCRIPT });
        }
      } catch (_) {}
    };

    ws.onclose = () => {
      activeSockets.delete(page.id);
    };

    ws.onerror = () => {
      activeSockets.delete(page.id);
    };
  } catch (err) {
    activeSockets.delete(page.id);
  }
}

async function checkAndInject() {
  if (!fs.existsSync(PORT_FILE)) return;

  try {
    const lines = fs.readFileSync(PORT_FILE, 'utf8').trim().split('\n');
    const port = lines[0]?.trim();
    if (!port) return;

    const pages = await fetchJson(`http://127.0.0.1:${port}/json/list`);
    if (!Array.isArray(pages)) return;

    for (const page of pages) {
      if (page.type === 'page' && page.webSocketDebuggerUrl) {
        await attachToPage(page);
      }
    }
  } catch (_) {}
}

async function main() {
  const isDaemon = process.argv.includes('--daemon') || process.argv.includes('-d');

  if (isDaemon) {
    console.log('[*] Antigravity Persian RTL Daemon started. Watching for Antigravity windows...');
    while (true) {
      await checkAndInject();
      await wait(2000);
    }
  } else {
    // One-shot execution
    if (!fs.existsSync(PORT_FILE)) {
      console.log('[!] Antigravity is not currently running.');
      process.exit(0);
    }
    await checkAndInject();
    // Allow brief time for sockets to connect & send
    await wait(1500);
    console.log('[✓] Styles applied.');
    process.exit(0);
  }
}

main().catch(err => {
  console.error('[✗] Error:', err.message);
  process.exit(1);
});
