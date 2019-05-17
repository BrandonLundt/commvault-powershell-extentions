#
# RESTEndPoints.ps1
#
<#
	.DESCRIPTION
	.End point definitions
	.Require minimum powershell version 3.0
#>
    #COMMON APIs
	 $REST_AUTH_URL_PREFIX           = "http://";
     $REST_AUTH_URL_PREFIX_SECURE    = "https://";
     $REST_DEFAULT_PORT              = "81";
     $REST_BASE_URL                  = "Server:port/SearchSvc/CVWebService.svc/";
     $REST_WEBCONSOLE_URL            = "Server/webconsole/api/";
     $REST_LOGIN                     = "Login";
	 $REST_HTTP_STATUS_CODES         = @(200, 201, 202, 203, 204, 205, 206, 206, 207, 208);



function Get-RestAPIDetails($request){
   
      $restapi = @{

      'Connect-CommServ' = @{
      
        Description      = 'Login to Commserv'
        Endpoint         = 'Login'
        Method           = 'Post'
        Body             = ''
        
      }
    

    'Get-Token'             = @{
      
        Description      = 'Login to Commserv'
        Endpoint         = 'Login'
        Method           = 'Post'
        Body             = ''
        
      }

    'Get-Alert'             = @{
      
        Description      = 'Gets alert list'
        Endpoint         = 'AlertRule'
        Method           = 'Get'
        Body             = ''
        
      }

      
    'Start-DRBackup'             = @{
      
        Description      = 'Starts DR backup job'
        Endpoint         = 'CommServ/DRBackup'
        Method           = 'Post'
        Body             = ''
        
      }

      'Add-Client'             = @{
      
        Description      = 'Add new client'
        Endpoint         = 'CreateTask'
        Method           = 'Post'
        Body             = ''
        
      }

    'Get-Client'             = @{
      
        Description      = 'Get client list from Commserv'
        Endpoint         = 'Client'
        Method           = 'Get'
        Body             = ''
        
      }

     
      'Get-ClientProps'             = @{
      
        Description      = 'Get clientproperties for given client from Commserv'
        Endpoint         = 'Client/ClientId'
        Method           = 'Get'
        Body             = ''
        
      }

      
      'Get-ClientAdditionalSettings'             = @{
      
        Description      = 'Get additional settings for given client from Commserv'
        Endpoint         = 'Client/ClientId/AdditionalSettings'
        Method           = 'Get'
        Body             = ''
        
      }
      
      'Set-ClientProps'             = @{
      
        Description      = 'Get clientproperties for given client from Commserv'
        Endpoint         = 'Client/ClientId'
        Method           = 'Post'
        Body             = ''
        
      }

      
      'Add-ClientGroup'             = @{
      
        Description      = 'Adds new ClientGroup'
        Endpoint         = '/ClientGroup'
        Method           = 'Post'
        Body             = ''
        
      }
      

      'Get-ClientGroup'             = @{
      
        Description      = 'Get ClientGroup list from Commserv'
        Endpoint         = '/ClientGroup'
        Method           = 'Get'
        Body             = ''
        
      }


      'Get-ClientGroupProps'             = @{
      
        Description      = 'Get ClientGroup list from Commserv'
        Endpoint         = '/ClientGroup/clientGroupId'
        Method           = 'Get'
        Body             = ''
        
      }

       'Set-ClientGroup'             = @{
      
        Description      = 'Get ClientGroup list from Commserv'
        Endpoint         = '/ClientGroup/clientGroupId'
        Method           = 'Post'
        Body             = ''
        
      }


      'Get-Collection'             = @{
      
        Description      = 'Get subclient list for given clientId from Commserv'
        Endpoint         = 'Subclient?clientId=ClientId'
        Method           = 'Get'
        Body             = ''
        
      }
     
     
      'Get-CollectionProps'             = @{
      
        Description      = 'Get subclient props for given subclient from Commserv'
        Endpoint         = 'Subclient/SubclientId'
        Method           = 'Get'
        Body             = ''
        
      }

      
      'Set-CollectionProps'= @{
      
        Description      = 'Set subclient props for given subclient from Commserv'
        Endpoint         = 'Subclient/SubclientId'
        Method           = 'Post'
        Body             = ''
        
      }

      
      'Get-Job'          = @{
      
        Description      = 'Get the list of all jobs in Commserv'
        Endpoint         = '/Job'
        Method           = 'Get'
        Body             = ''
        
      }

      'Get-JobDetails'          = @{
      
        Description      = 'Get job details for JobId'
        Endpoint         = '/JobDetails'
        Method           = 'Post'
        Body             = ''
        
      }
       
      'Kill-Job'         = @{
      
        Description      = 'Kill the specified job'
        Endpoint         = 'Job/jobId/action/kill'
        Method           = 'Post'
        Body             = ''
        
      }

       
      'Suspend-Job'      = @{
      
        Description      = 'Suspend the specified job'
        Endpoint         = 'Job/jobId/action/pause'
        Method           = 'Post'
        Body             = ''
        
      }

       
      'Resume-Job'       = @{
      
        Description      = 'Resume the specified job'
        Endpoint         = 'Job/jobId/action/resume'
        Method           = 'Post'
        Body             = ''
        
      }
       
      'Add-Content'             = @{
      
        Description      = 'Add subclient contnet for given subclient from Commserv'
        Endpoint         = 'Subclient/SubclientId'
        Method           = 'Post'
        Body             = ''
        
      }


       'Add-VM'             = @{
      
        Description      = 'Add VM to a given subclient in Commserv'
        Endpoint         = 'Subclient/SubclientId'
        Method           = 'Post'
        Body             = ''
        
      }

       'Remove-VM'             = @{
      
        Description      = 'Removes VM  a given from collection'
        Endpoint         = 'Subclient/SubclientId'
        Method           = 'Post'
        Body             = ''
        
      }


       'Protect-VM'             = @{
      
        Description      = 'Starts backup job for given  VM'
        Endpoint         = 'CreateTask'
        Method           = 'Post'
        Body             = ''
        
      }

      
       'Perform-VMBrowse'             = @{
      
        Description      = 'Gets the browse restult for the VM'
        Endpoint         = 'VM?propertyLevel=AllProperties&status=0&PseudoClientId={Id}'
        Method           = 'Get'
        Body             = ''
        
      }

      'Get-VMlist'             = @{
      
        Description      = 'Gets VM list(All Protected VMs)'
        Endpoint         = 'VM?forUser=true&status=1'
        Method           = 'Get'
        Body             = ''
        
      }

      'Recover-VM'             = @{
      
        Description      = 'Starts restore job for given  VM'
        Endpoint         = 'CreateTask'
        Method           = 'Post'
        Body             = ''
        
      }

      'Mount-VM'             = @{
      
        Description      = 'StartsVM Live mount job'
        Endpoint         = 'CreateTask'
        Method           = 'Post'
        Body             = ''
        
      }

      'InplaceRecover-VMDetails'             = @{
      
        Description      = 'Returns the object for InplaceRestore'
        Endpoint         = 'VM?guid={Id}'
        Method           = 'Get'
        Body             = ''
      }

       'Get-StoragePolicy'             = @{
      
        Description      = 'Returns the SP details'
        Endpoint         = 'StoragePolicy'
        Method           = 'Get'
        Body             = ''
      }

      'Get-MA'             = @{
      
        Description      = 'Returns the list of MA'
        Endpoint         = 'MediaAgent'
        Method           = 'Get'
        Body             = ''
      }

      'Get-SPlistforMA'             = @{
      
        Description      = 'Returns the list storage polices associated with MA'
        Endpoint         = 'StoragePolicyListAssociatedToMediaAgent?MediaAgent=ID'
        Method           = 'Get'
        Body             = ''
      }

      'Get-Library'             = @{
      
        Description      = 'Returns the list BackupTargets or storage libraries'
        Endpoint         = 'Library'
        Method           = 'Get'
        Body             = ''
      }

      'Get-LibraryProps'             = @{
      
        Description      = 'Returns the list BackupTargets and its properties'
        Endpoint         = 'Library/ID'
        Method           = 'Get'
        Body             = ''
      }

      'Create-Library'             = @{
      
        Description      = 'Create magnetic library'
        Endpoint         = 'Library'
        Method           = 'Post'
        Body             = ''
      }

      'Get-DiskSpace'             = @{
      
        Description      = 'Get the diskspace available in mountPath'
        Endpoint         = 'Library/{Id}'
        Method           = 'Get'
        Body             = ''
      }

      'Start-SendLogFiles'             = @{
      
        Description      = 'Calls Sendlogfiles'
        Endpoint         = 'CreateTask'
        Method           = 'Post'
        Body             = ''
      }

      'Get-SLA'             = @{
      
        Description      = 'Gets SLA'
        Endpoint         = 'SLAReport'
        Method           = 'Post'
        Body             = ''
      }
       
       'Protect-MissedSLA'  = @{
      
        Description      = 'Gets SLA'
        Endpoint         = 'SLAReport'
        Method           = 'Post'
        Body             = ''
      }

      'Protect-Subclient'  = @{
      
        Description      = 'API to submitbackup'
        Endpoint         = 'Subclient/{SubclientId}/action/backup?backupLevel={BackupType}' #Prefix end point with {webconsole}. 
                                                                                                            #so this url will be treated special for webconsole.
        Method           = 'Post'
        Body             = ''
      }

    }#End of $restapi

     return $restapi.$request
}# End of function Get-RESTAPI
    
Export-ModuleMember Get-RestAPIDetails
Export-ModuleMember -Variable REST_*