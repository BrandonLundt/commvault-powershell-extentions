#
# Protect-MissedSLA.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets missed SLA for the client or whole commcell and Starts the backup job
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Gets the missed SLA for client or commcell and kick off backup job for respective subclients.

    .PARAMETER 
       -Client <clientName>,  
        
    
    .OUTPUT
        On success it returns job Id else exception.

    .Usage
        Example1: Protect-MissedSLA
        Example1: Protect-MissedSLA -ClientName <client> -Category 3 -EmailId <emailid> (Protects all subclients which are missed SLA due to no job found)
#>



function Protect-MissedSLA{
<#
      .Example 
      Protect-MissedSLA
      .Example
         Protect-MissedSLA -ClientName <client> -Category 3 -EmailId <emailid> (Protects all subclients which are missed SLA due to no job found)
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter (Mandatory = $False, Position = 3, ValueFromPipeline = $False)] 
[int] $Category, # Category => Any = 0,Protected = 1,Failed = 2,NoJobFound = 3, NoSchedule = 4, Default vaule = 2 only failed subclients will be protected.


[Parameter (Mandatory = $False, Position = 3, ValueFromPipeline = $False)] 
[int] $Status, # Status => Any = 0,Protected = 1,Unportected = 2,Excluded = 3

[Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $EmailId

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
            if(-not $Category) #Category will be 2 (failed only VMs\subclients will be protected)
            {
                $Category = 2
            }
            if(-not $Status) #Status will be 2 (Unprotected will be protected)
            {
                $Status = 2
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
            
            #Set the approproate flags to Get-SLA
            $SLAFlags = @{}
            $SLAFlags.Add("pageSize", 20),
            $SLAFlags.Add("type", 1) #Client or Agent type. Default client = 1
            $SLAFlags.Add("category", $Category) #Detailed type - Default = 2 Failed VMs
            $SLAFlags.Add("status", $Status) #Status flag. Default =2 Unprotected clients 

            $body     = (Prepare-GetSLAPayLoad $SLAFlags).body

            $headerObject = Get-RestHeader($SessionObject)
            #Update the base URL to webconsole U
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $response = Submit-Restrequest($Payload)

            $result = validateResponse($response)
           
            if($result.failedSubclientList)
            {
                $failedObjects    = @{}
                $uniquesubclients = @{}
                $jobIds           = @()
                foreach($row in $result.failedSubclientList)
                {
                    if(-not ($uniquesubclients.ContainsKey($row.appId)))
                    {
                        $uniquesubclients.Add($row.appId,$row)
                        write-host($row.subclient)
                    }
                    
                }

                #Submit the jobs for each of the subclient which has failed object to protect
                foreach($key in $uniquesubclients.Keys){
                    $jobIds += Protect-Subclient -SubclientId $uniquesubclients[$key].appId
                }
                
                #return job ids on success
                return $jobIds
            } 
            
            else{ #Return only  last SLA row.
                 Write-Verbose($response)
                 return ("No failed backup rows found ")
            }
            
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-JobDetails function'
		    $ErrorMessage = $_.Exception.Message
		    return $ErrorMessage
        }

    }
    

}

Export-ModuleMember -Function "*"