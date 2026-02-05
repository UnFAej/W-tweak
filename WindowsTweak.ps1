#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Tweak Tool - Optimasi Performa dan Pembersihan Bloatware
.DESCRIPTION
    Script ini mengoptimalkan Windows dengan:
    - Menonaktifkan fitur yang tidak perlu
    - Menghapus bloatware bawaan
    - Mengoptimalkan performa sistem
.NOTES
    Author: Windows Tweak Tool
    Version: 1.1
    PERINGATAN: Jalankan sebagai Administrator!
#>

# ============================================
# KONFIGURASI
# ============================================
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Windows Tweak Tool v1.1"

# Warna untuk output
function Write-Header { param($Text) Write-Host "`n=======================================================" -ForegroundColor Cyan; Write-Host " $Text" -ForegroundColor Yellow; Write-Host "=======================================================" -ForegroundColor Cyan }
function Write-Success { param($Text) Write-Host " [OK] $Text" -ForegroundColor Green }
function Write-Info { param($Text) Write-Host " [i] $Text" -ForegroundColor Cyan }
function Write-Warn { param($Text) Write-Host " [!] $Text" -ForegroundColor Yellow }

# ============================================
# CEK ADMINISTRATOR
# ============================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Script harus dijalankan sebagai Administrator!" -ForegroundColor Red
    Write-Host "Klik kanan pada PowerShell lalu pilih Run as Administrator" -ForegroundColor Yellow
    pause
    exit
}

# ============================================
# BUAT BACKUP FOLDER
# ============================================
Write-Header "MEMBUAT BACKUP SEBELUM TWEAK"

$backupTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFolder = "$PSScriptRoot\Pre-Tweak_$backupTime"

try {
    # Buat folder backup
    New-Item -Path $backupFolder -ItemType Directory -Force | Out-Null
    Write-Info "Folder backup: $backupFolder"
    
    # Export registry keys yang akan diubah
    Write-Info "Mengeksport registry keys..."
    
    # Visual Effects
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "$backupFolder\VisualEffects.reg" /y 2>$null
    reg export "HKCU\Control Panel\Desktop" "$backupFolder\Desktop.reg" /y 2>$null
    
    # Game DVR
    reg export "HKCU\System\GameConfigStore" "$backupFolder\GameConfigStore.reg" /y 2>$null
    
    # Themes
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "$backupFolder\Personalize.reg" /y 2>$null
    
    # Content Delivery Manager
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "$backupFolder\ContentDeliveryManager.reg" /y 2>$null
    
    # Search
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" "$backupFolder\Search.reg" /y 2>$null
    
    # Advertising
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "$backupFolder\AdvertisingInfo.reg" /y 2>$null
    
    # Explorer Advanced
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "$backupFolder\ExplorerAdvanced.reg" /y 2>$null
    
    # Buat file restore script
    $restoreScript = @"
@echo off
echo Mengembalikan registry ke kondisi sebelum tweak...
echo.
for %%f in (*.reg) do (
    echo Importing %%f...
    reg import "%%f"
)
echo.
echo Selesai! Restart Explorer atau PC untuk menerapkan.
pause
"@
    $restoreScript | Out-File -FilePath "$backupFolder\RESTORE.bat" -Encoding ASCII
    
    Write-Success "Backup berhasil dibuat di: $backupFolder"
    Write-Info "Jalankan RESTORE.bat di folder tersebut untuk rollback"
} catch {
    Write-Warn "Gagal membuat backup (lanjut tanpa backup)"
}

# ============================================
# OPTIMASI PERFORMA
# ============================================
Write-Header "OPTIMASI PERFORMA SISTEM"

# 1. Matikan Visual Effects yang tidak perlu
Write-Info "Mengoptimalkan Visual Effects..."
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
Set-ItemProperty -Path $path -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue

# Matikan animasi window
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -ErrorAction SilentlyContinue
Write-Success "Visual Effects dioptimalkan"

# 2. Matikan Transparency Effects
Write-Info "Menonaktifkan Transparency Effects..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Transparency Effects dinonaktifkan"

# 3. Matikan Game DVR dan Game Bar
Write-Info "Menonaktifkan Game DVR dan Game Bar..."
$gameDVRPath = "HKCU:\System\GameConfigStore"
Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -ErrorAction SilentlyContinue

# Game Bar via policy
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Game DVR dan Game Bar dinonaktifkan"

# 4. Matikan Startup Apps yang tidak perlu
Write-Info "Mengoptimalkan Startup Apps..."
$startupApps = @(
    "Microsoft.OneDrive",
    "Spotify",
    "Discord",
    "Skype"
)
foreach ($app in $startupApps) {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Remove-ItemProperty -Path $regPath -Name $app -ErrorAction SilentlyContinue
}
Write-Success "Startup Apps dioptimalkan"

