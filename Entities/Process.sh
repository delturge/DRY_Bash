#!/bin/bash

##################################################################
#              Functions to deal with processes.                 #
##################################################################

function getProcesses ()
{
    ps -e -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat --no-headers
}

function getProcess ()
{
   local -r PID=$1
   ps -p $PID -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat --no-headers
}

function getSomeProcesses ()
{
    local -r $PIDS="$@"

    for pid in $PIDS
    do
        getProcess $pid
    done
}

function getProcessReport ()
{
   local -r PID=$1
   ps -p $PID -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat
}

function isProcess ()
{
    kill -s EXIT $1 > /dev/null 2>&1
    return $?
}

##
# Echos the elspased process time in seconds (etimes).
####
function getProcessSeconds ()
{
    local -r PID=$1
    getProcess $PID | awk '{print $12}' | trim
}

function getProcessStatus ()
{
    local -r PID=$1
    getProcess $PID | awk '{print $13}' | trim
}

function getPgid ()
{
    local -r PID=$1
    getProcess $PID | awk '{print $3}' | trim
}

function isZombie ()
{
    local -r PID=$1
    local processStatus

    processStatus=$(getProcessStatus $PID)
    
    [[ "$processStatus" == "Z" ]]
    return $?
}

function hasChildPids ()
{
    local -r PPID=$1
    echo $(getProcesses) | awk '{print $3}' | sort -n | uniq | grep "^${PPID}$"
    return $?
}

function getChildPids ()
{
    local -r PPID=$1
    echo $(getProcesses) | awk '{print $2, $3}' | sort -k 2 | awk "\$2 == $PPID {print \$1}" | sort -n
}

function getParentPid ()
{
    local -r PID=$1
    getProcess $PID | awk '{print $3}') | trim
}

function killProcess ()
{
    local -r PID=$1

    if [[ ! isProcess $PID ]]
    then
        printError "Process $PID cannot be terminated because it does not exist!"
        return 0
    elif [[ kill -s TERM $PID ]] && [[ ! isProcess $PID ]]
    then
        printError "Process $PID was terminated.\n"
        return 0
    elif kill -s KILL $PID
        printError "Process $PID killed with SIGKILL (9) signal."
        return 0
    elif isZombie $PID
    then
        printError "Process $PID is in the defunct / ZOMBIE status!"
        return 1
    else
        errorMessage "Process $PID is alive! SIGTERM and SIGKILL had no effect. It is not a zombie."
    fi

    return 2
}

function attemptToKillPid ()
{
    local -r PID=$1

    if killProcess $PID
    then 
        return 0
    fi

    local ppid=$(getParentPid $pid)
    printError "Process id $pid of parent process $ppid was not able to be killed."
    return 1
}

function killPidFamily ()
{
    local -r PROCESSES="$@"
    local -ir NUM_PROCESSES_TO_KILL=$#
    local -i numKilledProcesses=0
    local ppid

    for pid in $PROCESSES
    do
        pid=$(echo $pid | trim)

        if ! hasChildPids $pid
        then
            attemptToKillPid $pid && (( numKilledProcesses++ ))
        else
            killPidFamily $(getChildPids $pid) && attemptToKillPid $pid && (( numKilledProcesses++ ))
        fi
    done

    (( numKilledProcesses == NUM_PROCESSES_TO_KILL ))
    return $?
}

function getRuntimeSeconds ()
{
    local -r PID=$1
    local -r DAY_IN_SECONDS=86400
    local runtimeSeconds

    if [[ ! isProcess $PID ]]
    then
        echo -n $DAY_IN_SECONDS
        return 1
    fi

    runtimeSeconds=$(getProcessSeconds $PID)

    # Check to see if nothing was returned.
    if [[ -z $runtimeSeconds ]]
    then
        runtimeSeconds=$DAY_IN_SECONDS
    fi

    echo -n $runtimeSeconds
    return 0
}

function limitProcessRuntime ()
{
    local -ir PID=$1
    local -ir MAX_RUNTIME_SECONDS=$2
    local -ir MAX_CHECKS=$3
    local -ir DELAY_SECONDS=$4
    local -ir CURRENT_TIME_IN_SECONDS=$SECONDS # Where $SECONDS is a built-in, global variable.
    local -ir TIMEOUT=$(( MAX_RUNTIME_SECONDS + CURRENT_TIME_IN_SECONDS ))

    local -i checks=0
    local -i runtimeSeconds

    runtimeSeconds=$(getRuntimeSeconds $PID)

    while (( runtimeSeconds < TIMEOUT )) && (( checks < MAX_CHECKS ))
    do
        (( checks++ ))
        sleep $DELAY_SECONDS
        runtimeSeconds=$(getRuntimeSeconds $PID)
    done

    if ! isProcess $PID
    then
        # The process is dead.
        return 0
    fi

    # The process is still running and needs to be killed by higher client code.
    return 1
}