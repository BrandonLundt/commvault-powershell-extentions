#
# Get-Alert.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the alert list
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Get the alert list

    .PARAMETER 
        NONE
        
    
    .OUTPUT
        Outputs the all alerts.

    .Usage
        Example1: Get-Alert
#>



function Get-Alert{
<#
    .Example
        Get-Alert
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
        #Prepare GET request
            $body    = ""
            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

            #Submit request
            $prop = Submit-Restrequest($Payload)
            if($prop.alertList)
            {
                return $prop.alertList
            }
            else{ Write-Error ("Error getting alert list "+$prop)
            }
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-Alert method'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"