#!/bin/bash

# Global vars
PROG_NAME='DockerTinyproxy'
PROXY_CONF='/etc/tinyproxy/tinyproxy.conf'
RUN_LOG='/var/log/tinyproxy/tinyproxy.log'

# Usage: screenOut STATUS message
screenOut() {
    timestamp=$(date +"%H:%M:%S")
    
    if [ "$#" -ne 2 ]; then
        status='INFO'
        message="$1"
    else
        status="$1"
        message="$2"
    fi

    echo -e "[$PROG_NAME][$status][$timestamp]: $message"
}

# Usage: checkStatus $? "Error message" "Success message"
checkStatus() {
    case $1 in
        0)
            screenOut "SUCCESS" "$3"
            ;;
        1)
            screenOut "ERROR" "$2 - Exiting..."
            exit 1
            ;;
        *)
            screenOut "ERROR" "Unrecognised return code."
            ;;
    esac
}

displayUsage() {
    echo
    echo '  Usage:'
    echo "      docker run -d --name='tinyproxy' -p <Host_Port>:8888 dannydirect/tinyproxy:latest <ACL>"
    echo
    echo "      - Set <Host_Port> to the port you wish the proxy to be accessible from."
    echo "      - Set <ACL> to 'ANY' to allow unrestricted proxy access, or one or more spece seperated IP/CIDR addresses for tighter security."
    echo
    echo "      Examples:"
    echo "          docker run -d --name='tinyproxy' -p 6666:8888 dannydirect/tinyproxy:latest ANY"
    echo "          docker run -d --name='tinyproxy' -p 7777:8888 dannydirect/tinyproxy:latest 87.115.60.124"
    echo "          docker run -d --name='tinyproxy' -p 8888:8888 dannydirect/tinyproxy:latest 10.103.0.100/24 192.168.1.22/16"
    echo
}

stopService() {
    screenOut "Checking for running Tinyproxy service..."
    if [ "$(pidof tinyproxy)" ]; then
        screenOut "Found. Stopping Tinyproxy service for pre-configuration..."
        killall tinyproxy
        checkStatus $? "Could not stop Tinyproxy service." \
                       "Tinyproxy service stopped successfully."
    else
        screenOut "Tinyproxy service not running."
    fi
}

parseAccessRules() {
    list=''
    for ARG in $@; do
        line="Allow\t$ARG\n"
        list+=$line
    done
    echo "$list" | sed 's/.\{2\}$//'
}

setMiscConfig() {
    sed -i -e"s,^MinSpareServers ,MinSpareServers\t1 ," $PROXY_CONF
    checkStatus $? "Set MinSpareServers - Could not edit $PROXY_CONF" \
                   "Set MinSpareServers - Edited $PROXY_CONF successfully."

    sed -i -e"s,^MaxSpareServers ,MaxSpareServers\t1 ," $PROXY_CONF
    checkStatus $? "Set MinSpareServers - Could not edit $PROXY_CONF" \
                   "Set MinSpareServers - Edited $PROXY_CONF successfully."
    
    sed -i -e"s,^StartServers ,StartServers\t1 ," $PROXY_CONF
    checkStatus $? "Set MinSpareServers - Could not edit $PROXY_CONF" \
                   "Set MinSpareServers - Edited $PROXY_CONF successfully."
}

enableLogFile() {
	sed -i -e"s,^#LogFile,LogFile," $PROXY_CONF
}

setAccess() {
    if [[ "$1" == *ANY* ]]; then
        sed -i -e"s/^Allow /#Allow /" $PROXY_CONF
        checkStatus $? "Allowing ANY - Could not edit $PROXY_CONF" \
                       "Allowed ANY - Edited $PROXY_CONF successfully."
    else
        sed -i "s,^Allow 127.0.0.1,$1," $PROXY_CONF
        checkStatus $? "Allowing IPs - Could not edit $PROXY_CONF" \
                       "Allowed IPs - Edited $PROXY_CONF successfully."
    fi
}

setAuth() {
    if [ -n "${BASIC_AUTH_USER}"  ] && [ -n "${BASIC_AUTH_PASSWORD}" ]; then
        screenOut "Setting up basic auth credentials."
        sed -i -e"s/#BasicAuth user password/BasicAuth ${BASIC_AUTH_USER} ${BASIC_AUTH_PASSWORD}/" $PROXY_CONF
    fi
}

setTimeout() {
    if [ -n "${TIMEOUT}"  ]; then
        screenOut "Setting up Timeout."
        sed -i -e"s/Timeout 600/Timeout ${TIMEOUT}/" $PROXY_CONF
    fi
}

startService() {
    screenOut "Starting Tinyproxy service..."
    /usr/bin/tinyproxy
    checkStatus $? "Could not start Tinyproxy service." \
                   "Tinyproxy service started successfully."
}

tailLog() {
    touch $RUN_LOG
    screenOut "Tailing Tinyproxy log..."
    tail -f $RUN_LOG
    checkStatus $? "Could not tail $RUN_LOG" \
                   "Stopped tailing $RUN_LOG"
}

# Check args
if [ "$#" -lt 1 ]; then
    displayUsage
    exit 1
fi
# Start script
echo && screenOut "$PROG_NAME script started..."
# Stop Tinyproxy if running
stopService
# Parse ACL from args
export rawRules="$@" && parsedRules=$(parseAccessRules $rawRules) && unset rawRules
# Set ACL in Tinyproxy config
setAccess $parsedRules
# Enable basic auth (if any)
setAuth
# Set Timeout (if any)
setTimeout
# Enable log to file
enableLogFile
# Start Tinyproxy
startService
# Tail Tinyproxy log
tailLog
# End
screenOut "$PROG_NAME script ended." && echo
exit 0
