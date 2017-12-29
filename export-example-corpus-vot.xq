import module namespace keeleleek ="http://vadja.keeleleek.ee" at "eelexify-module.xqm";
declare namespace vot = "http://www.eki.ee/dict/vot";

declare option output:method "xml";
declare option output:indent "no";
declare option output:omit-xml-declaration "yes";



(: Export to Korp with Giellatekno tags
   recursive typeswitch pattern from https://en.m.wikibooks.org/wiki/XQuery/Typeswitch_Transformations
:) 
declare function local:export-to-giellatekno-vrt($nodes as node()*)
{
  for $node in $nodes
  return
    typeswitch ($node)
    
    case (element(w))
    return
      concat(
        out:nl(),
        (: 1) token :)
        $node/text(),
        (: 2) lemma+morphemes :)
        if (exists($node/@lemma)) then (out:tab() || $node/@lemma) else (),
        if (exists($node/@pos)) then (" //_" || $node/@pos || "_ ") else (),
        if (exists($node/@analysis)) then ($node/@analysis || ", //") else ()
      )
      
    case (element(*))
    return
      (
        out:nl(), (: add a newline :)
        element {name($node)} {(
          $node/@*, (: pass through all attributes :)
          
          for $child in $node/node()
            return local:export-to-giellatekno-vrt($child)
          ,out:nl()
        )}
    )
    
    default
    return
      ()
};


let $corpus := 
<corpus title="Vadja keele sõnaraamat">
  <text title="Vadja näitelaused">
  {
  for $example in db:open($keeleleek:db-name)//vot:näitelause/text()
    let $tokens := analyze-string(
                        normalize-space($example),
                        '(\.\.\.)|\s|[.,…?!:;]'
                    )//text()[not(.=" ")]
    return
      <s>
      {
      for $token in $tokens
        return <w>{$token}</w>
      }
      </s>
  }
  </text>
</corpus>



return local:export-to-giellatekno-vrt($corpus)