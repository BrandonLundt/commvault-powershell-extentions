
NAME
    Protect-VM
    
SYNOPSIS
    
SYNTAX
    Protect-VM [-VMName] <String> [-ClientName] <String> [[-SubclientName] <String>] [[-JobType] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -VMName <String>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -ClientName <String>
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SubclientName <String>
        Use this parameter if you want to override the default behaviour.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -JobType <String>
        Use this parameter if you would like to force backup type.
        
        Required?                    false
        Position?                    4
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
    
    PS C:\>Protect-VM -VMName myVM
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Protect-VM -VMname myVM -ClientName myClient -Type Full
    
    
    
    
    
    
    
    
    
RELATED LINKS




