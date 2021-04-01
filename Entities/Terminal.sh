#!/bin/bash

function print ()
{
    local -r text="$1"
    echo -n "${text}"
}

function println ()
{
    local -r text="{$1}\n"
    print $text
}

function printError ()
{
    local -r errorMessage="$1"
    echo -n $(println $errorMessage) 1>&2
}

function prompt ()
{
    local -r text="$1"
    read -p "${print $text): "
    echo "$REPLY"
}

function showPwd ()
{
    message "Current Directory: $(pwd)"
}


