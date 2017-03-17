#!/bin/bash
#Script to release jobs kept on hold for the input job pattern and count

readonly script_dir="$( cd "$(dirname "$0")" && pwd -P )"

if [[ $# -gt 2 || $# -eq 0 ]]; then
        echo " USAGE: . batch_off_hold.sh <job-pattern> <count>"
        return 2>/dev/null || exit
fi

jobPattern="$1"
jobCount="$2"

jobprefix=$(echo "$jobPattern" | cut -d\% -f1)

#get list of jobs to release. Takes first 10 jobs if no value for count is provided as input
jobs=$(autorep -j %"$1"% -w | grep -E "$jobprefix" | grep -E 'OH'| awk '{print $1}' | head -"$jobCount")
printf "Releasing jobs:\n%s\n" "$jobs"

for job in $jobs; do
        if (sendevent -e JOB_OFF_HOLD -j  "$job"); then
                printf "Released job %s successfully\n" "$job"
        fi
done
