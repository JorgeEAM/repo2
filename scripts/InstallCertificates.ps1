Write-Host "Installing certificates...";

<#
    Install CA Root certificates
#>
Set-Location -Path "C:\certs"
[array]$certsArtifacts = Get-ChildItem -File;

foreach ($certsArtifact in $certsArtifacts) {
    $destinationPath = [System.IO.Path]::Combine("C:\certs", 'current');
    Write-Output ${destinationPath};
    Write-Host ${destinationPath};
    Expand-Archive -Path ${certsArtifact} -DestinationPath ${destinationPath};
    $cert = Get-ChildItem -Path ${destinationPath} -File;
    $certPath = [System.IO.Path]::Combine($destinationPath, $cert.name);
    Push-Location -Path Cert:\LocalMachine\Root\;
    Import-Certificate -FilePath $certPath;
    Pop-Location;
    Write-Output ${destinationPath};
    Remove-Item -Path ${destinationPath} -Recurse -Force;
}

[System.IO.Path]::Combine("C:\certs", '..') | Resolve-Path | Push-Location;
[System.IO.Path]::Combine("C:\certs", '*') | Remove-Item -Recurse -Force;
Set-Location -Path "C:\scripts"

Write-Host "Certificates installed.";

Get-Location
Get-ChildItem
