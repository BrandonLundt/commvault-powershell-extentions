#
# Protect-Subclient.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	   Starts backupjob for specific subclient/collection
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Starts backup job for subclient/collection.

    .PARAMETER 
       -SubclientId <SubclientId>,  
       -BackupType Full, Incremental, SynthFull
        
    
    .OUTPUT
        On success it returns job Id else exception.

    .Usage
        Example1: Protect-Subclient -SubclientId 100
        
#>



function Protect-Subclient{
<#
      .Example 
        Protect-Subclient -SubclientId 100
      .Example 
        Protect-Subclient -SubclientId 100 -BackupType Incremental/Full/SynthFull #Default incremental
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $SubclientId,

[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $BackupType
)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #validate the params
            if(-not $SubclientId)
            {
                throw "Please pass valid subclientId"
                
            }
             if(-not $BackupType)
            {
                $BackupType = 'Incremental'
                
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
            $endPoint     = $endPoint -creplace("{SubclientId}", $SubclientId)
            $endPoint     = $endPoint -creplace("{BackupType}", $BackupType)
            $SessionObject.requestProps.Endpoint = $endpoint
            
            $body     = {}

            $headerObject = Get-RestHeader($SessionObject)
            #Update the base URL to webconsole URL
            $PREFIX =  $REST_AUTH_URL_PREFIX
            $webconsole_base = $PREFIX + $REST_WEBCONSOLE_URL
            $port = $REST_DEFAULT_PORT
            $webconsole_base = (($webconsole_base.Replace("Server",$SessionObject.server))).Replace(" ","")
            $headerObject.baseUrl = $webconsole_base
            
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $response = Submit-Restrequest($Payload)

            $result = validateResponse($response)
           
            return $result
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-JobDetails function'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }
    

}

Export-ModuleMember -Function "*"