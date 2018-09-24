#
# Get-LibraryProps.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the properties of the library
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Get the proprties of library

    .PARAMETER 
        -LibraryName    -> optional parameter, if passed this module will return properties of that Library
        -LibraryId    -> optional parameter, if passed this module will return properties of that Library
    
    .OUTPUT
        Outputs the list of library and properties.

    .Usage
        Example1: Get-LibraryProps  
        Example2: Get-LibraryProps -LibraryName <myLib> //returns library properties
        Example2: Get-LibraryProps -LibraryId <myLibId> //returns library properties
#>


function Get-LibraryProps{
<#
    .Example
        Get-LibraryProps  
    .Example
        Get-LibraryProps -LibraryName <myLib> //returns library properties
    .Example
        Get-LibraryProps -LibraryId <myLibId> //returns library properties
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 2)]   
[ValidateNotNullorEmpty()]
[String] $LibraryName,
[Parameter(Mandatory = $False, Position =0, ValueFromPipeline = $True)]   
[ValidateNotNullorEmpty()]
[String] $LibraryId

)
    Begin{
        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            #prepare arguments
            if($LibraryName){
                $LibObject =  Get-Library -LibraryName $LibraryName
                if(-not $LibObject)
                {
                    Write-Error "Failed to get Library properties"
                    return 
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
            #get client id
            $headerObject = Get-RestHeader($SessionObject)
            
            #Update the endpoint
            $endPoint= $headerObject.endpoint
            if($LibraryId -or $LibraryName){
                if($LibraryId){
                    $endPoint= $endPoint -ireplace ("ID", $LibraryId)
                }
                if($LibObject){
                    $endPoint= $endPoint -ireplace ("ID", $LibObject.id)    
                }
            }
            else
            {
                Write-Error("Error: Please pass valid library name or Id ")
            }
            $headerObject.endpoint = $endPoint
            
            $body    = ""
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            
            if($prop.libraryInfo)
            {
               return $prop.libraryInfo
            }
            else{ Write-Error ("Error getting library porperties "+$prop)
            }
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-LibraryProps Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"