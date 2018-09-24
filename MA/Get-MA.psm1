#
# Get-MA.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the list MediaAgents
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Get the list of Media agents

    .PARAMETER 
        -MAName    -> optional parameter, if passed this module will return properties of that MA
    
    .OUTPUT
        Outputs the list of media agents and properties.

    .Usage
        Example1: Get-MA  
        Example2: Get-MA -MAName <myMA>
#>

function Get-MA{
<#
     .Example
        Get-MA  
     .Example
        Get-MA -MAName <myMA>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $MAName
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
                if($MAName)
                {
                    foreach ($MA in $prop.response)
                    {
                        if($MA.entityInfo.name  -eq $MAName)
                        {
                            return $MA.entityInfo
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