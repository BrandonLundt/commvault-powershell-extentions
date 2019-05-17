#
# Create-DiskSpace.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Gets the available disk space of the library
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Gets the available disk space of the library

    .PARAMETER 
        -MAName         -> optional parameter. If passed, this module will return all libraries and mmount path space details of the MA
        -LibraryName    -> optional parameter. If passed, this module will return all libraries and mmount path space details of the library
        -MountPath      -> optional parameter. If passed, this module will return all libraries and mmount path space details of the mountpath

    
    .OUTPUT
        Output the total space and space available 

    .EXAMPLE
        Example1: Get-DiskSpace
        Example2: Get-DiskSpace -MAName <MAName>
        Example2: Get-DiskSpace -LibraryName <library name>
        Example2: Get-DiskSpace -MountPath <mountPath name>
#>


function Get-DiskSpace{
<#
     .Example
        Get-DiskSpace

     .Example
        Get-DiskSpace -MAName <MAName>
     
     .Example
        Get-DiskSpace -LibraryName <library name>
     
     .Example
        Get-DiskSpace -MountPath <mountPath name>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $MAName,

[Parameter(Mandatory = $False, Position = 2)]   
[ValidateNotNullorEmpty()]
[String] $LibraryName,
[Parameter(Mandatory = $False, Position = 3)]   
[ValidateNotNullorEmpty()]
[String] $MountPath
)
    Begin{
        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            #prepare arguments
            if(-not $MAName -and -not $LibraryName){
                Write-Error("Please add atleast one of the arguments. MAName or LibraryName or both")
                return
            }
            if($MAName){
            #Get all libraries for the MA
               if(-not $LibraryName){
                $Libraries = Get-Library -MAName $MAName
               }
            }
            #Get libId for libraryName
            if($LibraryName){
                $LibId = Get-Library -LibraryName $LibraryName
            }
            #MountPath name has been passed. Wrap up the string so it wont fail for escape chars
            if($MountPath){
                $MountPath =  [regex]::Escape($MountPath)
            }

        }
        catch
        {
            Write-Verbose -Message $_.Exception.Message;
		    $ErrorMessage = $_.Exception.Message
		    return $ErrorMessage
        }
    }

    Process{

        try{
            $mPaths    = @()
            $endPoints = @()
            $endpoint     = $SessionObject.requestProps.Endpoint
            if($LibraryName){
                    $endPoints     += $endPoint -creplace("{Id}",$LibId.id)
                }
                else{ #Library name has not passed, so processing all library list under MA
                    foreach($Lib in $Libraries) {
                        $endPoints     += $endPoint -creplace("{Id}",$Lib.entityInfo.id)
                    }
                }
            foreach ($endpoint in $endPoints){
                    #Update endpoint
                    $SessionObject.requestProps.Endpoint = $endpoint
                    $headerObject = Get-RestHeader($SessionObject)
                    $body    = ""
                    $Payload = @{}
                    $Payload.Add("headerObject",$headerObject)
                    $Payload.Add("body",$body)
            
                    #Submit request
                    $prop = Submit-Restrequest($Payload)
            
                    if($prop.libraryInfo){
                        if($MountPath)
                        {
                            foreach ($path in $prop.libraryInfo.MountPathList)
                            {
                                $parsedStr = [regex]::Escape($path.mountPathName)
                                if( $parsedStr -Like "*$MountPath*")
                                {
                                    $mPaths += $prop.libraryInfo.MountPathList[0].mountPathSummary
                                }
                            }
                        }
                        else
                        {
                            $mPaths += $prop.libraryInfo.magLibSummary
                        }
                    }
                    else{ Write-Error ("Error getting mount path list "+$prop)
                        }
                  }
                  return $mPaths
                }
                catch
                {
                    Write-Verbose -Verbose 'Error in Get-DiskSpace module'
		            $ErrorMessage = $_.Exception.Message
		            Write-Error $ErrorMessage
                }
        }
    

}

Export-ModuleMember -Function "*"