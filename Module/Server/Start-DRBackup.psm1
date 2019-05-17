#
# Start-DRBackup.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Starts DR backup of the commserv
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Commandlet starts the DR backup of commserv

    .PARAMETER 
        NONE
        
    
    .OUTPUT
        Outputs the status of the job.

    .Usage
        Example1: Start-DRBackup
#>
function Start-DRBackup{
<#
     .Example
        Start-DRBackup
#>
[CmdletBinding()]

param(

)
    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
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
            $body    = Get-DRBackupObject
            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

            #Submit request
            $prop = Submit-Restrequest($Payload)
            if(-not $prop.error)
            {
                Write-Output "JobId:"
                return $prop.jobIds
            }
            else{ Write-Error ("Failed to start DRbackup job "+$prop.error)
            }
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Start-DRBackup method'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"