<#
    Enable .NET Framework Compatibility
#>


Write-Host "Enabling .NET Compatibility..."

##### .NET 3.5
if ($applicationInfo.NetVersion -eq "v2.0")
{
    dism /online /enable-feature /featurename:IIS-ASPNET45 /all;
    
    Exit 0;
}
##### .NET 4.x
elseif($applicationInfo.NetVersion -eq "v2.0") {
    dism /online /enable-feature /featurename:netfx3 /all;
    dism /online /enable-feature /featurename:IIS-NetFxExtensibility /all;
    dism /online /enable-feature /featurename:IIS-ASPNET /all;
    
    Exit 0;
}
##### .NET Version not found
else {
    Exit -1;
}

Write-Host ".NET Compatibility enabled."
