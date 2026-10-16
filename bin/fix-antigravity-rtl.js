#!/usr/bin/env node

/**
 * Antigravity Persian & RTL Enhancer
 * Connects to Antigravity's active Chromium/Electron DevTools instance
 * and injects native RTL and Vazirmatn typography styles.
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const os = require('os');

const PORT_FILE = path.join(os.homedir(), '.config', 'Antigravity', 'DevToolsActivePort');

const CSS_STYLES = `
  /* Vazirmatn Font & RTL typography for Antigravity */
  @import url('https://fonts.googleapis.com/css2?family=Vazirmatn:wght@300;400;500;600;700&display=swap');

  :lang(fa), [dir="rtl"], .rtl {
    font-family: "Vazirmatn", system-ui, -apple-system, sans-serif !important;
    direction: rtl !important;
    text-align: right !important;
  }

  /* XeLaTeX-style BiDi isolation for inline code & pre blocks */
  [dir="rtl"] code, [dir="rtl"] pre, code[dir="ltr"] {
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: isolate !important;
    display: inline-block;
  }

  /* Automatic bidirectional paragraph resolution (like XeLaTeX / UBA rule P2) */
  p, li, .whitespace-pre-wrap, [class*="message-content"] {
    unicode-bidi: plaintext !important;
  }
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

async function injectIntoPage(pageUrl) {
  return new Promise((resolve) => {
    const ws = new WebSocket(pageUrl);
    const timeout = setTimeout(() => {
      try { ws.close(); } catch (_) {}
      resolve(false);
    }, 4000);

    ws.onopen = () => {
      ws.send(JSON.stringify({
        id: 1,
        method: 'Runtime.evaluate',
        params: {
          expression: `(() => {
            let style = document.getElementById("antigravity-persian-rtl");
            if (!style) {
              style = document.createElement("style");
              style.id = "antigravity-persian-rtl";
              document.head.appendChild(style);
            }
            style.textContent = ${JSON.stringify(CSS_STYLES)};
            return document.title || "Antigravity Window";
          })()`,
          returnByValue: true
        }
      }));
    };

    ws.onmessage = (event) => {
      clearTimeout(timeout);
      try {
        const msg = JSON.parse(event.data);
        if (msg.id === 1) {
          const title = msg.result?.result?.value || 'Window';
          console.log(`[✓] Successfully injected Persian & RTL style into: "${title}"`);
          ws.close();
          resolve(true);
        }
      } catch (e) {
        resolve(false);
      }
    };

    ws.onerror = () => {
      clearTimeout(timeout);
      resolve(false);
    };
  });
}

async function main() {
  if (!fs.existsSync(PORT_FILE)) {
    console.log('[!] Antigravity does not appear to be running (DevToolsActivePort not found).');
    process.exit(0);
  }

  const lines = fs.readFileSync(PORT_FILE, 'utf8').trim().split('\n');
  const port = lines[0]?.trim();

  if (!port) {
    console.error('[✗] Failed to read DevTools port.');
    process.exit(1);
  }

  let pages = [];
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      pages = await fetchJson(`http://127.0.0.1:${port}/json/list`);
      break;
    } catch (e) {
      if (attempt < 3) await wait(1000);
    }
  }

  if (!pages || !pages.length) {
    console.log('[!] No active UI pages found to inject.');
    return;
  }

  let injectedCount = 0;
  for (const page of pages) {
    if (page.type === 'page' && page.webSocketDebuggerUrl) {
      const ok = await injectIntoPage(page.webSocketDebuggerUrl);
      if (ok) injectedCount++;
    }
  }

  if (injectedCount > 0) {
    console.log(`[✓] Persian RTL & Vazirmatn active on ${injectedCount} Antigravity page(s).`);
  }
}

main().catch(err => {
  console.error('[✗] Error executing injector:', err.message);
  process.exit(1);
});
