#
# Resume-Job.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Resume the suspended job for passed jobid
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Resume the job of passed job Id. And does nothing if jobId not passed.

    .PARAMETER 
        Mandatory arguments -JobId  
        
    
    .OUTPUT
        On success it returns status else error.

    .Usage
        Example1: Resume-Job -JobId <Id>

#>

function Resume-Job{
<#
   .Example
    Resume-Job -JobId <Id> 
#>

[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $JobId

)
    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            if (-not $JobId)
            { Write-Error("Error: Please pass jobId.")}
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
            $endPoint = $SessionObject.requestProps.Endpoint -creplace("jobId",$JobId) 
            $SessionObject.requestProps.Endpoint = $endPoint
            $body = ""
            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

	        $result = Submit-Restrequest($Payload)
         
            if($result)
            { return  $result.errors[0].errList}
            else{ return $result}
        
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