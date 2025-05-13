# Definiuj porty i nazwy reguł
$AgentPort = 10050
$ServerPort = 10051
$AgentRuleName = "Zabbix Agent Port ($AgentPort)"
$ServerRuleName = "Zabbix Server Port ($ServerPort)"

# Sprawdź, czy reguła dla portu agenta już istnieje i jest włączona
$AgentRuleExists = Get-NetFirewallRule -DisplayName $AgentRuleName -ErrorAction SilentlyContinue
if (-not $AgentRuleExists -or $AgentRuleExists.Enabled -eq $false -or $AgentRuleExists.Action -ne "Allow") {
    Write-Host "Tworzenie lub włączanie reguły dla portu agenta Zabbix: $AgentPort (TCP)"
    New-NetFirewallRule -DisplayName $AgentRuleName -Protocol TCP -LocalPort $AgentPort -Direction Inbound -Action Allow
} else {
    Write-Host "Reguła dla portu agenta Zabbix: $AgentPort (TCP) już istnieje i jest włączona."
}

# Sprawdź, czy reguła dla portu serwera już istnieje i jest włączona
$ServerRuleExists = Get-NetFirewallRule -DisplayName $ServerRuleName -ErrorAction SilentlyContinue
if (-not $ServerRuleExists -or $ServerRuleExists.Enabled -eq $false -or $ServerRuleExists.Action -ne "Allow") {
    Write-Host "Tworzenie lub włączanie reguły dla portu serwera Zabbix: $ServerPort (TCP)"
    New-NetFirewallRule -DisplayName $ServerRuleName -Protocol TCP -LocalPort $ServerPort -Direction Inbound -Action Allow
} else {
    Write-Host "Reguła dla portu serwera Zabbix: $ServerPort (TCP) już istnieje i jest włączona."
}

Write-Host "Sprawdzenie i konfiguracja reguł zapory dla portów Zabbix zakończona."