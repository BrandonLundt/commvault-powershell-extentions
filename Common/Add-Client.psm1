#
# Add-Client.psm1
#
<#
    Author : Anand Venkatesh
    Company: Commvault
	
    .DESCRIPTION
	    Create simpana client
	    Require minimum powershell version 3.0
#>

<#
    .SYNOPSIS
        Creates client in CommServ.

    .PARAMETER 
        Mandatory arguments -Name -UserName -Password  -AgentType -SubType
        
    
    .OUTPUT
        On success it installs client and return 0.

    .Usage
        Example1: Add-Client -ClientName <ClientName> -User <User> -Password <password> -AgentType <type>
       
        Type Name or ID can be taken from below
        1136	VirtualServer Agent on UNIX	Virtual Server
#>



function Add-Client{
<#
    .Example
        Add-Client -ClientName <ClientName> -User <User> -Password <password> -AgentType <type> -OS <Windows/Unix>
        Type Name or ID can be taken from below
            51	MediaAgent
            54	MediaAgent Core
            101	SharePoint iDataAgent
            156	DataArchiver WebProxy Agent for Exchange
            158	DataArchiver Agent for Exchange
            301	OSSV Agent
            356	Sybase iDataAgent
            358	MySQL iDataAgent
            362	PostgreSQL iDataAgent
            363	Documentum Agent
            402	SRM Windows File System Agent
            403	SRM Exchange Agent
            404	SRM NAS Agent
            405	SRM SQL Agent
            406	SRM Oracle Agent
            407	SRM NetWare Proxy Agent
            408	SRM SharePoint Agent
            705	Standalone File Archiver for Windows Agent
            713	VirtualServer Agent
            715	External Data Connector Agent
            908	DataArchiver Agent for Network Storage
            1102	Proxy FileSystem Agent
            1121	Novell OES Linux FS Agent
            1123	SRM File System Agent
            1126	Documentum Agent
            1128	External Data Connector Agent
            1136	VirtualServer Agent on UNIX
            1201	Informix Agent
            1202	Sybase Agent
            1203	SybaseIQ Agent
            1204	Oracle Agent
            1205	Oracle SAP Agent
            1206	SAPMAXDB Agent
            1207	DB2 Agent
            1208	MySQL Agent
            1209	Postgre SQL Agent
            1210	SAP HANA Agent
            1211	Cassandra Agent
            1301	MediaAgent
            1305	MediaAgent Core
            1351	OSSV Agent
            2003	NetWare MediaAgent
        
#>
[CmdletBinding()]

param(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $ClientName,

[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $User,

[Parameter(Mandatory = $True, Position = 2, ValueFromPipeline = $True)]
[ValidateNotNullorEmpty()]
[String] $Password,

[Parameter(Mandatory = $True)] #Value can be VirtualServer
[ValidateNotNullorEmpty()]
[String] $AgentType,

[Parameter(Mandatory = $True)] #Value can be VirtualServer
[ValidateNotNullorEmpty()]
[String] $OS


)
    Begin{

        try{
            #get Session
            $Name = $MyInvocation.MyCommand.Name
            $SessionObject   = Get-SessionDetails $Name
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
            $g = Get-Globals
            #Consolidate user inputs
            $inputs = @{}
            $inputs.Add("CommServName", $SessionObject.server)
            $inputs.Add("ClientName", $ClientName)
            $inputs.Add("ClientUser", $User)
            $inputs.Add("ClientPwd", $Password)
            $inputs.Add("ComponentId", $AgentType)
            $inputs.Add("OS", $OS)
            $inputs.Add("CommcellId", $g.commcellId)
            $inputs.Add("Commcelluser", $SessionObject.user)

            #prepare content to the request
            $inputJson = Prepare-PushInstall $inputs

            $headerObject = Get-RestHeader($SessionObject)
            $body     = $inputJson.body
            $Payload = @{}
            $Payload.Add("headerObject",$headerObject)
            $Payload.Add("body",$body)
            
            #Submit request
            $result = Submit-Restrequest($Payload)
            
            #send back the results
            return $result
        
        }
        catch
        {
            Write-Verbose -Verbose 'Error in Add-Client function'
		    $ErrorMessage = $_.Exception.Message
		    Write-Error $ErrorMessage
        }

    }

}

Export-ModuleMember -Function "*"