declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace functx = 'http://www.functx.com';

(: 
state before: vot-2016-07-01-19-29-22
state after: vot-2016-07-01-19-32-05, vot-2016-07-12-14-20-20
execution time: 74067ms
:)


for $rida in db:open('vot')//*:body/*:div/*:p
  return
    replace node $rida 
    with copy $uusrida := $rida
        modify (
          let $ms_viimane_element := ($uusrida//*:span[contains(./@class, "ms1")])[last()]
          return 
          if (not(exists($ms_viimane_element)))
          then ()
          else (
            let $ms_viimase_pos := functx:index-of-node($uusrida//*, $ms_viimane_element)
            let $kogu_ms := $uusrida//*[position() <= $ms_viimase_pos]
              (:for $ms_segm in $uusrida//*:span[contains(./@class, "ms1")]
              return $ms_segm:)
          
            let $kogu_ms_text := $kogu_ms/string()
        
            return
              if (count($kogu_ms) > 0)
              then (
                (: grupeeri ja liiguta märksõna artikli
                      algusesse :)
                insert node <vot:P><vot:mg><vot:m>{$kogu_ms_text}</vot:m></vot:mg></vot:P>
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
        )
        return $uusrida