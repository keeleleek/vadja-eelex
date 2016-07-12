declare namespace locale = "java:java.util.Locale";
  (locale:getAvailableLocales() ! locale:getLanguage(.))
  => distinct-values()
  => sort()