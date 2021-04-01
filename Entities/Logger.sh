
#!/bin/bash

##################################################################
#                    Functions for logging.                      #
##################################################################

################### Generic Logging Functions ####################

function isPriority ()
{
    typeset -rA SEVERITY_LEVELS=([emerg]=0 [alert]=1 [crit]=2 [err]=3 [warning]=4 [notice]=5 [info]=6 [debug]=7)
    typeset -r LEVEL=$1

    if : 
    then
        return 0
    fi

    return 1
}

function logToSystem ()
{
    typeset -r PRIORITY="$1"
    typeset -r MESSAGE="$2"

    logger -${PRIORITY} $MESSAGE
}

function logToApp ()
{
    typeset -r PRIORITY="$1"
    typeset -r MESSAGE="$2"

    errorMessage "${PRIORITY}:\n${MESSAGE}"
}