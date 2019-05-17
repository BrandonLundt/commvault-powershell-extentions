#
#Get-VSAConstants.psm1
#Author : Anand Venkatesh
#Company: Commvault
<#
    .DESCRIPTION
	    Holds VSA constants
	    Require minimum powershell version 3.0

    .SYNOPSIS
        VSA constants file.

    .PARAMETER 
   
    .OUTPUT
        VSA constants.

    .Usage
        Get-VSAConstants -VSAObject 
#>

#Global values
function Get-Globals{
    $Commcellglobals = @{}
    $Commcellglobals.Add("commcellId", 2)
    $Commcellglobals.Add("DefaultSubclient","default")

    return $Commcellglobals
}

#VM object 
function Get-VMObject{
    $EntityObj  = @{}
    $EntityObj.Add("Entity", "")           #Entity Name can be say: VM name in format like VM1, VM2, VM3
    $EntityObj.Add("EntityType", "")       #Virtualization entity type. ESX Host, Datastore, VM, Cluster...etc 
    $EntityObj.Add("OperationType", "")    #DELETE or ADD  or OVERWRITE
    $EntityObj.Add("ClientId", "")         #Virtualization clientId
    
    return $EntityObj
}

#JobProperties object
function Get-JobObject(){
    $JobObject = @{}
    $JObObject.Add("ClientId","")             #Virtualization Client Id
    $JObObject.Add("SubclientId","")          #Subclient or Collection Id    
    $JObObject.Add("VMName","")               #VM name 
    $JObObject.Add("commcellId",2)          #Commcell Id. Default it is set to 2
    $JObObject.Add("Jobtype",2)             #Jobtype is backup type. Full - 1, Incrmental - 2, Synthfull -3
    $JObObject.Add("runIncrementalBackup",$true)#RunIncremental by default set to 1
    $JObObject.Add("backupFailedVMs",$false)     #Backup failedVMs only option.  If set to 1, job will backup only failed VMs
    $JObObject.Add("collectMetaInfo",$false)     #If set to 1, metadata will be collected

    return $JObObject
}


function Get-VSAConstants($objName){
try{
    
    #VSA object type
    $VSAEntityObj = @{
                SERVER	    = 1
                RES_POOL    = 2
                VAPP	    = 3
                DATACENTER	= 4
                FOLDER	    = 5
                CLUSTER	    = 6
                DATASTORE	= 7
                DATASTORE_CLUSTER = 8
                VM	        = 9
                VMName	    = 10
                VMGuestOS	= 11
                VMGuestHostName	= 12
                ClusterSharedVolumes = 13
                LocalDisk   = 14
                ClusterDisk	= 15
                UnprotectedVMs=	16
                ROOT	    = 17
                FileServer	= 18
                SMBShare	= 19
                TypesFolder	= 20
                VMFolder	= 21
                ServerFolder= 22
                TemplateFolder = 23
                StorageRepositoryFolder	= 24
                VAppFolder	= 25
                DatacenterFolder = 26
                ClusterFolder= 27
                VMPowerState = 28
                VMNotes	     = 29
                VMCustomAttribute = 30
                Network	     = 31
                User	     = 32
                VMTemplate	 = 33
                Tag	         = 34
                TagCategory	 = 35
                Subclient	 = 36
                ClientGroup	 = 37
                ProtectionDomain = 38
                ConsistencyGroup = 39
                InstanceSize = 40
                Organization = 41
    
        }
        return $VSAEntityObj.$objName


}
catch{
    $ErrorMessage = $_.Exception.Message
    $errString = "Error: exception in Get-VSAConstants "+$ErrorMessage
    
    Write-Verbose -Verbose $errString
}

}

<#
class VMInfo
{
   
   
   #constructor
    VMInfo([String]$VendorType){
                switch($VendorType){
                    ("VMware") {"VMware"; break}
                    ("Hyperv") {"Hyperv"; break}
                    (default)  {"VMware"; break}
                }
        }
}
#>