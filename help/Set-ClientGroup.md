
NAME
    Set-ClientGroup
    
SYNOPSIS
    
SYNTAX
    Set-ClientGroup [-ClientGroupName] <Object> [-ClientGroupProps] <Object> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientGroupName <Object>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -ClientGroupProps <Object>
        
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
    
    Set-ClientGroup -ClientGroupName <name>-ClientGroupProps <prop in json format>
    
    
    $prop = @{
               {
          "clientGroupOperationType":Update,
          "clientGroupDetail":{
            "description":"client group description",
            "clientGroup":{
              "clientGroupName":"CG001"
            }
            "associatedClientsOperationType":3,
            "associatedClients":[
              {
                "clientName":"test001"
              }
              {
                "clientName":"test002"
              }
            ]
          }
        }
    
    
    
    
    
    
RELATED LINKS




