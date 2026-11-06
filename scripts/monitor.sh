#!/bin/bash

# Website Uptime Monitoring Script

# Websites that must remain online

REQUIRED_WEBSITES=(
"https://sirvickcloud9.online"
"https://blog.sirvickcloud9.online"
)

# Websites whose downtime is currently expected

EXPECTED_DOWN_WEBSITES=(
"https://clinic.sirvickcloud9.online"
)

echo "===================================="
echo " WEBSITE UPTIME MONITOR"
echo "===================================="
echo "Monitoring started at: $(date)"
echo ""

FAILED=0
CHECKED=0

if ! command -v curl >/dev/null 2>&1; then
echo "ERROR: curl is not installed."
exit 127
fi

# Function to check website availability

check_website() {
WEBSITE="$1"
EXPECTATION="$2"

CHECKED=$((CHECKED + 1))

echo "Checking: $WEBSITE"

HTTP_STATUS=$(curl -L -s -o /dev/null \
    -w "%{http_code}" \
    --connect-timeout 10 \
    --max-time 15 "$WEBSITE")

if [[ "$EXPECTATION" == "REQUIRED" ]]; then

    if [[ "$HTTP_STATUS" =~ ^[23][0-9][0-9]$ ]]; then
        echo "STATUS: UP (HTTP $HTTP_STATUS)"

    elif [[ "$HTTP_STATUS" == "000" ]]; then
        echo "STATUS: DOWN (Connection failure or timeout)"
        FAILED=1

    else
        echo "STATUS: ERROR (HTTP $HTTP_STATUS)"
        FAILED=1
    fi

else

    if [[ "$HTTP_STATUS" == "000" ]]; then
        echo "STATUS: EXPECTED DOWN (Intentional downtime)"

    elif [[ "$HTTP_STATUS" =~ ^[23][0-9][0-9]$ ]]; then
        echo "NOTICE: Website is unexpectedly UP (HTTP $HTTP_STATUS)"

    else
        echo "NOTICE: Website responded with HTTP $HTTP_STATUS; downtime was expected."
    fi

fi

echo "------------------------------------"

}

# Check required websites

echo "CHECKING REQUIRED WEBSITES"
echo ""

for WEBSITE in "${REQUIRED_WEBSITES[@]}"; do
check_website "$WEBSITE" "REQUIRED"
done

# Check websites with expected downtime

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
echo "RESULT: Monitoring completed with unexpected failures."
exit 1
else
echo "RESULT: All required websites passed availability checks."
exit 0
fi
