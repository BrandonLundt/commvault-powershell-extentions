#
# Get-Job.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the list of all jobs. Based on parameters this commandlet filters the output
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Get ClientGroup property from CommServ.

    .PARAMETER 
        optional arguments -Filter, -ClientName, -JobCategory,  
        
    
    .OUTPUT
        On success it returns list of jobs.

    .Usage
        Example1: Get-Job #Default lists all ACTIVE JOBS
        Example2: Get-Job -Filter SNAPBACKUP    -> Returns all Snapbackup job type
        Example3: Get-Job -ClientName MyClient  -> Returns all jobs of the client MyClient
        Example4: Get-Job -ClientName MyClient -Subclient MySubclient  -> Returns all jobs of the subclient from MyClient
        Example5: Get-Job -JobCategory  ACTIVE  -> Returns all running jobs
        Example6: Get-Job -Filter SNAPBACKUP -JobCategory  ACTIVE  -> Returns all snap backup type and currently running jobs

#>



function Get-Job{
<#
    .Example
        Get-Job
        
    .Example
        Get-Job -Filter SNAPBACKUP    -> Returns all Snapbackup job type
    
    .Example
        Get-Job -ClientName MyClient  -> Returns all jobs of the client MyClient
    
    .Example
        Get-Job -ClientName MyClient -Subclient MySubclient  -> Returns all jobs of the subclient from MyClient
    
    .Example
        Get-Job -JobCategory  ACTIVE  -> Returns all running jobs
    
    .Example
        Get-Job -Filter SNAPBACKUP -JobCategory  ACTIVE  -> Returns all snap backup type and currently running jobs
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $SubclientName,


[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $Filter,

[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $JobCategory

)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            $endpointParams = $null
            #validate the params
            if($ClientName)
            {
                $ClientObj      = Get-Client -Client $ClientName
                $endpointParams = "clientId=" + $ClientObj.clientId

                if($ClientObj -eq $null -or $ClientObj -eq "")
                {
                    Write-Error("Error: Couldn't find the clientName name in Commserv")
                }
            }
            #If subclient name passed get the subclient Id
            if($SubclientName)
            {
                $SubclientObject= Get-Collection -Client $ClientName -CollectionName $SubclientName
                $SubclientId    = $SubclientObject.subclientId  
                
            }

            #If filter type passed as argument. Example Snapbackup, DATA_VERIFICATION or SYNTHFULL etc
            if($Filter)
            {
                if($endpointParams){
                    $endpointParams = $endpointParams+"&"+ "jobFilter="+$Filter
                }
                else{ 
                    $endpointParams = "jobFilter="+$Filter
                }
            }
            #JobCategory is the argument which has values Active, Finished, All. If this is not passed this commandlet returns everything.
            if($JobCategory)
            {
                if($endpointParams){
                   $endpointParams  =  $endpointParams+"&"+ "jobCategory="+$JobCategory
                }
                else{ 
                    $endpointParams = "jobCategory="+$JobCategory
                }
            }
            #If nothing passed fetch ACTIVE JOBS
            if(-not ($Filter -or $JobCategory)){
                $endpointParams = "jobCategory=ACTIVE"
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
            $endPoint = $endPoint + "?" + $endpointParams
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
            if($result.jobs)
            {
                if($SubclientId)
                {
                    [System.Collections.ArrayList]$SubclientJobs = @()
                    foreach($jobObj in $result.jobs)
                    {
                        if($jobObj.jobSummary.subclient.subclientId -eq $SubclientId)
                        {
                            $SubclientJobs.Add($jobObj)
                        }
                    }
                    return $SubclientJobs
                }
                else{ return $result.jobs}
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