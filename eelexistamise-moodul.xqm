(:~
 : This module contains the Votic dictionary EELexification scripts.
 : @copyright Keeleleek
 : @license GPLv3
 : @author Kristian Kankainen
 :)
module namespace keeleleek = "http://vadja.keeleleek.ee";
declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace functx = 'http://www.functx.com';

declare variable $keeleleek:db-name := "voteelex";

(:~ marks the elements holding headwords :)
declare updating function keeleleek:mark-headwords() {
  for $vana-rida in db:open($keeleleek:db-name)//*:body/*:div/*:p
  return
    replace node $vana-rida with 
    copy $rida := $vana-rida
        modify (
          for $ms1node in $rida//*:span[string-length(.) > 0 and contains(./@class, "ms1")]
            return (
              (: nimeta ümber <span class="ms1"> --> <vot:P><vot:mg><vot:m> :)
              insert node <vot:P><vot:mg><vot:m>{$ms1node/string()}</vot:m></vot:mg></vot:P>
                  after $ms1node,
              delete node $ms1node),
              (: nime artiklielement ümber :)
            rename node $rida as 'vot:A',
            delete node $rida/@xml:lang
        )
        return $rida
};


(:~ combine articles without headwords together with the previous headword article :)
declare updating function keeleleek:fix-missing-headword-articles() {
  for $katkinerida in db:open($keeleleek:db-name)//vot:A[not(exists(.//vot:m))]
  let $õigerida := $katkinerida/preceding-sibling::vot:A[1]
  return (
      insert nodes $katkinerida/node()
          as last into $õigerida,
          delete node $katkinerida
  )
};

(:~ merges two successive vot:m elements :)
declare updating function keeleleek:merge-successive-m-elements() {
  (: kõik märksõnatekstid mis järgnevad märksõnatekstile pantakse kokku eelmise elemendi alla:)
  for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[count(vot:P) > 1]
    return 
      replace node $vana-artikkel with
      copy $artikkel := $vana-artikkel
      modify(
        for $P in $artikkel//vot:P
          return
          if ($P/preceding-sibling::node()[1]/node-name() = QName("http://www.eki.ee/dict/vot", "P"))
          then (
            insert node $P/vot:mg/vot:m/string() as last into $P/preceding-sibling::node()[1]/vot:mg/vot:m,
            delete node $P
          )
          else ()
      )
      return $artikkel
};


(:~ deletes the html head element from the dictionary xml :)
declare updating function keeleleek:clean-html-delete-head() {
  delete nodes db:open($keeleleek:db-name)//*:head
};

(:~ renames the html body element as eelex sr :)
declare updating function keeleleek:clean-html-rename-sr() {
  for $body in db:open($keeleleek:db-name)//*:body 
    return (
      (: lisa keel või muuda olemasolev keel :)
      if (exists($body/@xml:lang))
      then (replace value of node $body/@xml:lang with "vot")
      else (insert node attribute xml:lang {"vot"} into $body),
      (: muuda html-body ümber sr elemendiks :)
      rename node $body as "vot:sr"
    )
};

