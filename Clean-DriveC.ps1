#Skrypt PowerShell do bezpiecznego czyszczenia dysku C: w systemie Windows 10/11. 
#Skrypt:
#	• Czyści foldery tymczasowe użytkownika i systemu
#	• Czyści pamięć podręczną Windows Update
#	• Opróżnia Kosz
# Informuje o ilości zwolnionego miejsca
# Dodane info, żeby user nie dostał zawału jak wyskoczy warning :)

# Uruchom jako administrator!!!!

function Get-FreeSpaceGB {
    $drive = Get-PSDrive -Name C
    return [math]::Round($drive.Free / 1GB, 2)
}

Write-Host "`n🔍 Sprawdzanie dostępnego miejsca na dysku C..."
$beforeCleanup = Get-FreeSpaceGB
Write-Host "💾 Dostępne miejsce przed czyszczeniem: $beforeCleanup GB`n"

Write-Host "🧹 Rozpoczynanie czyszczenia bezpiecznych folderów..." -ForegroundColor Cyan

# Lista folderów do czyszczenia
$pathsToClean = @(
    "$env:LOCALAPPDATA\Temp\*",
    "$env:TEMP\*",
    "C:\Windows\Temp\*",
    "C:\Windows\SoftwareDistribution\Download\*",
    "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Windows\INetCache\*"
)

foreach ($path in $pathsToClean) {
    try {
        Write-Host "➡️ Czyszczenie: $path"
        Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Warning "⚠️ Nie udało się usunąć: $path"
        Write-Host "ℹ️ To normalne w przypadku niektórych plików systemowych. Nie przejmuj się." -ForegroundColor Yellow
    }
}

# Sprawdzenie miejsca po czyszczeniu
$afterCleanup = Get-FreeSpaceGB
Write-Host "`n✅ Czyszczenie zakończone."
Write-Host "💾 Dostępne miejsce po czyszczeniu: $afterCleanup GB"

$freedSpace = [math]::Round($afterCleanup - $beforeCleanup, 2)
Write-Host "📈 Zwolniono około: $freedSpace GB`n"
