#
# CommonUtils.psm1
#
<#
	.DESCRIPTION
	.common methods and classes for all APIs
	.Require minimum powershell version 5.0
#>

#Method takes API name and returns the REST endpoint obbject with token
function Get-SessionDetails($MethodName)
{
    try{
            $sessionObj   = @{}
        #get Session
            $sessionToken = $global:ConnectionPool.token
            
            #Get properties for processing REST call
            $requestProps = (Get-RestAPIDetails -request $MethodName)

            #Validate the session
            $isSessionValid = validateSession($sessionToken)
            if($isSessionValid -eq $false)
            {
                Write-Error 'Error: Session timeout. Please login again'
                return 'Error: Session timeout. Please login again'
            }
            $sessionObj.Add("sessionToken",$sessionToken)
            $sessionObj.Add("requestProps", $requestProps)
            $sessionObj.Add("server", $global:ConnectionPool.server)
            $sessionObj.Add("port", $global:ConnectionPool.port)
            $sessionObj.Add("user", $global:ConnectionPool.user)

        return $sessionObj
    }
    catch{
        Write-Error("Error- Failed to GetSession details "+$_.Exception.Message)
    }
}

#Method takes session object and returns the filled header
function Get-RestHeader($SessionObject)
{
    try{
            $headerObj = @{}
             #Prepare GET request
            $headerObj.Add("header",@{Accept = 'application/json'; Authtoken = $SessionObject.sessionToken})
            $headerObj.Add("method",$SessionObject.requestProps.Method)
            $headerObj.Add("endpoint", $SessionObject.requestProps.Endpoint)
            
            $baseUrl  = (Get-BaseUrl $global:ConnectionPool.server $global:ConnectionPool.port)
            $headerObj.Add("baseUrl",$baseUrl)

        return $headerObj
    }
    catch{
        Write-Error("Error- Failed to Get-RestHeader method "+$_.Exception.Message)
    }
}



#Method takes session object and returns the filled header
function Submit-Restrequest($Payload)
{
    try{
            #Submit request
	        $response = (Process-Request $Payload.headerObject.header $Payload.body $Payload.headerObject.baseUrl $Payload.headerObject.endpoint $Payload.headerObject.method)
            #validate the response
            $responseProp     = validateResponse($response)

            return $responseProp
    }
    catch{
        Write-Error("Error- Failed to submit RestRequest method "+$_.Exception.Message)
    }
}

<#
		Description: Method to validate the token
		Argument: takes String and returns treue or false
		Example: validateSession <token>
	#>
	function validateSession {
    param ([string] $token)
	
		try{
			if ($token -ne $null)
			{
				return $true;
			}
			else
			{return $false}
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $false
		}
}
    
    <#
		Description: Method to validate the response
		Argument: takes the REST response as input
		Example: validateSession <token>
	#>
	function validateResponse {
    param ($response)
	
		try{
			if($response.error)
            {
                return $response
            }
            
            #Process Response
            if($response.Status -eq 200 -and $response.Body -ne $null)
            {
                #Convert content to Json format
                $responseContent = ($response.Body.Content | ConvertFrom-Json)

                #Parse the response, return only subclient list
                return $responseContent
            }
            else{ return $response
            }
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $ErrorMessage
		}

}


     <#
		Description: Method to filter the result
		Argument: takes the json result output of REST API
		Example: validateSession <response> <filterList>
	#>
	function filterResponse {
    param ($response, $filter="all")
	    
		try{
		    	if($filter -eq "all")
                {
                    return $response
                }
                
                foreach($key in $filter)
                {
                    #Implement it when needed
                }
        
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $ErrorMessage
		}

}


 <#
		Description: Method to fileter the result
		Argument: takes the json result output of REST API
		Example: validateNullorEmpty <args> args-> key,value (tuple)
	#>
	function validateNullorEmpty {
    param ($arg)
	    
		try{
		    	if(-not $arg)
                {
                    Write-Error($arg ," is null")
                    return $null
                }
                else{
                    
                }
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $ErrorMessage
		}

}

