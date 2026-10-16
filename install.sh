#!/usr/bin/env bash
set -e

# ========================================================
# Antigravity Persian RTL & Vazirmatn Installer
# ========================================================

echo "--------------------------------------------------------"
echo "  نصب‌کننده‌ی پشتیبانی از زبان فارسی و قلم وزیرمتن در Antigravity"
echo "  Installing Antigravity Persian RTL & Vazirmatn Support"
echo "--------------------------------------------------------"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
FONTCONFIG_DIR="$HOME/.config/fontconfig/conf.d"
FONTS_DIR="$HOME/.local/share/fonts/vazirmatn"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
GEMINI_RULE_FILE="$HOME/.gemini/GEMINI.md"

# 1. Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[!] Node.js یافت نشد. لطفاً ابتدا Node.js را نصب کنید."
    echo "[!] Node.js is required but not installed. Please install Node.js first."
    exit 1
fi

# 2. Check & Install Vazirmatn Font if missing
echo "[*] بررسی نصب بودن قلم وزیرمتن (Checking Vazirmatn font)..."
if ! fc-list : family | grep -iq "vazirmatn"; then
    echo "[+] قلم وزیرمتن یافت نشد. در حال دریافت و نصب خودکار..."
    mkdir -p "$FONTS_DIR"
    VAZIR_RELEASE_URL="https://github.com/rastikerdar/vazirmatn/releases/latest/download/vazirmatn-v33.003.zip"
    TMP_ZIP="/tmp/vazirmatn.zip"
    TMP_DIR="/tmp/vazirmatn_extracted"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$VAZIR_RELEASE_URL" -o "$TMP_ZIP"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TMP_ZIP" "$VAZIR_RELEASE_URL"
    fi

    if [ -f "$TMP_ZIP" ]; then
        mkdir -p "$TMP_DIR"
        unzip -q -o "$TMP_ZIP" -d "$TMP_DIR"
        find "$TMP_DIR" -name "*.ttf" -exec cp {} "$FONTS_DIR/" \;
        rm -rf "$TMP_ZIP" "$TMP_DIR"
        fc-cache -f "$FONTS_DIR"
        echo "[✓] قلم وزیرمتن با موفقیت نصب شد."
    else
        echo "[!] هشدار: امکان دانلود خودکار فونت فراهم نشد. لطفاً پکیج fonts-vazirmatn را دستی نصب کنید."
    fi
else
    echo "[✓] قلم وزیرمتن روی سیستم نصب است."
fi

# 3. Setup Fontconfig Configuration
echo "[*] تنظیم پیکربندی Fontconfig..."
mkdir -p "$FONTCONFIG_DIR"
cp "$SCRIPT_DIR/config/99-vazirmatn-antigravity.conf" "$FONTCONFIG_DIR/99-vazirmatn-antigravity.conf"
fc-cache -f "$FONTCONFIG_DIR"
echo "[✓] تنظیمات Fontconfig با موفقیت اعمال شد."

# 4. Install fix-antigravity-rtl binary
echo "[*] نصب ابزار تزریق استایل fix-antigravity-rtl..."
mkdir -p "$LOCAL_BIN"
cp "$SCRIPT_DIR/bin/fix-antigravity-rtl.js" "$LOCAL_BIN/fix-antigravity-rtl"
chmod +x "$LOCAL_BIN/fix-antigravity-rtl"
echo "[✓] دستور fix-antigravity-rtl در $LOCAL_BIN قرار گرفت."

# Ensure ~/.local/bin is in PATH hint
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "[i] نکته: مسیر ~/.local/bin در متغیر PATH شما نیست. توصیه می‌شود آن را به .bashrc یا .zshrc اضافه کنید."
fi

# 5. Append Assistant Rule to ~/.gemini/GEMINI.md
echo "[*] به‌روزرسانی قوانین دستیار در GEMINI.md..."
mkdir -p "$(dirname "$GEMINI_RULE_FILE")"
touch "$GEMINI_RULE_FILE"

if ! grep -q "Persian (Farsi) & Mixed RTL/LTR Typography" "$GEMINI_RULE_FILE"; then
    echo "" >> "$GEMINI_RULE_FILE"
    cat "$SCRIPT_DIR/config/gemini-persian-rule.md" >> "$GEMINI_RULE_FILE"
    echo "[✓] قوانین نگارش فارسی با استاندارد XeLaTeX به GEMINI.md اضافه شد."
else
    echo "[✓] قوانین نگارش فارسی از قبل در GEMINI.md وجود دارد."
fi

# 6. Setup Systemd User Service Daemon
if command -v systemctl >/dev/null 2>&1 && systemctl --user status >/dev/null 2>&1; then
    echo "[*] فعال‌سازی سرویس دائمی systemd..."
    mkdir -p "$SYSTEMD_USER_DIR"
    cp "$SCRIPT_DIR/systemd/antigravity-rtl.service" "$SYSTEMD_USER_DIR/"
    systemctl --user daemon-reload
    systemctl --user enable --now antigravity-rtl.service
    echo "[✓] سرویس پس‌زمینه با موفقیت فعال شد. از این پس استایل‌ها به صورت دائمی روی تمام پنجره‌ها و تب‌های Antigravity اعمال و حفظ می‌شوند."
fi

# 7. Apply immediately if Antigravity is currently running
if [ -f "$HOME/.config/Antigravity/DevToolsActivePort" ]; then
    echo "[*] برنامه Antigravity هم‌اکنون در حال اجراست؛ در حال اعمال فوری استایل..."
    "$LOCAL_BIN/fix-antigravity-rtl" || true
fi

echo ""
echo "========================================================"
echo "  نصب با موفقیت انجام شد! (Installation Complete!)"
echo "  اکنون متون فارسی با قلم زیبای وزیرمتن و جهت درست نمایش داده می‌شوند."
echo "========================================================"
