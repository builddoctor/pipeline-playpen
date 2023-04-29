#!/bin/bash
#
set -xeuo pipefail

# thanks coderpatros!
#https://github.com/coderpatros/zap2junit
# can't find a cross-platform XSL 2.0 transfomer
#

dependendency() {
  local cmd=$1
  local package=$2
  which "${cmd}" || sudo apt-get install "${package}" -y
}

case $(uname -s) in
  Darwin)
    java -jar  /opt/homebrew/share/saxon-b/saxon9.jar -xsl:zap2junit.xsl -s:zap.xml
  ;;
  Linux)
    dependendency saxonb-xslt libsaxonb-java
    saxonb-xslt -xsl:zap2junit.xsl -s:zap.xml > junit.xml
  ;;
  *)
    echo "Sorry, I don't know this OS"
    echo 1
  ;;
esac
