let $dictfiles := (
  '../XVKS A-H.UUS_20.03.16_7.html',
  '../XVKS A-H.UUS_20.03.16_7.html',
  '../XVKS A-H.UUS_20.03.16_7.html',
  '../XVKS A-H.UUS_20.03.16_7.html'
)
for $file in $dictfiles
  let $dict := fn:doc($file)

(: leia kaks või enam samasugust järjestikku elementi :)

(:
let $el := 

:)
for $el in $dict//*
return 
  element { node-name($el) } 
  {
    $el/@*
  }
