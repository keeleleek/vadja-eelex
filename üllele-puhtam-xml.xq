declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace keeleleek ="http://codemodules.keeleleek.ee/xquery" at "votxq.xqm";

<vot:sr>{
for $vana-kirje in db:open('vot')//vot:A[position() < 5]
return
  copy $kirje := $vana-kirje
  modify (
    delete node $kirje//*[namespace-uri(.) != "http://www.eki.ee/dict/vot"],
    delete node $kirje//@*[namespace-uri(.) != "http://www.eki.ee/dict/vot"]
  )
  return $kirje
}</vot:sr>