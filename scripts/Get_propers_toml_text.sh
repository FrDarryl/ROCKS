#!/bin/env bash

function Usage() {
    echo "Usage: $0 -r Rite ${RitesRE} -m MassType ${MassTypesRE} -i PropersID [-p Proper ${PropersRE} (default:all)] [-o OutputFilePath]" 1; exit 1;
}

function Create_output_file() {

    # Add heading to output file.
    if [[ -z "${PropersID_Alt}" ]]; then
        echo "MASS PROPERS ($Rite) for ${PropersID}" >| $OutFP
    else
        echo "MASS PROPERS ($Rite) for ${PropersID} with ${PropersID_Alt}" >| $OutFP
    fi
        echo "" >> $OutFP

    # Add propers to output file.
    for proper in "${Propers[@]}"
    do
        [[ ! -z $Proper ]] && [[ "${proper}" != "${Proper}" ]] && continue;

        tomlFileFP="${ROCKS_RITUS}/${Rite}_Propers-${MassType}.toml"
        tomlSelector="${MassType_PropersTomlTableKey}.${proper}"
        echo "Trying to get ${tomlSelector}"

        if ! Get_toml_text.sh -i $tomlFileFP -s $tomlSelector -o $OutFP
        then
            if [ ! -z "$MassType_PropersTomlTableKey_Alt" ]; then

                tomlFileFP="${ROCKS_RITUS}/${Rite}_Propers-${MassType_Alt}.toml"
                tomlSelector="${MassType_PropersTomlTableKey_Alt}.${proper}"
                echo "...Trying to get ${tomlSelector}."

                if ! Get_toml_text.sh -i ${tomlFileFP} -s ${tomlSelector} -o $OutFP
                then
                    echo "...No ${MassType_PropersTomlTableKey}.${proper} nor ${MassType_PropersTomlTableKey_Alt}.${proper} added. Hosed twice eh!"
                else
                    echo "...Added ${MassType_PropersTomlTableKey_Alt}.${proper}. Beauty eh!"
                fi
            else
                echo "...No ${MassType_PropersTomlTableKey}.${proper} added. Hosed eh!"
            fi
        else
            echo "...Added ${MassType_PropersTomlTableKey}.${proper}. Beauty eh!"
        fi
    done

    echo "Created OutputFile ${OutFP}"
}

function Get_alternative_mass_parameters() {

    # Query for (first) alternative PropersID
    tomlFileFP="${ROCKS_RITUS}/${Rite}_Propers-${MassType}.toml"
    tomlSelector="${MassType_PropersTomlTableKey}.PropersID_Alt"

    if ! PropersID_Alt=`Get_toml_text.sh -i ${tomlFileFP} -s ${tomlSelector}`
    then
        MassType_Alt=''
        MassType_PropersTomlTableKey_Alt=''

        MassType_Alt2="" # ToDo: Needed to test later if multiple alternative PropersID defined for selection.
        echo "N.B. No PropersID_Alt found for ."
    else
        # Set MassType_Alt and create its TOML Propers key
        MassType_Alt=`echo "${PropersID_Alt}" | perl -lpe "s/'//g" | perl -lpe 's/^(.+?)>.+$/$1/'`
        MassType_PropersTomlTableKey_Alt=`echo "${PropersID_Alt}" | perl -lpe "s/'//g" | perl -lpe "s/[ ,:;&>()]/-/g" | perl -lpe 's/--/-/g' | perl -lpe 's/-$//g'`
        echo "Found PropersID_Alt ${PropersID_Alt}."

        # Look for second alternative PropersID
        # tomlFileFP is same for all user MassType queries
        tomlSelector="${MassType_PropersTomlTableKey}.PropersID_Alt2"

        if ! PropersID_Alt2=`Get_toml_text.sh -i ${tomlFileFP} -s ${tomlSelector}`
        then
            MassType_Alt2=''
            MassType_PropersTomlTableKey_Alt2=''
            # echo "N.B. No PropersID_Alt2 found."
        else
            #  Get MassType_Alt2 and create its TOML Propers key
            MassType_Alt2=`echo "${PropersID_Alt2}" | perl -lpe "s/'//g" | perl -lpe 's/^(.+?)>.+$/$1/'`
            MassType_PropersTomlTableKey_Alt2=`echo "${PropersID_Alt2}" | perl -lpe "s/'//g" | perl -lpe "s/[ ,:;&>()]/-/g" | perl -lpe 's/--/-/g' | perl -lpe 's/-$//g'`
            echo "Found PropersID_Alt2 ${PropersID_Alt2}."
        fi

        #  Look for third alternative PropersID
        #  tomlFileFP is same for all user MassType queries
        tomlSelector="${MassType_PropersTomlTableKey}.PropersID_Alt3"

        if ! PropersID_Alt3=`Get_toml_text.sh -i ${tomlFileFP} -s ${tomlSelector}`
        then
            MassType_Alt3=''
            MassType_PropersTomlTableKey_Alt3=''
            # echo "N.B. No PropersID_Alt3 found."
        else
            # Get MassType_Alt3 and create its TOML Propers key
            MassType_Alt3=`echo "${PropersID_Alt3}" | perl -lpe "s/'//g" | perl -lpe 's/^(.+?)>.+$/$1/'`
            MassType_PropersTomlTableKey_Alt3=`echo "${PropersID_Alt3}" | perl -lpe "s/'//g" | perl -lpe "s/[ ,:;&>()]/-/g" | perl -lpe 's/--/-/g' | perl -lpe 's/-$//g'`
            echo "Found PropersID_Alt3 ${PropersID_Alt3}."
        fi
    fi

    # If multiple alternative PropersIDs defined, set MassType_Alt and MassType_PropersTomlTableKey_Alt based on user selection of the associated TOML Propers key.
    [[ ! -z $MassType_Alt2 ]] && Get_selected_alternative_mass_parameters

    [[ ! -z $MassType_Alt ]] && echo "Will use ${MassType_Alt} selector ${MassType_PropersTomlTableKey_Alt}.<proper> as alternative to ${MassType} selector ${MassType_PropersTomlTableKey}.<proper>."

}

