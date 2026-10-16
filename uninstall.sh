#!/usr/bin/env bash
set -e

echo "--------------------------------------------------------"
echo "  حذف‌کننده‌ی بسته پشتیبانی فارسی Antigravity"
echo "  Uninstalling Antigravity Persian RTL Support"
echo "--------------------------------------------------------"

# 1. Stop and remove systemd units
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user disable --now antigravity-rtl.path 2>/dev/null || true
    rm -f "$HOME/.config/systemd/user/antigravity-rtl.path"
    rm -f "$HOME/.config/systemd/user/antigravity-rtl.service"
    systemctl --user daemon-reload 2>/dev/null || true
    echo "[✓] سرویس systemd حذف شد."
fi

# 2. Remove binary
rm -f "$HOME/.local/bin/fix-antigravity-rtl"
echo "[✓] فایل اجرایی fix-antigravity-rtl حذف شد."

# 3. Remove fontconfig rule
rm -f "$HOME/.config/fontconfig/conf.d/99-vazirmatn-antigravity.conf"
fc-cache -f "$HOME/.config/fontconfig" 2>/dev/null || true
echo "[✓] تنظیمات Fontconfig حذف شد."

echo ""
echo "حذف کامل شد. (Uninstall complete)"
echo "توجه: در صورت تمایل می‌توانید بخش مربوط به قوانین فارسی را نیز دستی از ~/.gemini/GEMINI.md حذف نمایید."
