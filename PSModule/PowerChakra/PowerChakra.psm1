write-host -ForegroundColor Yellow "PowerChakra"

$script:JSSessions = new-object "System.Collections.ObjectModel.Collection``1[System.Object]" 
$script:newsessionnameindex = 0
$script:newsessionIDindex = 0

function New-JSSession
{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false)]
    [string] $Name
    )
    #TODO intelligent way to do job name
    $script:newsessionIDindex = $script:newsessionIDindex + 1;
    if($Name -eq $null -or $Name -eq "") 
      {
       $script:newsessionnameindex = $script:newsessionnameindex + 1;
       $Name = "Session{0}" -f $script:newsessionnameindex 
      }
    #TODO try/catch
    #TODO options to exclude JSON and ES5 shim.
    $engine = new-object MsieJavaScriptEngine.MsieJsEngine $true,$true
    $session = New-Object pscustomobject -Property @{
            Id = $script:newsessionIDindex 
            Name = $Name
            State = "NOTIMPLEMENTED" #TODO implement approprate states.
            Engine = $engine
        }
    $session.psobject.typenames.insert(0,"JSSession") #TODO some PS1XML formating for this object "type"
    $script:JSSessions.add( $session ) | out-null
    Write-Output $session
}

function Get-JSSession
{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false)]
    [string[]] $Name,
     [Parameter(Mandatory=$false)]
    [Int[]] $Id
    )
    #TODO: exception when not existing and implicitly requested
    #TODO: wildcard search on names    
    $script:JSSessions | 
        where-object { $id -eq $null  -or $id -eq $_.id } |
        where-object { $name -eq $null  -or $name -eq $_.name }
}

function Remove-JSSession
{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false)]
    [string[]] $Name,
     [Parameter(Mandatory=$false)]
    [Int[]] $Id
    )
    #TODO: exception when not existing and implicitly requested
    #TODO: wildcard search on names    
    $toremove = $script:JSSessions | 
        where-object { $id -eq $null  -or $id -eq $_.id } |
        where-object { $name -eq $null  -or $name -eq $_.name }
    
    $toremove | foreach { 
        #remove from our list
        $script:JSSessions.remove($_) | out-null
        #dispose of JS environment
        $_.engine.dispose() 
    }
    
    
}


