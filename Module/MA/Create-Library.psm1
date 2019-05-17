#
# Create-Library.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Create the disk library (BackupTarget)
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Creates BackupTarget

    .PARAMETER 
        -MAName    -> 
    
    .OUTPUT
        Outputs the list of library and properties.

    .Usage
        Example1: Get-Library  
        Example2: Get-Library -MAName <myMA> //returns library list of the MA
#>


function Get-Library{
<#
     .Example
        Get-Library  
     .Example
        Get-Library -MAName <myMA> //returns library list of the MA
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $MAName,

[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $LibraryName
)
    Begin{
        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            #prepare arguments
            if($MAName){
                $ClientObject =  Get-Client -Client $MAName
                if(-not $ClientObject)
                {
                    Write-Error "Failed to get Client properties"
                    return 
                }
            }

        }
        catch
        {
            Write-Verbose -Message $_.Exception.Message
		    $ErrorMessage = $_.Exception.Message
		    return $ErrorMessage
        }
    }

    Process{

        try{
            #get client id
            $headerObject = Get-RestHeader($SessionObject)
            $body    = ""
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            
            if($prop.response)
            {
                if($LibraryName)
                {
                    foreach ($Library in $prop.response)
                    {
                        if($Library.entityInfo.name  -eq $LibraryName)
                        {
                            return $Library.entityInfo
                        }
                    }
                }
                else
                {
                    $prop.response
                }
            }
            else{ Write-Error ("Error getting storagepolicy list "+$prop)
            }
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Protect-VM Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"