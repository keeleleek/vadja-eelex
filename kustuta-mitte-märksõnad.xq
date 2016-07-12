(: see kustutab ära kõik "mitte-märksõnad" html-idest
    failides on imelikud poolikud sõnaloendid ja ka
    algustähed on toodud välja eraldi elementides :)

let $dictfiles := (
  '../XVKS A-H.UUS_20.03.16_7.html',
  '../XVKS I-L.UUS_20.03.16.html',
  '../XVKS S-Y.UUS_20.03.16.html',
  '../XVKS M-R.UUS_20.03.16.11.html'
)
for $file in $dictfiles
  let $dict := fn:doc($file)

for $rida in $dict//*:body/*:div/*:p
  return 
  if (matches($rida, '&#9;'))
  then $rida
  else ()