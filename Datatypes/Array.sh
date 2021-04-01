#!/bin/bash

##################################################################
#                         Array Functions                        #
##################################################################


##################
# Indexed Arrays #
##################
#
# Explicit indexed array declaration
# declare -a arrayName
#
# Compound array assignment.
# declare -a arrayName=(string1 string2 string3 ... stringn)

######################
# Associative Arrays #
######################
#
# Explicit associative array declaration.
# declare -A arrayName
#
# Compound array assignment.
# typeset -A arrayName=([Dog]=30 [Cat]=30 [Bird]=30 [Fish]=30 [Frog]=30)
#
# Get list of keys
# "${!arrayName[@]}"

###############
# Both Arrays #
###############
#
# Add element
# arrayName[key/index]=string
#
# Push (add to end of array) element
# arrayName+=(string)
#
# Get array length
# ${#arrayName[*]} or ${#arrayName[@]}
#
# Get element length
# ${#arrayName[index/key]}
#
# Individual element assignment
# arrayName[index/key]=string
#
# Referencing an element
# ${arrayName[index/key]}
#
# Delete an element
# unset arrayName[index/key]
#
# Delete an array
# unset arrayName
#
# Return all values
# "${arrayName[*]}" or "${arrayName[@]}"
#
# Return all indices  ---> Use in counter counter type loop
# ${!arrayName[*]} or ${!arrayName[@]}

function strToArray ()
{

}

function arrayToStr ()
{

}

function inArray ()
{
    declare -r TARGET=$1

    shift 1

    for needle in "$@"
    do
        if [[ "$needle" == "$TARGET" ]]
        then
            return 0
        fi
    done

    return 1
}

