#
# RESTOps.ps1
#
<#
	.DESCRIPTION
	.Class to handle all REST operations
	.Require minimum powershell version 3.0
#>
	
	#Import-Module D:\LatestSP11_Snap\vaultcxtools\PowerShellCLI\PSModule\Commvault\Common\RESTEndPoints.ps1 -Verbose 
    #Import-Module D:\LatestSP11_Snap\vaultcxtools\PowerShellCLI\PSModule\Commvault\Common\PowerUtils.psm1 -Verbose

	
	#Method prepares Base URL with server and port 
	function  Get-BaseUrl
	{
		
            param([string]$server, [string] $port)
            
            try{
                #$PREFIX =  $REST_AUTH_URL_PREFIX_SECURE
                $PREFIX =  $REST_AUTH_URL_PREFIX
                $url = $PREFIX + $REST_BASE_URL
        
                #Remove whitespace
                $server = $server -split '\s+'
		
                if($port -eq $null -or $port -eq "")
                { 
                    $port = $REST_DEFAULT_PORT 
                }
                else
                {
                    $port = $port -split '\s+'
                }

                return  (($url.Replace("Server",$server)).Replace("port",$port)).Replace(" ","");
            }
        catch{
            $errormessage = $_.exception.message
			return $errormessage

        }
	}

	#<#Generates token 
	#	$server = Commserver name or IP
	#	$user = commcell user name
	#	$pwd = commcell in Secure string type
	#	$port = port if non default port configured to access webserver
	#	Usage: generateToken($server, $user, $securepass, $port)
	##>

	function Get-Token
    {
        param([string]$server, [string]$user, [securestring]$securepwd, [string]$port)
	   
		    try
		    {
                #LOGIN is POST Method
                $METHOD =  "POST"
                #prepare header for the request
			    $hdrs = @{"Accept" = 'application/json' }
		
			    #get encoded pwd after converting to plaintext
                $plainText = getStringFromSecureString($securepwd)
                $encodedpwd = getEncodedString($plainText)
			    $cred = @{
			    password = $encodedpwd
			    username = $user
			    }
			    $body = (ConvertTo-Json $cred)

			    #get base url
                
			    $baseurl =  (Get-BaseUrl $server $port)
                $outString = "Formatted base URL: "+$baseurl
                Write-Verbose -Message $outString
                

			    #call post request
                Write-Verbose -Message 'Submitting login Request'
			    $response = (Process-Request $hdrs $body $baseurl $REST_LOGIN $METHOD)
                if ($response.Status -eq 200)
                {
			        return ($response.Body | ConvertFrom-Json | Select token).token
                    #return $response.token
                }
                else
                { 
                    Write-Verbose -Message 'Failed to get token. Recieved null'
                    return $response
                   
                }

		    }
		catch{
			$errormessage = $_.exception.message
            $outString = 'Exception in Get-Token: '+$errormessage
			Write-Verbose -Message $outString
            return $errormessage
		}
	
    }


	
function Ignore_SSL
{
	$Provider = New-Object Microsoft.CSharp.CSharpCodeProvider
	$Compiler= $Provider.CreateCompiler()
	$Params = New-Object System.CodeDom.Compiler.CompilerParameters
	$Params.GenerateExecutable = $False
	$Params.GenerateInMemory = $True
	$Params.IncludeDebugInformation = $False
	$Params.ReferencedAssemblies.Add("System.DLL") > $null
	$TASource=@'
		namespace Local.ToolkitExtensions.Net.CertificatePolicy
		{
			public class TrustAll : System.Net.ICertificatePolicy
			{
				public TrustAll() {}
				public bool CheckValidationResult(System.Net.ServicePoint sp,System.Security.Cryptography.X509Certificates.X509Certificate cert, System.Net.WebRequest req, int problem)
				{
					return true;
				}
			}
		}
'@ 
	$TAResults=$Provider.CompileAssemblyFromSource($Params,$TASource)
	$TAAssembly=$TAResults.CompiledAssembly
        ## We create an instance of TrustAll and attach it to the ServicePointManager
	$TrustAll = $TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
        [System.Net.ServicePointManager]::CertificatePolicy = $TrustAll
}



