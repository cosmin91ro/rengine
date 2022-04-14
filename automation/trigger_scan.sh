#!/bin/bash

if [ $# -lt 6 ]; then
    echo "Usage: $0 <rengine_url> <target_domain> <rengine_username> <rengine_password> <scan_engine> <included_subdomains_file> [--wait]"
    exit 1
fi

bash login.sh $1 $3 $4

targets=""
get_targets () {
    targets=$(curl -s -b cookiejar "$1/api/queryTargetsWithoutOrganization/" --insecure)
}

get_target_id () {
    target_id=$(echo $targets | jq ".domains[] | if (.name == \"$1\") then .id else empty end")
}

get_engine_id () {
    echo "INFO: Looking for engine $2"
    engine_id=$(curl -s -b cookiejar "$1/api/listEngines/" --insecure | jq ".engines[] | if (.engine_name==\"$2\") then .id else empty end")
}

trigger () {
    echo "INFO: Getting CSRF token ..."
    csrf=$(curl -s $1/scan/start/$2 -b cookiejar -c cookiejar --insecure | sed -n "s/^.*name=\"csrfmiddlewaretoken\" value=\"\(.*\)\".*$/\1/p")
    # echo "csrf=$csrf"

    echo "INFO: Triggering scan ..."
    included_subdomains_file=$4
    touch $included_subdomains_file && \
    curl -s $1/scan/start/$2 -b cookiejar --insecure -o /dev/null -d "csrfmiddlewaretoken=$csrf&scan_mode=$3&importSubdomainTextArea=$(cat $included_subdomains_file)&outOfScopeSubdomainTextarea="

}

wait () {
    last_scan_id=$(curl -b cookiejar -s $1/api/listScanHistory/ | jq '.scan_histories[] | .id'  | head -n 1)
    scan_status=-1
    sleepTime=60  # seconds
    while [ ! $scan_status -eq 2 ]
    do
        sleep $sleepTime
        scan_status=$(curl -s -b cookiejar $1/api/scan/status/$last_scan_id | jq '.scanStatus')
        echo "Scan status = $scan_status"
    done
}

get_targets $1
get_target_id $2
echo "DEBUG: Target ID: $target_id"

get_engine_id $1 "$5"
echo "DEBUG: Engine ID: $engine_id"

trigger $1 $target_id $engine_id $6

if [ $7 = "--wait" ]; then
    wait
fi
rm cookiejar

echo "INFO: Done"
