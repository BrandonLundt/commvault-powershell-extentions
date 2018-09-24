#
# Get-CollectionProps.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets collection\subclient Properties
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Get Collection\subclient props from CommServ.

    .PARAMETER 
        SubclientClient object which is output of Get-Collection
        
    
    .OUTPUT
        On success it returns all subclient objects list of the client.

    .Usage
        Example1: Get-CollectionProps -SubClientObject 
        Example2: Get-collection -ClientName vsaqa -CollectionName abc | Get-CollectionProps 

#>



function Get-CollectionProps{
<#
    .Example
        Get-CollectionProps -ClientName vsaqa -CollectionName abc 

    .Example
        Get-CollectionProps -SubClientObject 
        
    .Example
        Get-collection -ClientName vsaqa -CollectionName abc | Get-CollectionProps 
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
[System.Object] $CollectionObject,
[Parameter(Mandatory = $False, Position = 0)]
[System.Object] $CollectionName,
[Parameter(Mandatory = $False, Position = 1)]
[System.Object] $ClientName

)
    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #Processs the arguments
            if($CollectionName)
            {
                if($ClientName){
                    $CollectionObject = Get-Collection -ClientName $ClientName -CollectionName $CollectionName
                }
                else{
                throw("Please pass client name. Client name cannot be empty") }
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
            $endPoint = $endPoint -creplace("SubclientId",$CollectionObject.subclientId) 
            $SessionObject.requestProps.endpoint = $endPoint

            $headerObject = Get-RestHeader($SessionObject)
            $body     = ''
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

	        $prop = Submit-Restrequest($Payload)
            if($prop.subClientProperties)
            {
                return $prop.subClientProperties
            }
            else{ return $prop
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