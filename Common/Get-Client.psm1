#
# Client.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets all properties of the client from CommServ
	    Require minimum powershell version 3.0
    
#>
<#
    .SYNOPSIS
        Retrieves client list from CommServ.
    .PARAMETER computername
        Client name to retrieve the info for that client.
    .OUTPUT
        Client list in JSON format

    .EXAMPLE
        Get-Client -name "$myClient"

    .EXAMPLE
        Get-Client 
#>
	<#
		Description: Method to get client list
		Argument: takes client name 
		Example: Get-Client without arguments will list all clients within commcell.
        Get-Client -name MyClient - will list only Client MyClient details
        Return Client - Id, Name, and additional properties
	#>


function Get-Client{
<#
    .EXAMPLE
        Get-Client -name <$myClient>

    .EXAMPLE
        Get-Client 
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $false, Position = 0)]
[ValidateNotNullorEmpty()]
[String] $Client,
[Switch] $AdditionalSettings,
[Switch] $Version,
[Switch] $TimeZone
)

Begin{

    try{
        #get Session
        $Name = $MyInvocation.MyCommand.Name
        $SessionObject   = Get-SessionDetails $Name
        
    }
    catch
    {
        Write-Verbose -Messsage 'Error in Get-Client Begin'
        Write-Verbose $_.Exception.Message
		$ErrorMessage = $_.Exception.Message
		return $ErrorMessage
    }
}

Process{

    try{
        $headerObject = Get-RestHeader($SessionObject)
        $body     = ''
        $Payload = @{}
        $Payload.Add("headerObject",$headerObject)
        $Payload.Add("body",$body)
            
        #Submit request
        $response = Submit-Restrequest($Payload)
        
        #Collection to hold client objects
        $clientObjects = @{}

        #Process Response
        if($response.clientProperties)
        {
            Foreach($clientProp in $response.clientProperties)
            {
               Write-Verbose -Message $clientProp.client.clientEntity
               #Populate client Props
               $clientSubProp     = @{}
               $clientSubProp.Add('clientId',          $clientProp.client.clientEntity.clientId)
               $clientSubProp.Add('clientName',        $clientProp.client.clientEntity.clientName)
               $clientSubProp.Add('clienthostName',    $clientProp.client.clientEntity.hostName)
               $clientSubProp.Add('type',              $clientProp.client.clientEntity._type_)
               $clientSubProp.Add('clientIdGUID',      $clientProp.client.clientEntity.clientGUID)
               $clientSubProp.Add('cvdPort',           $clientProp.client.cvdPort)
               
               $clientObjects.Add($clientProp.client.clientEntity.clientName,  $clientSubProp)
               
               #If Additional setting switch passed
               if($AdditionalSettings){
                    $clientSubProp.Add('AdditionalSettings', (Get-ClientAdditionalSettings -ClientId $clientProp.client.clientEntity.clientId))
               }

               
            }
        }

        else{
            $clientObjects = $null
        }

        #If client param passed send it only selected client
        if($clientObjects.ContainsKey($Client))
        {
            #get client props and update client version as well
            $clientProp = $clientObjects[$Client] 
            
            #if version switch passed
            if($Version){
                $verObj        = Get-ClientProps -ClientObject $clientProp
                $clientProp.Add("Version", $verObj.clientProperties[0].client.versionInfo)
            }

            #if timezone switch passed
            if($TimeZone){
                $TZObj        = Get-ClientProps -ClientObject $clientProp
                $clientProp.Add("TimeZone", $verObj.clientProperties[0].client.TimeZone)
            }

            return $clientProp
        }
        
        ##If Client name not passed, return whole list
        return $clientObjects
        

    }
    catch
    {
        Write-Verbose -Verbose 'Error in Get-Client Process'
        Write-Verbose $_.Exception.Message
		$ErrorMessage = $_.Exception.Message
		return $response
    }

}

}

Export-ModuleMember -Function "*"