function Get_selected_alternative_mass_parameters() {

    propersTomlTableKeys="${MassType_PropersTomlTableKey_Alt} ${MassType_PropersTomlTableKey_Alt2}"
    propersTomlTableKeysCount=2

    [[ ! -z $MassType_PropersTomlTableKey_Alt3 ]] && $propersTomlTableKeys+=" ${MassType_PropersTomlTableKey_Alt3}" && $propersTomlTableKeysCount++

    PS3="Please enter a number for the alternative PropersID key (1..${propersTomlTableKeysCount}): "
    select propersTomlTableKey in ${propersTomlTableKeys};
    do
        case "$propersTomlTableKey" in
            $MassType_PropersTomlTableKey_Alt)
                # MassType_Alt, MassType_PropersTomlTableKey_Alt and PropersID_Alt remain first alternative
                break
                ;;

            $MassType_PropersTomlTableKey_Alt2)
                MassType_Alt=$MassType_Alt2
                MassType_PropersTomlTableKey_Alt=$MassType_PropersTomlTableKey_Alt2
                PropersID_Alt=$PropersID_Alt2
                break
                ;;

            $MassType_PropersTomlTableKey_Alt3)
                MassType_Alt=$MassType_Alt3
                MassType_PropersTomlTableKey_Alt=$MassType_PropersTomlTableKey_Alt3
                PropersID_Alt=$PropersID_Alt3
                break
                ;;

            *)
                ;;
        esac
    done
}

MassType=''
declare -a MassTypes=('CommonMasses'
                      'RequiemMasses'
                      'SanctoraleMasses'
                      'TemporaleMasses'
                      'RitualMasses'
                      'VariousMasses'
                      'VotiveMasses'
                     )
MassTypesRE='^('
MassTypesRE+=$(IFS=\| ; echo "${MassTypes[*]}")
MassTypesRE+=')$'

Proper=''
declare -a Propers=('Entrance-Antiphon'
                    'Collect'
                    'Prayer-over-the-Offerings'
                    'Communion-Antiphon'
                    'Prayer-after-Communion'
                    'Prayer-over-the-People'
                   )
PropersRE='^('
PropersRE+=$(IFS=\| ; echo "${Propers[*]}")
PropersRE+=')$'

PropersID=''

Rite=''
declare -a Rites=('NOE'
                  'VOE'
                 )
RitesRE='^('
RitesRE+=$(IFS=\| ; echo "${Rites[*]}")
RitesRE+=')$'

OutFP='' # Optional parm; set to empty string. Will be defined according to Rite and PropersID options.

while getopts ":m:i:o:p:r:" opt; do
    case $opt in
        m) MassType="$OPTARG"
        ;;

        i) PropersID="$OPTARG"
        ;;

        o) OutFP="$OPTARG"
        ;;

        p) Proper="$OPTARG"
        ;;

        r) Rite="$OPTARG"
        ;;

        :) echo "Option -${OPTARG} requires an argument." && Usage
        ;;

        \?) echo "Option -$OPTARG invalid." && Usage
        ;;

    esac # case $opt in

    case $OPTARG in
        -*) echo "Option $opt argument invalid." && Usage
        ;;
    esac
done

#echo "MassTypesRE: /${MassTypesRE}/"
#echo "PropersRE:   /${PropersRE}/"
#echo "RitesRE:     /${RitesRE}/"

# Validate user-specified parms
: ${Rite:?Must specify -r}
#[[ -z "${Rite}" ]] && echo "No Rite specified." && Usage
[[  ! "${Rite}" =~ $RitesRE ]] && echo "Got invalid Rite '${Rite}'; it doesn't match '${RitesRE}'." && Usage
echo "Rite:        '$Rite'"

: ${MassType:?Must specify -m}
#[[ -z "${MassType}" ]] && echo "No MassType specified." && Usage
[[  ! "${MassType}" =~ $MassTypesRE ]] && echo "Got invalid MassType '${MassType}'; it doesn't match '${MassTypesRE}'." && Usage
echo "MassType:    '$MassType'"

: ${PropersID:?Must specify -i}
[[ -z "${PropersID}" ]] && echo "No PropersID specified." && Usage
echo "PropersID:   '$PropersID'"

[[ ! -z "${Proper}" ]] && [[ ! "${Proper}" =~ $PropersRE ]] && echo "Got invalid Proper '${Proper}'; it doesn't match '${PropersRE}'." && Usage
[[   -z "${Proper}" ]] && echo "No Proper specified so all Propers will be added to output file." || echo "Proper:      '$Proper'"

# Set Toml Table key ([A-Za-z0-9_]) PropersID
MassType_PropersTomlTableKey=`echo $PropersID | perl -lpe "s/'//g" | perl -lpe "s/[ ,:;&>()]/-/g" | perl -lpe 's/--/-/g' | perl -lpe 's/-$//g'`

[[ -z "${OutFP}" ]] && OutFP="${ROCKS_DOCS}/${Rite}_Propers_${MassType_PropersTomlTableKey}.txt"
echo "OutFP:       '$OutFP'"

# If there is there is an alternative PropersID defined in the Propers toml file, set the associated MassType_Alt parameters.
# If there are multiple alternative PropersIDs, user must select one,
Get_alternative_mass_parameters

Create_output_file

exit 0
