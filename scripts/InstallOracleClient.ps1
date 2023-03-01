Write-Host "Installing Oracle Client...";

######################################################
# INSTALL ORACLE DATA ACCESS COMPONENTS 19.3 (32bit) #
######################################################

$env:ORACLE_CLIENT_ZIP_FILE_LOCATION="https://nexusmaster.alm.europe.cloudcenter.corp/repository/scq-3rd-party-raw/oracle/database/oracle19c/windows/client/193000/"
$env:ORACLE_CLIENT_ZIP_FILE="NT_193000_client.zip"

$env:ORACLE_TEMP="c:\temp\oracle"
$env:ORACLE_TEMP_CLIENT=Join-Path $env:ORACLE_TEMP "\client32"
$env:ORACLE_HOME="C:\oracle\Product\19.0.0\Client32"
$env:ORACLE_BASE="c:\oracle"
$env:ODP_NET="C:\oracle\Product\19.0.0\Client32\ODP.NET\bin\2.x"

New-Item -Type Directory -Path "C:\Windows\assembly\GAC_32\Oracle.DataAccess\2.122.19.1__89b483f429c47342" -Force

New-Item -Type Directory -Path ${env:ORACLE_TEMP} -Force
Set-Location ${env:ORACLE_TEMP}


$current_http_proxy="$env:HTTP_PROXY"; 
$current_https_proxy = "$env:HTTPS_PROXY"; 
$url="${env:ORACLE_CLIENT_ZIP_FILE_LOCATION}${env:ORACLE_CLIENT_ZIP_FILE}";
Write-Host $url;
Invoke-WebRequest $url -OutFile ${env:ORACLE_CLIENT_ZIP_FILE} ;
$env:HTTP_PROXY = $current_http_proxy; 
$env:HTTPS_PROXY = $current_https_proxy; 
Expand-Archive -Path ${env:ORACLE_CLIENT_ZIP_FILE} -DestinationPath .; 
Get-ChildItem ;



# INSTALL ORACLE CLIENT
Set-Location ${env:ORACLE_TEMP_CLIENT}; 
Write-Output "INSTALING ORACLE DATABASE CLIENT VIA setup.exe process..."; 
Get-ChildItem ;


# See: https://silentinstallhq.com/oracle-database-19c-client-silent-install-how-to-guide/
Start-Process ${env:ORACLE_TEMP_CLIENT}\setup.exe -ArgumentList '-silent', '-nowait', '-ignoreSysPrereqs', '-ignorePrereqFailure', '-waitForCompletion', '-force', "ORACLE_HOME=${env:ORACLE_HOME}", "ORACLE_BASE=${env:ORACLE_BASE}", "oracle.install.IsBuiltInAccount=true", "oracle.install.client.installType=Runtime" -NoNewWindow -Wait; 
Write-Output "ORACLE DATABASE CLIENT INSTALLATION FINISHED."; 



# REGISTER CONFIG and GAC
Set-Location ${env:ODP_NET}; 
Write-Output "REGISTERING CONFIG AND GAG..."; 
.\OraProvCfg.exe /action:config  /force /product:odp /frameworkversion:v2.0.50727 /providerpath:"Oracle.DataAccess.dll"; 
.\OraProvCfg.exe /action:gac /providerpath:"Oracle.DataAccess.dll"; 
Set-Location C:\Windows\assembly\GAC_32\Oracle.DataAccess\2.122.19.1__89b483f429c47342\; 
Get-ChildItem -Filter *.dll -Recurse | Select-Object -ExpandProperty VersionInfo; 
Write-Output "CONFIG AND GAG REGISTER PROCESS FINISHED."; 
Set-Location ${env:ORACLE_HOME}; 


# SET ORACLE_HOME permissions (Avoid "System.Data.OracleClient requires Oracle client" exception)
$acl = Get-Acl ${env:ORACLE_HOME}; 
$accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new( 
    'Everyone', 
    [System.Security.AccessControl.FileSystemRights]::ReadAndExecute, 
    'ContainerInherit,ObjectInherit', 
    [System.Security.AccessControl.PropagationFlags]::None, [System.Security.AccessControl.AccessControlType]::Allow 
); 
$acl.AddAccessRule($accessRule); 
Set-Acl ${env:ORACLE_HOME} $acl; 
Get-Acl ${env:ORACLE_HOME}; 



# ADD the ODAC install directory and ODAC install directory's bin subdirectory to the system PATH environment variable before any other Oracle directories.
$pathContent = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine); 
$pathContentBuilder = [System.Text.StringBuilder]::new(); 
$oracleHomeSegment = "${env:ORACLE_HOME};"; 
$pathContentBuilder.Append($oracleHomeSegment); 
$oracleBinPath = Join-Path -Path "${env:ORACLE_HOME}" -ChildPath "bin" -Resolve; 
$oracleBinPath += ';'; 
$pathContentBuilder.Append(${oracleBinPath}); 
$pathContentBuilder.Append(${pathContent}); 
[System.Environment]::SetEnvironmentVariable('PATH', $pathContentBuilder.ToString(), [System.EnvironmentVariableTarget]::Machine); 



# REMOVE install scripts and files
[System.IO.Path]::Combine($env:ORACLE_TEMP, '..') | Resolve-Path | Push-Location; 
[System.IO.Path]::Combine($env:ORACLE_TEMP, '*') | Remove-Item -Recurse -Force;

Write-Host "Oracle Client installed.";
