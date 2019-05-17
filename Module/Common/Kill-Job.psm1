#
# Kill-Job.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Kills the job for passed jobid
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Kills the job of passed job Id. And does nothing if jobId not passed.

    .PARAMETER 
        Mandatory arguments -JobId  
        
    
    .OUTPUT
        On success it returns status else error.

    .Usage
        Example1: Kill-Job -JobId <Id>

#>



function Kill-Job{
<#
    .Example
         Kill-Job -JobId <Id>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $JobId

)
    Begin{

        try{
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
            $endpoint=  $SessionObject.requestProps.Endpoint
            $endPoint = $endPoint -creplace ("jobId",$JobId)
            $SessionObject.requestProps.Endpoint = $endPoint
            $headerObject = Get-RestHeader($SessionObject)
            $body    = ""
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #validate the response
            $bFound =$False
            $result = Submit-Restrequest($Payload)

            if($result.error)
            { 
                Write-Error($result.error)
                return  }
            else{ 
                return $result.errors[0].errList|select errLogMessage}
        
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