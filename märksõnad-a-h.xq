declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

(: 
state before: vot-2016-07-01-19-29-22
state after: vot-2016-07-01-19-32-05
execution time: 74067ms
:)

let $dictfiles := (
  'a-h.html',
  'i-l.html',
  'm-r.html',
  's-y.html'
)
for $file in $dictfiles
  let $dict := db:open('vot', $file)

for $rida in $dict//*:body/*:div/*:p
  return
    replace node $rida 
    with copy $uusrida := $rida
        modify (
          let $kogu_ms :=
            for $ms_segm in $uusrida//*:span[
              contains(./@class, "ms1")
              ]
            return $ms_segm
        
          let $kogu_ms_text := $kogu_ms/string()
      
          return
            if (count($kogu_ms) > 0)
            then (
              (: grupeeri ja liiguta märksõna artikli
                    algusesse :)
              insert node <vot:m>{$kogu_ms_text}</vot:m>
                as first into $uusrida,
              delete nodes $kogu_ms,
              (: nime artiklielement ümber :)
              rename node $uusrida as 'vot:A'
              (: kustuta kõik artikli atribuudid :)
              (:  delete nodes $uusrida/@* :)
            )
            else (: tagasta tühi (ära muuda midagi) :)
              ()
        )
        return $uusrida