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
  -t owasp/zap2docker-stable zap-baseline.py \
  -x zap.xml \
  -u https://github.com/builddoctor/pipeline-playpen/blob/main/zap.conf \
  -d \
  -t ${url}

  exit 0
