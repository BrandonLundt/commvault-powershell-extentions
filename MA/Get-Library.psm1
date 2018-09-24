#
# Get-Library.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Get the list Backuptargets (storage libraries)
	    Require minimum powershell version 5.0
#>

<#
    .SYNOPSIS
        Get the list of BackupTargets

    .PARAMETER 
        -MAName    -> optional parameter, if passed this module will return properties of that MA
    
    .OUTPUT
        Outputs the list of library and properties.

    .Usage
        Example1: Get-Library  
        Example2: Get-Library -MAName <myMA> //returns library list of the MA
#>


function Get-Library{
<#
    .Example 
        Get-Library  
    
    .Example
        Get-Library -MAName <myMA> //returns library list of the MA
    
    .Example
        Get-Library -MAName <myMA> -LibraryName <mylib> //returns library details matching <myMA>
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $MAName,

[Parameter(Mandatory = $False, Position = 1)]   
[ValidateNotNullorEmpty()]
[String] $LibraryName
)
    Begin{
        try{
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
            
            #prepare arguments
            if($MAName){
                $ClientObject =  Get-Client -Client $MAName
                if(-not $ClientObject)
                {
                    Write-Error "Failed to get Client properties"
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
            $body    = ""
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $prop = Submit-Restrequest($Payload)
            #Finallist of matching libraries
            $Finallist = @()
           
            if($prop.response)
            {
                #Collect all library IDs
                $libIds = @()

                foreach ($Library in $prop.response)
                {
                    $libIds+= $Library.entityInfo
                }

                if($MAName) #If MA name passed, we need to get all library list associated with the MA
                {
                    if($libIds.Length -gt 0)
                    {
                        foreach ($libId in $libIds)
                        {
                            $libdetail = Get-LibraryProps -LibraryId $libId.id
                            if($libdetail)
                            {
                                 if (($libdetail.magLibSummary.associatedMediaAgents).ToLower().Trim() -match ($MAName).ToLower())
                                 {
                                    if($LibraryName) #If library name also provided, filter matching per both Library and MA names
                                    {
                                        
                                        if($libId.name  -eq $LibraryName)
                                        {
                                            $Finallist+= $libId #Only library matching both MAName and LIbrary name
                                        }
                                    }
                                    else #If no library name and only MA name passed, this condition will satisfy.
                                    {
                                        $Finallist+= $libId #add all libraries of MA MAName
                                    }
                                 }
                                
                            }
                        }
                    }
                    
                    else
                    {
                        throw "No lirbaries found"
                    }
                }
                else #MAName not passed, so filter out by library name else return whole list
                {
                    if($LibraryName){
                        foreach($lib in $libIds)
                        {
                            if($lib.name -eq $LibraryName){
                                $Finallist+= $lib
                            }
                        }
                    }
                    else{
                            $Finallist = $libIds #return everything.
                    }
                }

                if($Finallist.Length -eq 0){
                    throw("No matching libraries found")
                }
                return $Finallist
            }
            else{ Write-Error ("Error getting library list "+$prop)
            
            }

        }
        catch
        {
            Write-Verbose -Verbose 'Error in Get-Library Process'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"