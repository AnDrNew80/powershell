Write-Host "=== Konfiguracja WinRM dla Ansible ===" -ForegroundColor Cyan

# 1. Pobierz nazwę hosta
$hostname = $env:COMPUTERNAME

# 2. Utwórz certyfikat (samopodpisany)
$cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation Cert:\LocalMachine\My
Write-Host "✔️ Certyfikat utworzony: $($cert.Thumbprint)"

# 3. Włącz WinRM i ustaw konfigurację
winrm quickconfig -quiet

# 4. Zezwól na połączenia nieszyfrowane
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# 5. Włącz uwierzytelnianie Basic
winrm set winrm/config/service/auth '@{Basic="true"}'

# 6. Dodaj zaufanych hostów (np. "*")
winrm set winrm/config/client '@{TrustedHosts="*"}'

# 7. Odblokuj zaporę systemu Windows
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes

Write-Host "=== Konfiguracja zakończona pomyślnie! ===" -ForegroundColor Green
