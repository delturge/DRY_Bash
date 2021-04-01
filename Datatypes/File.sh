
#!/bin/bash

##################################################################
#                         File Functions                         #
##################################################################

function isFile ()
{
    declare -r FILENAME=$1

    [[ -e $FILENAME ]]
    return $?
}

function isRegFile ()
{
    declare -r FILENAME=$1

    [[ -f $FILENAME ]]
    return $?
}

function isDirectory ()
{
    declare -r FILENAME=$1

    [[ -d $FILENAME ]]
    return $?
}

function isReadable ()
{
    declare -r FILENAME=$1

    [[ -r $FILENAME ]]
    return $?
}

function isWritable ()
{
    declare -r FILENAME=$1

    [[ -w $FILENAME ]]
    return $?
}

function isExecutable ()
{
    declare -r FILENAME=$1

    [[ -x $FILENAME ]]
    return $?
}

function isConfigurable ()
{
    declare -r FILENAME=$1

    [[ isRegFile $FILENAME && isReadable $FILENAME && isWritable $FILENAME ]]
    return $?
}

function fileToList ()
{
    declare -r FILENAME=$1
    cat $FILENAME
}

function getFileType ()
{
    declare -r FILENAME=$1
    file -b $FILENAME
}

function getFilenames ()
{
    declare -r TARGET_DIR="$1"
    declare -r GLOB_PATTERN="$2"

    find "$TARGET_DIR" -name "$GLOB_PATTERN" -print
}

function hasRegFiles ()
{
    declare $targetDir="$1"    # Where targetDir ends in a forward slash /
    ls -ld "${targetDir}*" 2> | sort -r | grep -m 1 '^-' > /dev/null 2>&1
}

function hasDirs ()
{
    declare $targetDir="$1"    # Where targetDir ends in a forward slash /
    ls -ld "${targetDir}*/" > /dev/null 2>&1
}

function getDirs ()
{
    declare $targetDir="$1"    # Where targetDir ends in a forward slash /
    ls -ld "${targetDir}*/"
}


function hasTheseDirs ()
{
    for directory in "$@"
    do
        if [[ ! isDirectory $directory ]]
        then
            errorMessage "The $directory directory does not exist, but it must."
            exit 1
        fi
    done
}

function makeFile ()
{
    declare -r FILENAME=$1
    declare -r ERROR_MESSAGE_PREFIX="$FILENAME already exists."

    if ! isFile $FILENAME
    then
        touch $FILENAME
        return 0
    fi

    errorMessage "$ERROR_MESSAGE_PREFIX: $(getFileType $FILENAME)"
    return 1
}

function makeManyFiles ()
{
    for filename in "$@"
    do
        makeFile $filename
    done
}

function countFiles ()
{
    declare -r DIRECTORY=$1
    ls -l $DIRECTORY | grep "^-" | wc -l | tr -d [:space:]
}