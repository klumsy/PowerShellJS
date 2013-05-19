 #ipmo C:\Users\v-kapros\Documents\GitHub\PowerChakra\PSModule\PowerChakra -Force
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
 