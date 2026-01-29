#!/bin/sh
set -eu
set -f

CRON_FILE="/etc/crontabs/root"
# Ensure the directory exists and the file is fresh
mkdir -p /etc/crontabs
: > "$CRON_FILE"

job_found=false
i=1

while :; do
    # Using 'eval' to get the dynamic variable names
    schedule=$(eval "echo \${CRON_JOB_${i}_SCHEDULE:-}")
    url=$(eval "echo \${CRON_JOB_${i}_URL:-}")

    if [ -z "$schedule" ] && [ -z "$url" ]; then
        break
    fi

    if [ -z "$schedule" ] || [ -z "$url" ]; then
        echo "ERROR: CRON_JOB_${i}_SCHEDULE and CRON_JOB_${i}_URL must both be set" >&2
        exit 1
    fi

    # Write the job to the crontab
    echo "$schedule echo \"[\$(date)] calling $url\" && curl -fsS --max-time 10 --retry 3 $url" >> "$CRON_FILE"
    
    job_found=true
    i=$((i + 1))
done

if [ "$job_found" = false ]; then
    echo "ERROR: No cron jobs configured" >&2
    exit 1
fi

# IMPORTANT: Fix permissions for BusyBox crond
chmod 0600 "$CRON_FILE"

echo "Starting crond with the following config:"
cat "$CRON_FILE"

# -f: foreground, -L /dev/stdout: log to stdout so you see it in docker logs
exec crond -f -L /dev/stdout