#!/bin/bash

function listServices ()
{
    systemctl list-units --type=service | sed =n '2,/^$/' | grep -v "$^" | awk '{print $1}' | awk -F. '{print $1}'
}

function getServiceName ()
{
    local -r SERVICE="$1"
    listServices | grep -E "^${SERVICE}" | trim
}

function isService ()
{
    local -r SERVICE="$1"
    local -r SERVICE_NAME=$(getServiceName $SERVICE)

    [[ ! -z $SERVICE_NAME ]]
    return $?
}

function getServicePid ()
{
    local -r SERVICE="$1"
    systemctl status $(getServiceName $SERVICE) | grep "Main PID" | awk '{print $3}' | trim
}

function isServiceConfLoaded ()
{
    local -r SERVICE="$1"

    [[ systemctl list-units --type=service --state=loaded "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isBootService ()
{
    local -r SERVICE="$1"

    [[ systemctl is-enabled "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isServiceRunning ()
{
    local -r SERVICE="$1"

    [[ systemctl is-active "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isServiceRunning ()
{
    local -r SERVICE="$1"

    [[ systemctl list-units --type=service --state=running "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isStartableService ()
{
    local -r SERVICE="$1"

    if [[ ! isService $SERVICE ]]
    then
        return 2
    fi

    local -r SERVICE_NAME=$(getServiceName $SERVICE)

    [[ isServiceConfLoaded $SERVICE_NAME && isBootService $SERVICE_NAME ]] && [[ ! isServiceRunning $SERVICE_NAME ]]
    return $?
}

function getServiceState ()
{
    local -r SERVICE=$1

    if isServiceConfLoaded $SERVICE
    then
        message "The $SERVICE configuration is loaded."
    else
        message "The $SERVICE configuration is not loaded!"
    fi

    if isServiceEnabled $SERVICE
    then
        message "The $SERVICE service is enabled."
    else
        message "The $SERVICE service is disabled!"
    fi

    if isServiceActive $SERVICE
    then
        message "The $SERVICE service is started successfully."
    else
        message "The $SERVICE service did not start successfully!"
    fi

    if isServiceRunnting $SERVICE
    then
        message "The $SERVICE service is running."
    else
        message "The $SERVICE service is not running."
    fi
}

function maskService ()
{
    local -r SERVICE=$1
    systemctl mask $SERVICE
}

function unmaskService ()
{
    local -r SERVICE=$1
    systemctl unmask $SERVICE
}

function enableDaemon ()
{
    local -r DAEMON=$1
    systemctl enable $DAEMON
}

function disableDaemon ()
{
    local -r DAEMON=$1
    systemctl disable $DAEMON
}

function startDaemon ()
{
    decalre -r DAEMON=$1
    systemctl start $DAEMON
}

function stopDaemon ()
{
    local -r DAEMON=$1
    systemctl stop $DAEMON
}

function restartDaemon ()
{
    local -r DAEMON=$1
    systemctl restart $DAEMON
}

function reloadDaemon ()
{
    local -r DAEMON=$1
    systemctl reload $DAEMON
}

function getServiceStatus ()
{
    local -r SERVICE=$1
    systemctl status $SERVICE
}

function getServiceGroupStatus ()
{
    for serviceName in "$@"
    do
        showServiceStatus $serviceName
    done
}

function getGroupNetStatus ()
{
    for daemon in "$@"
    do
        getNetStatus $daemon
    done
}

function startService ()
{
    local -r SERVICE=$1

    if [[ isServiceStartable $SERVICE ]]
    then
        message "Starting $SERVICE ..."
        startDaemon $SERVICE
        return $?
    fi

    message "$SERVICE cannot start. Check the load configration, enable, and stop it first."
    return 2
}

function startServiceGroup ()
{
    for daemon in "$@"
    do
        startService $daemon
    done
}

function stopService ()
{
    local -r SERVICE=$1

    if isServiceRunning $SERVICE
    then
        message "Stopping $SERVICE ..."
        stopDaemon $SERVICE
        return $?
    fi

    message "$SERVICE is already stopped ..."
    return 2
}

function stopServiceGroup ()
{
    for daemon in "$@"
    do
        stopService $daemon
    done
}

function enableService ()
{
    local -r SERVICE=$1
    
    if [[ ! isServiceEnabled $SERVICE ]]
    then
        message "Enabling $SERVICE ..."
        enableDaemon $SERVICE
        return $?
    fi

    message "$SERVICE is already enabled."
    return 2
}

function enableServiceGroup ()
{
    for daemon in "$@"
    do
        enableService $daemon
    done
}

function disableService ()
{
    local -r SERVICE=$1
    
    if isServiceEnabled $SERVICE
    then
        println "Disabling $SERVICE ..."
        disableDaemon $SERVICE
        return $?
    fi

    message "$SERVICE is already disabled."
    return 2
}

function disableServiceGroup ()
{
    for daemon in "$@"
    do
        disableService $daemon
    done
}