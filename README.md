# http-cron

## Introduction
http-cron is a docker container that allows you to make a curl get request to a specific url in a specific interval. I developed this tool as a timer to start cleaning/data saving jobs in my next.js projects.

## Installation and Usage
Create a docker-compose.yml file:
```yml
services:
    cron:
        image: ghcr.io/finn-freitag/http-cron:latest
        environment:
            CRON_JOB_1_SCHEDULE: "*/10 * * * *"
            CRON_JOB_1_URL: "https://example.com/api/cron"
            CRON_JOB_2_SCHEDULE: "0 15 10 ? * *"
            CRON_JOB_2_URL: "https://example2.com/cronjobs"
        restart:
            unless-stopped
```
The CRON_JOB_X_SCHEDULE environment variable uses [cron syntax](https://www.netiq.com/documentation/cloud-manager-2-5/ncm-reference/data/bexyssf.html). The CRON_JOB_X_URL is the URL you want to request. There could be as many cron jobs as you want, each with an increasing integer number starting at 1.

Start the docker container:
```
docker compose up -d
```
