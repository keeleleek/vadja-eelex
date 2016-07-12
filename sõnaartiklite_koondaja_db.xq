let $dictfiles := (
  'XVKS A-H.UUS_20.03.16_7.html',
  'XVKS I-L.UUS_20.03.16_7.html',
  'XVKS M-R.UUS_20.03.16_7.html',
  'XVKS S-Y.UUS_20.03.16_7.html'
)

for $file in $dictfiles
  let $dict := db:open("vadjahtml", $file)

for $rida in $dict//*:body/*:div/*:p
  let $kogu_ms :=
    for $ms_segm in $rida/*:span[
        contains(./@class, "ms1")
        ]
      return $ms_segm
    
  let $kogu_ms_text := $kogu_ms/text()
  
  return
    if (count($kogu_ms) > 0)
    then 
      
      <m>{$kogu_ms_text}</m>
    else
      (: katkised read liita kokku eelmise reaga :)
      let $vale-rida := $rida
      let $õige-rida := $rida
        /preceding-sibling::*:p[1]
      return 
        (node-name($õige-rida), count($õige-rida), $õige-rida, $rida)
        (: esimesena 
        insert node $vale-rida
          as last into $õige-rida :)
        (: teisel korral 
        delete node $vale-rida :)