# escape=`

FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
#FROM mcr.microsoft.com/dotnet/framework/aspnet:3.5

WORKDIR /certs
COPY /certs .

WORKDIR /source
RUN curl -k https://nexusmaster.alm.europe.cloudcenter.corp/repository/scq-iac-snapshots/SCF/ficres/DRWAPL_FICRES.zip -o DRWAPL_FICRES.zip
COPY applicationInfo.json .
COPY pwsCore.zip .
COPY tnsnames.ora .

WORKDIR /scripts
COPY /scripts .

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Get-ChildItem
RUN .\InstallPwshCore.ps1
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]


RUN .\RunUpServer.ps1 ;

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"] 
