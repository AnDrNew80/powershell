# PowerShell Script to Find All Expired Certificates

# Function to Get Expired Certificates
function Get-ExpiredCertificates {
    # Array to hold expired certificates
    $expiredCerts = @()

    # Define the certificate stores to check
    $certStores = @("Cert:\LocalMachine", "Cert:\CurrentUser")

    foreach ($store in $certStores) {
        try {
            # Get all certificates from the current store and its sub-stores
            $certs = Get-ChildItem -Path $store -Recurse -ErrorAction Stop
            
            # Filter expired certificates and add to the array
            $expiredCerts += $certs | Where-Object { $_.NotAfter -lt (Get-Date) }
        } catch {
            # Create a variable for the error message
            $errorMessage = $_.Exception.Message
            Write-Host "Error accessing store $(${store}): $errorMessage" -ForegroundColor Red
        }
    }

    # Return the expired certificates
    return $expiredCerts
}

# Main Script Execution
$expiredCertificates = Get-ExpiredCertificates

if ($expiredCertificates.Count -eq 0) {
    Write-Host "No expired certificates found." -ForegroundColor Green
} else {
    Write-Host "Expired Certificates:" -ForegroundColor Yellow
    foreach ($cert in $expiredCertificates) {
        Write-Host "Subject: $($cert.Subject)"
        Write-Host "Thumbprint: $($cert.Thumbprint)"
        Write-Host "Expiration Date: $($cert.NotAfter)"
        Write-Host "-----------------------------------"
    }
}

# End of Script