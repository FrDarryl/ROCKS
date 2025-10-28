#!/bin/env bash

function Get_user_parameters() {

    [[ ! -v DataType ]]      && LogEcho "ERROR" "Required global DataType not set. Exiting." && exit 1
    [[ ! -v GetoptsSwitch ]] && LogEcho "ERROR" "Required global GetopsSwitch not set. Exiting." && exit 1

    LogEcho "INFO" "Get_user_parameters caller parameters:"
    # Required
    LogEcho "INFO" "    GetoptsSwitch:   '${GetoptsSwitch}'"
    LogEcho "INFO" "    GetoptsRequired: '${GetoptsRequired}'"
    # Optional (based on caller requirements)
    [[ ! -z "${UrlRE}" ]] && LogEcho "INFO" "      UrlRE:         '${UrlRE}'"

    while getopts "${GetoptsSwitch}" opt; do
        case "${opt}" in
            d) DataType="${OPTARG}"
            ;;

            e) EventType="${OPTARG}"
            ;;

            m) MassType="$OPTARG"
            ;;

            o) OutFP="${OPTARG}"
            ;;

            r) Rite="$OPTARG"
            ;;

            s) Selector="${OPTARG}"
            ;;

            u) Url="${OPTARG}"
            ;;

            y) Year="${OPTARG}"
            ;;

            :) LogEcho "ERROR" "    Option -${OPTARG} requires an argument. Exiting." && exit 1
            ;;

            \?) LogEcho "ERROR" "    Option -${OPTARG} invalid. Exiting." && exit 1
            ;;

        esac

        case $OPTARG in
            -*) LogEcho "ERROR" "    Option ${opt} argument invalid. Exiting." && exit 1
            ;;
        esac
    done

    Validate_user_parameters

    Get_derived_parameters

    return 0
}

function Validate_user_parameters() {

    LogEcho "INFO" "    User parameters:"

    # This validation must be first as it can set further required parameters processed subsequently.
    if [[ "${GetoptsSwitch}" =~ d ]] && [[ "${GetoptsRequired}" =~ d ]]; then
        [[ -z "${DataType}" ]] && LogEcho "ERROR" "       Required parameter -d {DataType} not specified. Exiting." && exit 1
        [[ ! "${DataType}" =~ $DataTypesRE ]] && LogEcho "ERROR" "       Specified parameter DataType '${DataType}' invalid (must match '${DataTypesRE}'). Exiting." && exit 1
        LogEcho "INFO" "        DataType: '${DataType}'"

        case "${DataType}" in

            Articuli)
                GetoptsRequired+='u' &&
                LogEcho "INFO" "        GetoptsRequired: '${GetoptsRequired}' (augmented based on DataType)"
                ;;

            Bibliae)
                GetoptsRequired+='s' &&
                LogEcho "INFO" "        GetoptsRequired: '${GetoptsRequired}' (augmented based on DataType)"
                ;;

            Calendaria)
                GetoptsRequired+='ry' &&
                LogEcho "INFO" "        GetoptsRequired: '${GetoptsRequired}' (augmented based on DataType)"
                ;;

            Missale)
                GetoptsRequired+='u' &&
                LogEcho "INFO" "        GetoptsRequired: '${GetoptsRequired}' (augmented based on DataType)"
                ;;

            Propria)
                GetoptsRequired+='emrsu' &&
                LogEcho "INFO" "        GetoptsRequired: '${GetoptsRequired}' (augmented based on DataType)"
                ;;
        esac
    fi

    if [[ "${GetoptsSwitch}" =~ e ]] && [[ "${GetoptsRequired}" =~ e ]]; then
        [[ -z "${EventType}" ]] && LogEcho "ERROR" "       Required parameter -e {EventType} not specified. Exiting." && exit 1
        [[ ! "${EventType}" =~ $EventTypesRE ]] && LogEcho "ERROR" "       Specified parameter EventType '${EventType}' invalid (must match '${EventTypesRE}'). Exiting." && exit 1
        LogEcho "INFO" "        EventType: '${EventType}'"
    fi

    if [[ "${GetoptsSwitch}" =~ m ]] && [[ "${GetoptsRequired}" =~ m ]]; then
        [[ -z "${MassType}" ]] && LogEcho "ERROR" "       Required parameter -m {MassType} not specified. Exiting." && exit 1
        [[ ! "${MassType}" =~ $MassTypesRE ]] && LogEcho "ERROR" "       Specified parameter MassType '${MassType}' invalid (must match '${MassTypesRE}'). Exiting." && exit 1
        LogEcho "INFO" "        MassType: '${MassType}'"
    fi

    if [[ "${GetoptsSwitch}" =~ r ]] && [[ $GetoptsRequired =~ r ]]; then
        [[ -z "${Rite}" ]] && LogEcho "ERROR" "       Required parameter -r {Rite} not specified. Exiting." && exit 1
        [[ ! "${Rite}" =~ $RitesRE ]] && LogEcho "ERROR" "       Specified parameter Rite '${Rite}' invalid (must match '${RitesRE}'). Exiting." && exit 1
        LogEcho "INFO" "        Rite: '${Rite}'"
    fi

    if [[ "${GetoptsSwitch}" =~ s ]] && [[ "${GetoptsRequired}" =~ s ]]; then
        [[ -z "${Selector}" ]] && LogEcho "ERROR" "       Required parameter -s {Selector} not specified. Exiting." && exit 1
        LogEcho "INFO" "        Selector: '${Selector}'"
    fi

    if [[ "${GetoptsSwitch}" =~ u ]] && [[ "${GetoptsRequired}" =~ u ]]; then
        [[ -z "${Url}" ]] && LogEcho "ERROR" "       Required parameter -u {Url} not specified. Exiting." && exit 1
        [[ ! "${Url}" =~ $UrlRE ]]  && LogEcho "ERROR" "       Specified parameter Url '${Url}' invalid (must match '${UrlRE}'). Exiting." && exit 1

        # spider is unreliable; throws 403, etc. even when url is fine
        #urlResponse=$(wget -S --spider "${Url}"  2>&1 | \grep -P '\s*HTTP/' | perl -lpe 's/^\s+//g' | awk '{printf "%s+",$0} END {print ""}')
        LogEcho "INFO" "        Url: '${Url}'"
        #LogEcho "INFO" "            UrlResponse: '${urlResponse}'"
        #[[ ! "${urlResponse}" =~ '200 OK' ]] && LogEcho "ERROR" "           Cannot download content from Url. Exiting." && exit 1
    fi

    if [[ "${GetoptsSwitch}" =~ y ]] && [[ "${GetoptsRequired}" =~ y ]]; then
        [[ -z "${Year}" ]] && LogEcho "ERROR" "       Required parameter -y {Year} not specified. Exiting." && exit 1
        [[ ! "${Year}" =~ $YearRE ]] && LogEcho "ERROR" "       Specified parameter Year '${Year}' invalid (must match '$YearRE')." && exit 1
        LogEcho "INFO" "        Year: '${Year}'"
    fi

    return 0
}

