(:~ 
 : This module was created during the retro-digitization of the Votic dictionary.
 : It encapsulates a few general purpose functions sprung out from that work.
 :
 : @author Kristian Kankainen, MTÜ Keeleleek
 : @see http://www.github.org/kristiank/votxq
 : @version: 1.0
 :)
module namespace keeleleek = "http://codemodules.keeleleek.ee/xquery";


(:~ 
 : Encloses matching text with the element name given. Overlapping patterns
 : are not matched -- run the function twice instead. Don't do this!
 :  Identical elements with same text can be created!
 :
 : @param $root the element to be modified
 : @param $regexp the pattern to be matched
 : @param $enclosing-element the name of the element
 :)
declare updating
function keeleleek:enclose-matching-text(
  $root as element()+,
  $regexp as xs:string,
  $enclosing-element as xs:QName
  )
{
  (: should be similar to
  for $element in $root//(* except name($enclosing-element))/text()[matches(., $regexp)]/..:)
for $element in $root//text()[matches(., $regexp)]/..
  return replace node $element
    with copy $new-element := $element
    modify (
      for $text-node in $new-element/text()[matches(., $regexp)]
      let $analysis := fn:analyze-string($text-node, $regexp)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (:<vot:koht>{$part/text()}</vot:koht>:)
                  ($part/fn:group[@nr=1]/text(),
                   element {$enclosing-element} {$part/fn:group[@nr=2]/text()},
                   $part/fn:group[@nr=3]/text())
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
};
(:~ 
 : Encloses matching text with the element name given. Overlapping patterns
 : are not matched -- run the function twice instead. Don't do this!
 :  Identical elements with same text can be created!
 :
 : @param $root the element to be modified
 : @param $regexp the pattern to be matched
 : @param $enclosing-element the name of the element
 :)
declare
function keeleleek:enclose-matching-text-preview(
  $root as element()+,
  $regexp as xs:string,
  $enclosing-element as xs:QName
  )
{
  (: should be similar to
  for $element in $root//(* except name($enclosing-element))/text()[matches(., $regexp)]/..:)
for $element in $root//text()[matches(., $regexp)]/..
  return copy $new-element := $element
    modify (
      for $text-node in $new-element/text()[matches(., $regexp)]
      let $analysis := fn:analyze-string($text-node, $regexp)
      return (
        insert node (
          for $part in $analysis/*
            return
              switch ($part/name())
                case "fn:match" return 
                  (:<vot:koht>{$part/text()}</vot:koht>:)
                  ($part/fn:group[@nr=1]/text(),
                   element {$enclosing-element} {$part/fn:group[@nr=2]/text()},
                   $part/fn:group[@nr=3]/text())
                case "fn:non-match" return
                  $part/text()
                default return ()
              ) before $text-node,
              delete node $text-node
        )
    )
    return $new-element
};



