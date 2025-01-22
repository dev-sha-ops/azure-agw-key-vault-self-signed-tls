#!/bin/bash
ENDPOINT=https://jsonplaceholder.typicode.com/posts
AUTH_HEADER=abc:123                        
INPUT_SHORT_DESCRIPTION=test
INPUT_DESCRIPTION="\"\ttest \"ali\"\n"
INPUT_ASSIGNMENT_GROUP=test
INPUT_REQUESTED_BY=test
TEST_PLAN='1. Who is going to perform technical validation? (Provide name and contact #): xmatters Azure_Support\n2. When will the technical validation occur? Start date and time: Day of or after release\n3. When will the functionality be turned on (toggle on) to the users? Immediately preceding release\n4. Who is going to perform business/end user validation? (Provide name and contact #): Application teams\n5. When will the end-user validation occur? Start date and time: Next business day'
CURL_CMD=$(cat <<EOF
curl -s -w "%{http_code}" -o response.json 
    -X POST "$ENDPOINT" 
    -H "Content-Type: application/json" 
    -d '{ 
    "title": "foo",
    "body": "$TEST_PLAN",
    "userId": 1 
}'
EOF
)
RES=$(echo  "$CURL_CMD" | base64)
echo $RES | base64 -d