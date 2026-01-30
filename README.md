# http-cron

## Introduction
http-cron is a docker container that allows you to make a curl get request to a specific url in a specific interval. I developed this tool as a timer to start cleaning/data saving jobs in my next.js projects.

## Installation and Usage
Create a docker-compose.yml file (sample):
```yml
services:
    cron:
        image: ghcr.io/finn-freitag/http-cron:latest
        environment:
            CRON_JOB_SCHEDULE: "*/10 * * * *"
            CRON_JOB_1_URL: "https://example.com/api/cron"
            CRON_JOB_2_SCHEDULE: "0 15 10 ? * *"
            CRON_JOB_2_URL: "https://example2.com/cronjobs"
            CRON_JOB_3_TIMEOUT: "30"
            CRON_JOB_3_URL: "https://example3.com/timer"
        restart:
            unless-stopped
```
For every cronjob an URL must be set using CRON_JOB_X_URL. Replace X with the number of your cron job. Also a schedule must be set using [cron syntax](https://www.netiq.com/documentation/cloud-manager-2-5/ncm-reference/data/bexyssf.html). You could use a global CRON_JOB_SCHEDULE for all cron jobs and/or use CRON_JOB_X_SCHEDULE for a specific cron job. Optionally CRON_JOB_TIMEOUT/CRON_JOB_X_TIMEOUT and CRON_JOB_MAX_RETRIES/CRON_JOB_X_MAX_RETRIES could be set. There could be as many cron jobs as you want, each with an increasing integer number starting at 1.

### Summary:
Global parameters:
- CRON_JOB_SCHEDULE (required, global or specifc)
- CRON_JOB_TIMEOUT (optional, default: 10)
- CRON_JOB_MAX_RETRIES (optional, default: 3)

Specific parameters:
- CRON_JOB_X_URL (required)
- CRON_JOB_X_SCHEDULE (required, global or specific)
- CRON_JOB_X_TIMEOUT (optional, default: 10)
- CRON_JOB_X_MAX_RETRIES (optional, default: 3)

Start the docker container:
```
docker compose up -d
```
