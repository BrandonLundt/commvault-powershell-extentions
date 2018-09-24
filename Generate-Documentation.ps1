<#
    Generates documentation using psDoc-master
    using https://github.com/ChaseFlorell/psDoc
#>

#get Current location
$cwd = Get-Location
$psDocGeneratorPath = Join-Path -path $cwd -childpath "psDoc.ps1"
$CVModulePath = Join-Path -path $cwd -childpath "Get-CVModules.psm1"
Write-Verbose("Importing modules")

#import all modules
function Import-AllModules()
{
    $folders = @(Get-ChildItem  * -include *.psm1 -Recurse -ErrorAction SilentlyContinue )
    Foreach ($folder in $folders)
    {

        Foreach($import in @($folder))
        {
            try
            {
               if($import.Extension -eq ".psm1")
               {
                    Import-Module $import.fullname -Force -Global -Verbose
                    &$psDocGeneratorPath -moduleName $import.BaseName 
               }
             }
             catch
              {
                Write-Error -Message "Error in importing the file $($import.fullname): $_"
              }
        }
    }
    
}

#Call import moduels function
Import-AllModules
