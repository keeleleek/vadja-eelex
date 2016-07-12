declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace functx = 'http://www.functx.com';

(: 
state before: vot-2016-07-12-14-27-54
state after: vot-2016-07-12-16-41-00
execution time: 2414ms
:)

for $vana-artikkel in db:open('vot')//vot:A[exists(.//*:span[contains(@class, "nr1")])]
  let $nodes := $vana-artikkel/node()
  let $indices :=
    for $seq in (1 to count($nodes))
      return $seq[$nodes[$seq][contains(@class, "nr1")]]
  return
    replace node $vana-artikkel with
    copy $artikkel := $vana-artikkel
    modify (
      (: tükelda indeksite kohalt:)
      (: kuni esimeseni on Päis :)
      insert node <vot:P>{$nodes[position() < min($indices)]}</vot:P>
        as last into $artikkel,
      (: järgmised on Sisu tähendusnumbriga plokid :)
      (
        if (count($indices) = 1)
        then ()
        else (
            insert node
              <vot:S>{
          for $i in (1 to count($indices))
            let $index := $indices[$i]
            let $tähendusplokinumber := $nodes[$index]
            return 
                <vot:tp>{
                  attribute {'vot:tnr'} {replace($tähendusplokinumber, "[.]", "")},
                  $nodes[position() > $index 
                               and position() < (if (exists($indices[$i+1])) then ($indices[$i+1]) else(count($nodes)+1))]
                }</vot:tp>
            }</vot:S>
          as last into $artikkel)
      ),
      (: kustutame kõik vanad elemendid :)
      delete nodes $artikkel/(node() except (vot:P|vot:S))
      
    )
    return $artikkel