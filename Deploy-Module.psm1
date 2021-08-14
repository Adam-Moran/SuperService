[CmdletBinding()]
param ()
function RunTests() {
    Write-Host "`r`nRunning Tests" -ForegroundColor Green
    Write-Host '-----------------' -ForegroundColor Green
    
    $dotnetExe = Get-Command 'dotnet' -ErrorAction Stop
    $dotnetArgs = @('test')
    Write-Output "`r`nExecuting: $dotnetExe $dotnetArgs "
    & $dotnetExe $dotnetArgs 
    
    if($lastexitcode -ne 0) {
        throw "Test run failed with exit code ${lastexitcode}"
    }
}

function BuildImage() {
    Write-Host "`r`nBuilding Image" -ForegroundColor Green
    Write-Host '-----------------' -ForegroundColor Green

    docker build -f src\Dockerfile . --no-cache=true -t super-service:latest
    if($? -eq $false) {
        throw "Docker build failed with exit code ${lastexitcode}"
    }
}

function GenerateCertifcate([string]$CertPassword, [string]$DnsName, [string]$CertStoreLocation, [string]$CertExportPath) {
    
    Write-Host "`r`nGenerating Certificate" -ForegroundColor Green
    Write-Host '-----------------' -ForegroundColor Green

    try {
        $cert = New-SelfSignedCertificate -DnsName @($DnsName) -CertStoreLocation $CertStoreLocation

        $password = ConvertTo-SecureString $CertPassword -AsPlainText -Force
        $cert | Export-PfxCertificate -FilePath $CertExportPath -Password $password

    }
    catch {
        throw $_.Exception
    }
}

function UpdateHostFile([string]$DnsName) {
    Write-Host "`r`nUpdating Host file" -ForegroundColor Green
    Write-Host '-----------------' -ForegroundColor Green
    
    try {
        # TODO: Check if exists
        Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n127.0.0.1`t${DnsName}" -Force -ErrorAction Stop
    }
    catch {
        throw $_.Exception
    }

    Write-Output "Done!"
}

function RunImage([string]$CertExportPath, [string]$Configuration, [string]$CertPassword) {
    Write-Host "`r`nRunning Image" -ForegroundColor Green
    Write-Host '-----------------' -ForegroundColor Green
    
    $path = Split-Path -Path $CertExportPath
    $outputFile = Split-Path $CertExportPath -leaf
    
    docker run --rm -p 8000:80 -p 55005:443 -e ASPNETCORE_URLS="https://+;http://+" -e ASPNETCORE_HTTPS_PORT=55005 -e ASPNETCORE_ENVIRONMENT="${Configuration}" -e ASPNETCORE_Kestrel__Certificates__Default__Password="${CertPassword}" -e ASPNETCORE_Kestrel__Certificates__Default__Path="/root/cert/${outputFile}" -v "${path}:/root/cert" super-service:latest    
    if($? -eq $false) {
        throw "Image run failed with exit code ${lastexitcode}"
    }
}

Export-ModuleMember -Function RunTests
Export-ModuleMember -Function BuildImage
Export-ModuleMember -Function GenerateCertifcate
Export-ModuleMember -Function UpdateHostFile
Export-ModuleMember -Function RunImage
