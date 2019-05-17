#
# JobMgrUtils.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Job utility functions.
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Job\Task utility functions

    .PARAMETER 
        NONE

    .OUTPUT
        NONE

    .Usage
        NONE

#>

#JobProperties object
function Get-JobObject(){
    $JobObject = @{}
    $JobObject.Add("ClientId","")                #Virtualization Client Id
    $JobObject.Add("SubclientId","")             #Subclient or Collection Id    
    $JobObject.Add("VMName","")                  #VM name 
    $JobObject.Add("commcellId",2)               #Commcell Id. Default it is set to 2
    $JobObject.Add("Jobtype",2)                  #Jobtype is backup type. Full - 1, Incrmental - 2, Synthfull - 3, also called backuplevel
    $JobObject.Add("runIncrementalBackup",$true) #RunIncremental by default set to 1
    $JobObject.Add("backupFailedVMs",$false)     #Backup failedVMs only option.  If set to 1, job will backup only failed VMs
    $JobObject.Add("collectMetaInfo",$false)     #If set to 1, metadata will be collected
    $JobObject.Add("SubclientObj","")  
    $JobObject.Add("subTaskType",2)  
    $JobObject.Add("operationType",2)  #Backup or Restore
    $JobObject.Add("taskType",1)  #Backup or Restore

    #Use this object to pass additional specific properties per agent.
    return $JobObject
}



#Function to get UUID by calling VMbrowse API
    function Get-SubclientBackupTask($JobObj){
        try{
                #Sample JSON request for submitting job
                <#
                        {
                           "taskInfo":{
                              "associations":[
                                 {
                                    "subclientId":83,
                                    "applicationId":33,
                                    "clientName":"VSASTACK01",
                                    "backupsetId":52,
                                    "instanceId":1,
                                    "subclientGUID":"4485258A-ECCB-40DB-A033-187728F14477",
                                    "clientId":698,
                                    "subclientName":"default",
                                    "backupsetName":"TEST",
                                    "instanceName":"DefaultInstanceName",
                                    "_type_":7,
                                    "appName":"File System",
                                    "flags":{

                                    }
                                 }
                              ],
                              "task":{
                                 "taskType":1
                              },
                              "subTasks":[
                                 {
                                    "subTask":{
                                       "subTaskType":2,
                                       "operationType":2
                                    },
                                    "options":{
                                       "backupOpts":{
                                          "backupLevel":2
                                       }
                                    }
                                 }
                              ]
                           }
                        }
                #>

                    
                    $TMMsg_CreateTaskReq = [ordered] @{}
                    $taskInfo            = [ordered] @{}
                    [System.Collections.ArrayList]$associations        = @()
                    $associatMap         = [ordered] @{}
                    $associatMap.Add("subclientId",$JobObj.SubclientId)
                    $associatMap.Add("clientName",$JobObj.SubclientObj.clientName)
                    $associatMap.Add("backupsetId",$JobObj.SubclientObj.backupsetId)
                    $associatMap.Add("instanceId",$JobObj.SubclientObj.instanceId)
                    $associatMap.Add("subclientGUID",$JobObj.SubclientObj.subclientGUID)
                    $associatMap.Add("clientId",$JobObj.ClientId)
                    $associatMap.Add("subclientName",$JobObj.SubclientName)
                    $associatMap.Add("backupsetName",$JobObj.SubclientObj.backupsetName)
                    $associatMap.Add("instanceName",$JobObj.SubclientObj.instanceName)
                    $associatMap.Add("_type_",$JobObj.SubclientObj._type_)
                    $associatMap.Add("appName",$JobObj.SubclientObj.appName)
                    $flags       = [ordered] @{}
                    $associatMap.Add("flags",$flags)
                    $associations.Add($associatMap)

                    $task        = @{}
                    $task.Add("taskType", $JobObj.taskType)

                    [System.Collections.ArrayList]$subTasks    = @()
                    $subTasksMap = @{}
                    $subTask     = @{}
                    $subTask.Add("subTaskType",$JobObj.subTaskType)
                    $subTask.Add("operationType",$JobObj.operationType)
                    $options     = @{}
                    $backupOpts  = @{}
                    $backupOpts.Add("backupLevel",$JobObj.Jobtype)
                    $options.Add("backupOpts",$backupOpts)
                    $subTasksMap.Add("subTask",$subTask)
                    $subTasksMap.Add("options",$options)
                    $subTasks.Add($subTasksMap)

                    $taskInfo.Add("associations", $associations)
                    $taskInfo.Add("task", $task)
                    $taskInfo.Add("subTasks", $subTasks)

                    $TMMsg_CreateTaskReq.Add("taskInfo",$taskInfo)

                    #End of Json prep
                    $body  = $TMMsg_CreateTaskReq | ConvertTo-Json -Depth 10
                    Write-Verbose -Message ("Json out from Create-BackupTask "+$body)
                    return @{"body" = $body}
        }
        catch
        {
            $errorString = ("Exception in Get-SubclientBackupTask method "+ $_.Exception.Message)
            Write-Verbose -Verbose $errorString
            return $null
        }
    }