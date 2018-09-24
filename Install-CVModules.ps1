#Add CV module path to persistant PSModulePath.

#Reg path to PSModulePath
#$regPath = ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’

#get Current location
$cwd = Get-Location

#Save the current value in the $p variable.
$p = [Environment]::GetEnvironmentVariable("PSModulePath")


#Add the paths in $p to the PSModulePath value.

#$originalpaths = (Get-ItemProperty -Path $regPath -Name PSModulePath).PSModulePath
# Add your new path to below after the ;
#$newPath=$originalpaths+’;’+ $cwd

#Set-ItemProperty -Path $regPath -Name PSModulePath –Value $newPath
#Write-Verbose ("updated the env variable PSModulePath with value "+ $newPath)

$CVModulePath = Join-Path -path $cwd -childpath "Get-CVModules.psm1"
Import-Module $CVModulePath -Force -Global -Verbose
Get-CVModules 
