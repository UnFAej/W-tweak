@echo off
chcp 65001 >nul 2>&1
title Windows Tweak Tool v1.1
color 05
mode con: cols=60 lines=28

:MENU
cls
echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║                                                      ║
echo   ║             ╦ ╦  ╔╦╗╦ ╦╔═╗╔═╗╦╔═                     ║
echo   ║             ║║║   ║ ║║║║╣ ╠═╣╠╩╗                     ║
echo   ║             ╚╩╝   ╩ ╚╩╝╚═╝╩ ╩╩ ╩                     ║
echo   ║                                                      ║
echo   ║         Windows Optimization Tool v1.1               ║
echo   ╠══════════════════════════════════════════════════════╣
echo   ║                                                      ║
echo   ║   [1] Jalankan Semua Tweak (Recommended)             ║
echo   ║                                                      ║
echo   ║   [2] Tentang Tool Ini                               ║
echo   ║                                                      ║
echo   ║   [0] Keluar                                         ║
echo   ║                                                      ║
echo   ╠══════════════════════════════════════════════════════╣
echo   ║   [!] Jalankan sebagai Administrator!                ║
echo   ╚══════════════════════════════════════════════════════╝
echo.
set /p choice="   Pilih opsi [0-2]: "

if "%choice%"=="1" goto RUN_TWEAK
if "%choice%"=="2" goto ABOUT
if "%choice%"=="0" goto EXIT
goto MENU

:RUN_TWEAK
cls
echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║           MENJALANKAN WINDOWS TWEAK TOOL             ║
echo   ╚══════════════════════════════════════════════════════╝
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo   [X] ERROR: Harus dijalankan sebagai Administrator!
    echo.
    echo   Cara menjalankan:
    echo   1. Klik kanan pada file ini
    echo   2. Pilih "Run as administrator"
    echo.
    pause
    goto MENU
)

echo   [OK] Berjalan dengan hak Administrator
echo.
echo   Memulai proses optimasi...
echo.
timeout /t 2 >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsTweak.ps1"

echo.
echo   ══════════════════════════════════════════════════════
echo    Proses selesai! Tekan tombol apapun...
echo   ══════════════════════════════════════════════════════
pause >nul
goto MENU

:ABOUT
cls
echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║                 TENTANG WIN TWEAK                    ║
echo   ╠══════════════════════════════════════════════════════╣
echo   ║                                                      ║
echo   ║   [+] PERFORMA                                       ║
echo   ║       - Matikan animasi dan efek visual              ║
echo   ║       - Power Plan High Performance                  ║
echo   ║       - Nonaktifkan Game DVR                         ║
echo   ║       - Optimasi SSD                                 ║
echo   ║                                                      ║
echo   ║   [+] PRIVASI                                        ║
echo   ║       - Matikan Telemetry dan tracking               ║
echo   ║       - Nonaktifkan Cortana dan Bing                 ║
echo   ║       - Hapus iklan di Start Menu                    ║
echo   ║                                                      ║
echo   ║   [+] BLOATWARE                                      ║
echo   ║       - Hapus aplikasi bawaan tidak perlu            ║
echo   ║       - Matikan services tidak diperlukan            ║
echo   ║                                                      ║
echo   ║   [+] WINDOWS 11                                     ║
echo   ║       - Context menu klasik                          ║
echo   ║                                                      ║
echo   ╠══════════════════════════════════════════════════════╣
echo   ║   Script membuat Restore Point sebelum perubahan     ║
echo   ╚══════════════════════════════════════════════════════╝
echo.
pause
goto MENU

:EXIT
cls
echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║                                                      ║
echo   ║      Terima kasih telah menggunakan tool ini!        ║
echo   ║                                                      ║
echo   ╚══════════════════════════════════════════════════════╝
echo.
timeout /t 2 >nul
exit
