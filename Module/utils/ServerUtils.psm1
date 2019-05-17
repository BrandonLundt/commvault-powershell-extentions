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
        $taskFlags = [ordered] @{}
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
        $selectiveDeleteOption = [ordered] @{}
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

#Method to prepare Get-SLA payload
function Prepare-GetSLAPayLoad{
    param($payload)

    <# Sample JSON request
        {            "countScheduledJobs":0,"pageSize":20,"type":1,"countFullJobsOnly":0,"days":0,"category":4,"status":2,"localeId":{            "country":"US","language":"en","localeName":"en-us"            }        }

        OR
        {            "type":1,"countFullJobsOnly":0,"days":0,"category":4,"status":2        }

//=== SLA Report ===//

enum SLA_Type
{
    ByClient        = 1,
    ByAgentType     = 2
}

enum SLA_Status
{
    Any             = 0,
    Protected       = 1,
    Unprotected     = 2,
    Excluded        = 3
}

enum SLA_Category
{
    Any             = 0,
    // Protected
    Protected       = 1,
    // Unprotected
    Failed          = 2,
    NoJobFound      = 3,
    NoSchedule      = 4,
    SnapNoBackupCopy= 12,
    // Excluded
    BackupActivityDisabled = 5,
    LongtimeOffline = 6,
    Deconfigured    = 7,
    ExcludedFromSLAProperty = 8,
    DoNotBackupVM   = 9,
    RecentlyInstalledNoJob = 10,
    ExcludedServerType = 11

}
    #>

    try{
        $map_SLA = [ordered]@{}
        $map_SLA.Add("type",$payload.type)
        $map_SLA.Add("category",$payload.category)
        $map_SLA.Add("status",$payload.status)

        $body  = $map_SLA | ConvertTo-Json -Depth 10
        Write-Verbose -Message ("Json out from Prepare-GetSLAPayload "+$body)
        return @{"body" = $body}
    }
    catch{
        Write-Error("Exception in Prepare-GetSLA task "+$_.Exception.Message)
        return $null
    }
}



