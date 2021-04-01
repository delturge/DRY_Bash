function getNetStatus ()
{
    typeset -r DAEMON=$1
    netstat -lpna | grep $DAEMON
}
