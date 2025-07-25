Naprawa błędu Windows Update 

Masz w Windows Update jedną, wkurzającą paczkę, która wciąż wraca i ma status „Install error …" U mnie tak właśnie wisiała jedna paczka z kodem błędu – 0x80070103”
Spokojnie. Poniżej pokaże Ci jak w prosty sposób za pomocą gotowego  skryptu  PowerShell,mozna to posprzątać.

Co to w ogóle za błąd 0x80070103?
Najczęściej to sterownik, który:
	• już masz w nowszej wersji, albo
	• nie pasuje do twojego sprzętu.
Windows próbuje go wgrać,ale się  nie udaje się, i tak w kółko.

Co zrobimy?
	1. Zatrzymamy usługi Windows Update.
	2. Wyczyścimy wpisy w rejestrze, które mówią „hej, mam coś do dokończenia”.
	3. Usuniemy pliki z kolejki aktualizacji.
	4. Włączymy wszystko z powrotem.
	5. Zrestartujesz komputer.
Po tym Windows zwykle „zapomina” o złej paczce.

Zanim zaczniesz
	• Uruchom PowerShell jako Administrator.
Wyszukaj „PowerShell”, kliknij prawym → Uruchom jako administrator.
	• Zapisz skrypt do pliku, np. fix-windowsupdate.ps1.

 👉 Gotowy skrypt , znajdziesz również w moim repo na Github: tutaj

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

Ile to trwa?
Zwykle 30–90 sekund. Najdłużej trwa czyszczenie folderów, jeśli masz dużo plików.

Zablokuj sterowniki z Windows Update

Jeśli nie chcesz, by Windows w ogóle ciągnął sterowniki przez Windows Update:

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" `
  -Name ExcludeWUDriversInQualityUpdate -Value 1 -PropertyType DWord -Force
(Wrócić do domyślnego możesz ustawiając wartość na 0 lub usuwając ten wpis.)

Najczęstsze pytania (FAQ)
❓ Czy ten skrypt coś popsuje?
Nie powinien. On tylko czyści kolejkę aktualizacji i „flagi” w rejestrze, które mówią systemowi, że coś jest do dokończenia.
❓ Zniknie historia aktualizacji?
Tak, część historii może zniknąć z widoku Windows Update. To normalne po czyszczeniu.
❓ Muszę robić restart?
Tak. To ważne, żeby system poukładał wszystko na nowo.
❓ Czy muszę uruchamiać PowerShell jako administrator?
Tak. Bez tego skrypt nie ma dostępu do usług i rejestru.

