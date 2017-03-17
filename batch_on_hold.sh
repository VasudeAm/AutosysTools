#!/bin/bash
#Script to keep jobs of the given input pattern on hold

readonly script_dir="$( cd "$(dirname "$0")" && pwd -P )"

if [[ $# -gt 2 || $# -eq 0 ]]; then
        echo " USAGE: . batch_on_hold.sh <job-pattern> <count>"
        return 2>/dev/null || exit
fi

jobPattern="$1"
jobCount="$2"

jobprefix=$(echo "$jobPattern" | cut -d\% -f1)

#get list of jobs to hold. Takes first 10 jobs if no value for count is provided as input
jobs=$(autorep -j %"$1"% -w -L 0 | grep -E "$jobprefix" | grep -E 'IN|SU|FA|TE'| awk '{print $1}' | head -"$jobCount")
printf "Holding jobs:\n%s\n" "$jobs"

for job in $jobs; do
        if (sendevent -e JOB_ON_HOLD -j  "$job"); then
                printf "Held job %s successfully\n" "$job"
        fi
done
