
NAME
    Protect-MissedSLA
    
SYNOPSIS
    
SYNTAX
    Protect-MissedSLA [[-ClientName] <String>] [[-Category] <Int32>] [[-Status] <Int32>] [[-EmailId] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientName <String>
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Category <Int32>
        
        Required?                    false
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Status <Int32>
        
        Required?                    false
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -EmailId <String>
        Status => Any = 0,Protected = 1,Unportected = 2,Excluded = 3
        
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
    
    PS C:\>Protect-MissedSLA
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    Protect-MissedSLA -ClientName <client>-Category 3 -EmailId <emailid> (Protects all subclients which are missed SLA due to no job found)
    
    
    
    
    
    
    
    
    
RELATED LINKS