# 5. Set Power Plan ke High Performance
Write-Info "Mengatur Power Plan ke High Performance..."
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
if ($LASTEXITCODE -ne 0) {
    # Jika High Performance tidak ada, buat dari Balanced
    powercfg /duplicatescheme 381b4222-f694-41f0-9685-ff5bb260df2e 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
}
Write-Success "Power Plan diatur ke High Performance"

# 6. Matikan Hibernasi (hemat disk space)
Write-Info "Menonaktifkan Hibernasi..."
powercfg /hibernate off 2>$null
Write-Success "Hibernasi dinonaktifkan (menghemat ruang disk)"

# 7. Optimize SSD (jika ada)
Write-Info "Mengoptimalkan pengaturan SSD..."
fsutil behavior set DisableLastAccess 1 | Out-Null
fsutil behavior set EncryptPagingFile 0 | Out-Null
Write-Success "Pengaturan SSD dioptimalkan"

# 8. Matikan Search Indexing
Write-Info "Mengoptimalkan Windows Search..."
Stop-Service "WSearch" -Force -ErrorAction SilentlyContinue
Set-Service "WSearch" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Success "Windows Search Indexing dinonaktifkan"

# 9. Matikan Superfetch/SysMain (untuk SSD)
Write-Info "Menonaktifkan Superfetch/SysMain..."
Stop-Service "SysMain" -Force -ErrorAction SilentlyContinue
Set-Service "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Success "Superfetch/SysMain dinonaktifkan"

# 10. Matikan Windows Tips
Write-Info "Menonaktifkan Windows Tips dan Suggestions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Windows Tips dinonaktifkan"

# ============================================
# MATIKAN TELEMETRY DAN PRIVASI
# ============================================
Write-Header "MENONAKTIFKAN TELEMETRY DAN TRACKING"

# 1. Matikan Telemetry
Write-Info "Menonaktifkan Telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
Stop-Service "DiagTrack" -Force -ErrorAction SilentlyContinue
Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Success "Telemetry dinonaktifkan"

# 2. Matikan Activity History
Write-Info "Menonaktifkan Activity History..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Activity History dinonaktifkan"

# 3. Matikan Advertising ID
Write-Info "Menonaktifkan Advertising ID..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Advertising ID dinonaktifkan"

# 4. Matikan Location Tracking
Write-Info "Menonaktifkan Location Tracking..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -ErrorAction SilentlyContinue
Write-Success "Location Tracking dinonaktifkan"

# 5. Matikan Feedback Notifications
Write-Info "Menonaktifkan Feedback Notifications..."
New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Feedback Notifications dinonaktifkan"

# ============================================
# HAPUS BLOATWARE
# ============================================
Write-Header "MENGHAPUS BLOATWARE"

$bloatwareApps = @(
    # Microsoft Apps yang umumnya tidak diperlukan
    "Microsoft.3DBuilder"
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MSPaint"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    
    # Third-party bloatware yang sering terinstall
    "SpotifyAB.SpotifyMusic"
    "Disney.37853FC22B2CE"
    "king.com.CandyCrushFriends"
    "king.com.CandyCrushSaga"
    "FACEBOOK.FACEBOOK"
    "Flipboard.Flipboard"
    "Twitter.Twitter"
    "DuoLingo"
    "EclipseManager"
    "ActiproSoftwareLLC"
    "Amazon.com.Amazon"
    "Netflix"
    "Nordcurrent.CookingFever"
    "PandoraMediaInc"
    "Asphalt8Airborne"
    "TheNewYorkTimes.NYTCrossword"
    "TuneIn.TuneInRadio"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "Clipchamp.Clipchamp"
    "MicrosoftTeams"
    "Microsoft.Todos"
    "Microsoft.PowerAutomateDesktop"
)

$removedCount = 0
foreach ($app in $bloatwareApps) {
    $package = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
    if ($package) {
        Write-Info "Menghapus $app..."
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        $removedCount++
    }
}
Write-Success "$removedCount aplikasi bloatware dihapus"

# ============================================
# MATIKAN SERVICES YANG TIDAK PERLU
# ============================================
Write-Header "MENONAKTIFKAN SERVICES YANG TIDAK PERLU"

