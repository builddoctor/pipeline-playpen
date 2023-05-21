#!/bin/bash
#
set -xeuo pipefail

# thanks coderpatros!
#https://github.com/coderpatros/zap2junit
# can't find a cross-platform XSL 2.0 transfomer
#
#
OUTPUT='junit.xml'

dependendency() {
  local cmd=$1
  local package=$2
  which "${cmd}" || sudo apt-get install "${package}" -y
}

case $(uname -s) in
  Darwin)
    java -jar  /opt/homebrew/share/saxon-b/saxon9.jar -xsl:zap/zap2junit.xsl -s:zap.xml > "${OUTPUT}"
  ;;
  Linux)
    dependendency saxonb-xslt libsaxonb-java
    saxonb-xslt -xsl:zap/zap2junit.xsl -s:zap.xml > "${OUTPUT}"
  ;;
  *)
    echo "Sorry, I don't know this OS"
    echo 1
  ;;
esac
