#!/bin/bash

function returnValue ()
{
    echo $1
}

function newline ()
{
    echo -e "\n"
}

function message ()
{
    readonly text="$1"
    echo -e "\n${text}"
}

function errorMessage ()
{
    readonly errorText="$1"
    echo $(message $errorText) 1>&2
}

function showPwd ()
{
    message "Current Directory: $(pwd)"
}

function pause ()
{
    text="$1"
    read -p "${text}: "
}

# Load datatype libaries.
. ../Datatypes/Datatype.sh

# Load entities.
. ../Entities/Entity.sh