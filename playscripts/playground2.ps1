$gitprojectpath = "C:\Users\v-kapros\Documents\GitHub\PowerChakra\"
[system.reflection.assembly]::LoadFile($(join-path $gitprojectpath "PSmodule\Powerchakra\MsieJavaScriptEngine.dll")) | out-null
$engine = new-object MsieJavaScriptEngine.MsieJsEngine $true,$true

function eval([string]$script)
{
 $res = $engine.Evaluate($script);$res;$res.gettype();
}

eval("1+1")
eval("1.9+3.2") 
eval("'string'")
eval("null"); # DBnull
#eval("undefined") # xception
#eval("[1,2]") #com object and enumeration collection error.
eval("{a:1}") #just 1
#eval("{a:1,b:2}") #evaluate error saying ; expectd, then you cannot call a method on a null-valued expression
eval("var x ={a:1,b:2};x") #com object
#eval("var x =['a','b','c'];x")

$engine.Execute("function add(x,y) { return x + y } ")
eval("add(3,4)")

$engine.CallFunction("add",3,4)
$engine.Execute("function makeobj(x,y) { return {x:x,y:y}}")
$res = $engine.CallFunction("makeobj",3,4)
$engine.Execute("function getprop(x,y) { return x[y];}")
$engine.CallFunction("getprop",$res,"y"); #i can actually pass the com object back in, and work on it (so basically we can run something, get result, and if its a comobjec
#pass it back to a function that does some tests and JSONifies it. (or whatnot, like if its an array breaks it up and makes that decision for each item)
$engine.Execute("function returnarray() { return [1,2,3,4];}") 
#$engine.CallFunction("returnarray") #still has enumeration issue. (this didn't happen in other code).

$engine.Evaluate("JSON.stringify({a:1,b:2})") | ConvertFrom-Json



