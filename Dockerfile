# escape=`

FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
#FROM mcr.microsoft.com/dotnet/framework/aspnet:3.5

WORKDIR /source
COPY applicationInfo.json .
COPY DRWAPL_FICRES.zip .

WORKDIR /scripts
COPY /scripts .

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Get-ChildItem
RUN .\InstallPwshCore.ps1
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]


RUN .\RunUpServer.ps1 ;

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"] 
