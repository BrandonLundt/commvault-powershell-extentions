#
# Get-SLA.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the SLA for given client or commcell
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Gets the SLA for client or commcell.

    .PARAMETER 
       -Client <clientName>,  
        
    
    .OUTPUT
        On success it returns SLA and email SLA report.

    .Usage
        Example1: Get-SLA
        Example2: Get-SLA -EmailId <emailid>
        Example1: Get-SLA -ClientName <client> -EmailId <emailid>.
#>



function Get-SLA{
<#
     .Example
         Get-SLA
     .Example
        Get-SLA -EmailId <emailid>
     .Example
        Get-SLA -ClientName <client> -EmailId <emailid>.
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $EmailId,

[Parameter (Mandatory = $False, Position = 2, ValueFromPipeline = $False)] 
[int]$Status, # Status => Any = 0, Protected = 1, Unprotected     = 2, Excluded        = 3

[Parameter (Mandatory = $False, Position = 3, ValueFromPipeline = $False)] 
[int] $Category, # Category => Any = 0,Protected = 1,Failed = 2,NoJobFound = 3, NoSchedule = 4,


[Switch] $Detail # This switch output entire object. If you need more details than just summary


)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #validate the params
            if($ClientName)
            {
                $ClientProp  = Get-Client -Client $ClientName
            }
            
            if(-not $Status){ #Default value for status = 0
            $Status = 0 }

            if(-not $Category){ #Default value for Category = 0
            $Category = 0 }
            
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
            
            #Set the approproate flags to Get-SLA
            $SLAFlags = [ordered]@{}
            $SLAFlags.Add("type", 1) #Client or Agent type. Default client = 1
            $SLAFlags.Add("category", $Category) #Detailed type - Default = 4 Unprotected and no jobs
            $SLAFlags.Add("status", $Status) #Status flag. Default =2 Unprotected clients 

            $body     = (Prepare-GetSLAPayLoad $SLAFlags).body

            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $response = Submit-Restrequest($Payload)

            $result = validateResponse($response)
            if($result.lastSLA){
                #Return whole object as is.
                if($Detail){
                        return $result
                }
                else{ #Return only  last SLA row.
                        return $result.lastSLA
                    }
            }
            else{
                return $response
            }
        
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