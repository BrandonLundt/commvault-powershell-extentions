
NAME
    Get-ClientProps
    
SYNOPSIS
    
SYNTAX
    Get-ClientProps [[-ClientName] <Object>] [[-ClientObject] <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientName <Object>
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -ClientObject <Object>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-ClientProps -ClientName $clientObject
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>(Get-Client -name {{clientName}}).Name | Get-ClientProps
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    $prop = Get-ClientProp -ClientName <clientName>
    
    
    $prop.clientProperties[0].AdvancedFeatures //Gets the list of features or packages installed
    
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>get-clientprops -ClientName prodtest1 | Select clientProperties -ExpandProperty clientProperties
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS C:\>get-clientprops -ClientName prodtest1 | Select clientProperties -ExpandProperty clientProperties | Select client -ExpandProperty client | Select jobResulsDir  //To get jobresults directory
    
    
    
    
    
    
    
    
    
RELATED LINKS




