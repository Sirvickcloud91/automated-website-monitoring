#!/bin/bash

# Website Uptime Monitoring Script

WEBSITES=(
"https://sirvickcloud9.online"
"https://blog.sirvickcloud9.online"
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

for WEBSITE in "${WEBSITES[@]}"; do

CHECKED=$((CHECKED + 1))

echo "Checking: $WEBSITE"

HTTP_STATUS=$(curl -L -s -o /dev/null \
    -w "%{http_code}" \
    --connect-timeout 10 \
    --max-time 15 "$WEBSITE")

if [[ "$HTTP_STATUS" =~ ^[23][0-9][0-9]$ ]]; then
    echo "STATUS: UP (HTTP $HTTP_STATUS)"

elif [[ "$HTTP_STATUS" == "000" ]]; then
    echo "STATUS: DOWN (Connection failure or timeout)"
    FAILED=1

else
    echo "STATUS: ERROR (HTTP $HTTP_STATUS)"
    FAILED=1
fi

echo "------------------------------------"

done

echo ""

if [[ "$CHECKED" -ne "${#WEBSITES[@]}" ]]; then
echo "ERROR: Not all websites were checked."
exit 2
fi

echo "Monitoring completed at: $(date)"

if [[ "$FAILED" -eq 1 ]]; then
echo "RESULT: Monitoring completed with failures."
exit 1
else
echo "RESULT: All websites passed availability checks."
exit 0
fi
