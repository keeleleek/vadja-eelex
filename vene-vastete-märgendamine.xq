declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace keeleleek ="http://codemodules.keeleleek.ee/xquery" at "votxq.xqm";

(: 
state before: vot-2016-07-01-19-46-42
state after: vot-2016-07-01-19-47-55
execution time: 4905ms
:)

let $kürilitsa := "([-]?(\p{IsCyrillic}|\p{IsCyrillicSupplement}|ï)(\p{IsCyrillic}|\p{IsCyrillicSupplement}|\p{IsCombiningDiacriticalMarks}|[ ï/,()]|&#45;|&#8211;)*)"

for $element in db:open('vot')//vot:A//text()[matches(., $kürilitsa)]/..
  return replace node $element
    with copy $new-element := $element
    modify (
      for $text-node in $new-element/text()[matches(., $kürilitsa)]
      let $analysis := fn:analyze-string($text-node, $kürilitsa)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (:<vot:koht>{$part/text()}</vot:koht>:)
                  (<vot:vene>{$part/fn:group/string()}</vot:vene>)
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
