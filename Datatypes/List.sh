#!/bin/bash

##################################################################
#                         List Functions                         #
##################################################################

function listToString ()
{
    echo "$*"
}

function listToStrings ()
{
    echo "$@"
}

function numberList ()
{
    declare SEPARATOR=$1
    declare LIST=$2

    nl -s $SEPARATOR $LIST
}

function inList ()
{
    declare TARGET_STRING=$1
    
    shift 1

    for element in "$@"
    do
        if [[ $element == $TARGET_STRING ]]
        then
            return 0
        fi
    done

    return 1
}