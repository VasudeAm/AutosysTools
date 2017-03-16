#!/bin/bash

###############################################################################################
#This script is used for extarcting Autosys Jobs list from Autosys jil files
#Syntax : sh update_autosys_jobs.sh
#Output : A file named Autosys_Jobs_List_yyyy-mm-dd.txt with autosys job names and their details will be
#generated.
###############################################################################################

#Function to do initial assignments and checks
initialize()
{
        readonly script_dir="$( cd "$(dirname "$0")" && pwd -P )
        temp_dir="$script_dir/temp"
        filename="$temp_dir/job_jils_$(date +'%F').txt"
        output="$temp_dir/Autosys_Jobs_List_$(date +'%F').txt"
        [[ -f "$output" ]] && rm "$output"
		
}


#Function to process each jil file
process_jils()
{
        file="$1"

        #check if the jil file exists
        if [ ! -f "$file" ]
        then
                return
        fi
		
        #initialisations
        jobname=""
        run_command=""
        machine=""
        starttime="NIL"
        runcal="NIL"
        excal="NIL"
        startcon=""
        daysofweek="NIL"
	profile=""

        #parses jil file to get value for each field
        jobname=$(awk '/insert_job/{print $2}' "$file")
		
        #Run command name parsed from the command argument
        run_command=$(awk '/command/{print $2}' "$file")
		
        #run machine name
        machine=$(awk '/machine/' "$file")
		
        #get the start time of the job if any
        starttime=$(awk -F '"' 'if $1 == "start_times" {print $2} else if $1 == "start_mins" {print "minute" $2 "of every hour"}' "$file")
		
        #get the run calendar name & exclude calendar names
        runcal=$(awk '/run_calendar/{print $2}' "$file")
        excal=$(awk '/exclude_calendar/{print $2}' "$file")
		
	#get the start condition
        startcon=$(awk -F ':' '/condition:/{print $2}' "$file")
		
        #get days of week attribute
        daysofweek=$(awk '/days_of_week/{print $2}' "$file")
		
	#get the aurtosys profile attribute value
        profile=$(awk '/profile/{print $2}' "$file")

        #assign value NA/NIl as applicable
        if [ "$starttime" == "" ]
        then
                starttime="NIL"
        fi

        if [ "$runcal" == "" ]
        then
                runcal="NIL"
        fi

        if [ "$excal" == "" ]
        then
                excal="NIL"
        fi

        if [ "$startcon" == "" ]
        then
                startcon="NIL"
        fi

        if [ "$machine" == "Other Machines" ]
        then
                projectname="NIL"
        fi
        if [ "$daysofweek" == "" ]
        then
                daysofweek="NIL"
        fi

        #Writes each job jil parsed output to the output file

        echo "$jobname;$projectname;$machine;$starttime;$runcal;$excal;$startcon;$daysofweek;$profile" >> "$output"

        rm "$file"

}

main()
{

        echo "------------Script called at time $(date) ................."
        initialize
	
        #write all the jils in the current environment of all jobs to a file
        autorep -j ALL -q >> "$filename"

		    #A temp file to hold a jil
        temp_file="$temp_dir/tmp_jils.txt"

        #extarct each jil
        while read -r LINE
        do

                str1=$(echo "$LINE" | cut -c 1,2)

                echo "$LINE" >> "$temp_file"

                if [ "$str1" == "/*" ]
                then
                        #call the function to process a single jil
                        process_jils "$temp_file"

                fi

        done < "$filename"


        if [ ! -f "$output" ]; then
                echo "$output file has not been created"
                exit 255;
        fi

        #Sort the final output file
        sort -t ";" "$output"


        #Add header to the output file
        sed  -i '1i Job Name| Run command | Machine| Start Time| Run Calendar | Exclude Calendar| Start Condition| Scheduled Days | Profile ' "$output"

        #Removing the temporary jil file & jil output files
        [[ -f "$temp_file" ]] && rm "$temp_file"

        [[ -f "$filename" ]] && rm "$filename"

        echo "------------Script ended at time $(date) ------------------------"

}

#call main function to start execution
main "$@"
