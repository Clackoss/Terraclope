<#
.DESCRIPTION
Check if passwords are valid for Azure VMs
.OUTPUTS
[Boolean] : $false if password are not ok, $true else
#>
function Get-PasswordValidity {
    param (
        #Passwords
        [Parameter(Mandatory = $true)]
        [securestring]$reverseProxyPassword,
        [Parameter(Mandatory = $true)]
        [securestring]$WebServerPassword
    )
    $passwordRegex = "(?=^.{8,}$)(?=.*\d)(?=.*[!@#$%^&*]+)(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$"

    if (((ConvertFrom-SecureString $reverseProxyPassword -AsPlainText) -match $passwordRegex) -and ((ConvertFrom-SecureString $WebServerPassword -AsPlainText) -match $passwordRegex)) {
        return $true
    }
    else {
        Write-Host "One of the password do not meet complexity (one lower, one upper, one alphanumeric, one number)"
        return $false
        
    }
}

#prompt user for password
$ArePasswordOk = $false
$cpt = 0
while (!$ArePasswordOk) {
    [securestring]$reverseProxyPassword = Read-Host "Reverse Proxy Vm admin password"-AsSecureString
    [securestring]$WebServerPassword = Read-Host "Web Server Vm admin password"-AsSecureString
    $ArePasswordOk = (Get-PasswordValidity -reverseProxyPassword $reverseProxyPassword -WebServerPassword $WebServerPassword)
    $cpt++
    if ($cpt -gt 5) {
        Return "leaving..."
    }
}

#Deploy Terraclope
cd ./terraclope-infra
terraform.exe init
terraform.exe apply -var="reverse_proxy_password=$((ConvertFrom-SecureString $reverseProxyPassword -AsPlainText))" -var="web_server_password=$((ConvertFrom-SecureString $WebServerPassword -AsPlainText))" --auto-approve
cd ..

