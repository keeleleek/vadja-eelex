declare namespace vot = "http://www.eki.ee/dict/vot";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace keeleleek ="http://codemodules.keeleleek.ee/xquery" at "votxq.xqm";


for $a in db:open('basex')/vot:sr/vot:A[position() < 10]
  return (
  <artikkel>
    <märksõna>{$a//vot:m}</märksõna>
    {for $koht in $a//vot:koht
        return <pog><kyla>{$koht/string()}</kyla></pog>}
    {for $vene-vaste in $a//vot:vene
        return <xp xml:lang="ru">
            <xg>{$vene-vaste/string()}</xg>
          </xp>
    }
    <np><n>{$a//vot:ki}</n></np>
  </artikkel>
)