
NAME
    Protect-Subclient
    
SYNOPSIS
    
SYNTAX
    Protect-Subclient [-SubclientId] <String> [[-BackupType] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -SubclientId <String>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -BackupType <String>
        
        Required?                    false
        Position?                    1
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
    
    PS C:\>Protect-Subclient -SubclientId 100
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Protect-Subclient -SubclientId 100 -BackupType Incremental/Full/SynthFull #Default incremental
    
    
    
    
    
    
    
    
    
RELATED LINKS




