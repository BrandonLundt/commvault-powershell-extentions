
NAME
    Get-StoragePolicy
    
SYNOPSIS
    
SYNTAX
    Get-StoragePolicy [[-StoragePolicyName] <String>] [[-MAName] <String>] [[-CopyName] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -StoragePolicyName <String>
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -MAName <String>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -CopyName <String>
        Use this when you want to retrive specific copy properties
        
        Required?                    false
        Position?                    3
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
    
    PS C:\>Get-StoragePolicy
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-StoragePolicy -StoragePolicyName SP1
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    Get-StoragePolicy -MAName <myMA>
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    Get-StoragePolicy -StoragePolicyName SP1 -MAName <myMA>
    
    
    
    
    
    
    
    
    
RELATED LINKS




