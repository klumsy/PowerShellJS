write-host -ForegroundColor Yellow "PowerShellJS"

#region implementation detail variables for module
$script:JSSessions = new-object "System.Collections.ObjectModel.Collection``1[System.Object]" 
$script:newsessionnameindex = 0
$script:newsessionIDindex = 0
#endregion
 
#region JSSession CMDlets (New,Get,Remove)
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
    $engine = new-object MsieJavaScriptEngine.MsieJsEngine "ChakraActiveScript",$true,$true
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
#endregion

function Get-JSCommand {
[cmdletbinding()]param()
Get-Command -Module PowerChakra
}


function Invoke-TypeScript
{
   [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,Position=0)]
    [string] $Script,
    [Parameter(Mandatory=$false)]
    [string] $Name,
    [Parameter(Mandatory=$false)]
    [Int] $Id,
    [Parameter(Mandatory=$false)]
    [ValidateScript({$_ -eq $null -or $_.psobject.typenames -contains "JSSession"} )]
    [object] $Session,
    [Parameter(Mandatory=$false)]
    [switch] $NoResults
    )
    #TODO find session, otherwise create a temporary session. #we aren't having fan out , so only so with one , if duplicates then error
    $hassession = $false;$hasTempSession=$false;
    if($session -ne $null) { $hassession = $true; } #lets trust that if the classname is JSSession its valid
    elseif ($id -ne 0 ) {
        $tmp = Get-JSSession -id $id
        if (@($tmp).Count -gt 1) { throw "Must resolve to a single session" }
        if ($tmp -ne $null) {$session = $tmp; $hassession = $true} 
     }
    elseif ($name -ne [string]::Empty) {
        $tmp = Get-JSSession -Name $Name
        if (@($tmp).Count -gt 1) { throw "Must resolve to a single session" }
        if ($tmp -ne $null) {$session = $tmp; $hassession = $true} 
     }
    if(-not $hassession)
     {
      $engine = new-object MsieJavaScriptEngine.MsieJsEngine $true,$true
      $tmpsession = New-Object pscustomobject -Property @{
            Id = -1
            Name = "TMP SESSION"
            State = "NOTIMPLEMENTED" #TODO implement approprate states.
            Engine = $engine
        }
      $tmpsession.psobject.typenames.insert(0,"JSSession") #TODO some PS1XML formating for this object "type"
      $hasTempSession = $true;
      $session = $tmpsession
      $hassession = $true
     }
    $istypeScriptLoaded = $session.engine.Hasvariable("TypeScript") 
    if (!$istypeScriptLoaded) { 
       $session.Engine.ExecuteFile($(join-path $psscriptroot "typescript.js"),[System.Text.Encoding]::UTF8)
     }
     $session.Engine.setVariableValue("_typescripttocompile",$script)
    invoke-JS -session $session -Script "
         var compiler = new TypeScript.TypeScriptCompiler()
         var snapshot = TypeScript.ScriptSnapshot.fromString(_typescripttocompile)
         compiler.addFile('dynamictypescript.js', snapshot);
         var iter = compiler.compile();
         var output = '';
         while(iter.moveNext()) {
            var current = iter.current().outputFiles[0];
            output += !!current ? current.text : '';
          }
          eval(output)
          " -NoResults:$NoResults

    if($hasTempSession)
     {
      #cleanup
      $session.engine.dispose();
     }
 
}


function Invoke-JS {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,Position=0)]
    [string] $Script,
    [Parameter(Mandatory=$false)]
    [string] $Name,
    [Parameter(Mandatory=$false)]
    [Int] $Id,
    [Parameter(Mandatory=$false)]
    [ValidateScript({$_ -eq $null -or $_.psobject.typenames -contains "JSSession"} )]
    [object] $Session,
    [Parameter(Mandatory=$false)]
    [switch] $NoResults
    )
    #TODO find session, otherwise create a temporary session. #we aren't having fan out , so only so with one , if duplicates then error
    $hassession = $false;$hasTempSession=$false;
    if($session -ne $null) { $hassession = $true; } #lets trust that if the classname is JSSession its valid
    elseif ($id -ne 0 ) {
        $tmp = Get-JSSession -id $id
        if (@($tmp).Count -gt 1) { throw "Must resolve to a single session" }
        if ($tmp -ne $null) {$session = $tmp; $hassession = $true} 
     }
    elseif ($name -ne [string]::Empty) {
        $tmp = Get-JSSession -Name $Name
        if (@($tmp).Count -gt 1) { throw "Must resolve to a single session" }
        if ($tmp -ne $null) {$session = $tmp; $hassession = $true} 
     }
    if(-not $hassession)
     {
      $engine = new-object MsieJavaScriptEngine.MsieJsEngine $true,$true
      $tmpsession = New-Object pscustomobject -Property @{
            Id = -1
            Name = "TMP SESSION"
            State = "NOTIMPLEMENTED" #TODO implement approprate states.
            Engine = $engine
        }
      $tmpsession.psobject.typenames.insert(0,"JSSession") #TODO some PS1XML formating for this object "type"
      $hasTempSession = $true;
      $session = $tmpsession
      $hassession = $true
     }
    if ($NoResults)
     {
         $session.engine.execute($script)
     }
    else
     {
       $session.engine.evaluate($script)
     }
    if($hasTempSession)
     {
      #cleanup
      $session.engine.dispose();
     }
    
}


Export-ModuleMember -Function New-JSSession,Get-JSSession,Remove-JSSession,Get-JSCommand,Invoke-JS,Invoke-TypeScript



