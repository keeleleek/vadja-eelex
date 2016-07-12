declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

(: 
state before: vot-2016-07-01-19-37-43
state after: vot-2016-07-01-19-46-42, vot-2016-07-12-14-26-06
execution time: 187ms + 147ms + 2056ms + 2423ms
:)

(:delete nodes db:open('vot')//xhtml:head:)

(:for $body in db:open('vot')//xhtml:body 
  return rename node $body as "vot:sr":)

(:for $html-root in db:open('vot')/xhtml:html
  return replace node $html-root with $html-root//vot:sr:)

(:for $div in db:open('vot')//xhtml:div
  return replace node $div with $div/vot:A:)
