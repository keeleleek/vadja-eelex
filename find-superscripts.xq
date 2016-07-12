(:distinct-values(db:open('basex')//*:A//*[contains(@class, "nr1")]/text()) :)
db:open('vot')//text()[matches(., ".*\p{IsSuperscriptsandSubscripts}.*")]