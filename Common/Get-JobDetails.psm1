#
# Get-JobDetails.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the details of the job for job Id
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Gets the details of the job for the job Id passed.

    .PARAMETER 
       -JobId <id>,  
        
    
    .OUTPUT
        On success it returns details of the job.

    .Usage
        Example1: Get-JobDetails -JobId <100>
#>



function Get-JobDetails{
<#
    .Example
        Get-JobDetails -JobId <100>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $False)]
[ValidateNotNullorEmpty()]
[String] $JobId
)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #validate the params
            if($JobId)
            {
                $jobObject = @{}
                $jobObject.Add("jobId",[int]$JobId)
                $body  = $jobObject | ConvertTo-Json -Depth 10
            }
            else{
            raise "Please pass job Id"
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
            
            $headerObject = Get-RestHeader($SessionObject)
            #$body     = $jobObject
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $response = Submit-Restrequest($Payload)

            #$bFound =$False
            $result = validateResponse($response)
            if($result.job.jobDetail){
                return $result.job.jobDetail
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