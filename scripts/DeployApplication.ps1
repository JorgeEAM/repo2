param ([Parameter(Mandatory)] $info)

<#
    Functions Block
#>
Function Add-Path($Path) {
    $Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $Path
    [Environment]::SetEnvironmentVariable( "Path", $Path, "Machine" )
}

Write-Output "Deploying application...";
$env:path = "${env:path};C:\Windows\System32\inetsrv";


<#
    Remove default web site content.
#>
#Remove-Website -Name 'Default Web Site';
Remove-Item -Recurse -Force C:\inetpub\wwwroot\*;
Expand-Archive -Path "C:\source\DRWAPL_FICRES.zip" -DestinationPath "C:\source\Application"
Write-Host $env:path;
Get-ChildItem -Path "C:\source\Application\"
Get-ChildItem -Path "C:\source\Application\Isban.Ficres.UK.UI\*" | Move-Item -Destination "C:\inetpub\wwwroot\$($info.Application)\" -WhatIf;
Get-ChildItem -Path "C:\source\Application\Isban.Ficres.UK.UI\*" | Move-Item -Destination "C:\inetpub\wwwroot\$($info.IISiteApp.name)";


<#
    Creating WebSite and Application configuration. 
#>


# AppPool Creation
appcmd add apppool /name:$($info.IISitePool.name) /managedRuntimeVersion:$($info.IISitePool.managedRuntimeVersion) /managedPipelineMode:$($info.IISitePool.managedPipelineMode)
# Setting features
$info.IISitePool.features | ForEach-Object {
    appcmd set apppool "$($info.IISitePool.name)" /$($_.PSObject.Properties.Name):$($_.PSObject.Properties.Value)
}

# Site Creation
#appcmd add site /name:$($info.IISiteServer.name) /physicalPath:$($info.IISiteServer.physicalpath) /bindings:$($info.IISiteServer.bindings)
# Setting features
$info.IISiteServer.features | ForEach-Object {
    appcmd set site "$($info.IISiteServer.name)" /$($_.PSObject.Properties.Name):$($_.PSObject.Properties.Value)
}

# VirtualApp Creation
Write-Host "appcmd add app /site.name:$($info.IISiteServer.name) /path:/$($info.IISiteApp.name) /physicalPath:$($info.IISiteApp.physicalpath)"
appcmd add app /site.name:$($info.IISiteServer.name) /path:/$($info.IISiteApp.name) /physicalPath:$($info.IISiteApp.physicalpath)
# Setting relation between VirtualApp and AppPool
Write-Host "appcmd set app "$($info.IISiteServer.name)/$($info.IISiteApp.name)" /applicationPool:"$($info.IISitePool.name)""
appcmd set app "$($info.IISiteServer.name)/$($info.IISiteApp.name)" /applicationPool:"$($info.IISitePool.name)"
# Setting features
$info.IISiteApp.features | ForEach-Object {
    Write-Host "appcmd set app "$($info.IISiteServer.name)/$($info.IISiteApp.name)" /$($_.PSObject.Properties.Name):$($_.PSObject.Properties.Value)"
    appcmd set app "$($info.IISiteServer.name)/$($info.IISiteApp.name)" /$($_.PSObject.Properties.Name):$($_.PSObject.Properties.Value)
}

appcmd stop apppool /apppool.name:$($info.IISitePool.name)
#appcmd start apppool /apppool.name:$($info.IISitePool.name)

appcmd list apppool /apppool.name:$($info.IISitePool.name)

Write-Output "Application deployed.";