#Method to Push-install client
function Prepare-PushInstall{
    param($payload)

    <# Sample JSON request
            {  
               "taskInfo":{  
                  "associations":[  
                     {  
                        "commCellId":2
                     }
                  ],
                  "task":{  
                     "taskType":1,
                     "initiatedFrom":1,
                     "taskFlags":{  
                        "disabled":false
                     }
                  },
                  "subTasks":[  
                     {  
                        "subTask":{  
                           "subTaskType":1,
                           "operationType":4026
                        },
                        "options":{  
                           "adminOpts":{  
                              "clientInstallOption":{  
                                 "reuseADCredentials":false,
                                 "installOSType":0,
                                 "discoveryType":0,
                                 "installerOption":{  
                                    "requestType":0,
                                    "Operationtype":0,
                                    "CommServeHostName":"vsavccs",
                                    "RemoteClient":false,
                                    "installFlags":{  
                                       "allowMultipleInstances":true,
                                       "restoreOnlyAgents":false,
                                       "killBrowserProcesses":true,
                                       "install32Base":false,
                                       "disableOSFirewall":false,
                                       "stopOracleServices":false,
                                       "skipClientsOfCS":false,
                                       "addToFirewallExclusion":true,
                                       "ignoreJobsRunning":false,
                                       "forceReboot":false,
                                       "overrideClientInfo":true,
                                       "firewallInstall":{  
                                          "enableFirewallConfig":false,
                                          "firewallConnectionType":0,
                                          "portNumber":0
                                       }
                                    },
                                    "User":{  
                                       "userName":"admin",
                                       "userId":1
                                    },
                                    "clientComposition":[  
                                       {  
                                          "packageDeliveryOption":0,
                                          "overrideSoftwareCache":false,
                                          "components":{  
                                             "commonInfo":{  
                                                "globalFilters":2
                                             },
                                             "fileSystem":{  
                                                "configureForLaptopBackups":false
                                             },
                                             "componentInfo":[  
                                                {  
                                                   "osType":"Windows",
                                                   "ComponentId":703
                                                }
                                             ]
                                          },
                                          "clientInfo":{  
                                             "client":{  
                                                "evmgrcPort":0,
                                                "cvdPort":0
                                             }
                                          }
                                       }
                                    ]
                                 },
                                 "clientDetails":[  
                                    {  
                                       "clientEntity":{  
                                          "clientName":"172.24.19.0",
                                          "commCellId":2
                                       }
                                    }
                                 ],
                                 "clientAuthForJob":{  
                                    "password":"YnVpbGRlciExMg==",
                                    "userName":"Administrator"
                                 }
                              },
                              "updateOption":{  
                                 "rebootClient":true
                              }
                           }
                        }
                     }
                  ]
               }
            }
    #>

    try{
        #taskInfo
        $taskInfo    = [ordered] @{}

        #Associations
        [System.Collections.ArrayList] $associations_arr  = @()
        $assocations_items = [ordered] @{}
        $assocations_items.Add("commCellId",$payload.CommcellId)
        $associations_arr.Add($assocations_items)

        #task
        $task   = [ordered] @{}
        $task.Add("taskType",1)
        $task.Add("initiatedFrom",1)
        $taskFlags = [ordered] @{}
        $taskFlags.Add("disabled", $false)
        $task.Add("taskFlags",$taskFlags)
        
        #Subtasks
        [System.Collections.ArrayList] $subTasks_arr = @()
        $subTasks_dic = [ordered] @{}
        $subTask      = [ordered] @{}
        $subTask.Add("subTaskType", 1)
        $subTask.Add("operationType", 4026)
        $subTasks_dic.Add("subTask", $subTask)

        #Options
        $options      = [ordered] @{}
        $adminOpts    = [ordered] @{}
        $clientInstallOption =    [ordered] @{}
        $clientInstallOption.Add("reuseADCredentials",$false)
        $clientInstallOption.Add("installOSType", 0)
        $clientInstallOption.Add("discoveryType", 0)

        $installerOption =  [ordered] @{}
        $installerOption.Add("requestType", 0)
        $installerOption.Add("Operationtype", 0)
        $installerOption.Add("CommServeHostName", $payload.CommServName) #update this
        $installerOption.Add("RemoteClient", $false)

        $installFlags = [ordered] @{}
        $installFlags.Add("allowMultipleInstances", $true)
        $installFlags.Add("restoreOnlyAgents", $false)
        $installFlags.Add("killBrowserProcesses", $true)
        $installFlags.Add("install32Base", $false)
        $installFlags.Add("disableOSFirewall", $false)
        $installFlags.Add("stopOracleServices", $false)
        $installFlags.Add("skipClientsOfCS", $false)
        $installFlags.Add("addToFirewallExclusion", $true)
        $installFlags.Add("forceReboot", $false)
        $installFlags.Add("overrideClientInfo", $true)
        $firewallnstall = [ordered] @{}
        $firewallnstall.Add("enableFirewallConfig", $false)
        $firewallnstall.Add("firewallConnectionType", 0)
        $firewallnstall.Add("portNumber", 0)
        $installFlags.Add("firewallInstall", $firewallnstall)
        $installerOption.Add("installFlags", $installFlags)

        $user        = [ordered] @{}
        $user.Add("userName", $payload.Commcelluser) #update this
        $user.Add("userId", 1)
        $installerOption.Add("User", $user)

        [System.Collections.ArrayList] $clientComposition_arr  = @()
        $clientComposition_dic  = [ordered] @{}
        $clientComposition_dic.Add("packageDeliveryOption", 0)
        $clientComposition_dic.Add("overrideSoftwareCache", $false)
        $components             = [ordered] @{}
        $commonInfo             = [ordered] @{}
        $commonInfo.Add("globalFilters",2)
        $components.Add("commonInfo",$commonInfo)
        $filesystem             = [ordered] @{}
        $filesystem.Add("configureForLaptopBackups", $false)
        $components.Add("fileSystem",$filesystem)
        $componentInfo          = [ordered] @{}
        [System.Collections.ArrayList] $comonentInfo_arr       = @()
        $componentInfo.Add("osType",$payload.OS) #update
        $componentInfo.Add("ComponentId", [int]$payload.ComponentId) #update
        $comonentInfo_arr.Add($componentInfo)
        $components.Add("componentInfo",$comonentInfo_arr)
        $clientComposition_dic.Add("components", $components)
        $clientInfo             = [ordered] @{}
        $client                 = [ordered] @{}
        $client.Add("evmgrcPort",0)
        $client.Add("cvdPort",0)
        $clientInfo.Add("client", $client)
        $clientComposition_dic.Add("clientInfo", $clientInfo)
        $clientComposition_arr.Add( $clientComposition_dic)
        $installerOption.Add("clientComposition", $clientComposition_arr)

        $clientInstallOption.Add("installerOption", $installerOption)

        [System.Collections.ArrayList] $clientDetails_arr      = @()
        $clientDetails_dic      = [ordered] @{}
        $clientEntity           = [ordered] @{}
        $clientEntity.Add("clientName", $payload.ClientName) #update
        $clientEntity.Add("commCellId", $payload.CommcellId)
        $clientDetails_dic.Add("clientEntity",$clientEntity)
        $clientDetails_arr.Add($clientDetails_dic)
        
        $clientInstallOption.Add("clientDetails", $clientDetails_arr)

        $clientAuthForJob       = [ordered] @{}
        $clientAuthForJob.Add("password", $payload.ClientPwd) #update
        $clientAuthForJob.Add("userName", $payload.ClientUser) #update

        $clientInstallOption.Add("clientAuthForJob", $clientAuthForJob)

        $adminOpts.Add("clientInstallOption",$clientInstallOption)

        $updateOption          = [ordered] @{}
        $updateOption.Add("rebootClient", $true) #update


        $adminOpts.Add("updateOption",$updateOption)

        $options.Add("adminOpts", $adminOpts)

        $subTasks_dic.Add("options", $options)
        $subTasks_arr.Add($subTasks_dic)

        $taskInfo.Add("associations", $associations_arr)
        $taskInfo.Add("task", $task)
        $taskInfo.Add("subTasks", $subTasks_arr)

        $taskInfo_dic = [ordered] @{}
        $taskInfo_dic.Add("taskInfo",$taskInfo)

        $body  = $taskInfo_dic | ConvertTo-Json -Depth 20
        Write-Verbose -Message ("Json out from Prepare-PushInstall "+$body)
        return @{"body" = $body}
    }
    catch{
        Write-Error("Exception in Prepare-PushInstall task "+$_.Exception.Message)
        return $null
    }
}

