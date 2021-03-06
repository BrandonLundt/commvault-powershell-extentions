
NAME
    Mount-VM
    
SYNOPSIS
    
SYNTAX
    Mount-VM [-VMName] <String> [-ClientName] <String> [[-SubclientName] <String>] [[-PolicyName] <String>] [[-JobId] <String>] [<CommonParameters>]
    
    
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
        Use this when specific subclient to be used for the VM
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -PolicyName <String>
        This argument will be used to pick up certain Livemount policy
        
        Required?                    false
        Position?                    4
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -JobId <String>
        If want to mount VM from specific Job Id
        
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
    
    PS C:\>Mount-VM -VMName myVM
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Mount-VM -VMname myVM -ClientName myClient
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Mount-Vm -VMName myVM -PolicyName myLivemountPolicy
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Mount-VM -VMName myVM -JobId 100
    
    
    
    
    
    
    
    
    
RELATED LINKS




