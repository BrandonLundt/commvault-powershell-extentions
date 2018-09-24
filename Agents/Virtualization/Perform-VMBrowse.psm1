#
#    Perform-VMBrowse.psm1
#    Author : Anand Venkatesh
#    Company: Commvault
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Performs browse for the VM
	    Require minimum powershell version 3.0

    .SYNOPSIS
        Creates browse task and resturns the browse details for the VM

    .PARAMETER 
        -VMName        -> Mandatory argument, this is the VM name.
        -ClientName    -> Client name(Virtualization client name)
    .OUTPUT
        Outputs browse results.

    .Usage
        Example1: Perform-VMBrowse -VMName myVM
        
#>

function Perform-VMBrowse{
<#
    .Example
        Perform-VMBrowse -VMName myVM
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $VMName,

[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $ClientName

)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #prepare arguments
            if($ClientName){
                $ClientObject =  Get-Client -Client $ClientName
                if(-not $ClientObject)
                {
                    Write-Error "Failed to get Client properties"
                    return $null
                }
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
                $endPoint     = $SessionObject.requestProps.endpoint
                #Update endpoint
                $endPoint = $endPoint -creplace("{Id}",$ClientObject.clientId) 
                $SessionObject.requestProps.endpoint = $endPoint
                $headerObject = Get-RestHeader($SessionObject)
                #Set request body which will be used to update the request
                $body     = ""
                 #Submit request
                $Payload = @{}
                $Payload.Add("headerObject",$headerObject)
                $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            if($prop)
            {
                if($VMName){ #If Name passed, filter by VMName
                    foreach($vmRecord in $prop.vmStatusInfoList)
                    {
                        if($vmRecord.name -eq $VMName)
                        {
                            $bFound = $true
                            break
                        }
                    }
                    if($bFound)
                    {
                        return $vmRecord
                    }
                    else{ return $null }
                    }
                else {return $prop}
            }
    }
    catch{
            $errorString = ("Exception in Get-VMProp method "+ $_.Exception.Message)
            Write-Verbose -Verbose $errorString
            return $null
         }
    }

}

Export-ModuleMember -Function "*"