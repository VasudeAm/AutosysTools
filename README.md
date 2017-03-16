# AutosysTools
This repository contains shell scripts useful for autosys batch management.

**jil_parser.sh** 

Parses the JILs for all Autosys Jobs deployed in the current environment and gives a semi-colon separated file as output. This file could be manipulated to get job statistics based on the defined parameters.

The colomns specified in the output file are :

* Job Name 
* Run command 
* Machine
* Start Time
* Run Calendar
* Exclude Calendar
* Start Condition
* Scheduled Days 
* Profile
