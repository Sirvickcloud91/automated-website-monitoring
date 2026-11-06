# Automated Website Uptime Monitoring

Automated website availability monitoring using **Bash, cURL, and GitHub Actions**.

This project monitors multiple websites, checks their HTTP response status, handles temporary HTTP 429 rate-limiting responses, and reports availability results through GitHub Actions.

It was built as a practical DevOps learning project to explore Bash scripting, automation, HTTP response handling, and continuous monitoring.

## Project Overview

The monitoring script checks three websites:

* https://sirvickcloud9.online
* https://blog.sirvickcloud9.online
* https://clinic.sirvickcloud9.online

The websites are divided into two categories:

| Category          | Website                     | Purpose                                                                                    |
| ----------------- | --------------------------- | ------------------------------------------------------------------------------------------ |
| Required          | sirvickcloud9.online        | Expected to remain available                                                               |
| Required          | blog.sirvickcloud9.online   | Expected to remain available                                                               |
| Expected downtime | clinic.sirvickcloud9.online | Temporarily unavailable because its EC2 instance was terminated to avoid ongoing AWS costs |

The script distinguishes between required websites and websites with intentionally expected downtime.

## Project Objectives

* Automate website availability checks.
* Use Bash to build a reusable monitoring script.
* Use cURL to retrieve HTTP response codes.
* Automate execution through GitHub Actions.
* Identify unavailable websites and HTTP errors.
* Handle temporary HTTP 429 responses through automatic retries.
* Return appropriate exit codes to GitHub Actions.

## Architecture

The monitoring process follows this sequence:

GitHub Actions
|
v
Ubuntu Runner
|
v
Install / Verify cURL
|
v
Execute Bash Script
|
v
Send HTTP Requests
|
v
Check Website Responses
|
v
Classify Results
|
v
Display Monitoring Report
|
v
Return Workflow Exit Code

## Technologies Used

| Technology     | Purpose                                             |
| -------------- | --------------------------------------------------- |
| Bash           | Monitoring script and automation logic              |
| cURL           | Sending HTTP requests and retrieving response codes |
| GitHub Actions | Automated workflow execution                        |
| Ubuntu         | GitHub-hosted runner environment                    |
| GitHub         | Source code management and version control          |

## Repository Structure

```text
automated-website-monitoring/
│
├── .github/
│   └── workflows/
│       └── uptime-monitor.yml
│
├── scripts/
│   └── monitor.sh
│
└── README.md
```

## How the Monitoring Script Works

The main monitoring script is located at:

`scripts/monitor.sh`

It performs the following operations:

### 1. Website Classification

Websites are separated into two Bash arrays:

* `REQUIRED_WEBSITES`
* `EXPECTED_DOWN_WEBSITES`

This allows the script to distinguish between critical availability failures and intentional downtime.

### 2. HTTP Status Checks

The script uses cURL to send HTTP requests and retrieve response codes.

The current classification includes:

| HTTP response   | Interpretation                |
| --------------- | ----------------------------- |
| 2xx or 3xx      | Website available             |
| 000             | Connection failure or timeout |
| 429             | Rate limited                  |
| Other responses | HTTP error                    |

The requests follow redirects and use connection and overall request timeouts.

### 3. HTTP 429 Retry Handling

During testing, the blog initially returned HTTP 429 when accessed from the GitHub Actions runner.

However, the website opened normally in a regular browser.

To handle this temporary response, I improved the script with:

* A maximum of three attempts.
* A 10-second wait between attempts when HTTP 429 is returned.
* A custom User-Agent identifying the monitoring request.
* Separate reporting for persistent rate limiting.

If a required website continues returning HTTP 429 after all attempts, the script reports that availability could not be confirmed and returns a failure exit code.

### 4. Expected Downtime Handling

The clinic website is intentionally classified separately because its EC2 instance was terminated to avoid ongoing AWS costs.

When the script detects a connection failure for this website, it reports:

`STATUS: EXPECTED DOWN (Intentional downtime)`

This does not cause the workflow to fail.

If the clinic becomes reachable again, the script reports that it is unexpectedly UP.

### 5. Exit Codes

The script uses exit codes to communicate monitoring results to GitHub Actions.

| Exit code | Meaning                                                                  |
| --------- | ------------------------------------------------------------------------ |
| 0         | All required websites passed availability checks                         |
| 1         | A required website returned an unexpected failure or inconclusive result |
| 2         | Not all configured websites were checked                                 |
| 127       | cURL is unavailable                                                      |

## GitHub Actions Automation

The workflow is located at:

`.github/workflows/uptime-monitor.yml`

It uses:

* `ubuntu-latest` as the runner.
* `actions/checkout@v4` to retrieve the repository.
* cURL for HTTP checks.
* `bash scripts/monitor.sh` to execute the monitoring script.

### Execution Schedule

The workflow is configured to run:

* Automatically every five minutes.
* Manually through the GitHub Actions interface using `workflow_dispatch`.

GitHub Actions scheduling is subject to GitHub's scheduling availability and may occasionally be delayed.

## Testing and Results

The monitoring script was tested through actual GitHub Actions workflow executions.

### Successful Monitoring Run – November 6, 2026

One verified run produced the following results:

| Website                     | First response | Final result         |
| --------------------------- | -------------- | -------------------- |
| sirvickcloud9.online        | HTTP 200       | UP                   |
| blog.sirvickcloud9.online   | HTTP 429       | HTTP 200 after retry |
| clinic.sirvickcloud9.online | HTTP 000       | EXPECTED DOWN        |

The blog initially returned HTTP 429. The script waited 10 seconds and retried the request. The second attempt returned HTTP 200.

The final output was:

`RESULT: All required websites passed availability checks.`

GitHub Actions completed successfully in 21 seconds.

**Verified workflow run:**
https://github.com/Sirvickcloud91/automated-website-monitoring/actions/runs/42243422032

## Challenges and Lessons Learned

Building this project involved troubleshooting several issues.

### Bash Script Formatting

Some Markdown code-fence characters were accidentally copied into the Bash script, causing command-not-found and syntax errors.

I learned the importance of keeping Markdown formatting separate from executable script content.

### HTTP 429 Rate Limiting

The blog returned HTTP 429 from the GitHub Actions runner even though it opened normally in a browser.

Adding retry handling helped the script recover when the next request returned HTTP 200.

### Expected Downtime

The clinic server was intentionally terminated to avoid AWS costs.

Separating expected downtime from required website availability made the monitoring results more meaningful.

### GitHub Actions Exit Codes

I learned that GitHub Actions uses the script's exit code to determine whether a job succeeds or fails.

This helped me understand how monitoring scripts communicate their results to automation platforms.

## Current Project Scope and Limitations

This project currently performs HTTP availability checks.

It does not yet provide:

* Historical uptime reports or dashboards.
* Email or SMS notifications.
* Response-time trend analysis.
* SSL certificate expiry alerts.
* Persistent monitoring data storage.

These are possible areas for future improvements.

## Conclusion

This project helped me gain practical experience with Bash scripting, cURL, GitHub Actions, HTTP response codes, retry logic, and automated website monitoring.

It also taught me that monitoring is not simply about checking whether a website responds. It is important to interpret responses correctly, distinguish expected downtime from unexpected failures, and make automation report meaningful results.

**Project repository:**
https://github.com/Sirvickcloud91/automated-website-monitoring

