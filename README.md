# Antigravity Persian RTL & Vazirmatn Suite
> راه‌حل جامع، چندسکویی (Cross-Platform) و با تأخیر صفر (Zero-Latency) برای تایپوگرافی زبان فارسی، قلم وزیرمتن و رفع تداخل متون فارسی و انگلیسی در Google Antigravity مشابه با استاندارد XeLaTeX

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-brightgreen.svg)](#)
[![Font](https://img.shields.io/badge/Font-Vazirmatn-teal.svg)](https://github.com/rastikerdar/vazirmatn)
[![Latency](https://img.shields.io/badge/Latency-0ms%20(Offline%20First)-orange.svg)](#)
[![Safety](https://img.shields.io/badge/Safety-Monaco%20%26%20Terminal%20Protected-success.svg)](#)

<div dir="rtl">

## چرا این ابزار ساخته شد؟ (صورت مسئله)

محیط برنامه و چت دستیار هوش مصنوعی **Google Antigravity** به صورت پیش‌فرض با جهت چپ‌به‌راست (`direction: ltr`) و بدون فونت فارسی بهینه‌سازی‌شده رندر می‌شود. هنگامی که به زبان فارسی گفت‌وگو می‌کنید، مشکلات زیر تجربه کاربری را مختل می‌سازد:

1. **وارونگی و پرش علائم نگارشی**: نقطه (`.`‌)، دونقطه (`:`)، پرانتزها و علامت سوال (`؟`) به جای قرار گرفتن در انتهای جمله، به ابتدای خط یا طرف مخالف می‌پرند.
2. **به‌هم‌ریختگی عبارات ترکیبی فارسی و انگلیسی**: قرار گرفتن اسامی پکیج‌ها، نام توابع یا اصطلاحات انگلیسی میان عبارات فارسی، کلمات را جلو و عقب می‌کند.
3. **فونت ناهماهنگ و درشت سیستمی**: سیستم‌عامل‌ها برای متن‌های فارسی به سراغ فونت‌های ناهماهنگ با وب مدرن (مانند DejaVu یا Arial) می‌روند که خوانایی را به شدت کاهش می‌دهد.
4. **تداخل با ادیتور و ترمینال در روش‌های سطحی**: تغییر جهت عمومی صفحه باعث آسیب به محیط کدنویسی (Monaco)، خراب شدن ایندنت‌ها، جابه‌جا شدن کرسر و وارونه شدن ترمینال لینوکس می‌شود.

این پروژه یک راه‌حل چندلایه و مهندسی‌شده ارائه می‌دهد که خروجی فارسی را با قلم محبوب و چشم‌نواز **وزیرمتن (Vazirmatn)** و دقتی در تراز **XeLaTeX + xepersian** نمایش می‌دهد، بدون آن‌که کوچک‌ترین آسیبی به ویرایشگر کد یا ترمینال وارد کند.

---

## ویژگی‌ها و معماری پروژه

### ۱. بدون تأخیر و آفلاین (Zero-Latency & Offline-First)
فونت وزیرمتن مستقیماً از حافظه محلی سیستم فراخوانی می‌شود (`local('Vazirmatn')`). هیچ درخواستی به سرورهای Google Fonts یا شبکه ارسال نمی‌شود؛ در نتیجه محدودیت‌های اینترنت یا تحریم‌ها هیچ تأثیری روی لود فونت ندارند و زمان لود ۰ میلی‌ثانیه است.

### ۲. سپرهای ایمنی اختصاصی (Safety Shields)
- **سپر Monaco Editor**: ویرایشگر کد اصلی و نمای Diff با قوانین صریح `direction: ltr !important`، فونت مونو و `unicode-bidi: normal` محافظت شده‌اند. تورفتگی‌ها (Indentation) و مکان‌نمای متن (Cursor) دست‌نخورده باقی می‌مانند.
- **سپر Terminal / xterm.js**: پنجره‌های خط فرمان و ترمینال‌های ادغام‌شده کاملاً چپ‌به‌راست و با فونت تک‌فاصله باقی می‌مانند.
- **سپر فرمول‌های ریاضی KaTeX**: تمام نمادها، عملگرها و فرمول‌های ریاضی از راست‌چین شدن محافظت شده و ساختار خود را حفظ می‌کنند.
- **ایزوله‌سازی کدهای درون‌خطی**: عبارات انگلیسی و تگ‌های `code` در میان جملات فارسی مانند دستور `\lr{...}` در زی‌پرشین ایزوله می‌شوند (`unicode-bidi: isolate`).

### ۳. پایداری در برابر آپدیت‌های Antigravity (Update-Proof)
این ابزار فایل‌های اجرایی خود برنامه را دستکاری یا Patch نمی‌کند. ارتباط از طریق پروتکل رسمی **Chrome DevTools Protocol (CDP)** و با متد `Page.addScriptToEvaluateOnNewDocument` انجام می‌شود؛ یعنی اسکریپت پیش از رندر هر صفحه در کرومیوم کامپایل می‌شود و با هر ری‌استارت، آپدیت نرم‌افزار، یا باز کردن پنجره و تب جدید، استایل‌ها فوراً و بدون وقفه اعمال می‌شوند.

### ۴. مصرف نامحسوس منابع (Lightweight)
سرویس پس‌زمینه با Node.js بومی و کمتر از ۱۵ مگابایت رم و ۰٪ بار پردازنده عمل می‌کند.

---

## روش نصب (Installation)

### لینوکس و مک (Linux & macOS)

سریع‌ترین راه نصب با یک دستور از طریق ترمینال:

```bash
curl -fsSL https://raw.githubusercontent.com/aliamani/antigravity-persian-rtl/main/install.sh | bash
```

یا از طریق دریافت دستی مخزن:

```bash
git clone https://github.com/aliamani/antigravity-persian-rtl.git
cd antigravity-persian-rtl
chmod +x install.sh
./install.sh
```

**اسکریپت به صورت خودکار:**
- در لینوکس: قلم وزیرمتن را بررسی و نصب کرده، پیکربندی `fontconfig` را تنظیم می‌کند و دیمن کاربری `systemd` (یا XDG Autostart) را فعال می‌سازد.
- در مک: قلم وزیرمتن را در `~/Library/Fonts` نصب کرده و سرویس پس‌زمینه `LaunchAgent` را رجیستر می‌کند.
- ابزار دستور خط فرمان `fix-antigravity-rtl` را در مسیر `~/.local/bin` شما نصب می‌کند.
- قوانین نگارش حرفه‌ای فارسی را در `~/.gemini/GEMINI.md` تنظیم می‌کند.

---

### ویندوز (Windows PowerShell)

پنجره‌ی PowerShell را باز کرده و دستور زیر را اجرا کنید:

```powershell
irm https://raw.githubusercontent.com/aliamani/antigravity-persian-rtl/main/windows/install.ps1 | iex
```

یا پس از دریافت پروژه:
```powershell
cd antigravity-persian-rtl
powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
```

این اسکریپت قلم وزیرمتن را نصب کرده، ابزار اجرایی را در مسیر کاربر قرار داده و سرویس استارتاپ ویندوز را برای اجرای نامرئی در پس‌زمینه پیکربندی می‌کند.

---

## خط فرمان و دستورات کنترلی (CLI Commands)

پس از نصب، دستور `fix-antigravity-rtl` در ترمینال شما در دسترس است:

```bash
# بررسی وضعیت سرویس، پورت فعال و پنجره‌های متصل Antigravity
fix-antigravity-rtl status

# اعمال فوری و دستی استایل‌ها بر روی پنجره‌های فعال
fix-antigravity-rtl
```

**نمونه خروجی وضعیت (`status`):**
```text
----------------------------------------------------
  Antigravity Persian RTL & Vazirmatn Status
----------------------------------------------------
[i] Platform: linux (x64)
[i] DevTools Port File: ~/.config/Antigravity/DevToolsActivePort
[✓] Antigravity is running (Active CDP Port: 34457)
[✓] Open UI Windows/Tabs: 1
    1. "Fixing Persian English Text Direction - antigravity-persian-rtl - Antigravity"
[i] systemd Service Status: ● ACTIVE (Daemon running)
----------------------------------------------------
```

---

## روش حذف (Uninstall)

برای بازگرداندن تمام تنظیمات به حالت اولیه:

### لینوکس و مک:
```bash
./uninstall.sh
```

### ویندوز:
فایل `antigravity-persian-rtl.vbs` را از پوشه `Startup` ویندوز حذف کنید.

</div>

---

## English Overview

**Antigravity Persian RTL & Vazirmatn Suite** is a zero-latency, cross-platform enhancement for **Google Antigravity**. It solves bidirectional (BiDi) text mixture problems, fixes misplaced punctuation, and renders Saber Rastikerdar's elegant **Vazirmatn** font natively across all chat and UI panels without breaking the Monaco code editor, terminal, or KaTeX math formulas.

### Highlights
- **Zero-Latency & Local**: 100% offline-first using local font rendering. No external web requests or CDN dependencies.
- **Safety Shields**:
  - `Monaco Editor`: Left-to-right, monospaced indentation and cursor positioning remain fully preserved.
  - `Terminal (xterm.js)`: Native LTR terminal behavior guaranteed.
  - `KaTeX`: Mathematical equations remain properly oriented.
- **CDP Engine**: Injected dynamically via Chrome DevTools Protocol (`Page.addScriptToEvaluateOnNewDocument`), making it completely resilient to window reloads and application updates.
- **Cross-Platform**: Full support for Linux (`systemd` / XDG Autostart), macOS (`LaunchAgent`), and Windows (PowerShell + Startup daemon).

---

## لایسنس (License)

این پروژه تحت پروانه‌ی [MIT](LICENSE) منتشر شده است.  
قلم گران‌قدر وزیرمتن اثر جاودان صابر راستی‌کردار (روحش شاد) تحت مجوز Open Font License می‌باشد.
