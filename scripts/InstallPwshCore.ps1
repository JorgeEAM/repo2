Write-Host "Installing Powershell Core...";
Set-Location "C:\source" ;
Expand-Archive pwsCore.zip;
Start-Process msiexec -ArgumentList '/i', 'pwsCore\PowerShell-7.3.2-win-x64.msi', '/quiet' -Wait -PassThru;
Remove-Item pwsCore\PowerShell-7.3.2-win-x64.msi;
Write-Host "Powershell Core Installed.";
