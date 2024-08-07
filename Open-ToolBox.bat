@echo off
title Open ToolBox

mode con: cols=125 lines=36

:: Check for administrative privileges
powershell -Command "if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { exit 1 }"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

cls
wmic /? >nul 2>&1
if %errorlevel% neq 0 (
    echo [31mFirst start configuration don't close the application[0m
    DISM /Online /Add-Capability /CapabilityName:WMIC~~~~
) else (
    echo.
)
cls

cls
set "TPMX=TPM: [33mNONE "
for /f "tokens=11 delims=," %%i in ('wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get * /format:csv 2^> nul') do set TPMVER=%%i
for /f %%i in ('wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get * 2^>nul ^| find "TRUE"') do set "TPMX=TPM: [33mTRUE / %TPMVER% [0m" || set "TPMX=TPM: [33mNONE "
for /f "tokens=2" %%i in ('wmic os get caption') do set VERSION1=%%i
for /f "tokens=3" %%i in ('wmic os get caption') do set VERSION2=%%i
for /f "tokens=4" %%i in ('wmic os get caption') do set VERSION3=%%i
reg Query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework" | find /i "0x0" > NUL && set "FNETFX4=DISABLE" || set "FNETFX4=ENABLE"
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2^> nul') DO SET "CODENAME= %%B "
FOR /F "skip=2 tokens=2,*" %%A IN ('reg.exe query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ReleaseId"') DO set "DFMT7= %%B "
FOR /F "skip=2 tokens=2,*" %%A IN ('reg.exe query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild"') DO set "DFMT5= %%B"
FOR /F "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v UBR') do set "UBRHEX=%%~b"
set /a UBRDEC=%UBRHEX%
for /f "tokens=3 delims=()" %%a in ('wmic timezone get caption /value') do set tzone1=%%a
for /f "tokens=2 delims=()" %%a in ('wmic timezone get caption /value') do set tzone2=%%a
cls

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set "OSARC= 64bit ")
if "%PROCESSOR_ARCHITECTURE%"=="x86" (set "OSARC= 32bit ")


set "downloadDir=%USERPROFILE%\Downloads"

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "arch=64"
) else (
    set "arch=32"
)

