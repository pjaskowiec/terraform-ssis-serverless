#!/bin/bash

function benchmark_lambda() {
    python /root/lambda-memory-performance-benchmark/benchmark.py -f "$1" -r "$2" -p "$3"
}

for ((i=1; $i<1002; i++)); do
    json_variable="\"$i\""
    jq --argjson var "$json_variable" '.id = $var' lambda_payloads/payload_delete.json > /tmp/test.json   
    aws lambda invoke --function-name "pj-mgr-student" \
     --region eu-north-1 \
    --invocation-type Event \
    --payload file:///tmp/test.json \
    --cli-binary-format raw-in-base64-out \
    /tmp/response.json
done