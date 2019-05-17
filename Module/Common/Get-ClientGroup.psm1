#
# Get-ClientGroup.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets Client group list or just client group object
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Get ClientGroup list from CommServ.

    .PARAMETER 
        Option name 
        
    
    .OUTPUT
        On success it returns all client group objectsor single clientgroup object if name passed.

    .Usage
        Example1: Get-ClientGroup -ClientGroupName [Name]
       

#>



function Get-ClientGroup{
<#
    .Example
        Get-ClientGroup -ClientGroupName [Name]
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientGroupName

)
    Begin{

        try{
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
            $headerObject = Get-RestHeader($SessionObject)
            $body     = ''
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $result = Submit-Restrequest($Payload)
            
            $bFound = $False
            if($result)
            {
                if($ClientGroupName)        
                {
                    foreach($group in $result.groups)
                    {
                        if($group.name -eq $ClientGroupName)
                        {
                            $bFound = $True
                            return $group
                        }
                    }
                    if($bFound -eq $False)
                    {
                        Write-Error("Client group name not found "+$ClientGroupName)
                    }
                }
                else{ return $result.groups
                }
            }
            else{ return $result
            }
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-Client Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"