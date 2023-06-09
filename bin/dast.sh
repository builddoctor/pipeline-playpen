#!/bin/bash

BASE="builddoctor-pipeline-playpen.azurewebsites.net/"

case "${1}" in
  test|prod)
    url="https://${1}-${BASE}"
  ;;

  *)
    echo "Usage: $0 <env>"
    exit 1
  ;;
esac

docker run  -v "$(pwd):/zap/wrk/:rw" \
   --user root \
  -t owasp/zap2docker-stable zap-baseline.py \
  -x zap.xml \
  -u file:///zap/wrk/zap/zap.conf \
  -d -I -r zap/zap.html \
  -t ${url}

  exit 0
