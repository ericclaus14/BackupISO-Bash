#!/bin/bash

##################################################################################################
# Author: Eric Claus
# Last Modified: 8/24/17
# CPTE 440 - Assignment 1 - Backup
# Purpose: Write a script for your Linux box which creates an ISO file containing a set of
#          directories specified in a configuration file. This script should automatically execute
#          each night at 3:00 a.m., and produce a file named for the date on which it was created.
#          Also write a script on your Windows box which copies the ISO file to the Windows box,
#          and deletes all but the most recent three.
###################################################################################################

#################################################################
# Send all output (stdout and stderr) to log file.              #
#################################################################
exec &>/home/ericclaus/assignment-1/bkISO.log

#############
# Help file #
#############
function display_help {
        echo
        echo " -- Script to create a backup iso."
        echo " -h Display the help file."
        echo
        exit
}

###########################################
# getops (parsing command line arguments) #
# Note: getops was used instead of getop  #
#       for the sake of simplicity.       #
###########################################
while getopts 'h' option; do
        case "option" in
                h) display_help
                ;;
                *) display_help
                ;;
        esac done

##############################################################################################
#                                                                                            #
# BEGIN MAIN PART OF SCRIPT                                                                  #
#                                                                                            #
##############################################################################################

# Date variable to be used in the ISO file name
DATE=`date +%Y%m%d`

# Full path to the desired backup ISO
backupISO="/home/ericclaus/assignment-1/bk$DATE.iso"

# Config file containing a list of files and directories to be backed up
configFile="backup.conf"

# Read in the config file and loop through, line by line.
while IFS='' read -r line || [[ -n "$line" ]]; do
        # Lines begenning with a "#" are skipped over.
        [[ "$line" =~ ^#.*$ ]] && continue

        # Check if target item is a directory
        if [ -d "$line" ]; then
                # If so, pull the directory's name, begening after the last "/" in the path.
                # This is used with the -graft-points flag in the mkisofs command.
                dirName=${line##*/}

                # Append '$dirName=$line' to the $params variable. This maps the directory to
                # a directory inside the ISO, addressing the issue of contents from all folders
                # being pulled into the root of the ISO, and preserving folder structure.
                params="$params $dirName=$line "

        # If item is a file, simply append it to the $params variable.
        else
                params="$params $line "
        fi

# Redirect input from the backup.conf file.
done < $configFile

# The actuall command used to make the ISO. See man mkisofs for more information.
mkisofs -graft-points -J -o $backupISO $params
