$applicationInfo=Get-Content "C:\source\applicationInfo.json" | ConvertFrom-Json;
Set-Location "C:\scripts";
.\ConfigureServer.ps1 $applicationInfo
.\DeployApplication.ps1 $applicationInfo
