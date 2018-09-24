#
# VMutils.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    VM utility functions.
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        VM utility functions

    .PARAMETER 
        NONE

    .OUTPUT
        NONE

    .Usage
        NONE

#>


    #Function to get VM properties
    function Get-VMProp($ClientId, $VMname){
    try{
         #get Session
            $sessionToken = $global:ConnectionPool.token
            $BrowseAPI = "Perform-VMBrowse"
            #Get properties for processing REST call
            $requestProps = (Get-RestAPIDetails -request $BrowseAPI)

            #Validate the session
            $isSessionValid = validateSession($sessionToken)
            if($isSessionValid -eq $false)
            {
                #Write-Error 'Error: Session timeout. Please login again'
                return      'Error: Session timeout. Please login again'
            }

            #Prepare GET request
            $header   = @{Accept = 'application/json'; Authtoken = $sessionToken}
            $method   = $requestProps.Method
            $endPoint = $requestProps.Endpoint
            
            $endPoint = $endPoint -creplace("{Id}",$ClientId) 
            $baseUrl  = (Get-BaseUrl $global:ConnectionPool.server $global:ConnectionPool.port)

            #Set request body which will be used to update the request
            $body     = ""
             #Submit request
            Write-Verbose -Message 'Submitting GetClient Request'
	        $response = (Process-Request $header $body $baseUrl $endPoint $method)
            $prop     = validateResponse($response)
            if($prop)
            {
                foreach($vmRecord in $prop.vmStatusInfoList)
                {
                    #If VM backedup by Commvault we will get properties as below
                    #$vmRecord.
                    <#
                        vmHost        : 172.24.25.144
                        vmGuestSpace  : 79345958912
                        bkpStartTime  : 1518065866
                        type          : 9
                        vmStatus      : 1
                        vmBackupJob   : 76
                        strOSName     : Microsoft Windows Server 2012 (64-bit)
                        vmSize        : 107374850220
                        vmUsedSpace   : 78864449536
                        subclientId   : 8
                        bkpEndTime    : 1518067853
                        vmAgent       : vsavccs
                        name          : 100GB-Thick-Eager0-Data75G-DR
                        vmHardwareVer : vmx-13
                        strGUID       : 501be2df-9a2d-d184-5b3e-7361135609fb
                        subclientName : TEST1
                    #>
                    if($vmRecord.name -eq $VMName)
                    {
                        $bFound = $true
                        break
                    }
                }
                if($bFound)
                {
                    return $vmRecord
                }
                else{ return $null }
            }
    }
    catch{
            $errorString = ("Exception in Get-VMProp method "+ $_.Exception.Message)
            Write-Verbose -Verbose $errorString
            return $null
         }

    }

    #Function to get UUID by calling VMbrowse API
    function Get-VMUUID($ClientId, $VMName){
        try{
                $VMProp = Get-VMProp -ClientId $ClientId -VMname $VMName
                
                if($VMProp.strGUID)
                {
                    Write-Verbose -Message ("Found GUID for the VM "+$VMName +" "+$VMProp.strGUID)
                    return $VMProp.strGUID
                }
                else{ 
                    Write-Verbose -Verbose ("GUID not found for the VM "+ $VMName)
                    return $null }
           
            
        }
        catch
        {
            $errorString = ("Exception in Get-VMUUID method "+ $_.Exception.Message)
            Write-Verbose -Verbose $errorString
            return $null
        }
    }


    #Function to prepare VM content. this returns an object that can be used for Add or Remove content REST API
    function Prepare-Content($EntityObj){
        try{
            [System.Collections.ArrayList]$childrenNode = @()

            if($EntityObj.Entity)
                {
                    $values = $EntityObj.Entity -split ","
                    if($values)
                    {
                        foreach($val in $values)
                        {
                            #Default UUID will be null
                            $uuid = $null
                            $uuid = (Get-VMUUID -ClientId $EntityObj.ClientId -VMName $EntityObj.Entity)
                            if(-not $uuid){
                                Write-Verbose -Verbose "VM GUID not found"
                                return $null
                            }
                            $constantObj = Get-VSAConstants -objName $EntityObj.EntityType
                            $VMObj = [ordered]@{}
                            $VMObj.Add("allOrAnyChildren" , $true)
                            $VMObj.Add("displayName"      , $val)
                            $VMObj.Add("equalsOrNotEquals", $true)
                            $VMObj.Add("name"             , $uuid)
                            if($constantObj -eq "" -or $constantObj -eq $null)
                            {
                                $constantObj = 10
                            }
                            $VMObj.Add("type"             , $constantObj)
                            $VMObj.Add("path"             , "")
                            $childrenNode.Add($VMObj)
                        }
                    }

                }
            else{ return $null
            }

                #Prepare request payload
                $rootObj                = @{}
                $subClientProp          = @{}
                $children               = @{}
                $children.Add("children", $childrenNode)
                $subClientPropertiesObj = @{}
                $subClientPropertiesObj.Add("vmContentOperationType",$EntityObj.OperationType)
                $subClientPropertiesObj.Add("vmDiskFilterOperationType",1)
                $subClientPropertiesObj.Add("vmFilterOperationType",1)
                $subClientPropertiesObj.Add("vmContent" , $children)


                $subClientProp.Add("subClientProperties", $subClientPropertiesObj)
                #$rootObj.Add("App_UpdateSubClientPropertiesRequest", $subClientProp)
                $body = $subClientProp | ConvertTo-Json -Depth 10
                return $body
            }
        catch{
            $errorString = ("Failed to construct VM content " + $_.Exception.Message )
            Write-Verbose -Verbose $errorString
            return $errorString
        }
    }

