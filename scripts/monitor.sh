#!/bin/bash

# Website Uptime Monitoring Script

REQUIRED_WEBSITES=(
"https://sirvickcloud9.online"
"https://blog.sirvickcloud9.online"
)

EXPECTED_DOWN_WEBSITES=(
"https://clinic.sirvickcloud9.online"
)

FAILED=0
CHECKED=0

echo "===================================="
echo " WEBSITE UPTIME MONITOR"
echo "===================================="
echo "Monitoring started at: $(date)"
echo ""

if ! command -v curl >/dev/null 2>&1; then
echo "ERROR: curl is not installed."
exit 127
fi

check_website() {
WEBSITE="$1"
EXPECTATION="$2"

CHECKED=$((CHECKED + 1))

echo "Checking: $WEBSITE"

HTTP_STATUS="000"

for ATTEMPT in 1 2 3; do

    echo "Attempt $ATTEMPT of 3"

    HTTP_STATUS=$(curl -L -s -o /dev/null \
        -w "%{http_code}" \
        -A "Mozilla/5.0 (compatible; SirVickWebsiteMonitor/1.0)" \
        --connect-timeout 10 \
        --max-time 15 "$WEBSITE")

    if [[ "$HTTP_STATUS" != "429" ]]; then
        break
    fi

    if [[ "$ATTEMPT" -lt 3 ]]; then
        echo "Rate limited (HTTP 429). Waiting 10 seconds..."
        sleep 10
    fi

done

if [[ "$EXPECTATION" == "REQUIRED" ]]; then

    if [[ "$HTTP_STATUS" =~ ^[23][0-9][0-9]$ ]]; then
        echo "STATUS: UP (HTTP $HTTP_STATUS)"

    elif [[ "$HTTP_STATUS" == "000" ]]; then
        echo "STATUS: DOWN (Connection failure or timeout)"
        FAILED=1

    elif [[ "$HTTP_STATUS" == "429" ]]; then
        echo "STATUS: RATE LIMITED (HTTP 429)"
        echo "NOTICE: Availability could not be confirmed."
        FAILED=1

    else
        echo "STATUS: HTTP ERROR ($HTTP_STATUS)"
        FAILED=1
    fi

else

    if [[ "$HTTP_STATUS" == "000" ]]; then
        echo "STATUS: EXPECTED DOWN (Intentional downtime)"

    elif [[ "$HTTP_STATUS" =~ ^[23][0-9][0-9]$ ]]; then
        echo "NOTICE: Website is unexpectedly UP (HTTP $HTTP_STATUS)"

    elif [[ "$HTTP_STATUS" == "429" ]]; then
        echo "NOTICE: Website is rate limited (HTTP 429)."

    else
        echo "NOTICE: Website responded with HTTP $HTTP_STATUS."
    fi

fi

echo "------------------------------------"

}

echo "CHECKING REQUIRED WEBSITES"
echo ""

for WEBSITE in "${REQUIRED_WEBSITES[@]}"; do
check_website "$WEBSITE" "REQUIRED"
done

echo ""
echo "CHECKING WEBSITES WITH EXPECTED DOWNTIME"
echo ""

for WEBSITE in "${EXPECTED_DOWN_WEBSITES[@]}"; do
check_website "$WEBSITE" "EXPECTED_DOWN"
done

echo ""

TOTAL_WEBSITES=$((${#REQUIRED_WEBSITES[@]} + ${#EXPECTED_DOWN_WEBSITES[@]}))

if [[ "$CHECKED" -ne "$TOTAL_WEBSITES" ]]; then
echo "ERROR: Not all websites were checked."
exit 2
fi

echo "Monitoring completed at: $(date)"
echo "Total websites checked: $CHECKED"

if [[ "$FAILED" -eq 1 ]]; then
echo "RESULT: Monitoring completed with unexpected failures or inconclusive checks."
exit 1
else
echo "RESULT: All required websites passed availability checks."
exit 0
fi
