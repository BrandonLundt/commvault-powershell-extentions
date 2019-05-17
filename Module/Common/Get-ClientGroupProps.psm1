#
# Get-ClientGroupProps.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets Client group properties for the given group name if exists
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Get ClientGroup property from CommServ.

    .PARAMETER 
        Mandatory group name 
        
    
    .OUTPUT
        On success it returns client group properties.

    .Usage
        Example1: Get-ClientGroupProp -ClientGroupName
      
#>

function Get-ClientGroupProps{
<#
    .Example
        Get-ClientGroupProp -ClientGroupName
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientGroupName

)
    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            #validate the param
            if($ClientGroupName)
            {
                $GroupObj = Get-ClientGroup -ClientGroupName $ClientGroupName
                if($GroupObj -eq $null -or $GroupObj -eq "")
                {
                    Write-Error("Error: Couldn't find the clientgroup name in Commserv")
                }
            }
            else
            {
                Write-Error("Error: Please pass ClientGroupName value")
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
        #Prepare GET request
            $endPoint = $SessionObject.requestProps.Endpoint
            $endPoint = $endPoint -creplace("clientGroupId",$GroupObj.Id) 
            $SessionObject.requestProps.Endpoint = $endPoint
            $headerObject = Get-RestHeader($SessionObject)
            $body     = ''
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $result = Submit-Restrequest($Payload) 
            $bFound =$False
            
            if($result)
            {
                return $result.clientGroupDetail
            }
            else { return $result
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