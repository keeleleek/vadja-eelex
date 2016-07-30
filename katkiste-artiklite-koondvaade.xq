declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

(: 
state before: vot-2016-07-01-19-32-05
state after: vot-2016-07-01-19-34-02, vot-2016-07-12-14-21-04
execution time: 2955ms
:)

for $katkinerida in db:open('vot')//vot:A[not(exists(.//vot:m))]
  let $õigerida := $katkinerida/preceding-sibling::vot:A[1]
  return (
      insert nodes $katkinerida/node()
          as last into $õigerida,
          delete node $katkinerida
  )
