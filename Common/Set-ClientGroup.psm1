#
# Set-ClientGroup.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Set\updates the clientGroup properties
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Commandlet Set\Updates ClientGroup properties

    .PARAMETER 
        Mandatory group name 
        
    
    .OUTPUT
        On success it returns client group properties.

    .Usage
        Example1: Set-ClientGroup -ClientGroupName <name> -ClientGroupProps <prop in json format>
       
      
         Sample input jsonObject:
       $prop = @{
                   {
              "clientGroupOperationType":Update,
              "clientGroupDetail":{
                "description":"client group description",
                "clientGroup":{
                  "clientGroupName":"CG001"
                }
                "associatedClientsOperationType":3,
                "associatedClients":[
                  {
                    "clientName":"test001"
                  }
                  {
                    "clientName":"test002"
                  }
                ]
              }
            }
	}| ConvertTo-Json

#>



function Set-ClientGroup{
<#
    .Example
        Set-ClientGroup -ClientGroupName <name> -ClientGroupProps <prop in json format>
             $prop = @{
                   {
              "clientGroupOperationType":Update,
              "clientGroupDetail":{
                "description":"client group description",
                "clientGroup":{
                  "clientGroupName":"CG001"
                }
                "associatedClientsOperationType":3,
                "associatedClients":[
                  {
                    "clientName":"test001"
                  }
                  {
                    "clientName":"test002"
                  }
                ]
              }
            }
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientGroupName,

[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[System.Object] $ClientGroupProps

)
    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name

            #validate the param
            if($ClientGroupName)
            {
                $GroupObj = Get-ClientGroup -ClientGroupName $ClientGroupName
                if($GroupObj -eq $null -or $GroupObj -eq "")
                {
                    Write-Error("Error: Couldn't find the clientgroup name in Commserv")
                }
            }
            else
            {
                Write-Error("Error: Please pass valid ClientGroupName ")
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
            #Update endpoint
            $endPoint = $SessionObject.requestProps.Endpoint
            $endPoint = $endPoint -creplace("clientGroupId",$GroupObj.Id) 
            $SessionObject.requestProps.Endpoint = $endPoint
            
            $body     = $GroupObj | ConvertTo-Json
            $headerObject = Get-RestHeader($SessionObject)
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)

	        $result = Submit-Restrequest($Payload)
            $bFound =$False
            
            if($result)
            {
                return $result.clientGroupDetail
            }
            else { return $result
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