function Get_derived_parameters() {

    LogEcho "INFO" "    Derived parameters:"

    DataTypeFD="${DataFD}/${DataType}"
    LogEcho "INFO" "        DataTypeFD: '${DataTypeFD}'"

    case "${DataType}" in

        ActaPontificia|Canones|Catechismi|ConciliaOecumenica|EnchiridionSymbolorum|MusicaSacra|PatresEcclesiae)

            LogEcho "ERROR" "        Processing of DataType ${DataType} not yet implemented. Exiting." && exit 1
            ;;

        Articuli)

            #DataFB=`date '+%Y-%m-%d_'`
            DataFB=`echo "${Url}" |
                perl -lpe "tr/A-Z/a-z/" |
                perl -lpe "tr/\//_/" |
                perl -lpe "tr/~\,=\#\".:\?/-/" |
                perl -lpe "s/www-//g" |
                perl -lpe "s/\-\-+/-/g" |
                perl -lpe "s/\-$//"  |
                perl -lpe "s/\_$//"  |
                perl -lpe "s/_\-/_/g" |
                perl -lpe "s/\%\d\d/-/g" |
                perl -lpe "s/^.+__//"`

            LogEcho "INFO" "        DataFB: '${DataFB}'"
            ;;

        Bibliae)

            if [[ "${Selector}" =~ \..+\..+\..+ ]]; then
                TranslationID=`echo "${Selector}" | cut -d. -f1`
                BookID=`echo "${Selector}" | cut -d. -f2`
                ChapNum=`echo "${Selector}" | cut -d. -f3`
                VerseRange=`echo "${Selector}" | cut -d. -f4`
            elif [[ "${Selector}" =~ \..+\..+ ]]; then
                TranslationID=`echo "${Selector}" | cut -d. -f1`
                BookID=`echo "${Selector}" | cut -d. -f2`
                ChapNum=`echo "${Selector}" | cut -d. -f3`
            elif [[ "${Selector}" =~ \..+ ]]; then
                TranslationID=`echo "${Selector}" | cut -d. -f1`
                BookID=`echo "${Selector}" | cut -d. -f2`
            else
                TranslationID="${Selector}"
            fi

            # Available Translations are listed in Lookup files, one per Domain-name based {DataTypeSubFD}, i.e., 'ebible-org' and 'bibliacatolica-com-br'
            # specified as first column in its Lookup_file 'ROCKS/lookup/Bibliae_Translations_{DataTypeSubFD}.tsv'.
            # The bibles themselves are generated and stored as Toml and plain text files in ROCKS/data/Bibliae/{DataTypeSubFD}/{TranslationID}
            # ebible.et translations are formatted: {LanguageCode}{Version}, e.g. 'en-KJV'.
            # bibliacatolica.com.br translations are all formatted: {LanguageCode}_{Version}, e.g. 'en_KJV'.
            # Caveat: two ebible-org translationIDs contain an underscore: fra_fob and knv-fly_river.

            LogEcho "INFO" "        TranslationID: '${TranslationID}'"
            LogEcho "INFO" "        BookID: '${BookID}'"
            LogEcho "INFO" "        ChapNum: ${ChapNum}"
            LogEcho "INFO" "        VerseRange: '${VerseRange}'"

            shopt -s extglob # https://stackoverflow.com/questions/4554718/how-to-use-patterns-in-a-case-statement
            case "${TranslationID}" in

                fra_fob|knv-fly_river)
                    DataTypeSubFD='ebible-org'
                    ;;

                ??_*)
                    DataTypeSubFD='bibliacatolica-com-br'
                    ;;

                *)
                    DataTypeSubFD='ebible-org'
                    ;;
            esac

            LogEcho "INFO" "        DataTypeSubFD: '${DataTypeSubFD}'"

            # Lookup files maintained as same-name sheets of GoogleWorkspace Sheets file stmiford_ROCKS.
            # BookIDs are based on USFM definitions at https://ubsicap.github.io/usfm/identification/books.html
            LookupBooksTsvFP="${LookupFD}/Lookup_Books.tsv"
            LogEcho "INFO" "        LookupBooksTsvFP:                 ${LookupBooksTsvFP}'"

            LookupBooksDataTypeSubFdTsvFP="${LookupFD}/Lookup_Books_${DataTypeSubFD}.tsv"
            LogEcho "INFO" "        LookupBooksDataTypeSubFdTsvFP:    ${LookupBooksDataTypeSubFdTsvFP}"

            # Table from URL above; not used in app but defining it anyway for completeness for all Lookup files maintained in stmiford_ROCKS
            LookupBooksUsfmTsvFP="${LookupFD}/Lookup_Books_USFM.tsv"
            LogEcho "INFO" "        LookupBooksUsfmTsvFP:             ${LookupBooksUsfmTsvFP}"

            LookupTranslationsDataSubFdTsvFP="${LookupFD}/Lookup_Translations_${DataTypeSubFD}.tsv"
            LogEcho "INFO" "        LookupTranslationsDataSubFdTsvFP: ${LookupTranslationsDataSubFdTsvFP}"

            TranslationName=$( \grep -P "^${TranslationID}\t" "${LookupTranslationsDataSubFdTsvFP}" | cut -f2 )

            [[ -z "${TranslationName}" ]] && LogEcho "ERROR" "TranslationID ${TranslationID} is not available on ROCKS-registered websites 'ebible.org' and 'bibliacatolica.com.br'. Exiting." && exit 1

            LogEcho "INFO" "        TranslationName: '${TranslationName}'"

            if [[ "${DataTypeSubFD}" == "bibliacatolica-com-br" ]]; then
                TranslationUrlToken=$( \grep -P "^${TranslationID}\t" "${LookupTranslationsDataSubFdTsvFP}" | cut -f3 )
                LogEcho "INFO" "        TranslationUrlToken: '${TranslationUrlToken}'"

                LanguageCodeBookNamesColNum=$( \grep -P "^${TranslationID}\t" "${LookupTranslationsDataSubFdTsvFP}" | cut -f4 )
                LogEcho "INFO" "        LanguageCodeBookNamesColNum: ${LanguageCodeBookNamesColNum}"
            fi
            ;;

        Calendaria)

            DataFB="${Rite}_Ordo-${Year}"
            LogEcho "INFO" "        DataFB: '${DataFB}'"

            case "${Rite}" in
                VOE)
                    IcsUrl="https://www.universalis.com/europe.england.ordinariate/${Year}0101/vcalendar.ics"
                    ;;
                *)
                    IcsUrl="https://www.universalis.com/europe.england/${Year}0101/vcalendar.ics"
                    ;;
            esac

            LogEcho "INFO" "        IcsUrl: '${IcsUrl}'"
            ;;

        Missale)
            [[ ! "${Url}" =~ liturgies\.net ]] && LogEcho "ERROR" "       Cannot get ${DataType} data files from Url ${Url}; exiting." && exit 1

            PropersType=`echo "${Url}" | perl -lpe "s/.+roman_missal\/(.+)\.htm/\1/"`

            LogEcho "INFO" "        PropersType: '${PropersType}'"

            DataFB="${Rite}_Propers-${PropersType}"
            LogEcho "INFO" "        DataFB: '${DataFB}'"
            ;;

        Propria)

            [[ ! -z "${Url}" ]] && [[ ! "${Url}" =~ universalis\.com ]] && LogEcho "ERROR" "       Cannot get ${DataType} data files from Url ${Url}; exiting." && exit 1
            [[ -z "${Rite}" ]] && LogEcho "ERROR" "       Required parameter Rite not specified. Exiting." && exit 1
            [[ -z "${Selector}" ]] && LogEcho "ERROR" "       Required parameter Selector not specified. Exiting." && exit 1

            if [[ $Selector =~ \. ]]; then
                PropersKey=`echo "${Selector}" | cut -d. -f1`
                ProperKey=`echo "${Selector}" | cut -d. -f2`

                [[ ! $ProperKey =~ PropersKey_Alt ]] &&
                  [[ ! $ProperKey =~ $ProperKeysRE ]] &&
                  LogEcho "ERROR" "       Selector-specified ProperKey '${ProperKey}' invalid (must match '${ProperKeysRE}'). Exiting." && exit 1
            else
                PropersKey="${Selector}"
                ProperKey=''
            fi

            LogEcho "INFO" "        ProperKey:      '${ProperKey}'"
            LogEcho "INFO" "        PropersKey:     '${PropersKey}'"

            DataFB="${Rite}_Propers-${MassType}_${PropersKey}"

            # Public Universalis access only contains proper lessons/readings (subscription required for other propers).
            [[ ! -z "${Url}" ]] && DataFB+='-Lessons'

            LogEcho "INFO" "        DataFB: '${DataFB}'"
            ;;

        *)
            LogEcho "ERROR" "       Bug in function ${FUNCNAME}: Global DataType '${DataType}' not handled in case statement. Exiting." && exit 1
            ;;
    esac

    return 0
}

