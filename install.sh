#!/usr/bin/env bash
set -e

# ========================================================
# Antigravity Persian RTL & Vazirmatn Multi-Platform Installer
# Supported: Linux, macOS, WSL
# ========================================================

echo "--------------------------------------------------------"
echo "  نصب‌کننده‌ی جامع پشتیبانی از زبان فارسی و قلم وزیرمتن در Antigravity"
echo "  Antigravity Persian RTL & Vazirmatn Universal Installer"
echo "--------------------------------------------------------"

REPO_URL="https://github.com/alipmirzaei/antigravity-persian-rtl.git"
INSTALL_TARGET_DIR="$HOME/.local/share/antigravity-persian-rtl"

# 0. Pipe / Remote Execution Handling (curl ... | bash)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ ! -f "$SCRIPT_DIR/bin/fix-antigravity-rtl.js" ]; then
    echo "[*] در حال دریافت مخزن پروژه در $INSTALL_TARGET_DIR..."
    if command -v git >/dev/null 2>&1; then
        if [ -d "$INSTALL_TARGET_DIR/.git" ]; then
            cd "$INSTALL_TARGET_DIR" && git pull --quiet
        else
            mkdir -p "$(dirname "$INSTALL_TARGET_DIR")"
            git clone --quiet "$REPO_URL" "$INSTALL_TARGET_DIR"
        fi
    else
        echo "[!] برای نصب از طریق curl داشتن git الزامی است."
        exit 1
    fi
    exec bash "$INSTALL_TARGET_DIR/install.sh"
    exit 0
fi

OS_NAME="$(uname -s)"
LOCAL_BIN="$HOME/.local/bin"
GEMINI_RULE_FILE="$HOME/.gemini/GEMINI.md"

# 1. Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[!] Node.js یافت نشد. لطفاً ابتدا Node.js را نصب کنید."
    echo "[!] Node.js is required. Please install Node.js first."
    exit 1
fi

mkdir -p "$LOCAL_BIN"

# 2. Platform-Specific Setup
if [ "$OS_NAME" = "Linux" ]; then
    echo "[*] سیستم‌عامل تشخیص داده شده: Linux"
    FONTCONFIG_DIR="$HOME/.config/fontconfig/conf.d"
    FONTS_DIR="$HOME/.local/share/fonts/vazirmatn"
    SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
    AUTOSTART_DIR="$HOME/.config/autostart"

    # A. Vazirmatn Font
    echo "[*] بررسی نصب بودن قلم وزیرمتن (Checking Vazirmatn font)..."
    if ! fc-list : family 2>/dev/null | grep -iq "vazirmatn"; then
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
            fc-cache -f "$FONTS_DIR" 2>/dev/null || true
            echo "[✓] قلم وزیرمتن با موفقیت نصب شد."
        else
            echo "[!] هشدار: امکان دانلود خودکار فونت فراهم نشد. لطفاً پکیج fonts-vazirmatn را دستی نصب کنید."
        fi
    else
        echo "[✓] قلم وزیرمتن روی سیستم نصب است."
    fi

    # B. Fontconfig
    echo "[*] تنظیم پیکربندی Fontconfig..."
    mkdir -p "$FONTCONFIG_DIR"
    cp "$SCRIPT_DIR/config/99-vazirmatn-antigravity.conf" "$FONTCONFIG_DIR/99-vazirmatn-antigravity.conf"
    fc-cache -f "$FONTCONFIG_DIR" 2>/dev/null || true
    echo "[✓] تنظیمات Fontconfig با موفقیت اعمال شد."

    # C. Systemd User Service or Autostart Desktop Entry
    SYSTEMD_AVAILABLE=false
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user status >/dev/null 2>&1; then
            SYSTEMD_AVAILABLE=true
        fi
    fi

    if [ "$SYSTEMD_AVAILABLE" = "true" ]; then
        echo "[*] فعال‌سازی سرویس دائمی systemd..."
        mkdir -p "$SYSTEMD_USER_DIR"
        cp "$SCRIPT_DIR/systemd/antigravity-rtl.service" "$SYSTEMD_USER_DIR/"
        systemctl --user daemon-reload
        systemctl --user enable --now antigravity-rtl.service
        echo "[✓] سرویس پس‌زمینه systemd فعال شد."
    else
        echo "[*] فعال‌سازی راه‌انداز خودکار دسکتاپ (XDG Autostart)..."
        mkdir -p "$AUTOSTART_DIR"
        cp "$SCRIPT_DIR/autostart/antigravity-rtl.desktop" "$AUTOSTART_DIR/"
        echo "[✓] فایل ورود خودکار دسکتاپ فعال شد."
    fi

