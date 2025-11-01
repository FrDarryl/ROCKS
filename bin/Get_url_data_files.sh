#!/bin/env bash

function Usage() {
    LogEcho "ERROR" "Usage: $0 -d DataType"
    exit 1
}

#===================
# Start of execution
#===================

source "${ROCKS_HOME}/bin/Initialise.sh"

[[ $# -lt 1 ]] && Usage

source "${ROCKS_HOME}/bin/Get_user_parameters.sh"

GetoptsSwitch=':b:d:e:m:r:s:t:u:y:'
GetoptsRequired='d'

Get_user_parameters $*

source "${ROCKS_HOME}/bin/Create_url_data_files.sh"

PdfRstFP=''
PdfUrlFP=''
RstFP=''
TomlFP=''
VcsFP=''

LogEcho "INFO" "Additional derived parameters:"

# RST documentation: https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html

case "${DataType}" in

    Articuli)

        DomainName=$(echo "${Url}" | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/')
        LogEcho "INFO" "    DomainName: ${DomainName}"

        docsFB=$(Print_utf_date_today_string)
        docsFB+="_${DataFB}"

        PdfRstFP="${DocsFD}/${docsFB}_rst.pdf" &&
            LogEcho "INFO" "    PdfRstFP: ${PdfRstFP}'"
        #PdfUrlFP="${DocsFD}/${docsFB}_url.pdf" &&
        #    LogEcho "INFO" "    PdfUrlFP: ${PdfUrlFP}"
        RstFP="${DataTypeFD}/${DataFB}.rst" &&
            LogEcho "INFO" "    RstFP:    ${RstFP}"

        Create_Articuli_url_data_files
        ;;

    Bibliae)

        if [[ "${DataTypeSubFD}" =~ ebible-org ]]; then
            Create_Bibliae-ebible-org_url_data_files # All TXT data files downloaded as zip file and processed accordingly.
        elif [[ "${DataTypeSubFD}" =~ bibliacatolica-com-br ]]; then
            Create_Bibliae_bibliacatolica-com-br_url_data_files
        fi
        ;;

    Calendaria)

        TsvFP="${LookupFD}/Lookup_${DataFB}.tsv" &&
            LogEcho "INFO" "    TsvFP: ${TsvFP}"
        VcsFP="${DataTypeFD}/${DataFB}.vcs" &&
            LogEcho "INFO" "    VcsFP: ${VcsFP}"

        Create_Calendaria_url_data_files
        ;;

    Missale)

        RstFP="${DataTypeFD}/${DataFB}.rst"   &&
            LogEcho "INFO" "    RstFP:  ${RstFP}"
        TomlFP="${DataTypeFD}/${DataFB}.toml" &&
            LogEcho "INFO" "    TomlFP: ${TomlFP}"

        Create_Missale_url_data_files
        ;;

    Propria)

        urlUtfDate=$(echo "${Url}" | perl -lpe 's/^.+?(\d{4})(\d{2})(\d{2}).+$/\1-\2-\3/')
        LogEcho "INFO" "    UrlUtfDate: ${urlUtfDate}"

        docsFB="${urlUtfDate}_stmiford_${Rite}-${EventType}Propers"

        PdfRstFP="${DocsFD}/${docsFB}.pdf" &&
            LogEcho "INFO" "    PdfRstFP:   ${PdfRstFP}'"
        #PdfUrlFP="${DataTypeFD}/${DataFB}_url.pdf" &&
        #    LogEcho "INFO" "    PdfUrlFP: ${PdfUrlFP}"
        RstFP="${DocsFD}/${docsFB}.rst" &&
            LogEcho "INFO" "    RstFP:      ${RstFP}"
        TomlFP="${DataTypeFD}/${DataFB}.toml" &&
            LogEcho "INFO" "    TomlFP:     ${TomlFP}"

        Create_Propria_url_data_files
        ;;

esac

exit 0
