#!/bin/bash
#
#
count=0
while !  curl -fv https://test-builddoctor-pipeline-playpen.azurewebsites.net/ | grep -i hello; do
  sleep 5
  echo -n '.'
done
