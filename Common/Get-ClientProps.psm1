#
# Get-ClientProps.psm1
#
<#
    Author: Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets all properties of the client from CommServ
	    Require minimum powershell version 3.0
    
#>

<#

    .SYNOPSIS

    Retrieves client properties from CommServ.

    .PARAMETER computername

    Client name to retrieve the info from.
    
    .OUTPUT
    Client props in JSON format

    .EXAMPLE

    Get-ClientProps -ClientName $clientObject

    .EXAMPLE

    (Get-Client -name {{clientName}}).Name | Get-ClientProps
    Example2: $prop = Get-ClientProp -ClientName <clientName>
              $prop.clientProperties[0].AdvancedFeatures //Gets the list of features or packages installed
    Example3: get-clientprops -ClientName prodtest1 | Select clientProperties -ExpandProperty clientProperties
    Example4: get-clientprops -ClientName prodtest1 | Select clientProperties -ExpandProperty clientProperties | Select client -ExpandProperty client | Select jobResulsDir  //To get jobresults directory
    
#>



function Get-ClientProps{
<#
    .EXAMPLE
        Get-ClientProps -ClientName $clientObject

    .EXAMPLE
        (Get-Client -name {{clientName}}).Name | Get-ClientProps

    .Example
        $prop = Get-ClientProp -ClientName <clientName>
        $prop.clientProperties[0].AdvancedFeatures //Gets the list of features or packages installed
    
    .Example
        get-clientprops -ClientName prodtest1 | Select clientProperties -ExpandProperty clientProperties
    
    .Example
        get-clientprops -ClientName prodtest1 | Select clientProperties -ExpandProperty clientProperties | Select client -ExpandProperty client | Select jobResulsDir  //To get jobresults directory
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientName,

[Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientObject
)

    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

             #prepare arguments
             if(-not ($ClientName -or $ClientObject))
             {
                Write-Error("Please pass atleast one argument clientName or ClientObject")
                return
             }
             if($ClientName){
                $ClientObject =  Get-Client -Client $ClientName
                if($ClientObject -eq $null -or $ClientObject -eq "")
                {
                    Write-Error "Failed to get Client properties"
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

        try{#Update the endpoint
            $endPoint = $SessionObject.requestProps.Endpoint
            $endPoint = $endPoint.replace("ClientId",$ClientObject.clientId)
            $SessionObject.requestProps.Endpoint = $endPoint

            $headerObject = Get-RestHeader($SessionObject)
            $body     = ''
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
             #Submit request
             $response = Submit-Restrequest($Payload)
             return $response
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-Client Process'
            Write-Verbose $_.Exception.Message
		    $ErrorMessage = $_.Exception.Message
		    return $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"