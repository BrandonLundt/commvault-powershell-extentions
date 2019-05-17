#
# Set-Client.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Sets properties of the client
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        updates client properties in CommServ.

    .PARAMETER 
        Client object which is output of Get-Client -Name <Client>
        Properties to update the CommServ.
    
    .OUTPUT
        success response JSON format if success else generates error json 

    .EXAMPLE
        Set-Client -ClientObject -Property $ClientProp

    .EXAMPLE
        {{$PropObject}} | Set-Client
        {
     
     Sample input jsonObject:
       $prop = @{
	"App_SetClientPropertiesRequest" = @{
		"association" = @{
			"entity" = @{ 
				"clientName" = "client001" 
					} 
				}
			}
	"clientProperties" = @{
		"client" = @{ 
			"clientDescription"= "client-level description modified with rest api POST client" 
			} 
		} 
       } | ConvertTo-Json

    
#>



function Set-ClientProps{
<#
    .EXAMPLE
        Set-Client -ClientObject -Property $ClientProp

    .EXAMPLE
        {{$PropObject}} | Set-Client
        {
     
     Sample input jsonObject:
       $prop = @{
	"App_SetClientPropertiesRequest" = @{
		"association" = @{
			"entity" = @{ 
				"clientName" = "client001" 
					} 
				}
			}
	"clientProperties" = @{
		"client" = @{ 
			"clientDescription"= "client-level description modified with rest api POST client" 
			} 
		} 
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientObject,

[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientProp

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
            $endPoint = $SessionObject.requestProps.Endpoint
            $endPoint = $endPoint.replace("ClientId",$ClientObject.clientId)
            $SessionObject.requestProps.Endpoint = $endPoint
            
            #Set request body which will be used to update the client props
            $body     = $ClientProp | ConvertTo-Json
            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

	        $result = Submit-Restrequest($Payload)
            return $result
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