
NAME
    Connect-Commserv
    
SYNOPSIS
    
SYNTAX
    Connect-Commserv -Server <String> -User <String> [-Password] <SecureString> [-Port <String>] [-PSCreds <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Server <String>
        CommServ name
        
        Required?                    true
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -User <String>
        User name
        
        Required?                    true
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Password <SecureString>
        Password
        
        Required?                    true
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Port <String>
        Port if nondefault has been configured to connect webserver
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -PSCreds <Object>
        PS credentials object as argument
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    Connect-CommServ -Server <server name>-User <user> -Password <pwd> -Port [port]
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    Connect-CommServ -Server <server name>-PSCredential <ps credential object> -Port [port]
    
    
    
    
    
    
    
    
    
RELATED LINKS




