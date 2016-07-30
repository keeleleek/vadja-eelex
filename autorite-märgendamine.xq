declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
(:import module namespace keeleleek ="http://codemodules.keeleleek.ee/xquery" at "votxq.xqm";:)


(: punkt võib esineda nime järel :)
let $autorinimed := "(K-Ahl|Ahl|Al|Ar|Bor|Eur|Gro|Kett|Kõ-Len|Len|R-Lön|Lön|J-Must|Must|Mäg|Pal|Pal[.]?\s*[12]|Por|Reg|reg[.]?\s*[12]|Ränk|Salm[.]?\s*[12]|Set|K-Set|M-Set|Sj|J-Tsv|Tsv|Tum|Vilb|R-Reg)"
(: ise leitud: K-Ahl.|J-Tsv.|J-Must.|Kõ-Len.|   (Ahl. 105)  :)
let $regexp := concat(
  "(^|\s|[.,;])([(]",
  $autorinimed,
  "[.]?[)]|", (: esimesed autorinimed on variant alg- ja lõppsuluga :)
  $autorinimed, (: teine on lihtsalt autorinimi:)
  "[.]?)(\s|$|[.,;])"
)

for $element in db:open('vot')//(* except vot:autor)/text()[matches(., $regexp)]/..
  return 
    replace node $element with
    copy $new-element := $element
    modify (
      for $text-node in $new-element//text()[matches(., $regexp) and not(./parent::vot:autor)]
      let $analysis := fn:analyze-string($text-node, $regexp)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (:<vot:koht>{$part/text()}</vot:koht>:)
                  ($part/fn:group[@nr=1]/text(),
                    <vot:pog>
                      <vot:autor>{$part/fn:group[@nr=2]/string()}</vot:autor>
                    </vot:pog>,
                    $part/fn:group[@nr=4]/text()
                  )
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
