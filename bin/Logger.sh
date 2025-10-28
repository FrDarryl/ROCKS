#!/usr/bin/env bash

function LogEcho() {
    local logLevel=$1
    local logMessage=$2

    # If LogLevels global not set (as with direct LogEcho CLI call) or has no specified logLevel as key is undefined, print the message as is.
    [[ -z "${LogLevels[$logLevel]}" ]] && echo "${1}: ${2}" && return 0

    # If specified logLevel is lower than global LogLevel, do nothing.
    (( ${LogLevels[$logLevel]} < ${LogLevels[$LogLevel]} )) && return 2

    # Echo logMessage
    echo "${logLevel}: ${logMessage}"
}

#===================
# Start of execution
#===================

LogLevel="${ROCKS_LOGLEVEL}"

declare -A LogLevels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
