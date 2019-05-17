#
# Mount-VM.psm1
# Author : Anand Venkatesh
# Company: Commvault
<#
    .DESCRIPTION
	    Mount VM from target media and power ir ON if selected.
	    Require minimum powershell version 5.0

    .SYNOPSIS
        Mount VM from target media and power ir ON if selected.

    .PARAMETER 
        -VMName        -> Mandatory argument, this is the VM name.
        -ClientName    -> Mandatory parameter. Name of the client in which your VM getting backeddup.
    
    .OUTPUT
        Outputs the JobId on success else exception.

    .Example 
        Mount-VM -VMName myVM
    .Example 
        Mount-VM -VMname myVM -ClientName myClient
    .Example 
        Mount-Vm -VMName myVM -PolicyName myLivemountPolicy
    .Example 
        Mount-VM -VMName myVM -JobId 100
#>

function Mount-VM{
<#
    .Example 
        Mount-VM -VMName myVM
    .Example 
        Mount-VM -VMname myVM -ClientName myClient
    .Example 
        Mount-Vm -VMName myVM -PolicyName myLivemountPolicy
    .Example 
        Mount-VM -VMName myVM -JobId 100
#>

[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $VMName,

[Parameter(Mandatory = $True, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False, Position = 2 )] #Use this when specific subclient to be used for the VM
[ValidateNotNullorEmpty()]
[String] $SubclientName,

[Parameter(Mandatory = $False, Position = 3)]  #This argument will be used to pick up certain Livemount policy
[ValidateNotNullorEmpty()]
[String] $PolicyName,

[Parameter(Mandatory = $False, Position = 3)]  #If want to mount VM from specific Job Id
[ValidateNotNullorEmpty()]
[String] $JobId
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
                    return 
                }
            }
            #Validate the subclientName
            if($SubclientName)
            {
                $SubclientObject = Get-Collection -ClientName $ClientName -CollectionName $SubclientName
                if(-not $SubclientObject)
                { throw ("Cannot find subclient matching "+$SubclientName)  
                    
                }
            }
            #Get the VM properties
            $VMProp = Get-VMProp -ClientId $ClientObject.clientId -VMname $VMName
            if(-not $VMProp){
                Write-Verbose -Message ("Error - Failed to get VMProperties for the VM "+$VMName)
                return
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
            $headerObject = Get-RestHeader($SessionObject)
            
            #Set request body which will be used to update the request
            $body     = (Create-BackupTask -jobProps $JobObject).body
            if(-not $body){
                Write-Error "Failed to create backup object"
                return
            }
         
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            
            if($prop.jobIds)
            {
                Write-Output ("Successfully submitted the job. JobId: "+$prop.jobIds)
                return $prop.jobIds
            }
            else{ Write-Error ("Error submitting the job "+$prop)
            }
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Protect-VM Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"