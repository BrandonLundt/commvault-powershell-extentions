#
# Get-Collection.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets collection\subclient list
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Get Collection\subclient list from CommServ.

    .PARAMETER 
        Client -Name <Client>
        
    
    .OUTPUT
        On success it returns all subclient objects list of the client.

    .Usage
        Get-Collection -ClientName <Name> -CollectionName [name]
#>



function Get-Collection{
<#
    .EXAMPLE
        Get-Collection -ClientName <Name> -CollectionName [name]
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientName,

[Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $CollectionName

)

    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #prepare arguments
            $ClientObject =  Get-Client -Client $ClientName
            if($ClientObject -eq $null -or $ClientObject -eq "")
            {
                Write-Error "Failed to get Client properties"
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
            #update endpoint
            $endPoint = $SessionObject.requestProps.endpoint
            $endPoint = $endPoint -creplace("ClientId",$ClientObject.clientId)
            $SessionObject.requestProps.endpoint = $endPoint

            $headerObject = Get-RestHeader($SessionObject)
            $body     = ''
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

	        $responseContent = Submit-Restrequest($Payload)
            $bFound   = $False
            #Process Response
            if($responseContent.subClientProperties)
            {
                #Parse the response, return only subclient list
                if($CollectionName -ne $null) #Return only selected subclient props
                {
                    foreach($subclient in $responseContent.subClientProperties.subClientEntity)
                    {
                        if($subclient.subclientName -eq $CollectionName)
                        {
                            $bFound = $True
                            return $subclient
                        }
                    }

                    #Throw an error if subclient name not found
                    if($bFound -eq $False)
                    {
                        Write-Error ("Error: No subclient found with the name "+$CollectionName)
                    }
                }
                else #Return the whole list
                {
                    return $responseContent.subClientProperties.subClientEntity
                }
            }
            
            else{ Write-Error $response #Some exception
            }
        
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