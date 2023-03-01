Write-Output "Creating logs folder...";

$env:logs_home="C:\logs"

New-Item -Path ${env:LOGS_HOME} -ItemType Directory -Force; 
Push-Location ${env:LOGS_HOME}; 
$acl = Get-Acl .; 
$accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new( 
    'Everyone', 
    [System.Security.AccessControl.FileSystemRights]::FullControl, 
    'ContainerInherit,ObjectInherit', 
    [System.Security.AccessControl.PropagationFlags]::None, [System.Security.AccessControl.AccessControlType]::Allow 
); 
$acl.AddAccessRule($accessRule); 
Set-Acl . $acl; 
Get-Acl .;
Set-Location "C:\scripts";
Write-Output "Logs folder created.";

