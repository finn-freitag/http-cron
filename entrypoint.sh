#!/bin/sh
set -eu

CRON_FILE="/etc/crontabs/root"
: > "$CRON_FILE"

job_found=false

i=1
while :; do
    schedule_var="CRON_JOB_${i}_SCHEDULE"
    url_var="CRON_JOB_${i}_URL"

    schedule="$(eval echo \${$schedule_var-})"
    url="$(eval echo \${$url_var-})"

    if [ -z "$schedule" ] && [ -z "$url" ]; then
        break
    fi

    if [ -z "$schedule" ] || [ -z "$url" ]; then
        echo "ERROR: $schedule_var and $url_var must both be set" >&2
        exit 1
    fi

    echo "$schedule echo \"[\$(date)] calling $url\" && curl -fsS --max-time 10 --retry 3 $url" >> "$CRON_FILE"
    job_found=true
    i=$((i + 1))
done

if [ "$job_found" = false ]; then
    echo "ERROR: No cron jobs configured" >&2
    exit 1
fi

exec crond -f -l 2