#<#Process POST request 
	#	$hdr = @{}
	#	$hdr.Add("X-API-KEY","???")
	#	$obj = @{key1 ='val1'}
	#	$body = (ConvertTo-Json $obj)
	#	$url = "https://commserv:81/SearchSvc/CVWebService.svc/"
    #   $Method = "GET" or "POST"
	#	Usage: Process-Request ($hdr, $body, $url, $method)
	##>
	function Process-Request
    {
       param($hdr, $body, [string] $baseurl, [string] $endpoint, [string] $Method)
	    
		try
		{
		   #return object
            $status = @{}
           #Prepare end point
		    $url = ($baseurl + $endpoint)
            $outString = 'Processing REST request Endpoint: '+$url
            Write-Verbose -Message $outString

            ##Accept untrusted certificate and force TLS2
            <#
            try{
                    Add-Type -TypeDefinition @"
	                using System.Net;
	                using System.Security.Cryptography.X509Certificates;
	                public class TrustAllCertsPolicy : ICertificatePolicy {
	                    public bool CheckValidationResult(
	                        ServicePoint srvPoint, X509Certificate certificate,
	                        WebRequest request, int certificateProblem) {
	                        return true;
	                    }
	                    }
"@
                $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
                [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
                
                Ignore_SSL
                
                #Turn off the ssl cert validation
                #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true } 


                #[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls10 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Ssl3
                

                }
              catch 
              {
                Write-Verbose -Message $_
                Write-Verbose -Message $_.Exception.InnerException.Message
              }
              #>
      
              #validate the session expiry
              if(validateSession($hdr.Authtoken))
              {
                   #Post request
                   if($Method.ToLower() -eq 'post')
                   {
                        try{
		                        $response =  Invoke-WebRequest -Uri $url -Method $Method -Body $body -Headers $hdr -ContentType 'application/json' 
                                #$response =  Invoke-RestMethod -Uri $url -Method $Method -Body $body -Headers $hdr -ContentType 'application/json' 
                            }
                        catch
                            {
                                $outStr = "Exception while processing post request" + $_.Exception.Message
                                Write-Verbose -Message $outStr
                                $status.Add('Error', $outStr)
                                $status.Add('Body', $null)
                                return $status
                            }
                    
                   }
                   #Get request
                   if($Method.ToLower() -eq 'get')
                   {
                        try{
		                        #$response =  Invoke-RestMethod -Uri $url -Headers $hdr  -ContentType 'application/json' 
                                 $response =  Invoke-WebRequest -Uri $url -Headers $hdr -ContentType 'application/json' 
                        }
                        catch{
                                $outStr = "Exception while processing get request: " + $_.Exception.Message
                                Write-Verbose -Message $outStr
                                $status.Add('Error', $outStr)
                                $status.Add('Body', $null)
                                return $status
                        }
                   }

                #Check if the status code is success code
                if($REST_HTTP_STATUS_CODES.Contains($response.StatusCode))
                {
                    $status.Add('Body',$response)
                    $status.Add('Status',$response.StatusCode)
                }

                else
                {
                    $outString = 'Status code is not in success codes, failed to execute rest request ' + $response.StatusCode
                    Write-Verbose -Message $outString
                    $status.Add('Status',$response.StatusCode)
                    $status.Add('Error',$outString)
                }

		       }
              else
              {
                $outString = "Error - Your session has expied. Please login using Connect-CommServ"
                Write-Error $outString
                $status.Add('Status',$response.StatusCode)
                $status.Add('Body',$response)
                $status.Add('Error', $outString)
              }
              return $status

        }
    catch{
            $outString = 'Process-Request: Exception while Processing REST Request' + $_.Exception.Message
            Write-Verbose -Message $outString
		    $status.Add('Error',$_.Exception.Message)
			return $ErrorMessage
         }
		
}


    Export-ModuleMember -Function "*"
