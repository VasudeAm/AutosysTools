#!/bin/bash
#Script used to force start a specific number of failed or terminated jobs in the given pattern

if [[ $# -gt 2  || $# -eq 0 ]]; then
        echo " USAGE: . batch_fsj_job.sh <job-pattern> <count>"
        return 2>/dev/null || exit
fi

jobPattern="$1"
jobCount="$2"

jobprefix=$(echo "$jobPattern" | cut -d\% -f1)

#get list of jobs to force start. Takes first 10 jobs if no value for count is provided as input
jobs=$(autorep -j %"$1"% -w -L 0 | grep -E "$jobprefix" | grep -E 'FA|TE'| awk '{print $1}' | head -"$jobCount")
printf "Starting jobs:\n%s\n" "$jobs"

for job in $jobs; do
        if (sendevent -e FORCE_STARTJOB -j "$job"); then
                printf "Force started job %s successfully\n" "$job"
        fi
done
