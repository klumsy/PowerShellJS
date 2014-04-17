ipmo PowerShellJS -Force
$null = New-JSSession -Name test
Invoke-TypeScript -name test -script "1+1"
Invoke-TypeScript -name test -script "var adder = x => x * x" -NoResults
Invoke-JS -name test -Script "adder(5)"