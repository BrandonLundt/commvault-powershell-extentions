
NAME
    Get-LastBackup
    
SYNOPSIS
    
SYNTAX
    Get-LastBackup [-VMName] <Object> [[-ClientName] <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -VMName <Object>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ClientName <Object>
        
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
    
    Get-LastBackup -VMName <MyVM>
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    Get-LastBackup -VMName <MyVM>-ClientName <virtualization(vCenter name)>
    
    
    
    
    
    
    
    
    
RELATED LINKS




