
NAME
    Set-ClientProps
    
SYNOPSIS
    
SYNTAX
    Set-ClientProps [-ClientObject] <Object> [-ClientProp] <Object> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientObject <Object>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -ClientProp <Object>
        
        Required?                    true
        Position?                    1
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
    
    PS C:\>Set-Client -ClientObject -Property $ClientProp
    
    
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>{{$PropObject}} | Set-Client
    
    
    {
    
    Sample input jsonObject:
    $prop = @{
    "App_SetClientPropertiesRequest" = @{
    "association" = @{
    "entity" = @{ 
    "clientName" = "client001" 
    } 
    }
    }
    "clientProperties" = @{
    "client" = @{ 
    "clientDescription"= "client-level description modified with rest api POST client" 
    } 
    }
    
    
    
    
    
    
RELATED LINKS




