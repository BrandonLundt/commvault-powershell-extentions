
NAME
    Add-VM
    
SYNOPSIS
    
SYNTAX
    Add-VM [-ClientName] <String> [-SubclientName <String>] [-EntityType] <String> [-Entity] <String> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientName <String>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -SubclientName <String>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -EntityType <String>
        Example: Datastore, Folder, Cluster, Host etc if VMware.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Entity <String>
        Example: Name of the entity. This can be comma separated list
        
        Required?                    true
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
    
    Add-VM -ClientName <myClient>-SubclientName <testSubclient> -EntityType <VM> -Entity <myVM>
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    Add-VM -ClientName <myClient>-EntityType <VM> -Entity <VM1,VM2,VM3>
    
    
    
    
    
    
    
    
    
RELATED LINKS




