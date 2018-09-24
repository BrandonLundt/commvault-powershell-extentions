#
# Protect-VM.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Starts backup for the selected VM
	    Require minimum powershell version 3.0

    .SYNOPSIS
        Starts the backup job for the given VM

    .PARAMETER 
        -VMName        -> Mandatory argument, this is the VM name.
        -ClientName    -> Mandatory parameter. Name of the client in which your VM getting backeddup.
        -SubclientName -> Optional paramater. Name of the subclient in which your VM getting backed up.
        -Type    -> Optional paramater. Override the protection type by specifying string Full or Synthfull. By default this commandlet will run incremental job for the VM.
        
    
    .OUTPUT
        Outputs the JobId on success else exception.

    .Usage
        Example1: Protect-VM -VMName myVM
        Example2: Protect-VM -VMname myVM -ClientName myClient -Type Full

#>

function Protect-VM{
<#
     .Example
        Protect-VM -VMName myVM
     .Example
        Protect-VM -VMname myVM -ClientName myClient -Type Full
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $VMName,

[Parameter(Mandatory = $True, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False, Position = 2 )] #Use this parameter if you want to override the default behaviour.
[ValidateNotNullorEmpty()]
[String] $SubclientName,

[Parameter(Mandatory = $False, Position = 3)]  #Use this parameter if you would like to force backup type.
[ValidateNotNullorEmpty()]
[String] $JobType


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
            #Validate the subclientName
            if($SubclientName)
            {
                $SubclientObject = Get-Collection -ClientName $ClientName -CollectionName $SubclientName
                if(-not $SubclientObject)
                { throw ("Cannot find subclient matching "+$SubclientName)  
                    
                }
            }
            else
            {   #Subclient name not passed, so get defaultSubclient name
                $globalsObj     = Get-Globals 
                $SubclientName  = $globalsObj.DefaultSubclient 
                Write-Verbose -Verbose("Subclient name not provided so getting Id for default")
                $SubclientObject = Get-Collection -ClientName $ClientName -CollectionName $SubclientName
            }
            #Get the VM properties
            $VMProp = Get-VMProp -ClientId $ClientObject.clientId -VMname $VMName
            if(-not $VMProp){
                Write-Verbose -Message ("Error - Failed to get VMProperties for the VM "+$VMName)
                return
            }

            #Prepare jobObject
            $VMProp = Get-VMProp -ClientId $ClientObject.ClientId -VMname $VMName
            $JobObject              = Get-JobObject
            $JobObject["ClientId"]  = $ClientObject.ClientId
            $JobObject["VMName"]    = $VMName
            if($JobType){
                    $JobObject["Jobtype"]      = $JobType}
            if($SubclientObject){
                    if($VMProp.vmStatus -eq 1)
                    {
                        $JObObject["SubclientId"]  = $VMProp.subclientId
                    }
                     
                    else
                    {
                            #This condition will be executed when provided VM never got backedup.
                            Write-Verbose -Verbose("VM never backedup, and since no subclient name passed this VM will be added to defaultSubclient")
                            $SubclientObject = Get-Collection -ClientName $ClientName -CollectionName $SubclientName
                            $JObObject["SubclientId"]  = $SubclientObject.subclientId
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