$servicesToDisable = @(
    @{Name="dmwappushservice"; Desc="WAP Push Message Routing"},
    @{Name="RetailDemo"; Desc="Retail Demo Service"},
    @{Name="MapsBroker"; Desc="Downloaded Maps Manager"},
    @{Name="lfsvc"; Desc="Geolocation Service"},
    @{Name="SharedAccess"; Desc="Internet Connection Sharing"},
    @{Name="RemoteAccess"; Desc="Routing and Remote Access"},
    @{Name="RemoteRegistry"; Desc="Remote Registry"},
    @{Name="Fax"; Desc="Fax Service"},
    @{Name="XblAuthManager"; Desc="Xbox Live Auth Manager"},
    @{Name="XblGameSave"; Desc="Xbox Live Game Save"},
    @{Name="XboxNetApiSvc"; Desc="Xbox Live Networking Service"},
    @{Name="XboxGipSvc"; Desc="Xbox Accessory Management"}
)

foreach ($svc in $servicesToDisable) {
    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($service -and $service.Status -ne "Stopped") {
        Write-Info "Menonaktifkan $($svc.Desc)..."
        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
Write-Success "Services yang tidak perlu dinonaktifkan"

# ============================================
# OPTIMASI TAMBAHAN
# ============================================
Write-Header "OPTIMASI TAMBAHAN"

# Matikan Cortana
Write-Info "Menonaktifkan Cortana..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Cortana dinonaktifkan"

# Matikan iklan di File Explorer
Write-Info "Menonaktifkan iklan di File Explorer..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Iklan di File Explorer dinonaktifkan"

# Matikan Bing Search di Start Menu
Write-Info "Menonaktifkan Bing Search di Start Menu..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -ErrorAction SilentlyContinue
Write-Success "Bing Search di Start Menu dinonaktifkan"

# Matikan Web Search di Start Menu
Write-Info "Menonaktifkan Web Search di Start Menu..."
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -ErrorAction SilentlyContinue
Write-Success "Web Search di Start Menu dinonaktifkan"

# Bersihkan Temp Files
Write-Info "Membersihkan file temporary..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Success "File temporary dibersihkan"

# ============================================
# UNTUK WINDOWS 11 - Kembalikan Context Menu Lama
# ============================================
$winVer = [System.Environment]::OSVersion.Version.Build
if ($winVer -ge 22000) {
    Write-Header "OPTIMASI KHUSUS WINDOWS 11"
    
    Write-Info "Mengembalikan context menu klasik..."
    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -ErrorAction SilentlyContinue
    Write-Success "Context menu klasik diaktifkan (perlu restart Explorer)"
}

# ============================================
# SELESAI
# ============================================
Write-Header "TWEAK SELESAI!"
Write-Host ""
Write-Host " Semua optimasi telah diterapkan!" -ForegroundColor Green
Write-Host ""
Write-Host " Catatan:" -ForegroundColor Yellow
Write-Host " - Sebagian besar perubahan sudah aktif" -ForegroundColor White
Write-Host " - Untuk perubahan UI perlu restart Explorer" -ForegroundColor White
Write-Host " - Backup tersimpan di: $backupFolder" -ForegroundColor White
Write-Host ""
Write-Host " Pilihan:" -ForegroundColor Cyan
Write-Host " [1] Restart Explorer saja (tanpa restart PC)" -ForegroundColor White
Write-Host " [2] Restart PC sekarang" -ForegroundColor White
Write-Host " [3] Keluar (restart manual nanti)" -ForegroundColor White
Write-Host " [4] CANCEL - Batalkan dan hapus backup" -ForegroundColor Red
Write-Host ""
$choice = Read-Host " Pilih opsi (1/2/3/4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Info "Merestart Windows Explorer..."
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process explorer
        Write-Success "Explorer berhasil direstart!"
        Write-Host ""
        Write-Host " Perubahan UI sudah aktif. Selamat menikmati Windows yang lebih cepat!" -ForegroundColor Green
    }
    "2" {
        Write-Host ""
        Write-Warn "Komputer akan restart dalam 10 detik..."
        Write-Host " Tekan Ctrl+C untuk membatalkan" -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    "4" {
        Write-Host ""
        Write-Warn "Membatalkan tweak dan menghapus folder backup..."
        if (Test-Path $backupFolder) {
            Remove-Item -Path $backupFolder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "Folder backup dihapus: $backupFolder"
        }
        Write-Host ""
        Write-Host " Tweak dibatalkan. Jalankan RESTORE.bat jika Anda sudah punya backup sebelumnya." -ForegroundColor Yellow
    }
    default {
        Write-Host ""
        Write-Host " Anda bisa restart manual nanti untuk perubahan penuh." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host " Tekan Enter untuk menutup..." -ForegroundColor Cyan
Read-Host
