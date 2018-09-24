#
# Get-LastBackup.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets the last backup details for the VM.
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Gets the last backedup details for the VM including time, job id

    .PARAMETER 
        -VMname        
        
    .OUTPUT
        list last backup details if VM was backed earlier

    .Usage
        Example1: Get-LastBackup -VMName <MyVM>
#>

function Get-LastBackup{
<#
    .Example
        Get-LastBackup -VMName <MyVM>
    .Example
        Get-LastBackup -VMName <MyVM> -ClientName <virtualization(vCenter name)>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0)]
            $VMName,
[Parameter(Mandatory = $False, Position = 0)]
            $ClientName
)

    Begin{

        try{
          if(-not $VMName){
            Write-Error("Please pass valid VM Name ""$($VMName)"" ")
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
            if($ClientName){
                $backupObj = Get-VMlist -VMName $VMName -ClientName $ClientName }
            
            else{ $backupObj = Get-VMlist -VMName $VMName }
            
              if($backupObj.vmStatus -eq 1){
                $lastbackupTime = $backupObj |`
                Select  @{Name="LastBackupTime";Expression={[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.bkpEndTime))}}|`
                Select -ExpandProperty "LastBackupTime"
                
                return $lastbackupTime
           }
           else{
                $Error = "Backup not found for the VM "+$VMName
                Write-Error($Error)
                return $Error
           }

    }
    catch{
            $errorString = ("Exception in Get-LastBackup method ""$($_.Exception.Message)""")
            Write-Verbose -Verbose $errorString
            return $null
         }
    }

}

Export-ModuleMember -Function "*"