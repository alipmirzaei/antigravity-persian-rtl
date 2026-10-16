# ========================================================
# Antigravity Persian RTL & Vazirmatn Installer for Windows
# ========================================================

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  نصب‌کننده‌ی پشتیبانی از زبان فارسی و قلم وزیرمتن در Antigravity (ویندوز)" -ForegroundColor Green
Write-Host "  Installing Antigravity Persian RTL & Vazirmatn for Windows" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan

# 1. Check Node.js
if (-not (Get-Command "node" -ErrorAction SilentlyContinue)) {
    Write-Host "[!] خطا: Node.js روی سیستم یافت نشد. لطفاً ابتدا Node.js را از https://nodejs.org نصب کنید." -ForegroundColor Red
    Write-Host "[!] Node.js is required. Please install it from https://nodejs.org first." -ForegroundColor Red
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")

$UserBinDir = Join-Path $env:USERPROFILE ".local\bin"
if (-not (Test-Path $UserBinDir)) {
    New-Item -ItemType Directory -Path $UserBinDir -Force | Out-Null
}

# 2. Check & Install Vazirmatn Font
Write-Host "[*] بررسی نصب بودن قلم وزیرمتن (Checking Vazirmatn font)..." -ForegroundColor Yellow
$FontInstalled = $false
$RegFonts = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
if ($RegFonts) {
    foreach ($prop in $RegFonts.PSObject.Properties) {
        if ($prop.Name -like "*Vazirmatn*") {
            $FontInstalled = $true
            break
        }
    }
}
$SystemFonts = Get-ChildItem -Path "$env:WINDIR\Fonts" -Filter "*Vazirmatn*.ttf" -ErrorAction SilentlyContinue
if ($SystemFonts) { $FontInstalled = $true }

if (-not $FontInstalled) {
    Write-Host "[+] در حال دریافت و نصب خودکار قلم وزیرمتن..." -ForegroundColor Cyan
    $FontZipUrl = "https://github.com/rastikerdar/vazirmatn/releases/latest/download/vazirmatn-v33.003.zip"
    $TempZip = Join-Path $env:TEMP "vazirmatn.zip"
    $TempExtract = Join-Path $env:TEMP "vazirmatn_extracted"

    try {
        Invoke-WebRequest -Uri $FontZipUrl -OutFile $TempZip
        Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

        $UserFontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
        if (-not (Test-Path $UserFontDir)) {
            New-Item -ItemType Directory -Path $UserFontDir -Force | Out-Null
        }

        $TtfFiles = Get-ChildItem -Path $TempExtract -Recurse -Filter "*.ttf"
        foreach ($ttf in $TtfFiles) {
            $targetPath = Join-Path $UserFontDir $ttf.Name
            Copy-Item -Path $ttf.FullName -Destination $targetPath -Force
            # Register in HKCU Fonts registry
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$($ttf.BaseName) (TrueType)" -Value $targetPath
        }

        Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] قلم وزیرمتن با موفقیت برای کاربر فعلی نصب شد." -ForegroundColor Green
    } catch {
        Write-Host "[!] دانلود یا نصب خودکار فونت با خطا مواجه شد: $_" -ForegroundColor Yellow
        Write-Host "[i] می‌توانید فایل‌های TTF فونت وزیرمتن را دستی از گیت‌هاب دریافت و Install کنید." -ForegroundColor Yellow
    }
} else {
    Write-Host "[✓] قلم وزیرمتن روی سیستم نصب است." -ForegroundColor Green
}

# 3. Copy injector script & create command runner
Write-Host "[*] نصب اسکریپت fix-antigravity-rtl..." -ForegroundColor Yellow
$SourceJs = Join-Path $ProjectRoot "bin\fix-antigravity-rtl.js"
$TargetJs = Join-Path $UserBinDir "fix-antigravity-rtl.js"
Copy-Item -Path $SourceJs -Destination $TargetJs -Force

$CmdWrapper = Join-Path $UserBinDir "fix-antigravity-rtl.cmd"
"@echo off`r`nnode `"%~dp0fix-antigravity-rtl.js`" %*" | Out-File -FilePath $CmdWrapper -Encoding ASCII

# Ensure User PATH contains ~/.local/bin
$UserPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if ($UserPath -notlike "*$UserBinDir*") {
    $NewPath = "$UserBinDir;$UserPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, [EnvironmentVariableTarget]::User)
    $env:PATH = "$UserBinDir;$env:PATH"
    Write-Host "[✓] مسیر $UserBinDir به PATH کاربر افزوده شد." -ForegroundColor Green
}

# 4. Append Persian rule to ~/.gemini/GEMINI.md
Write-Host "[*] به‌روزرسانی قوانین دستیار در GEMINI.md..." -ForegroundColor Yellow
$GeminiDir = Join-Path $env:USERPROFILE ".gemini"
$GeminiMd = Join-Path $GeminiDir "GEMINI.md"
if (-not (Test-Path $GeminiDir)) {
    New-Item -ItemType Directory -Path $GeminiDir -Force | Out-Null
}
if (-not (Test-Path $GeminiMd)) {
    New-Item -ItemType File -Path $GeminiMd -Force | Out-Null
}

$RuleSource = Join-Path $ProjectRoot "config\gemini-persian-rule.md"
$RuleText = Get-Content -Path $RuleSource -Raw
$CurrentGemini = Get-Content -Path $GeminiMd -Raw -ErrorAction SilentlyContinue

if ($CurrentGemini -notlike "*Persian (Farsi) & Mixed RTL/LTR Typography*") {
    Add-Content -Path $GeminiMd -Value "`r`n$RuleText"
    Write-Host "[✓] قوانین نگارش فارسی با استاندارد XeLaTeX به GEMINI.md اضافه شد." -ForegroundColor Green
} else {
    Write-Host "[✓] قوانین نگارش فارسی از قبل در GEMINI.md وجود دارد." -ForegroundColor Green
}

# 5. Setup Background Daemon in Startup folder (Silent VBS Launcher)
Write-Host "[*] تنظیم راه‌اندازی خودکار در هنگام ورود به ویندوز (Startup Daemon)..." -ForegroundColor Yellow
$StartupFolder = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$VbsPath = Join-Path $StartupFolder "antigravity-persian-rtl.vbs"

$VbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
userProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
cmd = "node """ & userProfile & "\.local\bin\fix-antigravity-rtl.js"" --daemon"
WshShell.Run cmd, 0, False
"@

$VbsContent | Out-File -FilePath $VbsPath -Encoding ASCII
Write-Host "[✓] سرویس استارتاپ ویندوز تنظیم شد (اجرای کاملاً نامرئی در پس‌زمینه)." -ForegroundColor Green

# 6. Apply immediately
Write-Host "[*] اجرای ابزار برای پنجره‌های فعال Antigravity..." -ForegroundColor Yellow
& node $TargetJs

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  نصب در ویندوز با موفقیت انجام شد! (Installation Complete!)" -ForegroundColor Green
Write-Host "  دستور fix-antigravity-rtl status برای مشاهده وضعیت در دسترس است." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
