
NAME
    Get-SLA
    
SYNOPSIS
    
SYNTAX
    Get-SLA [[-ClientName] <String>] [[-EmailId] <String>] [[-Status] <Int32>] [[-Category] <Int32>] [-Detail] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientName <String>
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -EmailId <String>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Status <Int32>
        
        Required?                    false
        Position?                    3
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Category <Int32>
        Status => Any = 0, Protected = 1, Unprotected     = 2, Excluded        = 3
        
        Required?                    false
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Detail [<SwitchParameter>]
        This switch output entire object. If you need more details than just summary
        
        Required?                    false
        Position?                    named
        Default value                False
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
    
    PS C:\>Get-SLA
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    Get-SLA -EmailId <emailid>
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    Get-SLA -ClientName <client>-EmailId <emailid>.
    
    
    
    
    
    
    
    
    
RELATED LINKS




