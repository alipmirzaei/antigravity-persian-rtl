# Antigravity Persian RTL & Vazirmatn Fix
> پیکربندی استاندارد فونت وزیرمتن و رفع مشکل ترکیب متون فارسی و انگلیسی (RTL/LTR) در Google Antigravity مشابه XeLaTeX

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-orange.svg)](#)
[![Font](https://img.shields.io/badge/Font-Vazirmatn-green.svg)](https://github.com/rastikerdar/vazirmatn)

<div dir="rtl">

## چرا این ابزار لازم است؟ (مشکل چیست؟)

محیط چت و بوم کدنویسی **Google Antigravity** به صورت پیش‌فرض با جهت چپ‌به‌راست (`direction: ltr`) رندر می‌شود. هنگامی که به زبان فارسی می‌نویسید یا پاسخی فارسی دریافت می‌کنید، تداخل جهت متون (BiDi) باعث مشکلات زیر می‌شود:
1. **جابه‌جایی علائم نگارشی**: نقطه (`.`)، دو‌نقطه (`:`) و پرانتزها به جای قرار گرفتن در انتهای جمله، به ابتدای خط یا طرف مقابل می‌پرند.
2. **به‌هم‌ریختگی کلمات انگلیسی و کدها**: قرار گرفتن کلمات انگلیسی (مثل نام توابع، پکیج‌ها یا اصطلاحات فنی) میان جملات فارسی، چینش کلمات را وارونه می‌کند.
3. **فونت نامناسب سیستمی**: لینوکس برای کاراکترهای فارسی به سراغ فونت‌های ناهماهنگ و درشت مثل `DejaVu Sans` می‌رود.

این پروژه یک راه‌حل جامع ۳ لایه‌ای مشابه استاندارد **XeLaTeX + xepersian** پیاده می‌کند تا تجربه‌ای روان، زیبا و تمیز از زبان فارسی با قلم **وزیرمتن (Vazirmatn)** در Antigravity داشته باشید.

---

## این بسته چه کار می‌کند؟

1. **لایه ۱: قلم سیستمی (Fontconfig)**
   تنظیمات لینوکس (`fontconfig`) را طوری پیکربندی می‌کند که برای تمام متن‌های فارسی و عربی در سیستم و برنامه‌های مبتنی بر کرومیوم/الکترون، بدون دستکاری فونت لاتین انگلیسی، قلم محبوب **وزیرمتن** به عنوان قلم پیش‌فرض استفاده شود.
2. **لایه ۲: اصلاح خودکار رابط کاربری (Auto-RTL DevTools Injection)**
   از طریق پورت DevTools برنامه، استایل‌های راست‌چین هوشمند (`unicode-bidi: plaintext`، ایزوله‌سازی تگ‌های `code` و `pre`) را تزریق می‌کند تا هم پیام‌های ورودی کاربر و هم پاسخ‌های چت به‌درستی راست‌چین شوند.
3. **لایه ۳: سرویس پس‌زمینه خودکار (Systemd Path Watcher)**
   یک واحد `systemd --user` راه‌اندازی می‌کند که باز شدن Antigravity را تشخیص داده و استایل‌ها را به‌صورت کاملاً خودکار و نامرئی اعمال می‌کند.
4. **لایه ۴: قوانین دائمی دستیار (`~/.gemini/GEMINI.md`)**
   دستورالعمل استانداردی به دستیار هوش مصنوعی تزریق می‌کند تا پاسخ‌های فارسی را با ساختار درست و ایزوله‌سازی عبارات فنی بنویسد.

---

## روش نصب سریع (Quick Install)

ترمینال را باز کرده و دستور زیر را اجرا کنید:

```bash
git clone https://github.com/your-username/antigravity-persian-rtl.git
cd antigravity-persian-rtl
chmod +x install.sh
./install.sh
```

اسکریپت نصب به طور خودکار:
- وجود قلم وزیرمتن را بررسی کرده و در صورت نبود، آن را نصب می‌کند.
- تنظیمات `fontconfig` را اعمال می‌نماید.
- ابزار اجرایی `fix-antigravity-rtl` را در `~/.local/bin` نصب می‌کند.
- قانون نگارش فارسی را در `~/.gemini/GEMINI.md` قرار می‌دهد.
- پایشگر خودکار `systemd` را فعال می‌کند.

---

## سوالات متداول (FAQ)

### آیا با آپدیت شدن Antigravity این تنظیمات می‌پرد؟
**خیر!**
- فایل‌های پیکربندی در شاخه‌های کاربری سیستم شما (`~/.config/fontconfig/` و `~/.gemini/GEMINI.md` و `~/.local/bin/`) قرار دارند و آپدیت‌های بسته (چه از طریق Snap و چه Deb/Flatpak) به هیچ عنوان پوشه کاربری شما را دستکاری یا پاک نمی‌کنند.
- پایشگر `systemd` صرفاً فایل پورت فعال Antigravity را رصد می‌کند و مستقل از ورژن برنامه عمل می‌کند.
- استایل‌های CSS تزریق‌شده متکی به تگ‌های استاندارد وب (`p`، `li`، `code`، `pre`) و الگوریتم رسمی BiDi هستند، نه کلاس‌های موقت و متغیر.

### چگونه استایل را دستی اعمال کنم؟
اگر در هر زمان مایل بودید بدون راه‌اندازی مجدد، استایل‌ها را دستی روی پنجره باز اعمال کنید، فقط کافیست در ترمینال بنویسید:
```bash
fix-antigravity-rtl
```

---

## روش حذف (Uninstall)

برای بازگرداندن سیستم به حالت اولیه:
```bash
./uninstall.sh
```

</div>

---

## English Summary

`antigravity-persian-rtl` is a complete Persian (Farsi) and Arabic RTL typography booster for **Google Antigravity**. It solves bidirectional text mixing (BiDi) issues, misplaced punctuation, and enables Saber Rastikerdar's **Vazirmatn** font natively across the IDE interface using Fontconfig and DevTools WebSocket injection.

### Features
- **Native Vazirmatn Fontconfig Mapping**: English text stays crisp in system fonts; Persian glyphs automatically render in Vazirmatn.
- **BiDi Isolation**: Inline code and technical tokens behave like `\lr{...}` in XeLaTeX.
- **Automated Daemon**: Systemd user path unit injects styles automatically upon Antigravity launch.
- **Preserved Across Updates**: 100% user-space configuration, completely unaffected by application updates.

---

## لایسنس (License)
این پروژه تحت پروانه‌ی [MIT](LICENSE) منتشر شده است.
امتیاز فونت وزیرمتن متعلق به صابر راستی‌کردار (روحش شاد) تحت پروانه‌ی OFL است.