#===================
# Start of execution
#===================

# Initialise user-specified global parameters

DataType=''
MassType=''
Rite=''
Selector=''
Url=''
UrlRE=''

# Initialise derived global parameters

BookID=''
ChapNum=''
DataFB=''
DataTypeFD=''
ProperKey=''
PropersKey=''
PropersType=''
TranslationID=''
TranslationName=''
TranslationUrlToken=''
VerseRange=''

# Set allowable values associative arrays and accompanying regex validators

declare -a DataTypes=($(find $ROCKS_HOME/data/ -maxdepth 1 -type d |  perl -lpe 's/.+\///' | gawk '!/^$/'))
DataTypesRE='^('
DataTypesRE+=$(IFS=\| ; echo "${DataTypes[*]}")
DataTypesRE+=')$'

declare -a EventTypes=('NuptialMass'
                       'PatronalMass'
                       'RequiemMass'
                       'SchoolMass'
                       'SundayMass'
                       'VotiveMass'
                       'WeekdayMass'
                      )
EventTypesRE='^('
EventTypesRE+=$(IFS=\| ; echo "${EventTypes[*]}")
EventTypesRE+=')$'

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

declare -a ProperKeys=('Entrance-Antiphon'
                       'Collect'
                       'First-Reading'
                       'Responsorial-Psalm'
                       'Second-Reading'
                       'Gospel-Acclamation'
                       'Gospel'
                       'Prayer-over-the-Offerings'
                       'Communion-Antiphon'
                       'Prayer-after-Communion'
                   )
ProperKeysRE='^('
ProperKeysRE+=$(IFS=\| ; echo "${ProperKeys[*]}")
ProperKeysRE+=')$'

#  Many rites include English, the last character ('E'):
#   ES=Eastern Syriac English[Malayalam] (Syro-Malabar and Chaldean Catholic Uniate Churches)
#   NO=Novus Ordo English[Latin/Protuguese/Spanish/Tagalog]
#   VO=Vetus Ordo English[Latin] (Ordinariate and Tridentine liturgies)
#   WS=Western Syriac English[Malayalam] (Maronite, Syro-Malankara and Syriac Catholic Uniate Churches)

declare -a Rites=('ESE'
                  'ESEM'
                  'NOE'
                  'NOEL'
                  'NOEP'
                  'NOES'
                  'NOET'
                  'VOE'
                  'VOEL'
                  'VOEP'
                  'VOL'
                  'WSE'
                  'WSEM'
                 )
RitesRE='^('
RitesRE+=$(IFS=\| ; echo "${Rites[*]}")
RitesRE+=')$'

YearRE='^([0-9]{4})$'
