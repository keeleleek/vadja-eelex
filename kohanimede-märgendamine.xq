declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

(: 
state before: vot-2016-07-01-19-34-02
state after: vot-2016-07-01-19-37-43, vot-2016-07-12-14-27-54
execution time: 63069ms + 36497ms
:)

(: lisa word-boundary ja non-grouping-groups :)
let $kohanimed := "(^|\s|[.,;])([(](vdjL|Pi|Ke|Ki|Kõ|Ja|Po|Lu|Li|Ra|Mu|Sa|vdjI|Ii|Ko|Ma|Kl|Ku|Kr|K|R|U|L|P|M|V|J|I|S)[)]|(vdjL|Pi|Ke|Ki|Kõ|Ja|Po|Lu|Li|Ra|Mu|Sa|vdjI|Ii|Ko|Ma|Kl|Ku|Kr|K|R|U|L|P|M|V|J|I|S))(\s|$|[.,;])"


for $element in db:open('vot')//(* except vot:koht)/text()[matches(., $kohanimed)]/..
  return 
    replace node $element with
    copy $new-element := $element
    modify (
      for $text-node in $new-element//text()[matches(., $kohanimed) and not(./parent::vot:koht)]
      let $analysis := fn:analyze-string($text-node, $kohanimed)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (:<vot:koht>{$part/text()}</vot:koht>:)
                  ($part/fn:group[@nr=1]/text(),
                    <vot:pog>
                      <vot:koht>{$part/fn:group[@nr=2]/string()}</vot:koht>
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
