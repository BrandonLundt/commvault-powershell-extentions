#
#    Perform-VMBrowse.psm1
#    Author : Anand Venkatesh
#    Company: Commvault
	
#
<#
    .DESCRIPTION
	    Get the VM list. (Protected and Unprotected)
	    Require minimum powershell version 5.0
    .SYNOPSIS  
        Get the list of VMs discovered. That is protected and Unprotected VM list
    .PARAMETER 
        -Protected        -> Optional argument
        -UnProtected      -> Optional argument 
    .OUTPUT    
        By default lists all VMs, if flags is set, matching VMs will be returned
#>

function Get-VMlist{
<#
   .Example
        Get-VMlist  lists all VMs
   .Example
        Get-VMlist -Filter Protected lists all protected VMs
   .Example
        Get-VMlist -Filter UnProtected lists all Unprotected VMs
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0)]
            [switch]$Protected,
            [Parameter(Mandatory = $False, Position = 0)]
            [switch]$UnProtected,
[Parameter(Mandatory = $False, Position = 1)]
            $VMName,
[Parameter(Mandatory = $False, Position = 2)]
            $ClientName
)

    Begin{

        try{
            #If Filter value passed, VMs matching the criteria will be listed
            $FilterType = 0
            if($Protected){
                $FilterType = 1}     #Protected
            if($UnProtected){$FilterType = 2}   #Unprotected
            
            $Name = "Perform-VMBrowse"
            $SessionObject   = Get-SessionDetails $Name
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
            #If client name passed, we can use /VM API to get all VMs
            if($ClientName)
            {
                $endpoint     = $SessionObject.requestProps.Endpoint
                $ClientObject = Get-Client -Client $ClientName
                
                if( -not $ClientObject["Error"])
                {
                    #If filter has been passed. Filter Protected or Unprotected list
                    if($FilterType){
                        $endPoint     = $endPoint -creplace("{Id}",$ClientObject.clientId)
                        $status       = "status="+$FilterType
                        $endPoint     = $endPoint -creplace("status=0", $status)
                    }
                    else
                    {
                        $endPoint     = $endPoint -creplace("{Id}",$ClientObject.clientId) 
                    }
                }
                else{Write-Error("Error - Cannot find clientId for the client")
                     return $ClientObject
                    }
                #Update endpoint
                $SessionObject.requestProps.Endpoint = $endpoint
            }
            else #Since no client name provided, we should only get flat list of all protected VMs from commcell 
            {
                $BrowseAPI    =  $MyInvocation.MyCommand.Name
                #Get REST endpoint for Get-VMlist as no client name has been passed
                $SessionObject   = Get-SessionDetails $BrowseAPI
            }
            
            $headerObject = Get-RestHeader($SessionObject)

            #Set request body which will be used to update the request
            $body     = ""
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            #Submit request
            $prop = Submit-Restrequest($Payload)
          
            if(-not $prop.Error)
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
                #If not VMName passed, return whole list
                else {return $prop.vmStatusInfoList}
            }
            else{ Write-Error ($prop.Error)}
    }
    catch{
            $errorString = ("Exception in Get-VMProp method "+ $_.Exception.Message)
            Write-Verbose -Verbose $errorString
            return $null
         }
    }

}

Export-ModuleMember -Function "*"