#
# Recover-VM.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Restore the selected VM
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Starts the recovery job for the given VM

    .PARAMETER 
        -VMName        -> Mandatory argument, this is the VM name to be recovered.
        -ClientName    -> Mandatory parameter. Name of the client in which your VM to recover from.
    
    .OUTPUT
        Outputs the restore JobId on success else exception.

    .Usage
        Example1: Recover-VM -VMName myVM -Overwrite  Yes/No (Default no overwrite option selected)
        Example2: Recover-VM -VMname myVM -ClientName myClient 
        Example2: Recover-VM -VMname myVM -ClientName myClient -OutofplaceRecoveryProperties mydestinationObject

#>



function Recover-VM{
<#
        .Example
            Recover-VM -VMName myVM -Overwrite  Yes/No (Default no overwrite option selected)
        .Example
            Recover-VM -VMname myVM -ClientName myClient 
        .Example
            Recover-VM -VMname myVM -ClientName myClient -OutofplaceRecoveryProperties mydestinationObject

#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $VMName,

[Parameter(Mandatory = $False,  Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False, Position = 3)]   
[ValidateNotNullorEmpty()]
[String] $Overwrite,

[Parameter(Mandatory = $False, Position = 4)]   
[ValidateNotNullorEmpty()]
[String] $OutofplaceRecoveryProps

)
    Begin{

        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #prepare arguments
            if(-not $VMName){
                Write-Error -Message "Error - Please pass VMName" 
                return  
            }

            if($ClientName){
                $ClientObject =  Get-Client -Client $ClientName
                if(-not $ClientObject)
                {
                    Write-Error "Failed to get Client properties"
                    return 
                }
            }

             if($OutofplaceRecoveryProps){
                $OutofplaceObj =  Parse-OutofplaceRecoveryProps -Obj $OutofplaceRecoveryProps
                if(-not $ClientObject)
                {
                    Write-Error "Failed to get Client properties"
                    return 
                }
            }
           
            #Get the VM properties
            $VMProp = Get-VMlist -VMname $VMName
            if(-not $VMProp){
                Write-Error("Error - Failed to get VMProperties for the VM "+$VMName)
                return
            }
            #Validate VM object for valid backups
            else{
                if(-not $VMProp.vmStatus -eq 1){ throw "Backup not found for the VM"
                return }
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
            $body     = (Prepare-InplaceTask $RestoreObject).body
            if(-not $body){
                Write-Error "Failed to create recovery object"
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
            Write-Verbose -Verbose 'Error in Recover-VM Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"