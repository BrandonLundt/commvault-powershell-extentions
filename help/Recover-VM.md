
NAME
    Recover-VM
    
SYNOPSIS
    
SYNTAX
    Recover-VM [-VMName] <String> [[-ClientName] <String>] [[-Overwrite] <String>] [[-OutofplaceRecoveryProps] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -VMName <String>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -ClientName <String>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Overwrite <String>
        
        Required?                    false
        Position?                    4
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -OutofplaceRecoveryProps <String>
        
        Required?                    false
        Position?                    5
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
    
    PS C:\>Recover-VM -VMName myVM -Overwrite  Yes/No (Default no overwrite option selected)
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Recover-VM -VMname myVM -ClientName myClient
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Recover-VM -VMname myVM -ClientName myClient -OutofplaceRecoveryProperties mydestinationObject
    
    
    
    
    
    
    
    
    
RELATED LINKS




