#!/bin/env bash

function Usage() {
    >&2 echo "Usage: $0 -i InputTomlFilePath (e.g., CCC_English.toml) -s TomlSelector (e.g., CCC.Num10) [-o OutFilePath (appends text if file exists)]"
    exit 1
}

OutFP=''
TomlFP=''
TomlSelector=''

while getopts ":i:o:s:" opt; do
    case $opt in
        i) TomlFP="$OPTARG"
        ;;
        o) OutFP="$OPTARG"
        ;;
        s) TomlSelector="$OPTARG"
        ;;
        :) echo "Option -${OPTARG} requires an argument." && Usage
        ;;
        \?) >&2 echo "Option -$OPTARG invalid." && Usage
        exit 1
        ;;
    esac

    case $OPTARG in
        -*) >&2 echo "Option $opt argument invalid." && Usage
        exit 1
        ;;
    esac
done

[[ -z $TomlFP ]] && Usage;
[[ -z $TomlSelector ]] && Usage;

#[[ $# -lt 2 ]] && Usage
#[[ $# -gt 3 ]] && Usage
#
#tomlFP=$1
#tomlSelector=$2
#outFP=''
#[[ $# -eq 3 ]] && outFP=$3
text=`dasel -f "${TomlFP}" -s "${TomlSelector}" | perl -lpe 's/^\"//' | perl -lpe 's/\"$//'`
[[ -z $text ]] && exit 1;
[[ -z $OutFP ]] && echo "${text@E}" && exit 0;
echo "${text@E}">>$OutFP
