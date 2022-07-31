param (
    # Vms password needed for deletion
    [Parameter(Mandatory = $true)]
    [string]$reverseProxyPassword,
    [Parameter(Mandatory = $true)]
    [string]$WebServerPassword
)

Write-Host "You will destroy the Terraclope infrastructure, are you sure ? (yes)"
$confirmation = Read-Host "confirm"

if ($confirmation -ne "yes"){
    Return "Canceling destruction..."
}
else {
    #Deploy Terraclope
    cd ./terraclope-infra
    terraform.exe destroy -var="reverse_proxy_password=$($reverseProxyPassword)" -var="web_server_password=$($WebServerPassword)" --auto-approve
}