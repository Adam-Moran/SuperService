[CmdletBinding()]
param (
    [ValidateSet('Development', 'Production')]
    [string]$Configuration = "Development",

    [ValidateNotNullOrEmpty()]
    [string]$CertStoreLocation = "cert:\LocalMachine\My",

    # TODO: Secure string?
    [ValidateNotNullOrEmpty()]
    [string]$CertPassword = "password",

    [ValidateNotNullOrEmpty()]
    [string]$DnsName = "adam.local",

    [ValidateNotNullOrEmpty()]
    [string]$CertExportPath = "c:\certs\cert.pfx"
)

# TODO: Needed?
Import-Module "$PSScriptRoot\Deploy-Module.psm1"

RunTests
BuildImage
GenerateCertifcate -CertPassword $CertPassword -DnsName $DnsName -CertStoreLocation $CertStoreLocation -CertExportPath $CertExportPath
UpdateHostFile -DnsName $DnsName
RunImage -CertExportPath $CertExportPath -Configuration $Configuration -CertPassword $CertPassword
