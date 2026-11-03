#!/bin/bash

# Website Uptime Monitoring Script

WEBSITES=(
    "https://sirvickcloud9.online"
    "https://blog.sirvickcloud9.online"
    "https://clinic.sirvickcloud9.online"
)

echo "===================================="
echo "      WEBSITE UPTIME MONITOR"
echo "===================================="

FAILED=0

for WEBSITE in "${WEBSITES[@]}"; do

    echo "Checking: $WEBSITE"

    HTTP_STATUS=$(curl -L -s -o /dev/null \
        -w "%{http_code}" \
        --max-time 15 "$WEBSITE")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "STATUS: UP ($HTTP_STATUS)"
    else
        echo "STATUS: DOWN (HTTP $HTTP_STATUS)"
        FAILED=1
    fi

    echo "------------------------------------"

done

if [[ "$FAILED" -eq 1 ]]; then
    echo "Monitoring completed with failures."
    exit 1
else
    echo "All websites are responding successfully."
    exit 0
fi
