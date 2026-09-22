#!/usr/bin/env bash
# Wacht tot de Main Deploy Workflow voor SHA 153139db5 klaar is en print
# de nieuwe release-tag + APK-grootte. Stopt bij succes of na ~40 min.
SHA=153139db5
REPO=danield76799/Plusly
for i in $(seq 1 40); do
  data=$(curl -s "https://api.github.com/repos/$REPO/actions/runs?per_page=8")
  line=$(echo "$data" | python3 -c "
import json,sys
sha='$SHA'
for r in json.load(sys.stdin)['workflow_runs']:
    if 'Deploy' in r['name'] and r['head_sha'].startswith(sha):
        print(r['status'], r['conclusion'], r['run_number'], r['id'])
        break
else:
    print('notfound')
")
  set -- $line
  status=$1; conclusion=$2; runnumber=$3; runid=$4
  echo "[$(date +%H:%M:%S)] poging $i: status=$status conclusion=$conclusion run=$runnumber"
  if [ "$status" = "completed" ]; then
    echo "CONCLUSION=$conclusion"
    curl -s "https://api.github.com/repos/$REPO/releases?per_page=2" | python3 -c "
import json,sys
for r in json.load(sys.stdin):
    print('RELEASE', r['tag_name'], r['published_at'])
    for a in r.get('assets',[]):
        if 'arm64' in a['name']:
            print('  APK', a['name'], a['size'], 'bytes')
            print('  URL', a['browser_download_url'])
"
    exit 0
  fi
  sleep 60
done
echo "TIMEOUT na 40 pogingen"
