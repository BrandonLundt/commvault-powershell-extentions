#
# Get-StoragePolicy.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the list storage policy and properties
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Get the list of storage policy and properties

    .PARAMETER 
        -StoragePolicyName        -> optional argument, this is the SP name to which the properties to be retrieved.
        -MAName    -> Mandatory parameter. Name of the client in which your VM getting backeddup.
    
    .OUTPUT
        Outputs the list of storage policies and properties.

    .Usage
        Example1: Get-StoragePolicy  
        Example2: Get-StoragePolicy -StoragePolicyName SP1
        Example3: Get-StoragePolicy -StoragePolicyName SP1 -MAName MA1
#>

function Get-StoragePolicy{
<#
    .Example
        Get-StoragePolicy  
    .Example
        Get-StoragePolicy -StoragePolicyName SP1
    .Example
        Get-StoragePolicy -MAName <myMA>
    .Example
        Get-StoragePolicy -StoragePolicyName SP1 -MAName <myMA>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $StoragePolicyName,

[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $MAName,

[Parameter(Mandatory = $False, Position = 2 )] #Use this when you want to retrive specific copy properties
[ValidateNotNullorEmpty()]
[String] $CopyName

)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            #prepare arguments
            if($MAName){
                $MAObject =  Get-MA -MAName $MAName
                if(-not $MAObject)
                {
                    Write-Error "Failed to get MA properties"
                    return 
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
            if($MAName)
            {
               $SessionObject= Get-SessionDetails "Get-SPlistforMA"
               $SessionObject.requestProps.Endpoint  = $SessionObject.requestProps.Endpoint -ireplace ("ID",$MAObject.Id)
            }
            $headerObject = Get-RestHeader($SessionObject)
            $body         = ""
            $Payload      = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            set-alias ?: Invoke-Ternary -Option AllScope
            if($prop.policies -or $prop.storagePolicyInformationAssociatedToMA)
            {
                if($MAName){ #Verifies all massociated SPs to the MA and returns the list
                    $maId = Get-MA -MAName $MAName  #Get MA ID
                    if(-not $maId){throw "Cannot find MA"}

                    foreach($sp in $prop.storagePolicyInformationAssociatedToMA){
                        if($maId.Id -eq $sp.mediaAgent.mediaAgentId){
                                return $sp.storagePolicyAndCopy
                            }
                        }
                }
                else{
                    if($StoragePolicyName){ #StoragePolicy name passed, filter policies matching the storage policy
                        foreach($sp in $prop.policies){
                        if($StoragePolicyName -eq $sp.storagePolicyName){
                            return $sp
                            }
                        }
                    }
                    else{ return $prop.policies }
                }
            }
            else{ Write-Error ("Error getting storagepolicy list "+$prop)
            }
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-StoragePolicy module'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"