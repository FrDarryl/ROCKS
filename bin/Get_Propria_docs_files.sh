#!/bin/env bash

function Create_Propria_data_files() {

    [[ -z "${PdfRstFP}" ]] && LogEcho "ERROR" "No PdfRstFP specified. Cannot create data files." && return 1
    [[ -z "${RstFP}" ]] && LogEcho "ERROR" "No RstFP specified. Cannot create data files." && return 1
    [[ -z "${TomlFP}" ]] && LogEcho "ERROR" "No TomlFP specified. Cannot create data files." && return 1

    LogEcho "INFO" "Retrieving Propers..."

    # Add heading.
    rstHeader="${Rite} ${EventType} Propers for '${PropersID}'"
    [[ ! -z "${PropersKey_Alt}" ]] && rstHeader+=" with '${PropersID_Alt}'"
    echo "**${rstHeader}**" >| "${RstFP}"
    echo '' >> "${RstFP}" # Add a blank line after header

    # Add propers.
    for properKey in "${ProperKeys[@]}"
    do
        # Skip if there is a user-specified ProperKey (e.g. 'Entrance-Antiphon') and it doesn't match this one; default is all (-s 'PropersKey').
        [[ ! -z $ProperKey ]] && [[ "${properKey}" != "${ProperKey}" ]] && continue;

        tomlSelector="${PropersKey}.${properKey}"
        LogEcho "INFO" "    Trying to get '${tomlSelector}'..."

        LogEcho "INFO" "    Cmd: dasel -f $TomlFP -s $tomlSelector"
        properValue=`dasel -f $TomlFP -s $tomlSelector 2> /dev/null`
        if [[ ! -z "$properValue" ]]; then

            echo "${properValue}" | perl -lpe 's/^\"//' | perl -lpe 's/\"$//' | perl -lpe 's/\\n/\n/g' >> "${RstFP}"
            LogEcho "INFO" "        Added '${tomlSelector}'. Beauty eh!"

        else

            LogEcho "INFO" "        No '${tomlSelector}' found."
            if [[ ! -z "${PropersKey_Alt}" ]]; then

                tomlSelector_Alt="${PropersKey_Alt}.${properKey}"

                LogEcho "INFO" "        Trying to get '${tomlSelector_Alt}'..."

                LogEcho "INFO" "        Cmd: dasel -f $TomlFP_Alt -s $tomlSelector_Alt"
                properValue=`dasel -f ${TomlFP_Alt} -s ${tomlSelector_Alt} 2> /dev/null`
                if [[ ! -z "$properValue" ]]; then
                    echo "${properValue}" | perl -lpe 's/^\"//' | perl -lpe 's/\"$//' | perl -lpe 's/\\n/\n/g' >> "${RstFP}"
                    LogEcho "INFO" "            Added '${tomlSelector_Alt}'. Beauty eh!"
                else
                    LogEcho "INFO" "            No '${tomlSelector_Alt}' found."
                    LogEcho "INFO" "            No proper '${properKey}' added. Hosed eh!"
                fi
            else
                LogEcho "INFO" "        No proper '${properKey}' added. Hosed eh!"
            fi
        fi
    done

    LogEcho "INFO" "Created RstFP ${RstFP}"

    Edit_txt "${RstFP}"

    Create_pdf_from_file "${RstFP}" "${PdfRstFP}"

    LogEcho "INFO" "Created PdfRstFP ${PdfRstFP}"

    Display_pdf "${PdfRstFP}"

    return 0
}

