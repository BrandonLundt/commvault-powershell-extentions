
#import all modules
$folders = Get-ChildItem -Path $MyInvocation.MyCommand.Path -include *.psm1 -Recurse -Exclude Commvault.psm1
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

#Export-ModuleMember -Function $common.Basename