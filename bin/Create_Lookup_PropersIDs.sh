#!/bin/env bash

function Usage() {
    LogEcho "ERROR" "Usage: $0";
    exit 1;
}

source "${ROCKS_HOME}/bin/Initialise.sh"

[[ $# -ne 0 ]] && Usage;

tmpFP=$(mktemp --suffix ".tmp")
LogEcho "INFO" "tmpFP: ${tmpFP}"

cd "${ROCKS_LOOKUP}"

cat Lookup_VOE_Collects.tsv | cut -f1 | gawk '!/PropersID/' > "${tmpFP}"

cat Lookup_PropersIDs_English-Latin.tsv | cut -f1 | gawk '!/PropersID/' >> "${tmpFP}"
cat Lookup_PropersIDs_English-Latin.tsv | cut -f2 | gawk '!/PropersID_Alt/' >> "${tmpFP}"

Create_Lookup_PropersIDs_datatype.sh Propria
cat Lookup_PropersIDs_Propria.tsv >> "${tmpFP}"

Create_Lookup_PropersIDs_datatype.sh Calendaria
cat Lookup_PropersIDs_Calendaria.tsv >> "${tmpFP}"

LookupPropersIdsFP="${ROCKS_LOOKUP}/Lookup_PropersIDs.tsv"

[[ -f "${LookupPropersIdsFP}" ]] && rm "${LookupPropersIdsFP}"

echo "PropersIDs	" > "${LookupPropersIdsFP}" # Not specified in Calendaria or Propria files
echo "Feria	" >> "${LookupPropersIdsFP}" # Not specified in Calendaria or Propria files

perl -p -i -e 's/$/\t/' "${tmpFP}"

cat "${tmpFP}" | sort -u | gawk '!/^$/' >> "${LookupPropersIdsFP}"

LogEcho "INFO" "Created LookupPropersIdsFP ${LookupPropersIdsFP}"
