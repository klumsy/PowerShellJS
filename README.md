# PowerShell.JS - JavaScript hosted inside PowerShell.

This Project will Host MS's Chakra Javascript Engine inside of PowerShell, providing Cmdlets to execute arbitary Javascript, Javascript Functions from within PowerShell Now Supporting TypeScript 1.0

##Goals
* Run Arbitary JS from within PowerShell.
* Ability to have JSSessions so you can have more than one JS runtime active at a time.
    * get-JSSession -> list in the session in the environment. (or get a specific one).
    * New-JSSession -> ability to create a JS runtime environment with various options.
    * Remove-JSSesson -> remove a JS runtime environment.
* Load JS files into a JSSession.
* Load JS files.
* Run JS functions from PS, passing in properties.
* return JS results to PowerShell.
* Get-JSfunction -session X : List functions in a JS session (possibly in the future a provider).
* Get-JSVariable -Session X : List (or get a specific) variable from JS session.
* Set-JSVariable -Session X : sets the value of a JS var.
* Variables , Results and Arguments.
    * transform compatible types automatically (i.e string, bool, int, double (depending on number in JS 
      ), null etc.
    * ability to provide transformation functions.
    * other objects on the way in get transformed into JSON, and on the way out can come as JSON, or get     
      transformed to PSCustomObjects.
* Invoke-JS - main way to run JS
    * a way to invoke it simply where a session is created and destroyed at the end.
    * ability to create a new session with this.
    * ability to run code without returning any values.
    * ability to take in PS arguments, and pass them (and if needed transform them).
    * ability to return results as correct PS types, or JSON or PScustomObject.
* Invoke-JSfunction -Name ... -Session -Arguments : Ability to call a JS function in a session.
* New-JSproxy - Ability to take a JS function (or functions) and generate a PS wrapper.

##MidTerm Goals
* Call Back to PowerShell.
* Access PS variables from within JS.
* Ability to submit PS events.
* various package distributions (Joels, Chocolatey , Nuget)
* CoffeeScript and TypeScript support (include those libraries automatically, and functions that will parse,compile,and execute them)

##Non-Goals
* any WebServer or trying to be Node.JS.

##Possible Future Scope
* Enter-JSSession - basically a Javascript REPL interface not too unlike Node.JS 
* Start-JSJob - aysnc sessions that work like jobs. working behind the scenes, either it will plug
  into the PSJob framework with | Wait-job and Receive-Job or at least work in a consistant manner. (Wait-JSJob , Receive-JSJob).
* Object to do Ajax calls.

#Examples

	 ipmo PowerChakra -Force
	 
	 #invoke a simple expression
	 invoke-js "5+5"
	 
	 New-JSSession -Name test
	 #invoke an expression, in a session, and DON'T RETURN RESULTS
	 Invoke-JS -Name test -Script "var x = 5; function add(y){return y+y}" -NoResults
	 #reuse the session, running a function previously applied AND return results.
	 Invoke-JS -Name test -Script "add(x,10)"

	 #create a nested PS object
	 invoke-JS -Name test -Script "var ourobj = {name : 'PowerChakra', numbers : [1,2,3] , something: { x:1}  }" -NoResults
	 #get object as JSON, then convert to PS object 
	 $objectasJSON = invoke-JS -Name test -Script "JSON.stringify(ourobj)"
	 $objectasJSON 
	 $objectasPSobj = ConvertFrom-Json $objectasJSON
	 $objectasPSobj | fl
 
A TypeScript Example

	ipmo PowerShellJS -Force
	$null = New-JSSession -Name test
	Invoke-TypeScript -name test -script "1+1"
	Invoke-TypeScript -name test -script "var adder = x => x * x" -NoResults
	Invoke-JS -name test -Script "adder(5)"

#Installation
Copy PSModule/PowerShellJS to your PowerShellModules folder, then load with Import-Module

###Random Notes
SessionID and Name
Call backs
JS exceptions.


# License

(C) 2013-2014 ShellTools LLC. Released under [Microsoft Public License (Ms-PL)](https://github.com/klumsy/PowerChakra/blob/master/LICENSE.md)

The .Net Javascript Wrapper is derived from [MSieJavaScriptEngine]
(http://github.com/Taritsyn/MsieJavaScriptEngine)
[Microsoft Public License (Ms-PL)](http://github.com/Taritsyn/MsieJavaScriptEngine/blob/master/LICENSE.md)

# Credits
* [MSieJavaScriptEngine](http://github.com/Taritsyn/MsieJavaScriptEngine) - [License: Microsoft Public License (Ms-PL)](http://github.com/Taritsyn/MsieJavaScriptEngine/blob/master/LICENSE.md) Part of the code of this library served as the .Net library powering PowerChakra.
* [SassAndCoffee.JavaScript](http://github.com/xpaulbettsx/SassAndCoffee) - [License: Microsoft Public License (Ms-PL)](http://github.com/xpaulbettsx/SassAndCoffee/blob/master/COPYING) Part of the code of this library served as the basis for MSIE JS Engine.
* [ECMAScript 5 Polyfill](http://nuget.org/packages/ES5) - Adds support for many of the new functions in ECMAScript 5 to downlevel browsers using the samples provided by Douglas Crockford in his ["ECMAScript 5: The New Parts"](http://channel9.msdn.com/Events/MIX/MIX11/EXT13) talk.
* [JSON2 library](http://github.com/douglascrockford/JSON-js) - Adds support of the JSON object from ECMAScript 5 to downlevel browsers.
* [Microsoft Ajax Minifier](http://ajaxmin.codeplex.com/) - [License: Apache License 2.0 (Apache)](http://ajaxmin.codeplex.com/license) JS-files, that used MSIE JS Engine, minificated by using ajaxmin.exe.
* [TypeScript](http://typescript.codeplex.com) - [License: Apache License 2.0 (Apache)](http://typescript.codeplex.com/license) TypeScript Language and Compiler