function Get_alternative_proper_parameters() {

    # Query for (first) alternative PropersID
    tomlSelector="${PropersKey}.PropersKey_Alt"

    PropersKey_Alt=`dasel -f ${TomlFP} -s ${tomlSelector} 2> /dev/null | perl -lpe 's/^"//' | perl -lpe 's/"$//' | perl -lpe "s/'//g"`
    if [[ -z "${PropersKey_Alt}" ]]; then
        MassType_Alt=''
        LogEcho "INFO" "No PropersKey_Alt found for Table selector ${PropersKey}. Adding only MassType $MassType propers as they exist in the Missal."
    else
        # Set MassType_Alt and create its TOML Propers key
        MassType_Alt=`echo "${PropersKey_Alt}" | cut -d_ -f1 | perl -lpe "s/'//g"`
        MassType_Alt+='Masses'
        LogEcho "INFO" "Found PropersKey_Alt '${PropersKey_Alt}' which uses MassType '${MassType_Alt}'."

        # Look for second alternative PropersID
        tomlSelector="${PropersKey}.PropersKey_Alt2"

        PropersKey_Alt2=`dasel -f ${TomlFP} -s ${tomlSelector} 2> /dev/null | perl -lpe 's/^\"//' | perl -lpe 's/\"$//' | perl -lpe "s/'//g"`
        if [[ -z "${PropersKey_Alt2}" ]]; then
            MassType_Alt2=''
            LogEcho "INFO" "No PropersKey_Alt2 found."
        else
            #  Get MassType_Alt2 and create its TOML Propers key
            MassType_Alt2=`echo "${PropersKey_Alt2}" | cut -d_ -f1 | perl -lpe "s/'//g"`
            MassType_Alt2+='Masses'
            LogEcho "INFO" "Found PropersKey_Alt2 '${PropersKey_Alt2}' which uses MassType '${MassType_Alt2}'."
        fi

        #  Look for third alternative PropersID
        tomlSelector="${PropersKey}.PropersKey_Alt3"

        PropersKey_Alt3=`dasel -f ${TomlFP} -s ${tomlSelector} 2> /dev/null | perl -lpe 's/^\"//' | perl -lpe 's/\"$//' | perl -lpe "s/'//g"`
        if [[ -z "${PropersKey_Alt3}" ]] then
            MassType_Alt3=''
            LogEcho "INFO" "No PropersKey_Alt3 found."
        else
            # Get MassType_Alt3 and create its TOML Propers key
            MassType_Alt3=`echo "${PropersKey_Alt3}" | cut -d_ -f1 | perl -lpe "s/'//g"`
            MassType_Alt3+='Masses'
            LogEcho "INFO" "Found PropersKey_Alt3 '${PropersKey_Alt3}' which uses MassType '${MassType_Alt3}'."
        fi
    fi

    # If multiple alternative PropersIDs defined, set MassType_Alt and PropersKey_Alt based on user selection of the associated TOML Propers key.
    if [[ ! -z "${MassType_Alt2}" ]]; then
        if [[ "${ROCKS_INTERACTIVE}" == "TRUE" ]]; then
            Get_selected_alternative_proper_parameters
        else
            LogEcho "INFO" "ROCKS not running in INTERACTIVE mode so must use first defined alternative propers (${MassType_Alt} ${PropersKey_Alt})."
        fi
    fi

    if [[ -z "${ProperKey}" ]]; then
        LogEcho "INFO" "Will retrieve propers using MassType '${MassType}' PropersKey '${PropersKey}' as selector."
        [[ ! -z "${MassType_Alt}" ]] && LogEcho "INFO" "If proper/s missing, will retrieve them using MassType '${MassType_Alt}' PropersKey_Alt '${PropersKey_Alt}' as selector."
    else
        LogEcho "INFO" "Will retrieve proper using MassType '${MassType}' PropersKey.ProperKey '${PropersKey}.${ProperKey}' as selector."
        [[ ! -z "${MassType_Alt}" ]] && LogEcho "INFO" "If proper missing from above, will retrieve it using alternative MassType '${MassType_Alt}' PropersKey_Alt.ProperKey '${PropersKey_Alt}.${ProperKey}' as selector."
    fi

    return 0
}

