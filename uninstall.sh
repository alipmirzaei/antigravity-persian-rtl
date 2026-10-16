#!/usr/bin/env bash
set -e

# ========================================================
# Antigravity Persian RTL & Vazirmatn Uninstaller
# ========================================================

echo "--------------------------------------------------------"
echo "  حذف‌کننده‌ی بسته پشتیبانی فارسی Antigravity"
echo "  Uninstalling Antigravity Persian RTL Support"
echo "--------------------------------------------------------"

OS_NAME="$(uname -s)"

# 1. Stop and remove services
if [ "$OS_NAME" = "Linux" ]; then
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user disable --now antigravity-rtl.service 2>/dev/null || true
        systemctl --user disable --now antigravity-rtl.path 2>/dev/null || true
        rm -f "$HOME/.config/systemd/user/antigravity-rtl.path"
        rm -f "$HOME/.config/systemd/user/antigravity-rtl.service"
        systemctl --user daemon-reload 2>/dev/null || true
        echo "[✓] سرویس systemd متوقف و حذف شد."
    fi
    rm -f "$HOME/.config/autostart/antigravity-rtl.desktop"

    # Remove fontconfig rule
    rm -f "$HOME/.config/fontconfig/conf.d/99-vazirmatn-antigravity.conf"
    fc-cache -f "$HOME/.config/fontconfig" 2>/dev/null || true
    echo "[✓] تنظیمات Fontconfig حذف شد."

elif [ "$OS_NAME" = "Darwin" ]; then
    MAC_PLIST="$HOME/Library/LaunchAgents/com.antigravity.persian.plist"
    if [ -f "$MAC_PLIST" ]; then
        launchctl unload -w "$MAC_PLIST" 2>/dev/null || true
        rm -f "$MAC_PLIST"
        echo "[✓] دیمن LaunchAgent متوقف و از سیستم حذف شد."
    fi
fi

# 2. Remove binary
rm -f "$HOME/.local/bin/fix-antigravity-rtl"
echo "[✓] فایل اجرایی fix-antigravity-rtl حذف شد."

echo ""
echo "========================================================"
echo "  حذف با موفقیت انجام شد. (Uninstall complete)"
echo "  توجه: در صورت تمایل می‌توانید بخش مربوط به قوانین فارسی را نیز دستی از ~/.gemini/GEMINI.md حذف نمایید."
echo "========================================================"