#Creates backup Json for the VM 
#ClientId -->VirtualizationClientId
#VMname   --> VMName string type
#JobType  --> Backup job type Full = 1, Incremental = 2, Synthfull = 3
function Create-BackupTask($jobProps)
{
    <# JSON request smaple for VM backup
        {
  "processinginstructioninfo": {
    "locale": {
      "_type_": 66,
      "localeId": 0
    },
    "formatFlags": {
      "skipIdToNameConversion": true
    },
    "user": {
      "_type_": 13,
      "userName": "",
      "userId": 1
    }
  },
  "taskInfo": {
    "associations": [
      {
        "srmReportSet": 0,
        "subclientId": 8,
        "srmReportType": 0,
        "commCellId": 2,
        "_type_": 3
      }
    ],
    "task": {
      "taskType": 1,
      "ownerName": "admin",
      "initiatedFrom": 1,
      "policyType": 0,
      "taskFlags": {
        "disabled": false
      }
    },
    "subTasks": [
      {
        "subTask": {
          "subTaskName": "web sub task",
          "subTaskType": 2,
          "operationType": 2
        },
        "options": {
          "backupOpts": {
            "collectMetaInfo": false,
            "backupLevel": 2,
            "runIncrementalBackup": true,
            "isSpHasInLineCopy": false,
            "vsaBackupOptions": {
              "backupFailedVMsOnly": false,
              "selectiveVMInfo": [
                {
                  "vmGuid": "501b94e8-284d-cfac-c9d5-12cada55f66d"
                }
              ]
            }
          },
          "adminOpts": {
            "updateOption": {
              "invokeLevel": 0
            }
          }
        }
      }
    ]
  }
}
    #>

    try{
        $VMprop = Get-VMProp -ClientId $jobProps.ClientId -VMname $jobProps.VMName
        if(-not $VMprop){
            Write-Verbose -Message ("Error - Cannot get VM properties for the VM "+$jobProps.VMName)
            return    }

        #Building json
        
        $TMMsg_CreateTaskReq = [ordered] @{}
        #processinginstructioninfo
        $processinginstructioninfo = [ordered]@{}
        $locale       = @{}
        $locale.Add("_type_",66)
        $locale.Add("localeId",0)
        $formatFlags  = @{}
        $formatFlags.Add("skipIdToNameConversion", $true)
        $user         = @{}
        $user.Add("_type_", 13)
        $user.Add("userName", "")
        $user.Add("userId", 1)
        $processinginstructioninfo.Add("locale", $locale)
        $processinginstructioninfo.Add("formatFlags", $formatFlags)
        $processinginstructioninfo.Add("user", $user)

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

        #associations
        [System.Collections.ArrayList]$associations = @()
        $temp_array   = [ordered]@{}
        $temp_array.Add("srmReportSet",0)
        $temp_array.Add("subclientId",$jobProps.subclientId)
        $temp_array.Add("srmReportType",0)
        $temp_array.Add("commCellId",$jobProps.commcellId)
        $temp_array.Add("_type_",3)
        $associations.Add($temp_array)

        #subtasks
        [System.Collections.ArrayList]$subTasks     = @()
        $subTasks_map = [ordered]@{}
        $subTask      = [ordered]@{}
        $subTask.Add("subTaskName", "web sub task")
        $subTask.Add("subTaskType", 2)
        $subTask.Add("operationType", $jobProps.Jobtype)
        $subTasks_map.Add("subTask", $subTask)

        #options
        $options    = [ordered]@{}
        $backupOpts = [ordered]@{}
        $backupOpts.Add("backupLevel", $jobProps.Jobtype)
        $backupOpts.Add("runIncrementalBackup", $jobProps.runIncrementalBackup)
        $backupOpts.Add("isSpHasInLineCopy", $false)
        $backupOpts.Add("collectMetaInfo", $jobProps.collectMetaInfo)
        $vsaBackupOptions = @{}
        $vsaBackupOptions.Add("backupFailedVMsOnly",$jobProps.backupFailedVMs)
        [System.Collections.ArrayList]$selectiveVMInfo  = @()
        $temp_array       = @{}
        $temp_array.Add("vmGuid", $VMprop.strGUID)
        $selectiveVMInfo.Add($temp_array)
        $vsaBackupOptions.Add("selectiveVMInfo",$selectiveVMInfo)
        $backupOpts.Add("vsaBackupOptions", $vsaBackupOptions)
        $options.Add("backupOpts", $backupOpts)
        

        #adminOpts
        $adminOpts    = @{}
        $updateOption = @{}
        $updateOption.Add("invokeLevel",0)
        $adminOpts.Add("updateOption",$updateOption)
        $options.Add("adminOpts", $adminOpts)
        $subTasks_map.Add("options", $options)

        #SubTasks Array
        $subTasks.Add($subTasks_map)

        #Add sub sections to taskInfo
        $taskInfo.Add("associations", $associations)
        $taskInfo.Add("task", $task)
        $taskInfo.Add("subTasks", $subTasks)
        
        #Add subItems to the root
        $TMMsg_CreateTaskReq.Add("processinginstructioninfo",$processinginstructioninfo)
        $TMMsg_CreateTaskReq.Add("taskInfo",$taskInfo)

        #End of Json prep
        $body  = $TMMsg_CreateTaskReq | ConvertTo-Json -Depth 10
        Write-Verbose -Message ("Json out from Create-BackupTask "+$body)
        return @{"body" = $body}
    }
    catch{
        Write-Error("Exception in Create-BackupTask "+$_.Exception.Message)
        return $null
    }
}

