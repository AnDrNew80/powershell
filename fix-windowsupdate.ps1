# Naprawa błędu windows update – z działającym paskiem postępu

$script:step = 1
$totalSteps = 7

function Show-Step($msg) {
    Write-Host "[$script:step/$totalSteps] $msg"
    $script:step++
    Start-Sleep -Seconds 1
}

# 1. Zatrzymaj usługi
Show-Step "Zatrzymywanie usług Windows Update..."
Stop-Service wuauserv -Force
Stop-Service cryptSvc -Force
Stop-Service bits -Force
Stop-Service msiserver -Force

# 2. Usuń wpisy rejestru Pending Updates
Show-Step "Usuwanie wpisów rejestru oczekujących aktualizacji..."
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations" -ErrorAction SilentlyContinue

# 3. Usuń pending.xml jeśli istnieje
Show-Step "Usuwanie pliku pending.xml..."
$pendingXml = "C:\Windows\WinSxS\pending.xml"
if (Test-Path $pendingXml) {
    Remove-Item $pendingXml -Force
    Write-Host "Usunięto $pendingXml"
}

# 4. Czyszczenie SoftwareDistribution
Show-Step "Czyszczenie folderu SoftwareDistribution..."
Remove-Item -Recurse -Force "C:\Windows\SoftwareDistribution\*" -ErrorAction SilentlyContinue

# 5. Czyszczenie catroot2
Show-Step "Czyszczenie folderu catroot2..."
Remove-Item -Recurse -Force "C:\Windows\System32\catroot2\*" -ErrorAction SilentlyContinue

# 6. Uruchom ponownie usługi
Show-Step "Uruchamianie usług Windows Update..."
Start-Service wuauserv
Start-Service cryptSvc
Start-Service bits
Start-Service msiserver

# 7. Zakończ
Show-Step "Zakończono czyszczenie! Zrestartuj komputer, aby zakończyć operację."

Write-Host "`n✅ Gotowe. Uruchom ponownie komputer, aby Windows Update się odświeżył." -ForegroundColor Green