function Get_selected_alternative_proper_parameters() {

    propersKeys="${PropersKey_Alt} ${PropersKey_Alt2}"
    propersKeysCount=2

    [[ ! -z "${PropersKey_Alt3}" ]] && propersKeys+=" ${PropersKey_Alt3}" && $propersKeysCount++

    tput bold

    PS3="Please enter a number for the alternative PropersKey (1..${propersKeysCount}): "
    select propersKey in ${propersKeys};
    do
        case "${propersKey}" in
            $PropersKey_Alt)
                # MassType_Alt and PropersKey_Alt remain first alternative
                break
                ;;

            $PropersKey_Alt2)
                MassType_Alt="${MassType_Alt2}"
                PropersKey_Alt="${PropersKey_Alt2}"
                break
                ;;

            $PropersKey_Alt3)
                MassType_Alt="${MassType_Alt3}"
                PropersKey_Alt="${PropersKey_Alt3}"
                break
                ;;

            '')
                break
                ;;

            *)
                ;;
        esac
    done

    tput sgr0

    return 0
}

function Usage() {
    LogEcho "ERROR" "Usage: $0 -e EventType -m MassType -r Rite -s TomlSelector (PropersKey[.ProperKey])";
    exit 1;
}

#===================
# Start of execution
#===================

source "${ROCKS_HOME}/bin/Initialise.sh"

[[ $# -ne 8 ]] && Usage;

source "${ROCKS_HOME}/bin/Get_user_parameters.sh"

DataType='Propria'

GetoptsSwitch=':e:m:r:s:'
GetoptsRequired='emrs'

Get_user_parameters $*

TomlFP="${DataTypeFD}/${Rite}_Propers-${MassType}.toml"

tomlSelector="${PropersKey}.PropersID"
PropersID=`dasel -f ${TomlFP} -s ${tomlSelector} 2> /dev/null | perl -lpe 's/^\"//' | perl -lpe 's/\"$//' | perl -lpe "s/'//g"`
[[ -z "${PropersID}" ]] && LogEcho "ERROR" "Found no PropersID via TomlSelector ${tomlSelector} in ${TomlFP}. Exiting." && exit 1

# If there is there is an alternative PropersID defined in the Propers toml file, set the associated MassType_Alt parameters.
# If there are multiple alternative PropersIDs, user must select one,

Get_alternative_proper_parameters

if [[ ! -z "${MassType_Alt}" ]]; then
    TomlFP_Alt="${DataTypeFD}/${Rite}_Propers-${MassType_Alt}.toml"

    tomlSelector="${PropersKey_Alt}.PropersID"
    PropersID_Alt=`dasel -f ${TomlFP_Alt} -s ${tomlSelector} 2> /dev/null | perl -lpe 's/^\"//' | perl -lpe 's/\"$//' | perl -lpe "s/'//g"`
    [[ -z "${PropersID_Alt}" ]] && LogEcho "ERROR" "Found no PropersID via TomlSelector ${tomlSelector} in ${TomlFP_Alt}. Exiting." && exit 1
fi

# Same output file basename by default
docsFB="${DataFB}"

PdfRstFP="${DocsFD}/${docsFB}_rst.pdf"
RstFP="${DocsFD}/${docsFB}.rst"

LogEcho "INFO" "Additional derived parameters:"
LogEcho "INFO" "    PropersID:      '${PropersID}'"
LogEcho "INFO" "    PropersID_Alt:  '${PropersID_Alt}'"
LogEcho "INFO" "    PropersKey_Alt: '${PropersKey_Alt}'"
LogEcho "INFO" "    Using data files:"
LogEcho "INFO" "        TomlFP:         '${TomlFP}'"
LogEcho "INFO" "        TomlFP_Alt:     '${TomlFP_Alt}'"
LogEcho "INFO" "    Creating docs files:"
LogEcho "INFO" "        PdfRstFP:       '${PdfRstFP}'"
LogEcho "INFO" "        RstFP:          '${RstFP}'"

Create_Propria_data_files

exit 0
