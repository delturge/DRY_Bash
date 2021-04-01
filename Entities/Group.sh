
function addGroup ()
{
    typeset -r GID=$1
    typeset -r GROUP_NAME=$2

    groupadd -g $GID $GROUP_NAME 
}

function addToGroup ()
{
    typeset -r GROUP=$1
    shift 1

    for $user in "$@"
    do
        usermod -G $GROUP $user
    done
}
