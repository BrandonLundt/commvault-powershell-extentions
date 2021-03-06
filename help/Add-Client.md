
NAME
    Add-Client
    
SYNOPSIS
    
SYNTAX
    Add-Client [-ClientName] <String> [-User] <String> [-Password] <String> -AgentType <String> [-SubType <String>] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ClientName <String>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -User <String>
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -Password <String>
        
        Required?                    true
        Position?                    3
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -AgentType <String>
        Value can be VirtualServer
        
        Required?                    true
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SubType <String>
        Value can be - VMware
        
        Required?                    false
        Position?                    named
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
    
    Add-Client -ClientName <ClientName>-User <User> -Password <password> -AgentType <type>
    
    
    Type Name or ID can be taken from below
    41, Active Directory
    21, AIX File System
    134, Cloud Apps
    37, DB2
    103, DB2 MultiNode
    62, DB2 on Unix
    64, Distributed Apps
    128, Documentum
    90, Domino Mailbox Archiver
    91, DPM
    67, Exchange Compliance Archiver
    53, Exchange Database
    45, Exchange Mailbox
    54, Exchange Mailbox (Classic)
    56, Exchange Mailbox Archiver
    82, Exchange PF Archiver
    35, Exchange Public Folder
    73, File Share Archiver
    33, File System
    74, FreeBSD
    71, GroupWise DB
    17, HP-UX Files System
    65, Image Level
    75, Image Level On Unix
    76, Image Level ProxyHost
    87, Image Level ProxyHost on Unix
    3, Informix Database
    29, Linux File System
    89, MS SharePoint Archiver
    104, MySQL
    13, NAS
    83, Netware File Archiver
    12, Netware File System
    10, Novell Directory Services
    124, Object Link
    131, Object Store
    86, OES File System on Linux
    22, Oracle
    80, Oracle RAC
    130, Other External Agent
    125, PostgreSQL
    38, Proxy Client File System
    87, ProxyHost on Unix
    61, SAP for Oracle
    135, SAP HANA
    78, SharePoint Server
    20, Solaris 64bit File System
    19, Solaris File System
    81, SQL Server
    5, Sybase Database
    66, Unix File Archiver
    36, Unix Tru64 64-bit File System
    106, Virtual Server
    58, Windows File Archiver
    
    
    
    
    
    
RELATED LINKS




