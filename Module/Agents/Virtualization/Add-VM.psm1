
<#
   .SYNOPSIS
        Adds VM as a content to subclient\Collection.

    .PARAMETER 
        -ClientName    -> Name of the client in subclient exists
        -SubclientName ->Subclient name to which content to be added. If this parametrer not passed, commandlet assumes default
        -EntityType    -> EntityType can be VM, Host or Cluster etc
        -Entity        -> VirtualMachine Name, Datastore name etc
        
    
    .OUTPUTS
        Adds content to subclient.

    .EXAMPLE
        Example1: Add-VM -ClientName <myClient>  -SubclientName <testSubclient> -EntityType <VM> -Entity <myVM>
        Example2: Add-VM -ClientName <myClient>  -EntityType <VM> -Entity <VM1,VM2,VM3>

        More details on entityTYpe
        Object	Numeric Value	Text Value
            Server Host Name or IP Address	1	SERVER
            Resource Pool	2	RES_POOL
            vApp	3	VAPP
            Datacenter	4	DATACENTER
            Folder	5	FOLDER
            Cluster	 6	CLUSTER
            Datastore Name	7	DATASTORE
            Datastore Cluster	8	DATASTORE_CLUSTER
            Virtual Machine GUID	9	VM
            Virtual Machine Name or Pattern	10	VMName
            Virtual Machine Guest OS	11	VMGuestOS
            Virtual Machine Guest Host Name	12	VMGuestHostName
            Cluster Shared Volumes	13	ClusterSharedVolumes
            Local Disk	14	LocalDisk
            Cluster Disk	15	ClusterDisk
            Unprotected VMs	16	UnprotectedVMs
            All	17	ROOT
            File Server	18	FileServer
            Share	19	SMBShare
            Types	20	TypesFolder
            VMs	21	VMFolder
            Servers	22	ServerFolder
            Custom Templates	23	TemplateFolder
            Datastore List	24	StorageRepositoryFolder
            vApp List	25	VAppFolder
            Datacenters	26	DatacenterFolder
            Clusters	27	ClusterFolder
            Virtual Machine Power State	28	VMPowerState
            Virtual Machine Notes	29	VMNotes
            Virtual Machine Custom Attribute	30	VMCustomAttribute
            Network Adapter	31	Network
            User	32	User
            Virtual Machine Template	33	VMTemplate
            Tag	34	Tag
            Tag Category	35	TagCategory
            Subclient	36	Subclient
            Client Group	37	ClientGroup
            Protection Domain	38	ProtectionDomain
            Consistency Group	39	ConsistencyGroup
            Instance Size	40	InstanceSize
            Organization	41	Organization 
#>
function Add-VM{
<#
    .EXAMPLE  
        Add-VM -ClientName <myClient>  -SubclientName <testSubclient> -EntityType <VM> -Entity <myVM>
    .Example 
        Add-VM -ClientName <myClient>  -EntityType <VM> -Entity <VM1,VM2,VM3>
#>



[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $False)]
[ValidateNotNullorEmpty()]
[String] $SubclientName,

[Parameter(Mandatory = $True, Position = 1 )] #Example: Datastore, Folder, Cluster, Host etc if VMware.
[ValidateNotNullorEmpty()]
[String] $EntityType,

[Parameter(Mandatory = $True, Position = 2)] #Example: Name of the entity. This can be comma separated list
[ValidateNotNullorEmpty()]
[String] $Entity

)
    Begin{

        try{
            #OperationType
            $OperationType = "ADD"
            
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
           
            #prepare arguments
            $ClientObject =  Get-Client -Client $ClientName
            if(-not $ClientObject)
            {
                Write-Error "Failed to get Client properties"
                return 
            }
        
            #Validate the subclientName
            if($SubclientName)
            {
                $SubclientObject = Get-Collection -ClientName $ClientName -CollectionName $SubclientName
                if(-not $SubclientObject)
                { throw ("Cannot find subclient matching "+$SubclientName)  
                    
                }
            }
            #Prepare object to act on
            $EntityObj  = Get-VMObject
            $EntityObj["Entity"]        = $Entity                #Entity Name can be say: VM name in format like VM1, VM2, VM3 
            $EntityObj["EntityType"]    = $EntityType           #Virtualization entity type. ESX Host, Datastore, VM, Cluster...etc 
            $EntityObj["OperationType"] = $OperationType         #DELETE or ADD  or OVERWRITE
            $EntityObj["ClientId"]      = $ClientObject.clientId #Virtualization clientId
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
            $endPoint = $headerObject.endpoint
            
            #Update the endpoint
            $endPoint = $endPoint -creplace("SubclientId",$SubclientObject.subclientId) 
            $headerObject.endpoint = $endPoint

            #Set request body which will be used to update the request
            $body    = Prepare-Content -EntityObj $EntityObj
            if(-not $body)
            {
                return "Entity type not found"
            }
            Write-Verbose ("Consturcted json: "+$body[1])
         
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body[1])

             #Submit request
            $prop = Submit-Restrequest($Payload)

            if($prop.response)
            {
                $outString = "Added the entity "+ $Entity
                return $outString
            }
            else{ Write-Error $prop
            }
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-Client Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"