#Prepare inplaceRestore JSON
function Prepare-InplaceTask($RestoreObject)
{
    try{
        $inPlaceFlag = $True
        $VMProp      = $RestoreObject.VMProp
        $Overwrite   = $RestoreObject.Overwrite
        if(-not $Overwrite){
           $Overwrite = $False
        }
        if($VMProp){
            #prepare JSON for inplace restore
            <#
                {
                      "taskInfo": {
                        "associations": [
                          {
                            "subclientId": 237,
                            "applicationId": 106,
                            "clientName": "TestVapp__34de6bd6-46db-4f2f-b228-5f37f0106258_",
                            "clientId": 715
                          }
                        ],
                        "task": {},
                        "subTasks": [
                          {
                            "subTask": {
                              "subTaskType": 3,
                              "operationType": 1001
                            },
                            "options": {
                              "restoreOptions": {
                                "virtualServerRstOption": {
                                  "isDiskBrowse": true,
                                  "diskLevelVMRestoreOption": {
                                    "passUnconditionalOverride": false,
                                    "useVcloudCredentials": true,
                                    "endUserVMRestore": true,
                                    "vmClientId": 0,
                                    "vmName": "TestVapp_AdminConsole_K1",
                                    "powerOnVmAfterRestore": true,
                                    "advancedRestoreOptions": [
                                      {
                                        "newName": "TestVapp_AdminConsole_K1",
                                        "name": "TestVapp__34de6bd6-46db-4f2f-b228-5f37f0106258_",
                                        "guid": "502d33a1-53ad-487b-6780-0248334cd2fd"
                                      }
                                    ]
                                  }
                                },
                                "volumeRstOption": {
                                  "volumeLevelRestoreType": 1
                                },
                                "browseOption": {
                                  "commCellId": 2,
                                  "backupset": {
                                    "clientId": 715
                                  },
                                  "timeRange": {}
                                },
                                "destination": {
                                  "inPlace": false,
                                  "destClient": {
                                    "clientId": 9
                                  }
                                },
                                "fileOption": {
                                  "sourceItem": [
                                    "\\502d33a1-53ad-487b-6780-0248334cd2fd"
                                  ]
                                }
                              }
                            }
                          }
                        ]
                      }
                    } 
            #>
             
            #root element
            $rootElement          = [ordered]@{}
            $taskInfo             = [ordered]@{}
            #Associations
            [System.Collections.ArrayList]$associationsAray = @()
            $associationsdict     = @{}
            $associationsdict.Add("subclientId",$VMProp.subclientId)
            $associationsdict.Add("applicationId", 106)
            $associationsdict.Add("clientName", $VMProp.pseudoClient.clientName)
            $associationsdict.Add("clientId", $VMProp.pseudoClient.clientId)
            $associationsAray.Add($associationsdict)
            
            $task     = [ordered]@{}

            #subtasks
            $subTasks     = [ordered]@{}
            [System.Collections.ArrayList]$subTasksArray = @()
            $subTask      = [ordered]@{}
            $subTask.Add("subTaskType",3)
            $subTask.Add("operationType",101)
            $subTasks.Add("subTask",$subTask)

            #options
            $options        = [ordered]@{}
            $restoreOptions = [ordered]@{}
            $virtualServerRstOption = @{}
            $virtualServerRstOption.Add("isDiskBrowse",$true)
            $diskLevelVMRestoreOption=@{}
            $diskLevelVMRestoreOption.Add("passUnconditionalOverride",$Overwrite) #unconditional overwrite Flag
            $diskLevelVMRestoreOption.Add("useVcloudCredentials",$False)
            $diskLevelVMRestoreOption.Add("endUserVMRestore",$True)
            $diskLevelVMRestoreOption.Add("vmClientId",0)
            $diskLevelVMRestoreOption.Add("vmName",$VMProp.name)
            $diskLevelVMRestoreOption.Add("powerOnVmAfterRestore",$True)

            [System.Collections.ArrayList]$advancedRestoreOptionsArray = @()
            $advancedRestoreOptionsdict = @{}
            $advancedRestoreOptionsdict.Add("newName",$VMProp.name)
            $advancedRestoreOptionsdict.Add("name",$VMProp.name)
            $advancedRestoreOptionsdict.Add("guid",$VMProp.strGUID)
            $advancedRestoreOptionsArray.Add($advancedRestoreOptionsdict)
            $diskLevelVMRestoreOption.Add("advancedRestoreOptions",$advancedRestoreOptionsArray)
            
            $virtualServerRstOption.Add("diskLevelVMRestoreOption",$diskLevelVMRestoreOption)
            
            $restoreOptions.Add("virtualServerRstOption", $virtualServerRstOption)

            #VolumeRstOption
            $volumeRstOption = @{}
            $volumeRstOption.Add("volumeLevelRestoreType", 1)
            
            $restoreOptions.Add("volumeRstOption", $volumeRstOption)

            #browseOption
            $browseOption    = @{}
            #Commcell ID
            $globalObj = Get-Globals
            $browseOption.Add("commCellId", $globalObj.commcellId)
            $backupset       = @{}
            $backupset.Add("clientId",$VMProp.pseudoClient.clientId)
            $browseOption.Add("backupset",$backupset)
            $timeRange       = @{}
            $browseOption.Add("timeRange", $timeRange)

            $restoreOptions.Add("browseOption", $browseOption)

            #destination
            $destination     = @{}
            #Inplace flag
            $destination.Add("inPlace",$inPlaceFlag)
            $destClient      = @{}
            $destClient.Add("clientId",$VMProp.proxyClient.clientId)
            $destination.Add("destClient",$destClient)

            $restoreOptions.Add("destination", $destination)

            #fileOption
            $fileOption      = @{}
            [System.Collections.ArrayList]$sourceItem   = @()
            $path = "\\"+$VMProp.strGUID
            $sourceItem.Add($path)
            $fileOption.Add("fileOption", $sourceItem)

            $restoreOptions.Add("fileOption", $fileOption)
            
            $options.Add("restoreOptions", $restoreOptions)
           
            $subTasks.Add("options",$options)

            $subTasksArray.Add($subTasks)
            
            $taskInfo.Add("associations", $associationsAray)
            $taskInfo.Add("task", $task)
            $taskInfo.Add("subTasks", $subTasksArray)

            $rootElement.Add("taskInfo",$taskInfo)
       
            #End of Json prep
            $body  = $rootElement | ConvertTo-Json -Depth 10
            Write-Verbose -Message ("Json out from Prepare-InpaceRestoreTask "+$body)
            return @{"body" = $body}
        }
        else{
            Write-Error("Error - VMproperty object found null "+$VMProp)
            return $null
        }
    }
    
    catch{
        Write-Error("Error: Exception occurred in preapre inplace restore task "+$_.Exception.Message)
        return $_.Exception.Message
    }
}

#Method validates the user input for outofplace Restores and returns the map with values needed for out of place
function Parse-OutofplaceRecoveryProps($VMprop, $Obj)
{
    if(-not $Obj){ return "Error - Object passed is not valid for outofplace recovery" }
    if($Obj.VendorType -ieq "VMware")
    {
        
    }

}