#!/bin/bash

PROCESS_NAME="agent-app-leak"
LOG_DIR="${AGENT_LOG_DIR:-/app/logs}"
LOG_FILE="$LOG_DIR/monitor.log"
INTERVAL=2

mkdir -p "$LOG_DIR"

echo "===== monitor start: $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOG_FILE"
echo "TARGET_PROCESS:$PROCESS_NAME LOG_FILE:$LOG_FILE INTERVAL:${INTERVAL}s" >> "$LOG_FILE"

while true
do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    PIDS=$(pgrep -f "$PROCESS_NAME" | tr '\n' ' ')

    if [ -z "$PIDS" ]; then
        echo "[$TIMESTAMP] PROCESS:$PROCESS_NAME STATUS:NOT_RUNNING" >> "$LOG_FILE"
    else
        TOTAL_RSS=0
        TOTAL_CPU="0.0"
        PID_COUNT=0

        echo "[$TIMESTAMP] PROCESS:$PROCESS_NAME STATUS:RUNNING PIDS:[$PIDS]" >> "$LOG_FILE"

        for PID in $PIDS
        do
            if ps -p "$PID" > /dev/null 2>&1; then
                PPID_VALUE=$(ps -p "$PID" -o ppid= | xargs)
                CPU=$(ps -p "$PID" -o %cpu= | xargs)
                MEM=$(ps -p "$PID" -o %mem= | xargs)
                RSS=$(ps -p "$PID" -o rss= | xargs)
                VSZ=$(ps -p "$PID" -o vsz= | xargs)
                STATE=$(ps -p "$PID" -o stat= | xargs)
                THREADS=$(ps -o nlwp= -p "$PID" | xargs)
                CMD=$(ps -p "$PID" -o comm= | xargs)

                if [ -z "$RSS" ]; then
                    RSS=0
                fi

                if [ -z "$CPU" ]; then
                    CPU=0.0
                fi

                TOTAL_RSS=$((TOTAL_RSS + RSS))
                TOTAL_CPU=$(awk "BEGIN {print $TOTAL_CPU + $CPU}")
                PID_COUNT=$((PID_COUNT + 1))

                echo "[$TIMESTAMP] PID:$PID PPID:$PPID_VALUE CMD:$CMD CPU:${CPU}% MEM:${MEM}% RSS:${RSS}KB VSZ:${VSZ}KB STATE:$STATE THREADS:$THREADS" >> "$LOG_FILE"
            fi
        done

        TOTAL_RSS_MB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_RSS / 1024}")
        echo "[$TIMESTAMP] SUMMARY PROCESS:$PROCESS_NAME PID_COUNT:$PID_COUNT TOTAL_CPU:${TOTAL_CPU}% TOTAL_RSS:${TOTAL_RSS}KB TOTAL_RSS_MB:${TOTAL_RSS_MB}MB" >> "$LOG_FILE"
    fi

    sleep "$INTERVAL"
done