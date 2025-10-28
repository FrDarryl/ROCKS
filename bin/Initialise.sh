#!/bin/env bash

#===================
# Start of execution
#===================

[[ -z "${ROCKS_HOME}" ]] && echo "Environment variable ROCK_HOME is undefined. Contact admin to run ROCKS. Exiting." && exit 1;

export ROCKS_BIN="${ROCKS_HOME}/bin"
export ROCKS_DATA="${ROCKS_HOME}/data"
export ROCKS_DOCS="${ROCKS_HOME}/docs"
export ROCKS_LOOKUP="${ROCKS_HOME}/lookup"

BinFD="${ROCKS_BIN}"
DataFD="${ROCKS_DATA}"
DocsFD="${ROCKS_DOCS}"
LookupFD="${ROCKS_LOOKUP}"

# These may be initialised by system (.bashrc) or user
[[ -z "${ROCKS_INTERACTIVE}" ]] && export ROCKS_INTERACTIVE='FALSE' # Default unless otherwise set (no editing allowed).
[[ -z "${ROCKS_LOGLEVEL}" ]] && export ROCKS_LOGLEVEL='ERROR'       # Default unless otherwise set.

source "${ROCKS_BIN}/Logger.sh" # Must be here to allow logging in subsequent commands

# System environment contingencies

if [[ -z "${EDITOR}" ]]; then
    EditingEnabled='FALSE' && LogEcho "WARN" "Envar EDITOR is unset so manually editing text files in some use cases is not supported. Please contact sysadmin to correct this."
else
    if [[ "${ROCKS_INTERACTIVE}" == "TRUE" ]]; then
        EditingEnabled='TRUE'
    else
        EditingEnabled='FALSE'
    fi
fi

if [[ -z "${PDF_READER_APP}" ]]; then
    PdfDisplayEnabled='FALSE' && LogEcho "WARN" "Envar PDF_READER_APP is unset so displaying PDF files in some use cases is not supported. Please contact sysadmin to correct this."
else
    if [[ "${ROCKS_INTERACTIVE}" == "TRUE" ]]; then
        PdfDisplayEnabled='TRUE'
    else
        PdfDisplayEnabled='FALSE'
    fi
fi

declare -a RequiredInstalledCmds=('basename' 'dasel' 'gawk' 'iconv' 'lynx' 'pandoc' 'perl' 'realpath' 'wget')
foundUninstalledCmd='FALSE'
for cmd in "${RequiredInstalledCmds[@]}"; do
    [[ -z "$(which $cmd)" ]] &&
        foundUninstalledCmd='TRUE' &&
        LogEcho "ERROR" " Required Ubuntu package containing command '${cmd}' is not installed or accessible; please contact sysadmin to correct this."
done
[[ "${foundUninstalledCmd}" == 'TRUE' ]] && LogEcho "ERROR" "Cannot process request due to uninstalled software. Exiting." && exit 1

source "${ROCKS_BIN}/Utilities.sh"
