#!/bin/bash

PROCESS_NAME="agent-app-leak"
LOG_DIR="${AGENT_LOG_DIR:-/app/logs}"
LOG_FILE="$LOG_DIR/monitor.log"

mkdir -p "$LOG_DIR"

echo "===== monitor start: $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOG_FILE"

while true
do
    PID=$(pgrep -f "$PROCESS_NAME" | head -n 1)

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ -z "$PID" ]; then
        echo "[$TIMESTAMP] PROCESS:$PROCESS_NAME STATUS:NOT_RUNNING" >> "$LOG_FILE"
    else
        CPU=$(ps -p "$PID" -o %cpu= | xargs)
        MEM=$(ps -p "$PID" -o %mem= | xargs)
        RSS=$(ps -p "$PID" -o rss= | xargs)
        VSZ=$(ps -p "$PID" -o vsz= | xargs)
        STATE=$(ps -p "$PID" -o stat= | xargs)
        THREADS=$(ps -o nlwp= -p "$PID" | xargs)

        echo "[$TIMESTAMP] PID:$PID PROCESS:$PROCESS_NAME CPU:${CPU}% MEM:${MEM}% RSS:${RSS}KB VSZ:${VSZ}KB STATE:$STATE THREADS:$THREADS" >> "$LOG_FILE"
    fi

    sleep 2
done