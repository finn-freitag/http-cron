#!/bin/sh
set -eu
set -f

CRON_FILE="/etc/crontabs/root"
# Ensure the directory exists and the file is fresh
mkdir -p /etc/crontabs
: > "$CRON_FILE"

# Capture the global fallback schedule
GLOBAL_SCHEDULE="${CRON_JOB_SCHEDULE:-}"
MAX_RETRIES="${CRON_JOB_MAX_RETRIES:-3}"
TIMEOUT="${CRON_JOB_TIMEOUT:-10}"

job_found=false
i=1

while :; do
    # Using 'eval' to get the dynamic variable names
    spec_schedule=$(eval "echo \${CRON_JOB_${i}_SCHEDULE:-}")
    spec_max_retries=$(eval "echo \${CRON_JOB_${i}_MAX_RETRIES:-}")
    spec_timeout=$(eval "echo \${CRON_JOB_${i}_TIMEOUT:-}")
    url=$(eval "echo \${CRON_JOB_${i}_URL:-}")

    if [ -z "$url" ]; then
        break
    fi

    # Determine which schedule to use: Specific > Global
    # If both are empty, we have a URL but no way to know when to run it
    final_schedule="${spec_schedule:-$GLOBAL_SCHEDULE}"
    final_max_retries="${spec_max_retries:-$MAX_RETRIES}"
    final_timeout="${spec_timeout:-$TIMEOUT}"

    if [ -z "$final_schedule" ]; then
        echo "ERROR: No schedule found for CRON_JOB_${i}_URL. Set CRON_JOB_${i}_SCHEDULE or a global CRON_JOB_SCHEDULE." >&2
        exit 1
    fi

    # No check vor valid value of final_max_retries nd final_timeout, because they have default values
	
	cmd="printf \"[\$(date)] calling $url \" && code=\$(curl -s -o /dev/null -w \"%{http_code}\" --max-time $final_timeout --retry $final_max_retries \"$url\") && echo \"responding with \$code\""

    echo "$final_schedule $cmd" >> "$CRON_FILE"
    
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
exec crond -f -L /dev/stdout -l 8 2>&1 | grep --line-buffered -v "crond: USER root"