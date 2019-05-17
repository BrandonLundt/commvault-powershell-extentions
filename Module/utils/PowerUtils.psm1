#
# PowerUtils.ps1
#
<#
	Class provides all utility methods
#>

	<#
		Description: Method to convert Securestring to String
		Argument: takes secure string and returns string, null if the securestring is empty
		Example: getStringfromSecureString "MySecurestring"
	#>
	function getStringFromSecureString{
    param ([SecureString] $secureStr)
	
		try{
			if ($secureStr -ne $null)
			{
				#return ConvertFrom-SecureString  $secureStr;
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureStr)
                $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                return $UnsecurePassword
			}
			else
			{return $null}
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $ErrorMessage
		}
	
}

	<#
		Description: Method to convert String to SecureString
		Argument: takes String and returns Securestring, null if the string is empty
		Example: getSecureStringfromString "MyString"
	#>
	function getSecureStringfromString{
    param ([string] $Str)
	
		try{
			if ($Str -ne $null)
			{
				return (ConvertTo-SecureString $Str -AsPlainText -Force);
			}
			else
			{return $null}
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $ErrorMessage
		}
	
}

	
	<#
		Description: Method to Encode base 64 of the string
		Argument: takes String and returns encoded string, null if the string is empty
		Example: getEncodedString "MySecurestring"
	#>
	function getEncodedString {
    param ([string] $Str)
	
		try{
			if ($Str -ne $null)
			{
				return ([convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Str)));
			}
			else
			{return $null}
		}
		catch{
			$ErrorMessage = $_.Exception.Message
			Write-Verbose -Message $ErrorMessage
			return $ErrorMessage
		}
}

    
	


  
	

Export-ModuleMember -Function "*"