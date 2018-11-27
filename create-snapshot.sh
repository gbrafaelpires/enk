#!/bin/bash
# This script is triggered once a day by crontab. It's supposed to backup the 45
# days ago index to s3 "logs-es-prod-backups-us" and delete the index from the local machine.

DATE=$(date --date="45 days ago" +%Y-%m-%d)
INDEX_NAMES=("logstash" "filebeat")
SNAPSHOT_STATUS_SUCCESS="SUCCESS"
SNAPSHOT_MISSING_STATUS="snapshot_missing_exception"

checkSnapshotStatus () {
  curl -XGET localhost:9200/_snapshot/logs-es-prod/"$1"-"$2"/_status \
    | jq -r ".error.root_cause[].type"
}

createSnapshot () {
  curl -X PUT localhost:9200/_snapshot/logs-es-prod/"$1"-"$2"?wait_for_completion=true \
    -H 'Content-Type: application/json' -d \
    '{
      "indices": "'$1'-'$2'",
      "include_global_state": false
    }' \
    | jq -r ".snapshot.state"
}

deleteLocalIndex () {
  curl -X DELETE localhost:9200/"$1"-"$2"
}


for INDEX_NAME in "${INDEX_NAMES[@]}"
do
  SNAPSHOT_STATUS=$(checkSnapshotStatus "$INDEX_NAME" "$DATE")

  if [ "$SNAPSHOT_STATUS" == "$SNAPSHOT_MISSING_STATUS" ]
  then
    SNAPSHOT_RESULT=$(createSnapshot "$INDEX_NAME" "$DATE")

    if [ "$SNAPSHOT_RESULT" == "$SNAPSHOT_STATUS_SUCCESS" ]
    then
      deleteLocalIndex "$INDEX_NAME" "$DATE"
    else
      echo "SNAPSHOT FAILED FOR: $INDEX_NAME-$DATE"
      exit 0
    fi
  else
    echo "SNAPSHOT FAILED FOR: $INDEX_NAME-$DATE"
    exit 0
  fi
done