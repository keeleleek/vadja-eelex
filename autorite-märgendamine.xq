declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace keeleleek ="http://codemodules.keeleleek.ee/xquery" at "votxq.xqm";

(: kuskil on küll viga olemas -- kas mitte D-Tsv ? :)
let $autorinimed := "(^|\s|[.,;])(Ahl|Al|Ar|Bor|Eur|Gro|Kett|Len|Lön|Must|Mäg|Pal[.]\s*[12]|Por|Reg|reg[.]\s*[12]|Ränk|Salm[.]\s*[12]|Set|Sj|Tsv|Tum|Vilb)(\s|$|[.,;])"
(: ise leitud: K-Ahl.|J-Tsv.|J-Must.|Kõ-Len.|   (Ahl. 105)  :)

return keeleleek:enclose-matching-text(
  db:open('basex')//vot:A, $autorinimed, QName("http://www.eki.ee/dict/vot", "vot:autor")
)

(: 
updating
function enclose-matching-text(
  $root as node(),
  $regexp as xs:string(),
  $enclosing-element as QName(),
  ) :)
(:
for $element in db:open('basex')//vot:A//(* except vot:koht)/text()[matches(., $autorinimed)]/..
  return replace node $element
    with copy $new-element := $element
    modify (
      for $text-node in $new-element/text()[matches(., $autorinimed)]
      let $analysis := fn:analyze-string($text-node, $autorinimed)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  ($part/fn:group[@nr=1]/text(),<vot:koht>{$part/fn:group[@nr=2]/text()}</vot:koht>,$part/fn:group[@nr=3]/text())
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
:)