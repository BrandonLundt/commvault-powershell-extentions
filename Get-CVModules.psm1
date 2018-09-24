
#import all modules
function Get-CVModules()
{
    $folders = @(Get-ChildItem  * -include *.psm1 -Recurse -ErrorAction SilentlyContinue )
    Foreach ($folder in $folders)
    {

        Foreach($import in @($folder))
        {
            try
            {
               $filename =  'Importing '+ $import.filename
               Write-Verbose -Message $filename
               Import-Module $import.fullname -Force -Global -Verbose
             }
             catch
              {
                Write-Error -Message "Error in importing the file $($import.fullname): $_"
              }
        }
    }
    
}

#Export-ModuleMember -Function $common.Basename