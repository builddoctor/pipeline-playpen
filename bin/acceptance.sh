#!/bin/bash
#

env=$1
count=0

while !  curl -fv https://${env}-builddoctor-pipeline-playpen.azurewebsites.net/ | grep -i hello; do
  sleep 5
  echo -n '.'
done

echo "Tried ${count} times to connect"
