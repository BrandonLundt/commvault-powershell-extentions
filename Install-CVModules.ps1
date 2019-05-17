

#Locate Current User powershell module directory.
#Some additional logic would be needed to support this install in pwsh.
$p = [Environment]::GetEnvironmentVariable("PSModulePath")
$CurrentUserPath = $p -split ";" | Where-Object { $_ -like "*Documents\WindowsPowerShell*"}
#TO DO: Update this next bit to read in PSD1 file to locate version number
$CurrentUserPath = Join-Path -Path $CurrentUserPath -ChildPath "Commvault\1.0"

#Get current working directory
$LocalModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
#Append the module directory so we only copy the PowerShell to export
$CVModulePath = Join-Path -path $LocalModulePath -childpath "Module"

if( -not (Test-Path $CurrentUserPath)){
    New-Item -Path $CurrentUserPath -ItemType Directory
}
#Copy module as is to the Module Directory
Get-ChildItem -Path $CVModulePath | Copy-Item -Destination $CurrentUserPath -Recurse -Force