(:~ removes the root html element from the dictionary :)
declare updating function keeleleek:clean-html-replace-html() {
  for $html-root in db:open($keeleleek:db-name)/*:html
    return replace node $html-root with $html-root//vot:sr
};


(:~ removes the html div elements from the dictionary xml :)
declare updating function keeleleek:clean-html-remove-div() {
  for $div in db:open($keeleleek:db-name)//*:div
    return replace node $div with $div/vot:A
};

(:~ removes spans with class="ms1" from the dictionary xml :)
declare updating function keeleleek:clean-html-remove-ms1-spans() {
  delete nodes db:open($keeleleek:db-name)//*:span[contains(@class, "ms1")]
};

(: @todo hiljem võiks ka delete nodes xhtml:* :)

(:~ puts together superscript numbers with preceding words  :)
declare updating function keeleleek:move-superscript-numbers() {
  for $vana-artikkel in db:open($keeleleek:db-name)//text()[matches(., "^\s*(¹|²|³|\p{IsSuperscriptsandSubscripts})")]//ancestor::vot:A
  return
  replace node $vana-artikkel with
  copy $artikkel := $vana-artikkel
  modify(
    let $kõik-tekstid := $artikkel//text()
    for $hom-nr-tekst in $artikkel//text()[matches(., "^\s*(¹|²|³|\p{IsSuperscriptsandSubscripts})")]
      (: @todo: number ei pruugi alata sealt! leia numbri indeks! :)
      let $number := substring($hom-nr-tekst, 1, 1)
      let $numbrist-järgmine-tekst := substring($hom-nr-tekst, 2)
      let $nr-pos := functx:index-of-node($kõik-tekstid, $hom-nr-tekst)
      return (
        (: jätame teksti mis esines pärast numbrit alles :)
        replace value of node $kõik-tekstid[$nr-pos] with $numbrist-järgmine-tekst,
        (: lisame numbri eelmise tekstitipu otsa :)
        replace value of node $kõik-tekstid[$nr-pos - 1] with concat($kõik-tekstid[$nr-pos - 1], $number)
      )
  )
  return $artikkel
};

(:~ märgendab kõik kursiivis teksti vadjakeelseks :)
declare updating function keeleleek:märgenda-vadja-näitelaused() {
  for $italic-text in db:open("vot")//*:span[@class="regular-italic"]
  return
  replace node $italic-text with
  copy $text := $italic-text
  modify (
    (: lisa keel või muuda olemasolev keel :)
      if (exists($text/@xml:lang))
      then (replace value of node $text/@xml:lang with "vot")
      else (insert node attribute xml:lang {"vot"} into $text),
      (: nimeta 'span' ümber 'näitelause' elemendiks :)
      rename node $text as "vot:näitelause"
  )
  return $text
};

(:~ lisa kürilitsale keel :)
declare updating function keeleleek:lisa-vene-keele-märgend() {
  let $kürilitsa := "([-]?(\p{IsCyrillic}|\p{IsCyrillicSupplement}|ï)(\p{IsCyrillic}|\p{IsCyrillicSupplement}|\p{IsCombiningDiacriticalMarks}|[ ï/,()]|&#45;|&#8211;)*)"

for $element in db:open($keeleleek:db-name)//vot:A//text()[matches(., $kürilitsa)]/..
  return
    replace node $element with
    copy $new-element := $element
    modify (
      for $text-node in $new-element/text()[matches(., $kürilitsa)]
      let $analysis := fn:analyze-string($text-node, $kürilitsa)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (: @todo mis selle elemendi nimi peaks olema? :)
                  (<vot:vene xml:lang="ru">{$part/fn:group/string()}</vot:vene>)
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
};

(: @todo: võiks teha sama mis eelmine, aga kooloniga ehk märksõna liigiga -- seda pole vaja! :)
(:~ puts together superscript numbers with preceding words  :)
declare updating function keeleleek:move-word-final-consonants() {
  for $vana-artikkel in db:open($keeleleek:db-name)//text()[matches(., "^(ᴢ|ʙ|ᴅ|ɢ)")]//ancestor::vot:A
  return
  replace node $vana-artikkel with
  copy $artikkel := $vana-artikkel
  modify(
    let $kõik-tekstid := $artikkel//text()
    for $hom-nr-tekst in $artikkel//text()[matches(., "^(ᴢ|ʙ|ᴅ|ɢ)")]
      let $number := substring($hom-nr-tekst, 1, 1)
      let $numbrist-järgmine-tekst := substring($hom-nr-tekst, 2)
      let $nr-pos := functx:index-of-node($kõik-tekstid, $hom-nr-tekst)
      return (
        (: jätame teksti mis esines pärast numbrit alles :)
        replace value of node $kõik-tekstid[$nr-pos] with $numbrist-järgmine-tekst,
        (: lisame numbri eelmise tekstitipu otsa :)
        replace value of node $kõik-tekstid[$nr-pos - 1] with concat($kõik-tekstid[$nr-pos - 1], $number)
      )
  )
  return $artikkel
};


(:~ moves the headword's homonymy number as an attribute :)
declare updating function keeleleek:mark-headword-homonymy-number() {
  for $vana-märksõna in db:open($keeleleek:db-name)//vot:m[fn:matches(., "(¹|²|³|\p{IsSuperscriptsandSubscripts})\s*$")]
  return
  
  replace node $vana-märksõna with
  copy $märksõna := $vana-märksõna
  modify(
    let $märksõna-tekst := fn:replace($märksõna,
                                                       "(^.*)(¹|²|³|\p{IsSuperscriptsandSubscripts})(\s*$)",
                                                       "$1")
    let $märksõna-nr := fn:replace($märksõna,
                                                   "(^.*)(¹|²|³|\p{IsSuperscriptsandSubscripts})(\s*$)",
                                                   "$2")
      return (
        (: märksõna tekstiks jääb tekst ilma hom-numbrita ja tühemiketa :)
        replace value of node $märksõna with $märksõna-tekst,
        (: ülašriftis numbri peame tegema ümber tavaliseks numbriks :)
        insert node attribute vot:i {keeleleek:superscript-nr-to-nr($märksõna-nr)} into $märksõna
      )
  )
  return $märksõna
};

(:~ moves the homonymy number from the elements text into it's corresponding attribute :)
(: @todo this should eradicate the need of the previous headword-homonymy-number function :)
declare updating function keeleleek:mark-element-homonymy-number() {
  for $old-element-with-homnum in db:open($keeleleek:db-name)//(vot:m|vot:syn|vot:der|vot:mvt|vot:yvt)[matches(., "(¹|²|³|\p{IsSuperscriptsandSubscripts})(\s*$)")]
  return
    replace node $old-element-with-homnum with
    copy $element := $old-element-with-homnum
    modify(
      let $element-text := fn:replace($element,
                                                         "(^.*)(¹|²|³|\p{IsSuperscriptsandSubscripts})(\s*$)",
                                                         "$1")
      let $homnum-nr := fn:replace($element,
                                                     "(^.*)(¹|²|³|\p{IsSuperscriptsandSubscripts})(\s*$)",
                                                     "$2")
        return (
          (: elemendi tekstiks jääb tekst ilma hom-numbrita ja tühemiketa :)
          replace value of node $element with $element-text,
          (: ülašriftis numbri peame tegema ümber tavaliseks numbriks :)
          insert node attribute vot:i {keeleleek:superscript-nr-to-nr($homnum-nr)} into $element
        )
    )
    return $element
};


(:~ marks sense numbers :)
declare updating function keeleleek:mark-multi-senses() {
  for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[exists(.//*:span[contains(@class, "nr1")])]
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
};


(:~ marks the sense in mono-sensical item in articles where references exists :)
declare updating function keeleleek:mark-single-senses() {
  for $old-article in db:open($keeleleek:db-name)//vot:A[exists(.//vot:mvt union .//vot:vvt) and not(exists(.//vot:S))]
    return 
    replace node $old-article with
    copy $art := $old-article
    modify (
      let $last-before-S := ($art//(vot:mvt|vot:vvt))[last()]
      let $S := $last-before-S/following-sibling::node()
      (: koosta uus sisu-element :)
      let $new-S := <vot:S><vot:tp vot:tnr="1">{
          for $sibling in $S
            return 
              if ($sibling/node-name() = QName("http://www.eki.ee/dict/vot", "S"))
              then "heips" (: $sibling/vot:S :) (: @todo now this will never happen :)
              else $sibling
        }</vot:tp></vot:S>
      return
        if (count($new-S//node()) > 1)
        then (
          insert node $new-S after $last-before-S,
          delete node $S
        )
        else ()
    )
    return $art
};


(:~ helper function for converting superscript numbers to ordinary ascii digits :)
declare function keeleleek:superscript-nr-to-nr($superscript-nr as xs:string) {
  switch($superscript-nr)
  case "¹" return 1
  case "²" return 2
  case "³" return 3
  case "⁴" return 4
  case "⁵" return 5
  case "⁶" return 6
  case "⁷" return 7
  case "⁸" return 8
  case "⁹" return 9
  case "⁰" return 0
  default return $superscript-nr
};


(:~ mark placenames :)
declare updating function keeleleek:mark-placenames() {
  let $kohanimed := "(^|\s|[.,;])([(](vdjL|Pi|Ke|Ki|Kõ|Ja|Po|Lu|Li|Ra|Mu|Sa|vdjI|Ii|Ko|Ma|Kl|Ku|Kr|K|R|U|L|P|M|V|J|I|S)[)]|(vdjL|Pi|Ke|Ki|Kõ|Ja|Po|Lu|Li|Ra|Mu|Sa|vdjI|Ii|Ko|Ma|Kl|Ku|Kr|K|R|U|L|P|M|V|J|I|S))(\s|$|[.,;])"


for $element in db:open($keeleleek:db-name)//(* except vot:koht)/text()[matches(., $kohanimed)]/..
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
};


(:~ marks author names :)
declare updating function keeleleek:mark-author-names() {
  (: punkt võib esineda nime järel :)
let $autorinimed := "(Ahl|Al|Ar|Bor|Eur|Gro|Kett|Len|Lön|Must|Mäg|Pal|Pal[.]?\s*[12]|Por|[Rr]eg|[Rr]eg[.]?\s*[12]|Ränk|Salm[.]?\s*[12]|Set|Sj|Tsv|Tum|Vilb)"
(: ise leitud: K-Ahl.|J-Tsv.|J-Must.|Kõ-Len.|   (Ahl. 105)  :)
let $regexp := concat(
  "(^|\s|[.,;])([(]",
  $autorinimed,
  "[.]?[)]|", (: esimesed autorinimed on variant alg- ja lõppsuluga :)
  $autorinimed, (: teine on lihtsalt autorinimi:)
  "[.]?)(\s|$|[.,;])"
)

for $element in db:open($keeleleek:db-name)//(* except vot:autor)/text()[matches(., $regexp)]/..
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
};


(:~ marks specially marked placename and author names :)
declare updating function keeleleek:mark-special-place-author-names() {
let $kohanimed := "(vdjL|Pi|Ke|Ki|Kõ|Ja|Po|Lu|Li|Ra|Mu|Sa|vdjI|Ii|Ko|Ma|Kl|Ku|Kr|K|R|U|L|P|M|V|J|I|S)"
let $autorinimed := "(Ahl|Al|Ar|Bor|Eur|Gro|Kett|Len|Lön|Must|Mäg|Pal|Pal[.]?\s*[12]|Por|[Rr]eg|[Rr]eg[.]?\s*[12]|Ränk|Salm[.]?\s*[12]|Set|Sj|Tsv|Tum|Vilb)"
(: ise leitud: K-Ahl.|J-Tsv.|J-Must.|Kõ-Len.|   (Ahl. 105)  :)
let $regexp := concat(
  "(^|\s|[.,;])([(]",
  $kohanimed, "-", $autorinimed,
  "[.]?[)]|", (: esimesed autorinimed on variant alg- ja lõppsuluga :)
  $kohanimed, "-", $autorinimed, (: teine on lihtsalt autorinimi:)
  "[.]?)(\s|$|[.,;])"
)

for $element in db:open($keeleleek:db-name)//(* except vot:autor)/text()[matches(., $regexp)]/..
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
                  let $text := $part/fn:group[@nr=2]/string()
                  return 
                  ($part/fn:group[@nr=1]/text(),
                    <vot:pog vot:teor="2">
                      <vot:koht>{substring-before($text, "-")}</vot:koht>
                      <vot:autor>{substring-after($text, "-")}</vot:autor>
                    </vot:pog>,
                    $part/fn:group[@nr=(max($part/fn:group/@nr))]/text()
                  )
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
};


(:~ marks borrowing language :)
declare updating function keeleleek:mark-borrowing-language() {
  let $kohanimed := "(\[\s*<\s*)((e|is|sm|vn)(,\s*(e|is|sm|vn))*)(\s*\?\s*\])"

  for $element in db:open($keeleleek:db-name)//(* except vot:lak)/text()[matches(., $kohanimed)]/..
  return 
    replace node $element with
    copy $new-element := $element
    modify (
      for $text-node in $new-element//text()[matches(., $kohanimed) and not(./parent::vot:lak)]
      let $analysis := fn:analyze-string($text-node, $kohanimed)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (
                    for $keel in tokenize($part/fn:group[@nr=2]/string(), "\s*,\s*")
                      return
                      <vot:lak>{
                        if (contains($part/fn:group[@nr=6], "?"))
                        then (attribute vot:as {"?"})
                        else (),
                          $keel
                      }</vot:lak>
                  )
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
};

(:~ marks style :)
declare updating function keeleleek:mark-style() {
  let $kohanimed := "(^|\s|[.,;])((kk|mõist|rl|vs)[.]?)(\s|$|[.,;])"

  for $element in db:open($keeleleek:db-name)//(* except vot:nli)/text()[matches(., $kohanimed)]/..
  return 
    replace node $element with
    copy $new-element := $element
    modify (
      for $text-node in $new-element//text()[matches(., $kohanimed) and not(./parent::vot:nli)]
      let $analysis := fn:analyze-string($text-node, $kohanimed)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (:<vot:koht>{$part/text()}</vot:koht>:)
                  ($part/fn:group[@nr=1]/text(),
                      <vot:nli>{$part/fn:group[@nr=2]/string()}</vot:nli>,
                    $part/fn:group[@nr=3]/text()
                  )
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element

};


(:~ marks üldviited :)
declare updating function keeleleek:mark-üldviited() {
  for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[matches(., "Vt[.]\s+ka")]
  return
  replace node $vana-artikkel with
  copy $artikkel := $vana-artikkel
  modify (
    for $viide in $artikkel//text()[matches(., "Vt[.]\s+ka")]
      let $m := $viide//parent::vot:A/vot:m/string()
      let $viiteelement := $viide/following::*[1]
      let $viitetekst := $viiteelement/string()
      let $viited := tokenize($viitetekst, ",\s+")
      return
      if (exists($viiteelement))
      then (
        replace value of node $viide with replace($viide/string(), "[––]\s+Vt[.]\s+ka\s*", ""),
        replace node $viiteelement with <vot:yvtg>{
          for $viit in $viited
            return (
              <vot:yvt>{
                (: kustuta veel viimase viite järel oleva punkti ära :)
                replace($viit, "[.]\s*$", "")}</vot:yvt>
            )
          }</vot:yvtg>
      )
      else ()
  )
  return $artikkel
};

(:~ marks vasteviited :)
declare updating function keeleleek:mark-vasteviited() {
  for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[matches(., "←")]
  return
  replace node $vana-artikkel with
  copy $artikkel := $vana-artikkel
  modify (
    for $viide in $artikkel//text()[matches(., "←")]
      let $m := $viide//parent::vot:A/vot:m/string()
      let $viiteelement := $viide/following::*[1]
      let $viitetekst := $viiteelement/string()
      let $viited := $viitetekst (: substring kuni semikoolon :)
      let $liik := if (matches($viide, "dem")) then ("dem") 
                      else(if (matches($viide, "frekv")) then ("frekv") 
                      else(if (matches($viide, "refl")) then ("refl") 
                      else()))
      let $uustekst := replace($viide/string(), "\s*(dem|frekv|refl)[.]?\s*←\s*", "")
      return
      if (exists($viiteelement))
      then (
        replace value of node $viide with $uustekst,
        replace node $viiteelement with <vot:vvt>{
          for $viit in $viited
            return (
              <vot:der>{
                attribute vot:dk {$liik},
                replace($viit, "[;]\s*$", "")
              }</vot:der> (: kustuta viimase viite järel oleva punkti:)
            )
          }</vot:vvt>
      )
      else ()
  )
  return $artikkel
};


(:~ marks viidemärksõna viited :)
declare updating function keeleleek:mark-viidemärksõna-viited() {
  for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[matches(., "vt[.]\s+ka")]
  return
  replace node $vana-artikkel with
  copy $artikkel := $vana-artikkel
  modify (
    for $viide in $artikkel//text()[matches(., "^\s*vt[.]\s+ka\s*$")] (: @TODO üks viide on sidekriipsuga '- vt. ka' :)
      let $m := $viide//parent::vot:A/vot:m/string()
      let $viiteelement := $viide/following::*[1]
      let $viitetekst := $viiteelement/string()
      let $viited := tokenize($viitetekst, ",\s+")
      return
      if (exists($viiteelement))
      then (
        (: kustuta ära tühikutega ümbritsetud tekst 'vt. ka' :)
        replace value of node $viide with replace($viide/string(), "\s*vt[.]\s+ka\s*", ""),
        replace node $viiteelement with <vot:mvtg>{
          for $viit in $viited
            return (
              <vot:mvt>{replace($viit, "[.]\s*$", "")}</vot:mvt> (: kustuta viimase viite järel oleva punkti:)
            )
          }</vot:mvtg>
      )
      else ()
  )
  return $artikkel
};


(:~ marks üldnäited NB! depends on mark-üldviited() :)
declare updating function keeleleek:mark-üldnäited() {
  (: üldnäited esinevad vot:S elemendis pärast tähendusplokki tp ja enne üldviitegruppi yvt :)
for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[contains(., "■")]
  return 
  replace node $vana-artikkel with
  copy $artikkel := $vana-artikkel
  modify (
    let $tekst-element := $artikkel//text()[contains(., "■")]
    let $tekst := tokenize($tekst-element, "\s*■\s*")
    let $siblings := $tekst-element/following-sibling::node()
    (: stop on viimase üldviitegrupi index või viimane tipp :)
    let $stop :=
      if (count($siblings[node-name(.) = QName("http://www.eki.ee/dict/vot", "yvtg")]) > 0)
      then (functx:index-of-node($siblings, $siblings[node-name(.) = QName("http://www.eki.ee/dict/vot", "yvtg")][1]))
      else (count($siblings))
    
    let $ynp-sisu := ($siblings[position() < $stop])
    (: kõik tekst pärast ■ läheb üldnäiteploki algusesse :)
    let $ynp := <vot:ynp>{$tekst[2], $ynp-sisu}</vot:ynp>
    return (
      (: kõik tekst enne ■ jääb algsesse tekst-elemendisse :)
      replace value of node $tekst-element with $tekst[1],
      insert node $ynp after $tekst-element,
      delete nodes $ynp-sisu
    )
  )
  return $artikkel
};


(:~ marks original equivalents :)
declare updating function keeleleek:mark-original() {
  let $regexp := "^(.*)\(orig[.]?:?\s*([^\)]*)\)(.*)$"

  (: ei leia juhud üles, kus sulgudevaheline tekst asub omaette eraldi elemendis :)
  for $vana-text in db:open($keeleleek:db-name)//(* except vot:xor)/text()[matches(., $regexp)]/..
  return
    replace node $vana-text with
    copy $text := $vana-text
    modify(
      for $text-node in $text//text()[matches(., $regexp) and not(./parent::vot:xor)]
      let $analysis := fn:analyze-string($text-node, $regexp)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  ($part/fn:group[@nr=1]/text(),
                      <vot:xor>{$part/fn:group[@nr=2]/string()}</vot:xor>,
                    $part/fn:group[@nr=3]/text()
                  )
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) after $text-node,
              delete node $text-node
        )
    )
    return $text
};


(:~ moves the type of the headword into an attribute of the vot:m element. :)
declare updating function keeleleek:headword-type() {
  for $old-typed-headword in db:open($keeleleek:db-name)//vot:m[matches(., "^\s*~|:\s*$")]
    return 
    replace node $old-typed-headword with
    copy $typed-headword := $old-typed-headword
    modify(
      (: lõppeb kooloniga:)
      if (matches($typed-headword/text(), ":\s*$"))
      then (
        insert node attribute vot:liik {"vm"} into $typed-headword,
        replace value of node $typed-headword with replace($typed-headword/text(), "\s*:\s*$", "")
      )
      (: algab tildega:)
      else if (matches($typed-headword/text(), "^\s*~"))
      then (
        insert node attribute vot:liik {"ps"} into $typed-headword,
        replace value of node $typed-headword with replace($typed-headword/text(), "^\s*~\s*", "")
      )
      (: @todo throw error! :)
      else ()
    )
    return $typed-headword
};


(:~ extracts the information that makes up the headword's collation value :)
declare updating function keeleleek:update-headword-collate-value() {
  for $headword in db:open($keeleleek:db-name)//vot:m
    return
      insert node attribute vot:O {normalize-space(replace($headword, "[^\p{L} ]", ""))}
      into $headword
};


(:~ merges two consecutive placenames and authornames into a single pog element :)
declare (:updating:) function keeleleek:merge-pog-elements() {
  (: :)
  for $vana-artikkel in db:open($keeleleek:db-name)//vot:A[count(vot:pog) > 1]
    return 
      (:replace node $vana-artikkel with:)
      copy $artikkel := $vana-artikkel
      modify(
        for $autor-pog in $artikkel//vot:pog[exists(.//vot:autor)]
          let $preceding-pog := $autor-pog/preceding-sibling::*[1]
          return
            if ($preceding-pog/node-name() = QName("http://www.eki.ee/dict/vot", "pog")
                and exists($preceding-pog//vot:koht))
            then (
              insert node $autor-pog/vot:autor as last into $preceding-pog (:,
              delete node $autor-pog:)
            )
            else ()
      )
      return $artikkel
};


(:~ kustuta hiljem ära -- leiab ainult 20 sõnaartiklit :)
declare function keeleleek:mark-mg-ki-elements() {
  for $art in db:open($keeleleek:db-name)//vot:A[exists(./vot:P/preceding-sibling::text())]
    return $art
};


(:~ normalizes all whitespace :)
declare updating function keeleleek:fix-nbsp() {
  for $old-element-with-nbsp in db:open($keeleleek:db-name)//text()[contains(., "&#160;")]/..
    return 
    replace node $old-element-with-nbsp with
    copy $element-with-nbsp := $old-element-with-nbsp
    modify (
      for $text in $element-with-nbsp/text()[contains(., "&#160;")]
      return 
      replace node $text
      with normalize-space(replace($text, "&#160;", " "))
    )
    return $element-with-nbsp
};


(: marks the alternative headwords in P :)
declare updating function keeleleek:mark-alternative-headwords() {
  for $alt-hw in db:open("vot")//*:span[@class = "regular-italic" and exists(./ancestor::*:P)]
    return (
      rename node $alt-hw as "vot:m",
      delete nodes $alt-hw/@*
    )
};


(: marks the votic example texts in S :)
declare updating function keeleleek:mark-votic-example-texts() {
  for $example in db:open("vot")//*:span[@class = "regular-italic" and exists(./ancestor::*:S)]
    return (
      rename node $example as "vot:n",
      delete nodes $example/@*
    )
};


(:~ removes all element names and attributes that does not belong to eelex :)
declare updating function keeleleek:export-to-eelex() {
  for $wrong-ns-node in db:open($keeleleek:db-name)//((* except vot:*)|(@* except (@vot:*|@xml:*)))
    return
      if ($wrong-ns-node instance of element())
      (: elemendid kustutakse ära jättes alles nende sisu :)
      then (
        let $parent := $wrong-ns-node/..
        (: @todo insert whitespace before and after content :)
        return insert nodes $wrong-ns-node/node() after $parent/$wrong-ns-node,
        delete node $wrong-ns-node
      )
      (: atribuudid kustutakse ära koos nende sisuga :)
      else (delete node $wrong-ns-node)
};


(:~ 
This function takes a list of database names and optionally a list of language codes.
It creates separate full-text indexed databases for lemmatized searching of each language contained in the original database.
If the list of language codes is empty, all existing values of xml:lang found in the database is used.
The full-text databases are named 'dbname-ft-langcode' 
Another function normalizes the texts, removes duplicate entries and inserts xml:id attributes
:)
declare updating function keeleleek:create-ft-indices-for-each-lang(
  $db-names as xs:string*,
  $lang-codes as xs:string*
) {
  for $db-name in $db-names
    let $langs := if( not( empty( $lang-codes )))
                         then( $lang-codes )
                         else( distinct-values(db:open($db-name)//@xml:lang) )
    for $lang in $langs
      let $lang-group := db:open($db-name)//*[@xml:lang = $lang]
      let $ft-db-name := concat($db-name, '-ft-', $lang)
      
      (: create full-text db for each language :)
      return
        db:create(
          $ft-db-name,
            <context xml:lang="{$lang}">{
              for $text at $count-position in $lang-group
                return <text-representation id="{concat($ft-db-name, "-",$count-position)}">{
                            $text
                          }</text-representation>
            }</context>,
          $ft-db-name,
          map { 'ftindex': true(), 'language': $lang }
      ) 
};

(:~
Helper function for organizing the content of autogenerated full-text indices.
* normalize texts (both unicode and whitespace)
* remove duplicate entries
* insert identifiers
declare updating function keeleleek:reorganize-ft-indices() {
  
      let $lang-group-with-ids := 
                            for $element at $count-number in $lang-group//*
                              return
                                copy $element-with-id := $element
                                modify (
                                  insert node attribute 
                                      xml:id
                                      {concat($ft-db-name, '-', $count-number)} 
                                    into $element-with-id
                                )
                                return $element-with-id
  
};

:)


declare updating function keeleleek:remove-and-cleanup() {
  (: html elements, xml:lang attributes, spans, etc :)
};



(:~ 
 Return the names of elements in the votic namespace.
 :)
declare function keeleleek:show-vot-element-names() as xs:string* {
  distinct-values(index:facets('vot')//*[starts-with(@name, 'vot')]/@name)
};



(:~
 Return the number of whitespace separated Votic tokens contained in the example sentences.
 :)
declare function keeleleek:votic-tokens-in-example-sentences() as xs:integer{
  db:open("vot")//*:näitelause => distinct-values() => string-join(" ") => tokenize() => count()
};
