
NAME
    Get-CollectionProps
    
SYNOPSIS
    
SYNTAX
    Get-CollectionProps [[-CollectionObject] <Object>] [[-CollectionName] <Object>] [[-ClientName] <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -CollectionObject <Object>
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -CollectionName <Object>
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ClientName <Object>
        
        Required?                    false
        Position?                    2
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
    
    PS C:\>Get-CollectionProps -ClientName vsaqa -CollectionName abc
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-CollectionProps -SubClientObject
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-collection -ClientName vsaqa -CollectionName abc | Get-CollectionProps
    
    
    
    
    
    
    
    
    
RELATED LINKS




