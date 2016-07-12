declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

for $body in db:open('basex')//xhtml:body 
return rename node $body as "vot:sr"