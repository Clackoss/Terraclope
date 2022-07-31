<#
.DESCRIPTION
Check if passwords are valid for Azure VMs
.OUTPUTS
[Boolean] : $f²²alse if password are not ok, $true else
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
    [securestring]$WebServerPassword = Read-Host "Reverse Proxy Vm admin password"-AsSecureString
    $ArePasswordOk = (Get-PasswordValidity -reverseProxyPassword $reverseProxyPassword -WebServerPassword $WebServerPassword)
    $cpt++
    if ($cpt -gt 5) {
        Return "leaving..."
    }
}

#Deploy Terraclope
cd ./terraclope-infra
terraform.exe apply -var="reverse_proxy_password=$($reverseProxyPassword)" -var="web_server_password=$($WebServerPassword)" --auto-approve

#Set password on a txt file for destroy (comment this line if do not want it)
(ConvertFrom-SecureString $reverseProxyPassword -AsPlainText) | Set-content ../password.txt -force
(ConvertFrom-SecureString $WebServerPassword -AsPlainText) >> ../password.txt

