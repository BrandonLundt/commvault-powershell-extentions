#
#Start-SendLogFiles.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Uploads the logs from commserv
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Start SendLogFiles process. Based on input (jobId or Client) passed this will send logfiles.

    .PARAMETER 
        -ClientName         -> optional parameter. If passed, this module will prepare SendLogFile for the client Name
        -jobId              -> optional parameter. If passed, this module will prepare SendlogFile for the client Name
        -emailId            -> optional parameter. If passed, Sendlog will be sent to email id set.

    
    .OUTPUT
        status of the sendlogfiles job.

    .EXAMPLE
        Example1: Start-SendLogFiles -ClientName <client>
        Example2: Start-SendLogFiles -JobId      <JobId>  
        Example2: Start-SendLogFiles -ClientName <client> -emailId <email>
#>


function Start-SendLogFiles{
<#
    .Example
        Start-SendLogFiles -ClientName <client>
    .Example
        Start-SendLogFiles -JobId      <JobId>  
    .Example
        Start-SendLogFiles -ClientName <client> -emailId <email>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False, Position = 2)]   
[ValidateNotNullorEmpty()]
[String] $JobId,
[Parameter(Mandatory = $False, Position = 3)]   
[ValidateNotNullorEmpty()]
[String] $EmailId
)
    Begin{
        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            #prepare arguments
            if((-not $ClientName) -and (-not $JobId)){
                raise("Please select client name or jobId to sendlog")
            }
            if($ClientName){
            #Prepare sendlog for ClientName
                $ClientProp = Get-Client -Client $ClientName
            }
            if($JobId){
                $job = Get-JobDetails -JobId $JobId
                if($job){
                    $ClientProp = (Get-Client -Client $job.generalInfo.subclient.clientName)
                    $ClientName = $ClientProp.clientName
                    }
                else{
                    raise ("Please pass valid JobId. Coudn't find the job details for the Job Id "+$JobId)
                    }
            }
        }
        catch
        {
            Write-Verbose -Message $_.Exception.Message;
		    $ErrorMessage = $_.Exception.Message
		    return $ErrorMessage
        }
    }

    Process{
        try{
        #Get payload for SendLog
            $payload = @{}
            if($ClientName){
                $payload.Add("ClientName",$ClientName)
            }
            if($JobId){
                $payload.Add("JobId",$JobId)
            }
            if($EmailId){
                $payload.Add("EmailId",$EmailId)
            }
            $payload.Add("emailSubject","Logs for client "+$ClientName)
            
            $body         = (Prepare-SendLogPayload $payload).body
            $endpoint     = $SessionObject.requestProps.Endpoint
            
            #Update endpoint
            $SessionObject.requestProps.Endpoint = $endpoint
            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            if($prop){
                    return $prop
                  }
                
                }#End of trye
                catch
                {
                    Write-Verbose -Verbose 'Error in Get-DiskSpace module'
		            $ErrorMessage = $_.Exception.Message
		            Write-Error $ErrorMessage
                }
        }
    

}

Export-ModuleMember -Function "*"