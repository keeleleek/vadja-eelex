declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

for $div in db:open('basex')/xhtml:div
return  $div/vot:A