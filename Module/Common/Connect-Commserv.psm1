#
# Connect-CommServ.psm1
#
<#
	.DESCRIPTION
	ACommandlet to connect to Commserv and get the token
	Require minimum powershell version 3.0
#>


	<#
		Description: Method to get CommServ token
		Argument: Server, User name, Password , optional port if non default has been configured (81) 
		Example1: Connect-CommServ -Server <server name> -User <user> -Password <pwd> -Port [port]
        Example2: Connect-CommServ -Server <server name> -PSCredential <ps credential object> -Port [port]
        Returns token if success 
	#>


function Connect-Commserv{
<#
    .Example 
        Connect-CommServ -Server <server name> -User <user> -Password <pwd> -Port [port]
    .Example
        Connect-CommServ -Server <server name> -PSCredential <ps credential object> -Port [port]
#>
[CmdletBinding()]

param(
#CommServ name
[Parameter(Mandatory = $True)]
[ValidateNotNullorEmpty()]
[String] $Server,

#User name
[Parameter(Mandatory = $True)]
[ValidateNotNullorEmpty()]
[String] $User,

#Password
[Parameter(Position = 2, Mandatory = $True)]
[ValidateNotNullorEmpty()]
[Security.SecureString] $Password,


#[SecureString]${Type your commcell password },[Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Plain')]
#[Parameter(Mandatory = $True)]
#[String]$Password, 



#Port if nondefault has been configured to connect webserver
[Parameter(Mandatory = $False)]
[String] $Port,

#PS credentials object as argument
 [Parameter(ParameterSetName = 'PSCreds')]
 [System.Management.Automation.CredentialAttribute()]$PSCreds


)

Begin{
    try{
        #Prepare pre-requisites for the commandlet
        Write-Verbose 'Started with pre-reqs for the method '
        if($Password)
        {
           Write-Verbose -Message "Secure text recieved, converting"
           $PlainPassword = getStringfromSecureString $Password
    
        }
        if($PSCreds)
        {
            Write-Verbose -Message 'PSCreds passed. Extract password'
            $Password = $PSCreds.GetNetworkCredential().Password
        }
        if(-not $Port)
        {
            $Port = $null
        }

        $Name = $MyInvocation.MyCommand.Name
        #Get properties for processing REST call
        $requestProps = (Get-RestAPIDetails -request $Name)
    }
    catch{
            Write-Error 'Connect-CommServ Begin: Exception in Begin section'
            Write-Verbose $_.Exception.Message
			$ErrorMessage = $_.Exception.Message
			return $ErrorMessage
    }
}
    
Process{
    try{

        #Get Secure password
        #calling Get-Token
        $token = (Get-Token $Server $User $Password $Port)
        if($token.Error -or $token -eq $null){
            Write-Error ('Error: CommServ login failed '+$token.Error)
            return ('LoginFailed: Incorrect user name or Password '+$token.Error)
        }
        else{
            Write-Output 'Logged in to commserv'
        }
       
#        Write-Verbose -Message 'Setting token in globals for other commandlets access in the current session'
        $global:ConnectionPool = @{
            server    = $Server
            token     = $token
            user      = $User
            pass      = $PlainPassword
            port      = $Port
        }

         $global:ConnectionPool.GetEnumerator() | Where-Object -FilterScript {
      $_.name -notmatch 'token' | Out-Null
    }

    }
    catch{
            $outString =  'Connect-CommServ Process: Exception in Process section: ' + $_.Exception.Message
            Write-Verbose $outString
			$ErrorMessage = $_.Exception.Message
			return $ErrorMessage
    }
}





}

Export-ModuleMember -Function "*"