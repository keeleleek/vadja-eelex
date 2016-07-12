let $dict := fn:doc('../XVKS M-R.UUS_20.03.16.11.html')
let $vaipooli := "J, Ra, Li, Lu"
(: Jõgõperä, Rajo, Liivtšülä, Luuditsa :)


return 
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta charset="utf-8" />
		<title>XVKS M-R.UUS_20.03.16.11</title>
		<link href="XVKS-M-R.UUS_20.03.16.11-web-resources/css/XVKS%20M-R.UUS_20.03.16.11.css" rel="stylesheet" type="text/css" />
	</head>
	<body id="XVKS-M-R.UUS_20.03.16.11" xml:lang="en-US-POSIX">


{
for $item in $dict//*:span[
  contains-token(., 'Ra')
  or contains-token(., 'J')
  or contains-token(., 'Li')
  or contains-token(., 'Lu')
]/parent::*
  return $item
}



</body></html>