#
# Get-AdditionalSettings.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the list of all additional settings for the given client
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Get AdditionalSettings from CommServ.

    .PARAMETER 
        Manadatory argument ClientId should be passed
    
    .OUTPUT
        On success list of additionalSettings in json.

    .Usage
        Example1: Get-ClientAdditionalSettings -ClientId <ID>
        Example2: Get-ClientAdditionalsettings -ClientName <clientName> | Select keyName,value
#>



function Get-ClientAdditionalsettings{
<#
    .Example
        Get-ClientAdditionalSettings -ClientId <ID>
    .Example
        Get-ClientAdditionalsettings -ClientName <clientName> | Select keyName,value
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $ClientId,

[Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $ClientName
)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            $endpointParams = $null
            #validate the params
            if($ClientName)
            {
                $ClientObj = (Get-Client -Client $ClientName)
                $ClientId  = $ClientObj.clientId
            }
            if(-not $ClientId)
            {
                Write-Error("Please pass valid client Id")
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
            $endPoint = $endPoint -creplace("ClientId",$ClientId)
            $SessionObject.requestProps.Endpoint = $endPoint
            
            $headerObject = Get-RestHeader($SessionObject)
            $body     = ""
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $response = Submit-Restrequest($Payload)

            #$bFound =$False
            $result = validateResponse($response)
            if($result)
            {
                return $result.regKeys
            }
            else { return $result}
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-Job function'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"