:menu
cls
echo =====================================================================================================================
echo USER: [33m%USERNAME%[0m ^| COMPUTERNAME: [33m%COMPUTERNAME%[0m ^| NETFX4: [33m%FNETFX4%[0m ^| %TPMX%
echo CURRENT OS: [104m[37m %VERSION1% %VERSION2% %VERSION3% [0m[41m[37m%DFMT7%[0m[42m%CODENAME%[0m[44m%DFMT5%.%UBRDEC% [0m[45m%OSARC%[0m
echo TIME ZONE: [31m%tzone2%[0m ^| [31m%tzone1%[0m
echo =====================================================================================================================
echo.
echo [94mTWEAK ^| FIXED ^| CLEANER ^| OTHER                                Software[0m 
echo [33m-------------------------------                                --------
echo [94m[1]  [37m^|[0m Action Center ^& Notification ^| Cortana ^| Printer         [94m[20] [37m^|[0m Microsoft Edge             
echo [94m[2]  [37m^|[0m Clear Event Viewer Logs                                  [94m[21] [37m^|[0m Brave
echo [94m[3]  [37m^|[0m Clear Cache Updates ^| Delivery Optimization              [94m[22] [37m^|[0m Firefox
echo [94m[4]  [37m^|[0m Microsoft Activation                                     [94m[23] [37m^|[0m Google Chrome
echo [94m[5]  [37m^|[0m Hibernation ^| Fastboot ^| Sleepmode ^| Sysmain             [94m[24] [37m^|[0m Opera
echo [94m[6]  [37m^|[0m Pagefile (virtual memory)                                [94m[25] [37m^|[0m DuckDuckGo
echo [94m[7]  [37m^|[0m Right click Take Ownership Menu                          [94m[26] [37m^|[0m Librewolf
echo [94m[8]  [37m^|[0m Stops Windows Updates until 2077                         [94m[27] [37m^|[0m 7-Zip 24.07
echo [94m[9]  [37m^|[0m Compact ^| LZX compression                                [94m[28] [37m^|[0m VLC    
echo [94m[10] [37m^|[0m Remove Windows Defender                                  [94m[29] [37m^|[0m Notepad++ 8.6.9   
echo.
echo [94mUWP APPX ^| OTHER                                               OTHER ^| ETC
echo [33m----------------                                               -----------
echo [94m[11] [37m^|[0m Microsoft Store                                         [94m[30][0m ^| Microsoft Disk Benchmark
echo [94m[12][0m ^| Microsoft Xbox Game Bar                                 [94m[31][0m ^| Personalization
echo [94m[13][0m ^| Microsoft .NET Framework                                [94m[32][0m ^| Game Client - Steam/GOG/Origin/Epic/Ubisoft/Battle
echo [94m[14][0m ^| Microsoft OneDrive                                      
echo [94m[15][0m ^| Microsoft Music                                         
echo [94m[16][0m ^| Microsoft Movies ^& TV                                   
echo [94m[17][0m ^| Options For Windows 11                                  
echo.
echo [94mHighly recommended to install[0m
echo [33m-----------------------------[0m
echo [94m[18][0m ^| Visual C++ Redistributables AIO (system)
echo [94m[19][0m ^| DirectX (system)
echo.
echo [94m[0]  [37m^|[0m Exit[0m
echo.
set /p choice=[0mEnter your choice (0-32):[0m

if "%choice%"=="1" goto actionandnoti
if "%choice%"=="2" goto op2
if "%choice%"=="3" goto op3
if "%choice%"=="4" goto op4
if "%choice%"=="5" goto op5
if "%choice%"=="6" goto op6
if "%choice%"=="7" goto op7
if "%choice%"=="8" goto op8
if "%choice%"=="9" goto op9
if "%choice%"=="10" goto defender
if "%choice%"=="11" goto op10
if "%choice%"=="12" goto op11
if "%choice%"=="13" goto netframework
if "%choice%"=="14" goto onedrive0
if "%choice%"=="15" goto zunemusic
if "%choice%"=="16" goto movie
if "%choice%"=="17" goto opwin11
if "%choice%"=="18" goto op16
if "%choice%"=="19" goto op17
if "%choice%"=="20" goto edge
if "%choice%"=="21" goto brave
if "%choice%"=="22" goto firefox
if "%choice%"=="23" goto chrome
if "%choice%"=="24" goto opera
if "%choice%"=="25" goto duckduckgo
if "%choice%"=="26" goto librewolf
if "%choice%"=="27" goto 7zip
if "%choice%"=="28" goto vlc
if "%choice%"=="29" goto notepad
if "%choice%"=="30" goto opdisk
if "%choice%"=="31" goto pers
if "%choice%"=="32" goto gameclient
if "%choice%"=="forwindows11" goto forwindows11
if "%choice%"=="0" exit

cls
echo [31mInvalid option. Please select a number between 0 and 38.[0m
timeout /t 2 >nul
cls
goto menu

:edge
cls
call :download "Microsoft Edge" "MicrosoftEdgeSetup.exe" "https://go.microsoft.com/fwlink/?linkid=2109047&Channel=Stable&language=en&consent=1" "/silent /install"
goto end

:brave
cls
if "%arch%"=="64" (
    set "url=https://github.com/brave/brave-browser/releases/download/v1.67.123/BraveBrowserStandaloneSetup.exe"
    set "fileName=BraveBrowserSetup64.exe"
) else (
    set "url=https://github.com/brave/brave-browser/releases/download/v1.67.123/BraveBrowserStandaloneSetup32.exe"
    set "fileName=BraveBrowserSetup32.exe"
)
call :download "Brave" "%fileName%" "%url%" "/silent /install"
goto end

:firefox
cls
call :download "Firefox" "FirefoxSetup.exe" "https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US&arch=%arch%" "/silent /install"
goto end

:chrome
cls
if "%arch%"=="64" (
    set "url=https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
    set "fileName=GoogleChromeStandaloneEnterprise64.msi"
) else (
    set "url=https://dl.google.com/chrome/install/googlechromestandaloneenterprise.msi"
    set "fileName=GoogleChromeStandaloneEnterprise.msi"
)
call :download "Google Chrome" "%fileName%" "%url%" "/quiet"
goto end

:opera
cls
if "%arch%"=="64" (
    set "url=https://download3.operacdn.com/pub/opera/desktop/76.0.4017.177/win/Opera_76.0.4017.177_Setup_x64.exe"
    set "fileName=OperaSetup_x64.exe"
) else (
    set "url=https://download3.operacdn.com/pub/opera/desktop/76.0.4017.177/win/Opera_76.0.4017.177_Setup.exe"
    set "fileName=OperaSetup.exe"
)
call :download "Opera" "%fileName%" "%url%" "/silent /install"
goto end

:duckduckgo
cls
set "browserName=DuckDuckGo"
set "fileName=DuckDuckGo.msixbundle"
set "url=https://staticcdn.duckduckgo.com/windows-desktop-browser/help-pages/DuckDuckGo.msixbundle"
set "frameworkUrl=https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"

:: Check if the framework is already installed
powershell -Command "Get-AppxPackage -Name 'Microsoft.VCLibs.x64.14.00' -ErrorAction SilentlyContinue" >nul 2>&1
if %errorlevel% neq 0 (
    curl -L -o "%downloadDir%\Microsoft.VCLibs.x64.14.00.Desktop.appx" "%frameworkUrl%"
    if %errorlevel% neq 0 (
        echo [31mError downloading framework. Exiting.[0m
        exit /B 1
    )
    powershell -Command "Add-AppxPackage -Path '%downloadDir%\Microsoft.VCLibs.x64.14.00.Desktop.appx'"
    if %errorlevel% neq 0 (
        echo Error installing framework. Exiting.
        exit /B 1
    )
)

echo [0m=====================================================================================================================
echo [32mInstalling %browserName%...[0m
echo =====================================================================================================================
curl -L -o "%downloadDir%\%fileName%" "%url%"
if %errorlevel% neq 0 (
    echo [31mError downloading %browserName%. Exiting.[0m
    exit /B 1
)

powershell -Command "Add-AppxPackage -Path '%downloadDir%\%fileName%'"
if %errorlevel% neq 0 (
    echo Error installing %browserName%. Exiting.
    exit /B 1
)

echo %browserName% has been installed.
goto menu

:librewolf
cls
call :download "Librewolf" "LibrewolfSetup.exe" "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/127.0.2-2/librewolf-127.0.2-2-windows-x86_64-setup.exe" "/S"
goto end

:exit
exit /B

:download
set "browserName=%~1"
set "fileName=%~2"
set "url=%~3"
set "silentArgs=%~4"

echo =====================================================================================================================
echo [32mInstalling %browserName%...[0m
echo =====================================================================================================================
curl -L -o "%downloadDir%\%fileName%" "%url%"
if %errorlevel% neq 0 (
    echo Error downloading %browserName%. Exiting.
    exit /B 1
)
start /wait "" "%downloadDir%\%fileName%" %silentArgs%
if %errorlevel% neq 0 (
    echo [31mError installing %browserName%. Exiting.[0m
    exit /B 1
)

:: Check if the browser is installed
set "checkCommand="
if "%browserName%"=="Microsoft Edge" (
    set "checkCommand=msedge"
) else if "%browserName%"=="Brave" (
    set "checkCommand=brave"
) else if "%browserName%"=="Firefox" (
    set "checkCommand=firefox"
) else if "%browserName%"=="Google Chrome" (
    set "checkCommand=chrome"
) else if "%browserName%"=="Opera" (
    set "checkCommand=opera"
) else if "%browserName%"=="DuckDuckGo" (
    set "checkCommand=duckduckgo"
) else if "%browserName%"=="Librewolf" (
    set "checkCommand=librewolf"
)

if not "%checkCommand%"=="" (
    powershell -Command "Get-Command '%checkCommand%' -ErrorAction SilentlyContinue" >nul 2>&1
    if %errorlevel% neq 0 (
        echo %browserName% installation failed. Exiting.
        exit /B 1
    )
    echo %browserName% has been installed.
) else (
    echo Could not verify the installation of %browserName%.
)

goto menu

:actionandnoti
cls
echo [0m=====================================================================================================================
echo [32mAction Center and Notification[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Enable
echo [32m[2][0m ^| Disable
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mPrint Spooler for Printer (services)[0m                 
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[3][0m ^| Enable ^| Service Auto
echo [32m[4][0m ^| Disable ^| Service Manual
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mWindows Hello (Biometrics)[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[5][0m ^| Enable
echo [32m[6][0m ^| Disable
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo.


set /p op=Type option:
if "%op%"=="1" goto op01
if "%op%"=="2" goto op02
if "%op%"=="3" sc config Spooler start=auto && net start Spooler && echo Print Spooler is enabled. && timeout /t 2 >nul && goto actionandnoti
if "%op%"=="4" sc config Spooler start=demand && net stop Spooler && echo Print Spooler is disabled. && timeout /t 2 >nul && goto actionandnoti
if "%op%"=="5" goto biomet1
if "%op%"=="6" goto biomet2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 6.[0m
timeout /t 2 >nul
cls
goto actionandnoti

:op01
cls
color 0b
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="14393" (
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "0" /f
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "0" /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f
REG ADD "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "0" /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WerSvc" /v "Start" /t REG_DWORD /d "3" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d "3" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\SENS" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "0" /f
cls
echo [31mRestart the computer for the changes to take effect 1607.[0m
timeout /t 5 >nul
cls
goto actionandnoti
)
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WerSvc" /v "Start" /t REG_DWORD /d "3" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d "3" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService_3c549" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\SENS" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "0" /f
timeout /t 1 >nul
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto actionandnoti

:op02
cls
color 0E
color 0b
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="14393" (
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f
REG ADD "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WerSvc" /v "Start" /t REG_DWORD /d "3" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d "4" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService_3c549" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\SENS" /v "Start" /t REG_DWORD /d "4" /f
REG ADD "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f
cls
echo [31mRestart the computer for the changes to take effect 1607.[0m
timeout /t 5 >nul
cls
goto actionandnoti
)
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WerSvc" /v "Start" /t REG_DWORD /d "3" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d "4" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService_3c549" /v "Start" /t REG_DWORD /d "2" /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\SENS" /v "Start" /t REG_DWORD /d "4" /f
REG ADD "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f
timeout /t 1 >nul
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto actionandnoti

:biomet1
cls
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d 1 /f >nul
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "2" /f >nul
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 1 >nul
goto actionandnoti

:biomet2
cls
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d 0 /f >nul
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "3" /f >nul
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 1 >nul
goto actionandnoti

:7zip
cls
@echo off
echo  =====================================================================================================================
echo  [32mInstalling 7-Zip...[0m
echo  =====================================================================================================================
timeout /t 1 >nul
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto 7zip64
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto 7zip32

:7zip64
cls
curl -L -o "%downloadDir%\7z-x64.exe" "https://7-zip.org/a/7z2407-x64.exe"
cls
echo =====================================================================================================================
echo [32mInstalling 7-Zip x64...[0m
echo =====================================================================================================================
start /wait "" "%downloadDir%\7z-x64.exe" /S
timeout /t 2 >nul
cls
goto menu

:7zip32
cls
curl -L -o "%downloadDir%\7z-x86.exe" "https://7-zip.org/a/7z2407.exe"
cls
echo =====================================================================================================================
echo [32mInstalling 7-Zip x86...[0m
echo =====================================================================================================================
start /wait "" "%downloadDir%\7z-x86.exe" /S
timeout /t 2 >nul
cls
goto menu

:op2
cls
echo [0m=====================================================================================================================
echo [32mClear Event Viewer Logs[0m                                 
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Cleanup now               
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto op22
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 1.[0m
timeout /t 2 >nul
cls

:op22
cls
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin
for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
cls

:do_clear
wevtutil.exe cl %1
echo All Event Logs have been cleared!
timeout /t 1 >nul
goto menu


:op3
color 0D
cls
echo [0m=====================================================================================================================
echo [32mCleanup Windows Store Cache and Delivery Optimization[0m  
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Cleanup now
echo =====================================================================================================================
echo.                                     
echo [32m[0][0m ^| Back to menu
echo.                                      

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto op33
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 1.[0m
timeout /t 2 >nul
cls
goto op3
cls

:op33
cls
echo [0m=====================================================================================================================
echo [32mDo Cleaning.[0m                                          
echo =====================================================================================================================
net stop DoSvc
timeout /t 5 >nul
cls
echo =====================================================================================================================
echo [32mDo Cleaning..[0m
echo =====================================================================================================================
takeown /f "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization" /r /d y >nul 2>nul
timeout /t 5 >nul
cls
echo =====================================================================================================================
echo [32mDo Cleaning...[0m                                           
echo =====================================================================================================================
rd /Q /S  "%WINDIR%\SoftwareDistribution\Download\" >nul 2>nul
rd /Q /S  "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\" >nul 2>nul
timeout /t 5 >nul
cls
echo =====================================================================================================================
echo [32mDo Cleaning....[0m                                           
echo =====================================================================================================================
rd /Q /S "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\" >nul 2>nul
rd /Q /S "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs\" >nul 2>nul
rd /Q /S "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\State\" >nul 2>nul
del /q /f /s "%TEMP%\*"
timeout /t 5 >nul
cls
echo =====================================================================================================================
echo [32mDo Cleaning.....[0m                                               
echo =====================================================================================================================
mkdir "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" >nul 2>nul
mkdir "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs" >nul 2>nul
mkdir "%WINDIR%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\State" >nul 2>nul
mkdir "%WINDIR%\SoftwareDistribution\Download\" >nul 2>nul
timeout /t 5 >nul
cls
echo =====================================================================================================================
echo [32mDo Cleaning......[0m  
echo =====================================================================================================================
sc config DoSvc "start=" "delayed-auto" >nul 2>nul
timeout /t 5 >nul
cls
echo =====================================================================================================================
echo [31mWindows Store Cache Updates ^/ Delivery Optimization have been cleared![0m
echo =====================================================================================================================
net start DoSvc >nul 2>nul
timeout /t 5 >nul
cls
goto menu

:op4
cls
set "scriptUrl=https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/All-In-One-Version/MAS_AIO-CRC32_31F7FD1E.cmd"
set "scriptName=MAS_AIO-CRC32_31F7FD1E.cmd"

:: Download the script
curl -L -o "%downloadDir%\%scriptName%" "%scriptUrl%"
if %errorlevel% neq 0 (
    echo Error downloading the script. Exiting.
    exit /B 1
)

:: Execute the downloaded script
call "%downloadDir%\%scriptName%"
goto menu

:op5
cls
echo [0m=====================================================================================================================
echo [32mHibernation / Fastboot / Sleep mode[0m                      
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Disable : hiberfil.sys[0m                               
echo [32m[2][0m ^| Enable  : hiberfil.sys[0m                                                            
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mSysmain / Superfetch[0m                                   
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[3][0m ^| Disable : Sysmain ^/ Superfetch[0m                       
echo [32m[4][0m ^| Enable  : Sysmain ^/ Superfetch[0m                      
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: for laptops users can enable hibernation if you want to using sleepmode/standby mode.
echo [31mNOTE: for HDD users enable Sysmain and hibernation for better boot up times and application.
echo [31mNOTE: A computer with 4GB of RAM would have a 3.5GB hiberfil.sys file on your Drives.[0m
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto op55
if "%op%"=="2" goto op56
if "%op%"=="3" goto super1
if "%op%"=="4" goto super2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 4.[0m
timeout /t 2 >nul
cls

goto op5
:op55
powercfg.exe /h off
powercfg.exe /hibernate off
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
goto op5
:op56
powercfg.exe /h on
powercfg.exe /hibernate on
timeout /t 5 >nul
powercfg /h /type full
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
goto op5
:super2
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\Sysmain" /v "Start" /t REG_DWORD /d "2" /f
net start Sysmain
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
goto op5
:super1
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\Sysmain" /v "Start" /t REG_DWORD /d "4" /f
net stop Sysmain
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
goto op5
echo off

:op6
cls
echo [0m=====================================================================================================================
echo [32mPaging file (virtual memory)[0m                             
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Disable : Pagefile.sys[0m                               
echo [32m[2][0m ^| Enable  : Pagefile.sys [set to 256MB][0m                
echo [32m[3][0m ^| Enable  : Pagefile.sys [set to 3.0GB] [0m               
echo [32m[4][0m ^| Enable  : Pagefile.sys [set to 4.0GB] [0m               
echo [32m[5][0m ^| Enable  : Pagefile.sys [set to 8.0GB][0m                
echo [32m[6][0m ^| Enable  : Pagefile.sys [set to 16.0GB] [0m              
echo [32m[7][0m ^| Enable  : Pagefile.sys [Default System managed][0m      
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: Default System managed ex. 4GB of ram Pagefile.sys be using 4GB of size on your drives.[0m
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu                                   
echo.

timeout /t 2 >nul
set /p op=Type option:
if "%op%"=="1" goto m1
if "%op%"=="2" goto m2
if "%op%"=="3" goto m3
if "%op%"=="4" goto m4
if "%op%"=="5" goto m5
if "%op%"=="6" goto m6
if "%op%"=="7" goto m7
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 7.[0m
timeout /t 2 >nul
cls
goto op6

:m1
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 1 1" /f
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
wmic pagefileset where name="C:\\pagefile.sys" delete
cls
echo [31mRestart the computer for the changes to take effect.[0m.
timeout /t 5 >nul
cls
goto menu

:m2
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 256 256" /f
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto menu

:m3
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 3000 3000" /f
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto menu

:m4
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 4000 4000" /f
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto menu

:m5
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 8000 8000" /f
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto menu

:m6
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 16000 16000" /f
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto menu

:m7
Reg Add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys 0 0" /f
cls
echo [31mRestart the computer for the changes to take effect.[0m
timeout /t 5 >nul
cls
goto menu
echo off

:op7
cls
echo [0m=====================================================================================================================
echo [32mRight click Take Ownership Menu[0m                          
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Add                                                  
echo [32m[2][0m ^| Removed                                                                                     
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu  
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto op77
if "%op%"=="2" goto op78
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto op7

:op77
cls
:: Add "Take Ownership" to context menu for files
Reg add "HKCR\*\shell\Take Ownership" /ve /t REG_SZ /d "Take Ownership" /f
Reg add "HKCR\*\shell\Take Ownership\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f
:: Add "Take Ownership" to context menu for directories
Reg add "HKCR\Directory\shell\Take Ownership" /ve /t REG_SZ /d "Take Ownership" /f
Reg add "HKCR\Directory\shell\Take Ownership\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r /d y && icacls \"%%1\" /grant administrators:F /t" /f
timeout /t 2 >nul
cls
goto op7

:op78
cls
:: Remove "Take Ownership" from context menu for files
Reg delete "HKCR\*\shell\Take Ownership" /f
:: Remove "Take Ownership" from context menu for directories
Reg delete "HKCR\Directory\shell\Take Ownership" /f
timeout /t 2 >nul
cls
goto op7

:op8
cls
echo [0m=====================================================================================================================
echo [32mStops Windows Updates until 2077 (for version 1703 or higher version)[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Pause Windows Update until 2077                     
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: This only to stop Windows Update (Cumulative update), [33mDrivers[0m/[33mMS Store[0m/[33mDefenders[0m [31mUpdate will works as normal.[0m
echo [31mNOTE: To Pause in Windows 11 ^> Click ^> Windows Update ^> Click Pause and press 1 to Pause until 2077.[0m
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo. 

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto pauseupdate1
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 1.[0m
timeout /t 2 >nul
cls
goto op8

:pauseupdate1
cls
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedFeatureStatus" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedQualityStatus" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX" /v "IsConvergedUpdateStackEnabled" /t REG_DWORD /d "1" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursEnd" /t REG_DWORD /d "17" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursStart" /t REG_DWORD /d "8" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "AllowAutoWindowsUpdateDownloadOverMeteredNetwork" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "DeferQualityUpdatesPeriodInDays" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "FlightCommitted" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "LastToastAction" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "UxOption" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "InsiderProgramEnabled" /t REG_DWORD /d "0" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PendingRebootStartTime" /t REG_SZ /d "2019-07-28T03:07:38Z" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdatesStartTime" /t REG_SZ /d "2019-07-28T10:38:56Z" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdatesStartTime" /t REG_SZ /d "2019-07-28T10:38:56Z" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseUpdatesExpiryTime" /t REG_SZ /d "2077-01-01T10:38:56Z" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdatesEndTime" /t REG_SZ /d "2077-01-01T10:38:56Z" /f
REG ADD "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdatesEndTime" /t REG_SZ /d "2077-01-01T10:38:56Z" /f

cls
echo [31mYour Windows Update is now paused until 2077!!!!!![0m
timeout /t 4 >nul
goto op8

:op9
cls
echo [0m=====================================================================================================================
echo [32mCOMPACT OS LZX (for SSD/NvME)[0m                           
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| COMPACT OS LZX [LZMS]                                
echo [32m[2][0m ^| COMPACT OS NORMAL
echo ---------------------------------------------------------------------------------------------------------------------                                    
echo [31mNOTE: HDD Highly Not recommended to Use LZX [0m     
echo ---------------------------------------------------------------------------------------------------------------------
echo Folder and files that will be compressed                      
echo [33m"C:\Program Files"[0m                                       
echo [33m"C:\Program Files (x86)"[0m                                 
echo [33m"C:\ProgramData"[0m                                         
echo [33m"C:\Users"[0m                                               
echo [33m"C:\Windows"[0m                                             
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: it take 5min~10min on SSD to finish (HDD 30m~1h)[0m   
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo.                                         

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto co1
if "%op%"=="2" goto co2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto op9

:co1
cls
echo [31mPlease, Don't Touch Anything while compressing in progress.[0m
timeout /t 8 >nul
cls
cd "C:\Windows"
compact /c /s /a /f /q /i /exe:LZX
timeout /t 5 >nul
cls
echo [31mCompression is complete! Restart the computer for the changes to take effect.
timeout /t 8 >nul
cls
cls
goto menu

:co2
cls
color 0b
echo [31mPlease, Don't Touch Anything while compressing in progress.[0m
timeout /t 8 >nul
cls
Compact.exe /CompactOS:always
timeout /t 3 >nul
cls
echo [31mCompression is complete! Restart the computer for the changes to take effect.[0m
timeout /t 8 >nul
cls
goto menu

:op10
cls
echo [0m=====================================================================================================================
echo [32mMicrosoft Store[0m        
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m  ^| Install Microsoft Store
echo [32m[2][0m  ^| Remove Microsoft Store                                                       
echo =====================================================================================================================
echo.
echo [32m[0][0m  ^| Back to menu  
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto store1
if "%op%"=="2" goto store2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto op10

:store1
set "downloadDir=%USERPROFILE%\Downloads"
setlocal enableextensions
if /i "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (set "arch=x64") else (set "arch=x86")
cd /d "%~dp0"

::Download files
curl -L -o "%downloadDir%\Microsoft.DesktopAppInstaller_1.6.29000.1000_neutral_~_8wekyb3d8bbwe.AppxBundle"  "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.DesktopAppInstaller_1.6.29000.1000_neutral_~_8wekyb3d8bbwe.AppxBundle"
curl -L -o "%downloadDir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Appx/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml"
curl -L -o "%downloadDir%\Microsoft.NET.Native.Framework.1.6_1.6.24903.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Framework.1.6_1.6.24903.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "%downloadDir%\Microsoft.NET.Native.Framework.1.6_1.6.24903.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Framework.1.6_1.6.24903.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "%downloadDir%\Microsoft.NET.Native.Runtime.1.6_1.6.24903.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Runtime.1.6_1.6.24903.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "%downloadDir%\Microsoft.NET.Native.Runtime.1.6_1.6.24903.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Runtime.1.6_1.6.24903.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "%downloadDir%\Microsoft.StorePurchaseApp_11808.1001.413.0_neutral_~_8wekyb3d8bbwe.AppxBundle" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.StorePurchaseApp_11808.1001.413.0_neutral_~_8wekyb3d8bbwe.AppxBundle"
curl -L -o "%downloadDir%\Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Appx/Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml"
curl -L -o "%downloadDir%\Microsoft.VCLibs.140.00_14.0.26706.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00_14.0.26706.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "%downloadDir%\Microsoft.VCLibs.140.00_14.0.26706.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00_14.0.26706.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "%downloadDir%\Microsoft.WindowsStore_11809.1001.713.0_neutral_~_8wekyb3d8bbwe.AppxBundle" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.WindowsStore_11809.1001.713.0_neutral_~_8wekyb3d8bbwe.AppxBundle"
curl -L -o "%downloadDir%\Microsoft.WindowsStore_8wekyb3d8bbwe.xml" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Appx/Microsoft.WindowsStore_8wekyb3d8bbwe.xml"
curl -L -o "%downloadDir%\Microsoft.XboxIdentityProvider_12.45.6001.0_neutral_~_8wekyb3d8bbwe.AppxBundle" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.XboxIdentityProvider_12.45.6001.0_neutral_~_8wekyb3d8bbwe.AppxBundle"
curl -L -o "%downloadDir%\Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Appx/Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml"

for /f %%i in ('dir /b "%downloadDir%\*WindowsStore*.appxbundle" 2^>nul') do set "Store=%%i"
for /f %%i in ('dir /b "%downloadDir%\*NET.Native.Framework*1.6*.appx" 2^>nul ^| find /i "x64"') do set "Framework6X64=%%i"
for /f %%i in ('dir /b "%downloadDir%\*NET.Native.Framework*1.6*.appx" 2^nul ^| find /i "x86"') do set "Framework6X86=%%i"
for /f %%i in ('dir /b "%downloadDir%\*NET.Native.Runtime*1.6*.appx" 2^>nul ^| find /i "x64"') do set "Runtime6X64=%%i"
for /f %%i in ('dir /b "%downloadDir%\*NET.Native.Runtime*1.6*.appx" 2^>nul ^| find /i "x86"') do set "Runtime6X86=%%i"
for /f %%i in ('dir /b "%downloadDir%\*VCLibs*140*.appx" 2^>nul ^| find /i "x64"') do set "VCLibsX64=%%i"
for /f %%i in ('dir /b "%downloadDir%\*VCLibs*140*.appx" 2^>nul ^| find /i "x86"') do set "VCLibsX86=%%i"

if exist "%downloadDir%\*StorePurchaseApp*.appxbundle" if exist "%downloadDir%\*StorePurchaseApp*.xml" (
    for /f %%i in ('dir /b "%downloadDir%\*StorePurchaseApp*.appxbundle" 2^>nul') do set "PurchaseApp=%%i"
)
if exist "%downloadDir%\*DesktopAppInstaller*.appxbundle" if exist "%downloadDir%\*DesktopAppInstaller*.xml" (
    for /f %%i in ('dir /b "%downloadDir%\*DesktopAppInstaller*.appxbundle" 2^>nul') do set "AppInstaller=%%i"
)
if exist "%downloadDir%\*XboxIdentityProvider*.appxbundle" if exist "%downloadDir%\*XboxIdentityProvider*.xml" (
    for /f %%i in ('dir /b "%downloadDir%\*XboxIdentityProvider*.appxbundle" 2^>nul') do set "XboxIdentity=%%i"
)

if /i %arch%==x64 (
    set "DepStore=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
    set "DepPurchase=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
    set "DepXbox=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
    set "DepInstaller=%VCLibsX64%,%VCLibsX86%"
) else (
    set "DepStore=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
    set "DepPurchase=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
    set "DepXbox=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
    set "DepInstaller=%VCLibsX86%"
)

set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass"

cls
echo [0m=====================================================================================================================
echo [32mInstalling Microsoft Store..[0m
echo =====================================================================================================================
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath "%downloadDir%\%Store%" -DependencyPackagePath "%downloadDir%\%DepStore%" -LicensePath "%downloadDir%\Microsoft.WindowsStore_8wekyb3d8bbwe.xml"
for %%i in (%DepStore%) do (
    %PScommand% Add-AppxPackage -Path "%downloadDir%\%%i"
)
%PScommand% Add-AppxPackage -Path "%downloadDir%\%Store%"

if defined PurchaseApp (
cls
echo [0m=====================================================================================================================
echo [32mInstalling Microsoft Store....[0m
echo =====================================================================================================================
    1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath "%downloadDir%\%PurchaseApp%" -DependencyPackagePath "%downloadDir%\%DepPurchase%" -LicensePath "%downloadDir%\Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml"
    %PScommand% Add-AppxPackage -Path "%downloadDir%\%PurchaseApp%"
)
if defined AppInstaller (
    cls
    echo [0m=====================================================================================================================
    echo [32mInstalling Microsoft Store......[0m
    echo =====================================================================================================================
    1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath "%downloadDir%\%AppInstaller%" -DependencyPackagePath "%downloadDir%\%DepInstaller%" -LicensePath "%downloadDir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml"
    %PScommand% Add-AppxPackage -Path "%downloadDir%\%AppInstaller%"
)
if defined XboxIdentity (
    cls
    echo [0m=====================================================================================================================
    echo [32mInstalling Microsoft Store.........[0m
    echo =====================================================================================================================
    1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath "%downloadDir%\%XboxIdentity%" -DependencyPackagePath "%downloadDir%\%DepXbox%" -LicensePath "%downloadDir%\Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml"
    %PScommand% Add-AppxPackage -Path "%downloadDir%\%XboxIdentity%"
)
goto menu

:store2
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "remove-store.ps1" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Remove-store.ps1" 
cls
powershell -ExecutionPolicy Bypass -File "remove-store.ps1"
cls
del /q /s "remove-store.ps1" >nul 2>nul
cls
echo [31mMicrosoft Store is completely removed.[0m
timeout /t 3 >nul
goto menu
cls
timeout /t 2 >nul
goto menu

:op11
cls
echo [0m=====================================================================================================================
echo [32mMicrosoft Xbox Game Bar[0m                               
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Download and Install                          
echo [32m[2][0m ^| Removed Xbox Game Bar                         
echo [32m[3][0m ^| Enable or Disable Xbox Game Bar                            
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu 
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto startdownload1
if "%op%"=="2" goto gamebar2
if "%op%"=="3" goto gamebar3
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 3.[0m
timeout /t 2 >nul
cls
goto op11

:startdownload1
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Microsoft.XboxGamingOverlay_7.124.7102.0_neutral_~_8wekyb3d8bbwe.AppxBundle" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.XboxGamingOverlay_7.124.7102.0_neutral_~_8wekyb3d8bbwe.AppxBundle" 
curl -L -o "Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.UI.Xaml.2.7_7.2208.15002.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.UI.Xaml.2.7_7.2208.15002.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.Appx"
cls
goto :install

:install
cls
Reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f 2>nul
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "1" /f 2>nul
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f 2>nul
cls
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set "XGAMEBAR=x86" || set "XGAMEBAR==x64"
if "%XGAMEBAR=%"=="x64" goto :xboxgamebarx64
if "%XGAMEBAR=%"=="x86" goto :xboxgamebarx86
cls

:xboxgamebarx64
cls
echo [0m=====================================================================================================================
echo [32mInstalling Xbox Game Bar....[0m
echo =====================================================================================================================
cls
cd "%USERPROFILE%\Downloads"
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.7_7.2208.15002.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.XboxGamingOverlay_7.124.7102.0_neutral_~_8wekyb3d8bbwe.AppxBundle
cls
net start BcastDVRUserService
cls
timeout /t 5 >nul
goto menu

:xboxgamebarx86
cls
echo [0m=====================================================================================================================
echo [32mInstalling Xbox Game Bar....[0m
echo =====================================================================================================================
cls
cd "%USERPROFILE%\Downloads"
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.7_7.2208.15002.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.XboxGamingOverlay_7.124.7102.0_neutral_~_8wekyb3d8bbwe.AppxBundle
cls
net start BcastDVRUserService
cls
timeout /t 5 >nul
goto menu

:gamebar2
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "remove-xboxgamebar.ps1" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/remove-xboxgamebar.ps1"  
cls
powershell -ExecutionPolicy Bypass -File "remove-xboxgamebar.ps1"
cls
del /q /s remove-xboxgamebar.ps1 >nul 2>nul
cls
Reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul
net stop BcastDVRUserService
cls
timeout /t 5 >nul
goto menu

:gamebar3
Reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f >nul
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "1" /f >nul
start ms-settings:gaming-gamebar
cls
timeout /t 5 >nul
goto op11

:netframework
cls
echo [0m=====================================================================================================================
echo [32mMicrosoft .NET Framework 2.x/3.x/4.x[0m                   
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Force to use .NET Framework 3/2 (Disable force .NetFramework 4.x)
echo [32m[2][0m ^| Force to use Latest .Net Framework 4.x (Enable force .NetFramework 4.x)                                       
echo [0m=====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto netframework1
if "%op%"=="2" goto netframework2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto netframework


:netframework1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework" /v "OnlyUseLatestCLR" /t REG_DWORD /d 0 /f >nul 2>nul
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework" /v "OnlyUseLatestCLR" /t REG_DWORD /d 0 /f >nul 2>nul
cls
echo [0m=====================================================================================================================
echo [31mForced to use .NET Framework 3/2![0m
echo [0m=====================================================================================================================
timeout /t 3 >nul
cls
goto netframework

:netframework2
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework" /v "OnlyUseLatestCLR" /t REG_DWORD /d 1 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework" /v "OnlyUseLatestCLR" /t REG_DWORD /d 1 /f
cls
echo [0m=====================================================================================================================
echo [31mForced to use Latest .NET Framework 4.x![0m
echo [0m=====================================================================================================================
timeout /t 3 >nul
cls
goto netframework

:onedrive0
cls
echo [0m=====================================================================================================================
echo [32mMicrosoft OneDrive[0m                                       
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| ^| Download and Install                                                                         
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu 
echo.

set /p op=Type option:
if "%op%"=="1" goto onedrive1
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 1.[0m
timeout /t 2 >nul
cls
goto onedrive0

:onedrive1
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "OneDriveSetup.exe" "https://oneclient.sfx.ms/Win/Prod/19.174.0902.0013/OneDriveSetup.exe" 
Reg Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 0 /f
cls
call OneDriveSetup.exe "/silent /install"
cls
goto menu

:zunemusic
cls
echo [0m=====================================================================================================================
echo [32mMicrosoft Music[0m                               
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Download and Install                                                                        
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu  
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto startdownload2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 1.[0m
timeout /t 2 >nul
cls
goto zunemusic

:startdownload2
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Microsoft.ZuneMusic_11.2406.13.0_neutral_~_8wekyb3d8bbwe.Msixbundle" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.ZuneMusic_11.2406.13.0_neutral_~_8wekyb3d8bbwe.Msixbundle"
curl -L -o "Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/blob/main/Appx/Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx"
timeout /t 8 >nul
cls
goto zunecheckxinstall

:zunecheckxinstall
cls
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto zunemusic2020x64
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto zunemusic2020x86

:zunemusic2020x64
cls
echo [0m=====================================================================================================================
echo [32mInstalling Microsoft Music....[0m
echo =====================================================================================================================
cls
cd "%USERPROFILE%\Downloads"
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.ZuneMusic_11.2406.13.0_neutral_~_8wekyb3d8bbwe.Msixbundle
cls
timeout /t 5 >nul
goto menu

:zunemusic2020x86
cls
echo [0m=====================================================================================================================
echo [32mInstalling Microsoft Music....[0m
echo =====================================================================================================================
cls
cd "%USERPROFILE%\Downloads"
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.ZuneMusic_11.2406.13.0_neutral_~_8wekyb3d8bbwe.Msixbundle
cls
timeout /t 5 >nul
goto menu

:movie
cls
echo [0m=====================================================================================================================
echo [32mMicrosoft Movies ^& TV[0m                               
echo ---------------------------------------------------------------------------------------------------------------------
echo Download Microsoft Movies ^& TV from Microsoft Store                                                                    
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu  
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto startdownload3
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 1.[0m
timeout /t 2 >nul
cls
goto zunemusic

:startdownload3
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Microsoft.ZuneVideo_2019.24061.10086.0_neutral_~_8wekyb3d8bbwe.AppxBundle" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.ZuneVideo_2019.24061.10086.0_neutral_~_8wekyb3d8bbwe.AppxBundle"
curl -L -o "Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx"
curl -L -o "Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/Appx/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx"
timeout /t 8 >nul
cls
goto movieinstall

:movieinstall
cls
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto moviex64
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto moviex86

:moviex64
cls
echo [0m=====================================================================================================================
echo [32mInstalling Movies ^& TV....[0m
echo =====================================================================================================================
cls
cd "%USERPROFILE%\Downloads"
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.ZuneVideo_2019.24061.10086.0_neutral_~_8wekyb3d8bbwe.AppxBundle
cls
timeout /t 5 >nul
goto menu

:moviex86
cls
echo [0m=====================================================================================================================
echo [32mInstalling Movies ^& TV....[0m
echo =====================================================================================================================
cls
cd "%USERPROFILE%\Downloads"
cls
Powershell Add-AppxPackage -Path Microsoft.UI.Xaml.2.8_8.2310.30001.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00_14.0.33519.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x86__8wekyb3d8bbwe.Appx
cls
Powershell Add-AppxPackage -Path Microsoft.ZuneVideo_2019.24061.10086.0_neutral_~_8wekyb3d8bbwe.AppxBundle
cls
timeout /t 5 >nul
goto menu

:opwin11
cls
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22000" goto forwindows11
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22610" goto forwindows11
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22621" goto forwindows11
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22631" goto forwindows11
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="26100" goto forwindows11
cls

:recheck
FOR /F "tokens=1*" %%A IN ('wmic os get caption ^| find /i "Windows 11"') do goto nowin11 && goto yeswin11

:yeswin11
cls
echo [31mWindows 11 only[0m && timeout /t 4 >nul && goto menu

:nowin11
cls
goto forwindows11

:forwindows11
cls
echo [0m=====================================================================================================================
echo [32mOptions for Windows 11[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Restore Old/New Right click Context Menu
echo [32m[2][0m ^| Right click startmenu ^| Powershell ^| CMD
echo [32m[3][0m ^| Custom Patcher Taskbar/Explorer for Windows 11
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu[0m
echo.


timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto win1101
::if "%op%"=="2" goto win1107
if "%op%"=="2" goto win1108
if "%op%"=="3" goto win1112
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 4.[0m
timeout /t 2 >nul
cls
goto :opwin11

:win1101
cls
echo [0m=====================================================================================================================
echo [32mRestore Old/New Right click Context Menu[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Restore Old Right click Context Menu
echo [32m[2][0m ^| Restore New Right click Context Menu
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto win11context01
if "%op%"=="2" goto win11context02
if "%op%"=="0" goto forwindows11

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto :win1101

:win11context01
cls
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve 2>nul >nul
taskkill /F /IM explorer.exe >nul 2>nul
timeout /t 2 >nul
start explorer
goto win1101

:win11context02
cls
reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f 2>nul >nul
taskkill /F /IM explorer.exe >nul 2>nul
timeout /t 2 >nul
start explorer
goto win1101

:win1107
cls
echo [0m=====================================================================================================================
echo [32mExplorer Ribbon Old/Modern[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Restore Old Explorer Ribbon
echo [32m[2][0m ^| Restore New Explorer Ribbon
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto win11ribbon01
if "%op%"=="2" goto win11ribbon02
if "%op%"=="0" goto forwindows11

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto :win1107

:win11ribbon01
cls
reg.exe add "HKCU\Software\Classes\CLSID\{d93ed569-3b3e-4bff-8355-3c44f6a52bb5}\InprocServer32" /f /ve 2>nul >nul
taskkill /F /IM explorer.exe >nul 2>nul
timeout /t 2 >nul
start explorer
cls
goto win1107

:win11ribbon02
cls
reg.exe delete "HKCU\Software\Classes\CLSID\{d93ed569-3b3e-4bff-8355-3c44f6a52bb5}" /f 2>nul >nul
taskkill /F /IM explorer.exe >nul 2>nul
timeout /t 2 >nul
start explorer
cls
goto win1107

:win1108
cls
echo [0m=====================================================================================================================
echo [32mRight click startmenu ^| Powershell ^| CMD[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mPowershell (Admin)[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Enable
echo [32m[2][0m ^| Disable
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mCMD (Admin)[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[3][0m ^| Enable
echo [32m[4][0m ^| Disable
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto win11o3
if "%op%"=="2" goto win11o4
if "%op%"=="3" goto win11o5
if "%op%"=="4" goto win11o6
if "%op%"=="0" goto forwindows11

cls
echo [31mInvalid option. Please select a number between 0 and 4.[0m
timeout /t 2 >nul
cls
goto :win1108

:win11o3
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Add_PowerShell.reg" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Add_PowerShell.reg"
regedit /s "Add_PowerShell.reg" 
cls
goto win1108

:win11o4
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Remove_PowerShell.reg" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Remove_PowerShell.reg"
regedit /s "Remove_PowerShell.reg" 
cls
goto win1108

:win11o5
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Add_CMD.reg" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Add_CMD.reg"
regedit /s "Add_CMD.reg"  
goto win1108

:win11o6
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "Remove_CMD.reg" "https://raw.githubusercontent.com/MatiDEV-PL/Open-ToolBox/main/Remove_CMD.reg"
regedit /s "Remove_CMD.reg"  
goto win1108

:win1112
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22610" cls && echo Not Support for Windows 11 22H2 Version. && timeout /t 5 >nul && goto forwindows11
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22621" cls && echo Not Support for Windows 11 22H2 Version. && timeout /t 5 >nul && goto forwindows11
cls
echo [0m=====================================================================================================================
echo [32mExplorer Patcher for Windows 11[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Download Explorer Patcher
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[2][0m ^| Download WebView2 (required to use Weather on Taskbar)
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: To use Explorer Patcher ^| Right Click on Taskbar ^|  Properties ^| for Options.[0m
echo [31mNOTE: Please re-install again if explorer not showing.[0m
echo [31mNOTE: Weather on taskbar is now support on latest version. (WebView2 is required)[0m
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back
echo.


timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto win11taskbar3
if "%op%"=="2" goto widgetswin1103
if "%op%"=="0" goto forwindows11

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto :win1112

:win11taskbar3
cd "%USERPROFILE%\Downloads"
curl -L -o "random.exe" "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe"
cls
goto win11intaskbarXX

:win11intaskbarXX
cls
cd "%USERPROFILE%\Downloads"
echo [0m=====================================================================================================================
echo [32mInstalling..[0m
echo =====================================================================================================================
random.exe >nul
cls
echo [0m=====================================================================================================================
echo [32mInstalling....[0m
echo [0m=====================================================================================================================
Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d "0" /f >nul
goto :win1112

:widgetswin1103
cls
if "%arch%"=="64" (
    curl -L -o "%downloadDir%\MicrosoftEdgeWebview2Setup-x64.exe" "https://go.microsoft.com/fwlink/?linkid=2124701"
    cd "%downloadDir%"
    MicrosoftEdgeWebview2Setup-x64.exe
) else (
    curl -L -o "%downloadDir%\MicrosoftEdgeWebview2Setup-x86.exe" "https://go.microsoft.com/fwlink/?linkid=2099617"
    cd "%downloadDir%"
    icrosoftEdgeWebview2Setup-x86.exe
)
timeout /t 1 >nul
cls
goto :win1112

:op16
cls
echo [0m=====================================================================================================================
echo [32mVisual C++ Redistributables AIO x86 x64[0m                
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Microsoft Visual C++ 2002-2003-2005-2008-2010-2012-2013-2022 (AIO)
echo [32m[2][0m ^| Microsoft Visual C++ 2015-2017-2019 [33m14.29.30133.0[0m [31mx64-x86[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: If of some software cannot be install or running please try Option 2.[0m
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu 
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto vi1
if "%op%"=="2" goto vi2
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto op16

:vi2
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "vc_redist.x64.exe" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/vc_redist.x64.exe" 
curl -L -o "vc_redist.x86.exe" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/vc_redist.x86.exe" 
cls

:installvi2
cls
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto vi2x64
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto vi2x32
cls

:vi2x64
cd "%USERPROFILE%\Downloads"
echo [0m=====================================================================================================================
echo [32mInstalling....[0m
echo [0m=====================================================================================================================
timeout /t 2 >nul
vc_redist.x64.exe >nul
cls
goto menu

:vi2x32
cd "%USERPROFILE%\Downloads"
echo [0m=====================================================================================================================
echo [32mInstalling....[0m
echo [0m=====================================================================================================================
timeout /t 2 >nul
vc_redist.x86.exe >nul
cls
goto menu

:vi1
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "VisualCppRedist_AIO_x86_x64.exe" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/VisualCppRedist_AIO_x86_x64.exe"
cls
echo [0m=====================================================================================================================
echo [32mInstalling....[0m
echo [0m=====================================================================================================================
VisualCppRedist_AIO_x86_x64.exe >nul
cls 
goto menu

:op17
cls
echo [0m=====================================================================================================================
echo [32mDirectX Runtime Web Installer[0m                            
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Online Installer      
echo [32m[2][0m ^| Offline Installer                                                                     
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu  
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto dx1
if "%op%"=="2" goto dxoffline
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a number between 0 and 2.[0m
timeout /t 2 >nul
cls
goto op17

:dx1
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "dxwebsetup.exe" "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"
cls
echo [0m=====================================================================================================================
echo [32mInstalling....[0m
echo [0m=====================================================================================================================
dxwebsetup.exe >nul
cls
timeout /t 1 >nul
goto menu

:dxoffline
cls
cd "%USERPROFILE%\Downloads"
curl -L -o "7z1900-extra.zip" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/7z1900-extra.zip"
curl -L -o "directX_offline.exe" "https://github.com/MatiDEV-PL/Open-ToolBox/raw/main/directx_Jun2010_redist.exe" 
timeout /t 5 >nul
cls
powershell -command "Expand-Archive 7z1900-extra.zip"
7z1900-extra\7za x directX_offline.exe -aoa -o"directX_offline" >nul
cd "directX_offline"
cls
echo [0m=====================================================================================================================
echo [32mInstalling....[0m
echo [0m=====================================================================================================================
DXSETUP.exe >nul
timeout /t 1 >nul
cls
goto menu

:opdisk
cls
echo =====================================================================================================================
echo [32mMicrosoft Disk Benchmark Test (Write/Read) [0m              
echo ---------------------------------------------------------------------------------------------------------------------
echo Type[0m [33mC[0m, [33mD[0m, [33mE[0m, to [33mZ[0m that you want to test[0m             
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu  
echo.

timeout /t 1 >nul
set /p op=Benchmark Drive : 
if "%op%"=="C" goto diskc
if "%op%"=="c" goto diskc
if "%op%"=="D" goto diskd
if "%op%"=="d" goto diskd
if "%op%"=="E" goto diske
if "%op%"=="e" goto diske
if "%op%"=="F" goto diskf
if "%op%"=="f" goto diskf
if "%op%"=="G" goto diskg
if "%op%"=="g" goto diskg
if "%op%"=="H" goto diskh
if "%op%"=="h" goto diskh
if "%op%"=="I" goto diski
if "%op%"=="i" goto diski
if "%op%"=="J" goto diskj
if "%op%"=="j" goto diskj
if "%op%"=="K" goto diskk
if "%op%"=="k" goto diskk
if "%op%"=="L" goto diskl
if "%op%"=="l" goto diskl
if "%op%"=="M" goto diskm
if "%op%"=="m" goto diskm
if "%op%"=="N" goto diskn
if "%op%"=="n" goto diskn
if "%op%"=="O" goto disko
if "%op%"=="o" goto disko
if "%op%"=="P" goto diskp
if "%op%"=="p" goto diskp
if "%op%"=="Q" goto diskq
if "%op%"=="q" goto diskq
if "%op%"=="R" goto diskr
if "%op%"=="r" goto diskr
if "%op%"=="S" goto disks
if "%op%"=="s" goto disks
if "%op%"=="T" goto diskt
if "%op%"=="t" goto diskt
if "%op%"=="U" goto disku
if "%op%"=="u" goto disku
if "%op%"=="V" goto diskv
if "%op%"=="v" goto diskv
if "%op%"=="W" goto diskw
if "%op%"=="w" goto diskw
if "%op%"=="X" goto diskx
if "%op%"=="x" goto diskx
if "%op%"=="Y" goto disky
if "%op%"=="y" goto disky
if "%op%"=="Z" goto diskz
if "%op%"=="z" goto diskz
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a letter between C and Z.[0m
timeout /t 2 >nul
cls
goto opdisk

:diskc
cls
echo BENCHMARK DRIVE [33mC[0m:
echo =====================================================================================================================
winsat disk -drive C
echo =====================================================================================================================
pause
goto opdisk

:diskd
cls
echo BENCHMARK DRIVE [33mD[0m:
echo =====================================================================================================================
powershell winsat disk -drive D
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diske
cls
echo BENCHMARK DRIVE [33mE[0m:
echo =====================================================================================================================
winsat disk -drive E
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskf
cls
echo BENCHMARK DRIVE [33mF[0m:
echo =====================================================================================================================
winsat disk -drive F
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskg
cls
echo BENCHMARK DRIVE [33mG[0m:
echo =====================================================================================================================
winsat disk -drive G
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskh
cls
echo BENCHMARK DRIVE [33mH[0m:
echo =====================================================================================================================
winsat disk -drive H
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diski
cls
echo BENCHMARK DRIVE [33mI[0m:
echo =====================================================================================================================
winsat disk -drive I
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskj
cls
echo BENCHMARK DRIVE [33mJ[0m:
echo =====================================================================================================================
winsat disk -drive J
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskk
cls
echo BENCHMARK DRIVE [33mK[0m:
echo =====================================================================================================================
winsat disk -drive K
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskl
cls
echo BENCHMARK DRIVE [33mL[0m:
echo =====================================================================================================================
winsat disk -drive L
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskm
cls
echo BENCHMARK DRIVE [33mM[0m:
echo =====================================================================================================================
winsat disk -drive M
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskn
cls
echo BENCHMARK DRIVE [33mN[0m:
echo =====================================================================================================================
winsat disk -drive N
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:disko
cls
echo BENCHMARK DRIVE [33mO[0m:
echo =====================================================================================================================
winsat disk -drive O
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskp
cls
echo BENCHMARK DRIVE [33mP[0m:
echo =====================================================================================================================
winsat disk -drive P
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskq
cls
echo BENCHMARK DRIVE [33mQ[0m:
echo =====================================================================================================================
winsat disk -drive Q
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskr
cls
echo BENCHMARK DRIVE [33mR[0m:
echo =====================================================================================================================
winsat disk -drive R
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:disks
cls
echo BENCHMARK DRIVE [33mS[0m:
echo =====================================================================================================================
winsat disk -drive S
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskt
cls
echo BENCHMARK DRIVE [33mT[0m:
echo =====================================================================================================================
winsat disk -drive T
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:disku
cls
echo BENCHMARK DRIVE [33mU[0m:
echo =====================================================================================================================
winsat disk -drive U
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskv
cls
echo BENCHMARK DRIVE [33mV[0m:
echo =====================================================================================================================
winsat disk -drive V
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskw
cls
echo BENCHMARK DRIVE [33mW[0m:
echo =====================================================================================================================
winsat disk -drive W
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskx
cls
echo BENCHMARK DRIVE [33mX[0m:
echo =====================================================================================================================
winsat disk -drive X
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:disky
cls
echo BENCHMARK DRIVE [33mY[0m:
echo =====================================================================================================================
winsat disk -drive Y
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:diskz
cls
echo BENCHMARK DRIVE [33mZ[0m:
echo =====================================================================================================================
winsat disk -drive Z
timeout /t 1 >nul
echo =====================================================================================================================
pause
goto opdisk

:pers
cls
echo =====================================================================================================================
echo [32mPersonalization[0m                                                           
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mExplorer UI Ribbon[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Enable Explorer UI Ribbon                        
echo [32m[2][0m ^| Disable Explorer UI Ribbon
echo ---------------------------------------------------------------------------------------------------------------------         
echo [31mNOTE: Do not disable Ribbon if your software Use Ribbon ex. (Office/Paint/etc etc)[0m         
echo ---------------------------------------------------------------------------------------------------------------------
echo [32mTransparency Taskbar[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[3][0m ^| Enable Transparency Taskbar                      
echo [32m[4][0m ^| Disable Transparency Taskbar                                                           
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back to menu
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto pers1
if "%op%"=="2" goto pers2
if "%op%"=="3" goto pers3
if "%op%"=="4" goto pers4
if "%op%"=="0" goto menu

cls
echo [31mInvalid option. Please select a letter between 0 and 4.[0m
timeout /t 2 >nul
cls
goto pers

:pers1
cls
takeown /F "%systemdrive%\Windows\System32\UIRibbon.dll"
takeown /F "%systemdrive%\Windows\System32\*UIRibbon*"
ICACLS "%systemdrive%\Windows\System32\*UIRibbon*" /grant administrators:F
cls
ren %systemdrive%\Windows\System32\UIRibbon.dll.bak UIRibbon.dll
cls
taskkill /F /IM explorer.exe
start explorer
cls
echo [0m=====================================================================================================================
echo [32mExplorer UI Ribbon is Enable!
echo [0m=====================================================================================================================
timeout /t 2 >nul
cls
goto pers

:pers2
cls
takeown /F "%systemdrive%\Windows\System32\UIRibbon.dll"
takeown /F "%systemdrive%\Windows\System32\*UIRibbon*"
ICACLS "%systemdrive%\Windows\System32\*UIRibbon*" /grant administrators:F
cls
ren %systemdrive%\Windows\System32\UIRibbon.dll UIRibbon.dll.bak
cls
taskkill /F /IM explorer.exe
start explorer
cls
echo [0m=====================================================================================================================
echo [32mExplorer UI Ribbon is Disable![0m
echo [0m=====================================================================================================================
timeout /t 2 >nul
cls
goto pers

:pers3
cls
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d "1" /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f
cls
taskkill /F /IM explorer.exe
start explorer
cls
echo [0m=====================================================================================================================
echo [32Transparent Taskbar is Enable![0m
echo [0m=====================================================================================================================
timeout /t 2 >nul
cls
goto pers

:pers4
cls
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "UseOLEDTaskbarTransparency" /t REG_DWORD /d "0" /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f
cls
taskkill /F /IM explorer.exe
start explorer
cls
echo [0m=====================================================================================================================
echo [32Transparent Taskbar is Disable![0m
echo [0m=====================================================================================================================
timeout /t 2 >nul
cls
goto pers

:gameclient
cls
echo =====================================================================================================================
echo [32mGame Client[0m                               
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Steam          
echo [32m[2][0m ^| Origin         
echo [32m[3][0m ^| Ubisoft Connect
echo [32m[4][0m ^| GOG GALAXY 2.0 
echo [32m[5][0m ^| Epic Games     
echo [32m[6][0m ^| Battle.net     
echo [32m[7][0m ^| itch.io        
echo [32m[8][0m ^| Bethesda Net   
echo [32m[9][0m ^| EA App         
echo [32m[10][0m ^| Xbox App [31m(For Windows 10 20H2/21H1 or higher)
echo [32m[11][0m ^| Rockstar Games Launcher      
echo [32m[12][0m ^| Amazon Games App   
echo ---------------------------------------------------------------------------------------------------------------------
echo [31mNOTE: Please install[0m [33m"Visual C++ Redistributables AIO"[31m before Installing game clients.[0m
echo [31mNOTE: Required Internet for download.[0m                                                         
echo =====================================================================================================================
echo.
echo [0] %White%Back to menu
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto gameclient1
if "%op%"=="2" goto gameclient2
if "%op%"=="3" goto gameclient3
if "%op%"=="4" goto gameclient4
if "%op%"=="5" goto gameclient5
if "%op%"=="6" goto gameclient6
if "%op%"=="7" goto gameclient7
if "%op%"=="8" goto gameclient8
if "%op%"=="9" goto gameclient9
if "%op%"=="10" goto gameclient10xbox
if "%op%"=="11" goto gameclient11
if "%op%"=="12" goto gameclient12
if "%op%"=="0" goto menu

cls
echo Wrong numbers please try again...
timeout /t 2 >nul
cls
goto gameclient

:gameclient10xbox
cls
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "var=%%b" >nul
if "%var%"=="22000" goto winxboxappnope
cls
echo =====================================================================================================================
echo [32mXbox App For Windows 10 20H2/21H1 or higher version.[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [31m(NOTE: Please install Microsoft Store before install Xbox App, To install Microsoft Store go to Option 10 > 1)
echo (NOTE: If Dependencies is missing goto Xbox App > Settings > General > Dependencies > Install)
echo (NOTE: Some Game Xbox App Cannot be works on Administrator Account, please using Xbox App on non-Administrator User)
echo (NOTE: To using Latest Xbox App OS Build 1904x.1055 or Higher OS Build is required)[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| Install
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back          
echo.

timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto gameclient10
if "%op%"=="0" goto gameclient

cls
echo Wrong numbers please try again...
timeout /t 2 >nul
cls
goto gameclient

:winxboxappnope
cls
echo For Windows 11 user, Xbox app cannot be running on Administrator account,
echo please use Xbox app on non-administrator user.
echo.
echo For Windows 11 user, Please download xbox app from Microsoft store.
timeout /t 15 >nul
goto menu

:gameclient1
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "SteamSetup.exe" "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe" 
timeout /t 5 >nul
cls
echo Installing... please wait..
SteamSetup.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient2
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "OriginThinSetup.exe" "https://origin-a.akamaihd.net/Origin-Client-Download/origin/live/OriginThinSetup.exe" 
timeout /t 5 >nul
cls
echo Installing... please wait..
OriginThinSetup.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient3
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "UbisoftConnectInstaller.exe" "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe" 
cls
echo Installing... please wait..
UbisoftConnectInstaller.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient4
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "GOG_Galaxy_2.0.exe" "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe" 
cls
echo Installing... please wait..
GOG_Galaxy_2.0.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient5
cls
cd "%USERPROFILE%\Downloads"
cls
curl "EpicInstaller-10.19.2.msi" "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi"
cls
echo Installing... please wait..
EpicInstaller-10.19.2.msi
timeout /t 3 >nul
cls
goto gameclient

:gameclient6
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "Battle-Setup.exe" "https://blizz.ly/3hzFDqN" 
cls
echo Installing... please wait..
Battle-Setup.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient7
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "itch-setup.exe" "https://itch.io/app/download"
cls
echo Installing... please wait..
itch-setup.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient8
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "BethesdaNetLauncher_Setup.exe" "https://download.cdp.bethesda.net/BethesdaNetLauncher_Setup.exe" 
cls
echo Installing... please wait..
BethesdaNetLauncher_Setup.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient9
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "EADesktopInstaller.exe" "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EADesktopInstaller.exe" 
cls
echo Installing... please wait..
EADesktopInstaller.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient10
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "XboxInstaller.exe" "https://assets.xbox.com/installer/20190628.8/anycpu/XboxInstaller.exe"
cls
echo Installing... please wait..
start XboxInstaller.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient11
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "Rockstar-Games-Launcher.exe" "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe" 
cls
echo Installing... please wait..
Rockstar-Games-Launcher.exe
timeout /t 3 >nul
cls
goto gameclient

:gameclient12
cls
cd "%USERPROFILE%\Downloads"
cls
curl -L -o "AmazonGamesSetup.exe" "https://download.amazongames.com/AmazonGamesSetup.exe" 
cls
echo Installing... please wait..
AmazonGamesSetup.exe
timeout /t 3 >nul
cls
goto gameclient

:vlc
cls
@echo off
echo  =====================================================================================================================
echo  [32mInstalling VLC...[0m
echo  =====================================================================================================================
timeout /t 1 >nul
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto vlc64
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto vlc32

:vlc64
cls
curl -L -o "%downloadDir%\7z-x64.exe" "https://7-zip.org/a/7z2407-x64.exe"
cls
echo =====================================================================================================================
echo [32mInstalling VLC x64...[0m
echo =====================================================================================================================
start /wait "" "%downloadDir%\VLC-x64.exe" /S
timeout /t 2 >nul
cls
goto menu

:vlc32
cls
curl -L -o "%downloadDir%\VLC-x86.exe" "https://get.videolan.org/vlc/3.0.21/win32/vlc-3.0.21-win32.exe"
cls
echo =====================================================================================================================
echo [32mInstalling VLC x86...[0m
echo =====================================================================================================================
start /wait "" "%downloadDir%\VLC-x86.exe" /S
timeout /t 2 >nul
cls
goto menu

:notepad
cls
@echo off
echo  =====================================================================================================================
echo  [32mInstalling Notepad++...[0m
echo  =====================================================================================================================
timeout /t 1 >nul
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto notepad64
if "%PROCESSOR_ARCHITECTURE%"=="x86" goto notepad32

:notepad64
cls
curl -L -o "%downloadDir%\npp-x64.exe" "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.Installer.x64.exe"
cls
echo =====================================================================================================================
echo [32mInstalling Notepad++ x64...[0m
echo =====================================================================================================================
start /wait "" "%downloadDir%\npp-x64.exe" /S
timeout /t 2 >nul
cls
goto menu

:notepad32
cls
curl -L -o "%downloadDir%\npp-x86.exe" "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.Installer.exe"
cls
echo =====================================================================================================================
echo [32mInstalling Notepad++ x86...[0m
echo =====================================================================================================================
start /wait "" "%downloadDir%\npp-x86.exe" /S
timeout /t 2 >nul
cls
goto menu

:defender
cls
echo =====================================================================================================================
echo [32mWindows Defender Remover[0m
echo ---------------------------------------------------------------------------------------------------------------------
echo [32m[1][0m ^| [31mYes (Remove Windows Defender)[0m
echo =====================================================================================================================
echo.
echo [32m[0][0m ^| Back          
echo.
timeout /t 1 >nul
set /p op=Type option:
if "%op%"=="1" goto defender1
if "%op%"=="0" goto menu

cls
echo Wrong numbers please try again...
timeout /t 2 >nul
cls
goto defender

:defender1
cls
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true; Add-MpPreference -ExclusionPath '%downloadDir%'" >nul 2>&1
@echo off
cls
echo  =====================================================================================================================
echo  [32mDownloading Windows Defender...[0m
echo  =====================================================================================================================
timeout /t 1 >nul
cd "%downloadDir%"
curl -L -o "DefenderRemover.exe" "https://github.com/ionuttbara/windows-defender-remover/releases/download/release_def_12_8/DefenderRemover.exe"
cls
powershell -Command "Add-MpPreference -ExclusionPath '%downloadDir%\DefenderRemover.exe'" >nul 2>&1
start /wait "" "%downloadDir%\DefenderRemover.exe" /S
powershell -Command "Remove-MpPreference -ExclusionPath '%downloadDir%\DefenderRemover.exe'" >nul 2>&1

cls
goto menu

:end
echo Done.
pause
