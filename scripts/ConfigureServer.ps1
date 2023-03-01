param ([Parameter(Mandatory)] $applicationInfo)

Write-Host "Configuring server...";

.\EnableNETcompatibility.ps1 $applicationInfo.NetVersion;

$tasks = $applicationInfo.Tasks;
if ($tasks.Contains("Create-Logs-Folder")) { .\CreateLogsFolder.ps1; }
if ($tasks.Contains("Install-Certificates")) { .\InstallCertificates.ps1; }
if ($tasks.Contains("Install-Oracle-Client")) { .\InstallOracleClient.ps1; }

foreach ($file in $applicationInfo.MoveFilesToPath) {
    Write-Host "Movin files..." ;
    Move-Item -Path "C:\source\$($file.File)" -Destination $file.Path -WhatIf;
    Move-Item -Path "C:\source\$($file.File)" -Destination $file.Path -Force;
}

Write-Output "Server configured.";
