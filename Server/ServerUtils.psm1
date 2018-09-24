#
# ServerUtils.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Server utility functions.
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Server utility functions

    .PARAMETER 
        NONE

    .OUTPUT
        NONE

    .Usage
        NONE

#>
#Method to prepare DRBackup payload
function Get-DRBackupObject{
    $DRObj = @{}
    $DRObj.Add("isCompressionEnabled",$false)
    $DRObj.Add("jobType", 1)
    $DRObj.Add("backupType", 1)

    return $DRObj| ConvertTo-Json
}


#Method to prepare SendLog payload
function Prepare-SendLogPayload{
    param($payload)

    <# JSON request sample for SendLogFiles
    {  
   "taskInfo":{  
      "task":{  
         "taskType":1,
         "initiatedFrom":1,
         "policyType":0,
         "taskFlags":{  
            "disabled":false
         }
      },
      "subTasks":[  
         {  
            "subTask":{  
               "subTaskType":1,
               "operationType":5010
            },
            "options":{  
               "adminOpts":{  
                  "selectiveDeleteOption":{  

                  },
                  "sendLogFilesOption":{  
                     "actionLogsEndJobId":0,
                     "emailSelected":true,
                     "emailDescription":"",
                     "jobid":0,
                     "galaxyLogs":true,
                     "getLatestUpdates":false,
                     "actionLogsStartJobId":0,
                     "saveToLogDir":"",
                     "computersSelected":true,
                     "csDatabase":false,
                     "crashDump":true,
                     "isNetworkPath":false,
                     "saveToFolderSelected":false,
                     "notifyMe":true,
                     "includeJobResults":false,
                     "doNotIncludeLogs":true,
                     "machineInformation":true,
                     "emailSubject":"CommCell ID fe8c2 Logs for machines: PRODDEDUPE1 ",
                     "osLogs":true,
                     "actionLogs":false,
                     "includeIndex":false,
                     "databaseLogs":false,
                     "logFragments":false,
                     "uploadLogsSelected":true,
                     "useDefaultUploadOption":true,
                     "impersonateUser":{  
                        "useImpersonation":false
                     },
                     "emailids":[  
                        "support@commvault.com"
                     ],
                     "clients":[  
                        {  
                           "hostName":"172.24.40.62",
                           "clientId":5,
                           "clientName":"PRODDEDUPE1",
                           "displayName":"PRODDEDUPE1",
                           "clientGUID":"DF78C464-1BF9-4493-AC41-D0B752507B29"
                        }
                     ]
                  }
               }
            }
         }
      ]
   }
}
    #>
try{
   $TMMsg_CreateTaskReq = [ordered] @{}
   #taskInfo
        $taskInfo = [ordered]@{}
        $task     = [ordered]@{}
        $owner    = $global:ConnectionPool.user
        $task.Add("policyType",0)
        $task.Add("taskType",1)
        $task.Add("initiatedFrom",1)
        $task.Add("ownerName",$owner)
        $taskFlags = @{}
        $taskFlags.Add("disabled",$false)
        $task.Add("taskFlags", $taskFlags) 
        $taskInfo.Add("task",$task)

     #subtasks
        [System.Collections.ArrayList]$subTasks     = @()
        $subTasks_map = [ordered]@{}
        $subTask      = [ordered]@{}
        $subTask.Add("subTaskType", 1)
        $subTask.Add("operationType", 5010)
        $subTasks_map.Add("subTask", $subTask)

        #options
        $options    = [ordered]@{}
        $adminopts  = [ordered]@{}
        $selectiveDeleteOption = @{}
        $adminopts.Add("selectiveDeleteOption",$selectiveDeleteOption)
        $sendLogFilesOption     = [ordered]@{}
        $sendLogFilesOption.Add("actionLogsEndJobId",0)
        $sendLogFilesOption.Add("emailSelected",$true)
        $sendLogFilesOption.Add("emailDescription","")
        if($payload.ContainsKey("emailSubject")){
            $sendLogFilesOption.Add("emailSubject",$payload['emailSubject'])
        }
        if($payload.ContainsKey("JobId")){
            $iJobId = [int]$payload.JobId
            $sendLogFilesOption.Add("jobid",$iJobId)
        }
        $sendLogFilesOption.Add("galaxyLogs",$true)
        $sendLogFilesOption.Add("getLatestUpdates",$false)
        $sendLogFilesOption.Add("actionLogsStartJobId",0)
        $sendLogFilesOption.Add("saveToLogDir","")
        $sendLogFilesOption.Add("computersSelected",$true)
        $sendLogFilesOption.Add("csDatabase",$false)
        $sendLogFilesOption.Add("crashDump",$true)
        $sendLogFilesOption.Add("isNetworkPath",$false)
        $sendLogFilesOption.Add("saveToFolderSelected",$false)
        $sendLogFilesOption.Add("notifyMe",$true)
        $sendLogFilesOption.Add("includeJobResults",$false)
        $sendLogFilesOption.Add("doNotIncludeLogs",$true)
        $sendLogFilesOption.Add("machineInformation",$true)
        $sendLogFilesOption.Add("osLogs",$true)
        $sendLogFilesOption.Add("actionLogs",$false)
        $sendLogFilesOption.Add("includeIndex",$false)
        $sendLogFilesOption.Add("databaseLogs",$false)
        $sendLogFilesOption.Add("logFragments",$false)
        $sendLogFilesOption.Add("uploadLogsSelected",$true)
        $sendLogFilesOption.Add("useDefaultUploadOption",$true)

        $impersonateUser = [ordered]@{}
        $impersonateUser.Add("useImpersonation",$false)
        $sendLogFilesOption.Add("impersonateUser",$impersonateUser)

        #Email Ids
        

        [System.Collections.ArrayList]$emailids     = @()
        
        if($payload.ContainsKey("EmailId")){
            $emailids.Add($payload['EmailId'])
            $sendLogFilesOption.Add("emailids",$emailids)
        }
        else{#Default email id to Commvault support
            $emailids.Add('support@commvault.com')
            $sendLogFilesOption.Add("emailids",$emailids)
        }
        
        #Construct jobs array if JobId has been passed for SendLog
        if($payload.ContainsKey("JobId")){
            [System.Collections.ArrayList]$MultiJobIds     = @()
            $iJobId = [int]$payload.JobId
            $MultiJobIds.Add($iJobId)     
            $sendLogFilesOption.Add("multiJobIds",$MultiJobIds)
        }
        else{
            #construct client property map to reference client properties.
            [System.Collections.ArrayList]$clients     = @()
            if($payload.ContainsKey("ClientName")){
                $clientMap  = [ordered] @{}
                $clientProp = Get-Client -Client $payload['ClientName']

                $clientMap.Add("hostName",$clientProp.clienthostName)
                $clientMap.Add("clientId",$clientProp.clientId)
                $clientMap.Add("clientName",$clientProp.clientName)
                $clientMap.Add("displayName",$clientProp.clientName)
                $clientMap.Add("clientGUID",$clientProp.clientIdGUID)
            }
            $clients.Add($clientMap)
            $sendLogFilesOption.Add("clients",$clients)
        }

        $adminopts.Add("sendLogFilesOption",$sendLogFilesOption)
        $options.Add("adminOpts",$adminopts)

        $subTasks_map.Add("options", $options)
        $subTasks.Add($subTasks_map)
        
        $taskInfo.Add("subTasks",$subTasks)

        $TMMsg_CreateTaskReq.Add("taskInfo", $taskInfo)
         
         #End of Json prep
        $body  = $TMMsg_CreateTaskReq | ConvertTo-Json -Depth 10
        Write-Verbose -Message ("Json out from Create-SendLogFile "+$body)
        return @{"body" = $body}
}#try
catch{
        Write-Error("Exception in Create-SendLogFiles task "+$_.Exception.Message)
        return $null
}

}

