#!/bin/bash

case "${1}" in
  test)
    url='https://test-builddoctor-pipeline-playpen.azurewebsites.net/'
  ;;

  prod)
    url='https//devops.nz'
  ;;

  *)
    echo "Usage: $0 <env>"
    exit 1
  ;;
esac

docker run  -v $(pwd):/zap/wrk/:rw \
   --user root \
  -t owasp/zap2docker-stable zap-full-scan.py \
  -x zap.xml \
  -t ${url}

  exit 0
