#!/bin/bash

# thanks coderpatros!
#https://github.com/coderpatros/zap2junit
# can't find a cross-platform XSL 2.0 transfomer
case $(uname -s) in
  Darwin)
    java -jar  /opt/homebrew/share/saxon-b/saxon9.jar -xsl:zap2junit.xsl -s:zap.xml
  ;;
  Linux)
    which saxonb-xslt || sudo apt-get install -qq libsaxonb-java
    saxonb-xslt -xsl:zap2junit.xsl -s:zap.xml
  ;;
  *)
    echo "Sorry, I don't know this OS"
    echo 1
  ;;
esac
