let $dict := fn:doc('../XVKS A-H.UUS_20.03.16_7.html')
let $vaipooli := "J, Ra, Li, Lu"
(: Jõgõperä, Rajo, Liivtšülä, Luuditsa :)


return 
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta charset="utf-8" />
		<title>XVKS A-H.UUS_20.03.16_7</title>
		<link href="XVKS-A-H.UUS_20.03.16_7-web-resources/css/XVKS%20A-H.UUS_20.03.16_7.css" rel="stylesheet" type="text/css" />
	</head>
	<body id="XVKS-A-H.UUS_20.03.16_7" xml:lang="et-EE">


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