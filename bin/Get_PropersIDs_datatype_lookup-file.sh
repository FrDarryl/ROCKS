#!/bin/env bash

function Usage() {
    LogEcho "ERROR" "Usage: $0 DataType (Calendaria|Propria)";
    exit 1;
}

source "${ROCKS_HOME}/bin/Initialise.sh"

[[ $# -ne 1 ]] && Usage;

DataType="${1}"
DataTypeFD="${DataFD}/${DataType}"
LookupPropersIdsFP="${LookupFD}/Lookup_PropersIDs_${DataType}.tsv"

[[ -f "${LookupPropersIdsFP}" ]] && rm "${LookupPropersIdsFP}"

tmpFP=$(mktemp --suffix ".tmp")

case "${DataType}" in

    Propria)
        cd "${DataTypeFD}"

        for fp in ?OE_Propers-*Masses.toml; do
            \grep -P 'PropersID =' "${fp}" | perl -lpe 's/^PropersID = "//' | perl -lpe 's/"//g' >> "${tmpFP}";
        done
        ;;

    Calendaria)
        cd "${LookupFD}"

        for fp in Lookup_?OE_Ordo-20??.tsv; do
            cut "${fp}" -f5 >> "${tmpFP}";
            cut "${fp}" -f6 >> "${tmpFP}";
            cut "${fp}" -f7 >> "${tmpFP}";
            cut "${fp}" -f8 >> "${tmpFP}";
            cut "${fp}" -f9 >> "${tmpFP}";
        done
        ;;
    *)
        Usage
        ;;
esac

cat "${tmpFP}" | sort -u | gawk '!/^$/' >| "${LookupPropersIdsFP}"

LogEcho "INFO" "Created LookupPropersIdsFP ${LookupPropersIdsFP}"