elif [ "$OS_NAME" = "Darwin" ]; then
    echo "[*] سیستم‌عامل تشخیص داده شده: macOS (Darwin)"
    MAC_FONTS_DIR="$HOME/Library/Fonts"
    LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

    # A. Vazirmatn Font on macOS
    echo "[*] بررسی نصب بودن قلم وزیرمتن در macOS..."
    if [ ! -f "$MAC_FONTS_DIR/Vazirmatn-Regular.ttf" ]; then
        echo "[+] در حال دریافت و نصب خودکار قلم وزیرمتن در $MAC_FONTS_DIR..."
        mkdir -p "$MAC_FONTS_DIR"
        VAZIR_RELEASE_URL="https://github.com/rastikerdar/vazirmatn/releases/latest/download/vazirmatn-v33.003.zip"
        TMP_ZIP="/tmp/vazirmatn.zip"
        TMP_DIR="/tmp/vazirmatn_extracted"

        curl -fsSL "$VAZIR_RELEASE_URL" -o "$TMP_ZIP"
        if [ -f "$TMP_ZIP" ]; then
            mkdir -p "$TMP_DIR"
            unzip -q -o "$TMP_ZIP" -d "$TMP_DIR"
            find "$TMP_DIR" -name "*.ttf" -exec cp {} "$MAC_FONTS_DIR/" \;
            rm -rf "$TMP_ZIP" "$TMP_DIR"
            echo "[✓] قلم وزیرمتن با موفقیت در پوشه فونت‌های مک نصب شد."
        fi
    else
        echo "[✓] قلم وزیرمتن در $MAC_FONTS_DIR موجود است."
    fi

    # B. macOS LaunchAgent
    echo "[*] راه‌اندازی دیمن پس‌زمینه LaunchAgent در macOS..."
    mkdir -p "$LAUNCH_AGENTS_DIR"
    cp "$SCRIPT_DIR/macos/com.antigravity.persian.plist" "$LAUNCH_AGENTS_DIR/"
    launchctl unload "$LAUNCH_AGENTS_DIR/com.antigravity.persian.plist" 2>/dev/null || true
    launchctl load -w "$LAUNCH_AGENTS_DIR/com.antigravity.persian.plist"
    echo "[✓] دیمن LaunchAgent با موفقیت بارگذاری و فعال شد."
fi

# 3. Install binary to ~/.local/bin
echo "[*] نصب ابزار تزریق استایل fix-antigravity-rtl..."
cp "$SCRIPT_DIR/bin/fix-antigravity-rtl.js" "$LOCAL_BIN/fix-antigravity-rtl"
chmod +x "$LOCAL_BIN/fix-antigravity-rtl"
echo "[✓] دستور fix-antigravity-rtl در $LOCAL_BIN مستقر شد."

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "[i] نکته: مسیر ~/.local/bin در متغیر PATH شما نیست. توصیه می‌شود آن را به فایل .bashrc یا .zshrc خود بیافزایید:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 4. Append Assistant Rule to ~/.gemini/GEMINI.md
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

# 5. Apply immediately if Antigravity is running
echo "[*] بررسی اجرای برنامه Antigravity برای اعمال آنی استایل..."
"$LOCAL_BIN/fix-antigravity-rtl" || true

echo ""
echo "========================================================"
echo "  نصب با موفقیت انجام شد! (Installation Complete!)"
echo "  برای بررسی وضعیت در هر زمان می‌توانید دستور زیر را اجرا کنید:"
echo "    fix-antigravity-rtl status"
echo "========================================================"
