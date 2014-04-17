ipmo C:\dev\myown\PowerShellJS\PowerShellJS\PSModule\PowerShellJS -Force

 invoke-js "5+5"
  New-JSSession -Name test
 # var compiler = new TypeScript.TypeScriptCompiler();
 $typescriptjs = Get-Content C:\dev\myown\PowerShellJS\PowerShellJS\typescript\typescript.js -Raw

 #invoke-JS -Name test -Script $typescriptjs
 (Get-JSSession -Name test).Engine.ExecuteFile("C:\dev\myown\PowerShellJS\PowerShellJS\PSModule\PowerShellJS\typescript.js",[System.Text.Encoding]::UTF8)
 $typescriptcode = 'var isDone: boolean = false;'
 (Get-JSSession -Name test).Engine.setVariableValue("_typescripttocompile",$typescriptcode)
 #create a nested PS object
# invoke-JS -Name test -Script $typescriptcode -NoResults
 #get object as JSON, then convert to PS object 
 #invoke-JS -Name test -Script "var compiler = new TypeScript.TypeScriptCompiler()" -NoResults
 #invoke-JS -Name test -Script "var snapshot = TypeScript.ScriptSnapshot.fromString(_typescripttocompile);" -NoResults

 invoke-JS -Name test -Script "
 var compiler = new TypeScript.TypeScriptCompiler()
 var snapshot = TypeScript.ScriptSnapshot.fromString(_typescripttocompile)
 compiler.addFile('dynamictypescript.js', snapshot);
 var iter = compiler.compile();
 var output = '';
 while(iter.moveNext()) {
    var current = iter.current().outputFiles[0];
    output += !!current ? current.text : '';
  }" -NoResults

#      compiler.addFile(filename, snapshot);

 $objectasJSON = invoke-JS -Name test -Script "snapshot === undefined || snapshot === null" 
       
 $objectasJSON = invoke-js -name test -Script "JSON.stringify(output)"
 $objectasJSON
 #$objectasPSobj = ConvertFrom-Json $objectasJSON
 #$objectasPSobj | fl
 