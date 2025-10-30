#!/bin/env bash

function Create_Articuli_url_data_files() {

    [[ -z "${PdfRstFP}" ]] && LogEcho "ERROR" "No PdfRstFP specified. Cannot create data files." && return 1
    [[ -z "${RstFP}" ]] && LogEcho "ERROR" "No RstFP specified. Cannot create data files." && return 1
    [[ -z "${Url}" ]] && LogEcho "ERROR" "No Url specified. Cannot create data files." && return 1

    lynx -dump "${Url}" >| "${RstFP}"

    Detox_txt "${RstFP}"

    # ToDo: look at sponge from moreutils to obviate mktemp
    tmpFP=$(mktemp --suffix ".tmp") # https://stackoverflow.com/questions/10982911/creating-temporary-files-in-bash

    case "${DomainName}" in

        *anthonyesolen*)

            cat "${RstFP}" |
                perl -p0e "s/IFRAME.+//ms" |
                gawk '!/UPGRADE to support/' |
                gawk '!/gift subscription/' |
                gawk '!/SHARE WORD/' >| "${tmpFP}"
            Detox_txt "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *catholicculture*|*crisismagazine*)

            cat "${RstFP}" |
                perl -p0e "s/.+?DONATE TODAY//ms" |
                perl -p0e "s/.+?Submissions \*//ms" |
                perl -p0e "s/.+?^Commentary//ms" |
                perl -p0e "s/.+?^Opinion//ms" |
                perl -p0e "s/.+?Print issue//ms" |
                perl -p0e "s/\. Donate login.+//gms" |
                perl -p0e "s/Published on.+//gms" |
                perl -p0e "s/Subscription Options.+//gms" |
                perl -p0e "s/Read more.+//gms" |
                perl -p0e "s/Join the Conversation.+//gms" >| "${tmpFP}"
            Detox_txt "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *gatestoneinstitute*)

            cat "${RstFP}" |
                perl -p0e "s/.+?\* Search//ms" |
                perl -p0e "s/Get Free Exclusive.+//ms" |
                perl -lpe "s/^(\*.+)$/\n\1/" >| "${tmpFP}"
            Detox_txt "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *thecatholicdirectory*)

            cat "${RstFP}" |
                perl -p0e "s/.+Maps API\.//ms" |
                perl -p0e "s/THE CATHOLIC DIRECTORY.+//gms" |
                perl -p0e "s/Search for.+//gms" >| "${tmpFP}"
            Detox_txt "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *onepeterfive*)

            cat "${RstFP}" |
                perl -p0e "s/.+?Sign up to receive new OnePeterFive articles daily//ms" |
                perl -p0e "s/Popular on OnePeterFive.+//ms" >| "${tmpFP}"
            Detox_txt "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *thecatholicherald*)

            cat "${RstFP}" |
                perl -p0e "s/.+?The Catholic Herald//ms" |
                perl -p0e "s/The Catholic Herald.+//ms" >| "${tmpFP}"
            Detox_txt "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *)
            LogEcho "INFO" "    No special parsing applied to ${DomainName} content."
            ;;
    esac

    # Make first line bold
    sed -i '1s/^/**/' "${RstFP}"
    sed -i '1s/$/**/' "${RstFP}"

    LogEcho "INFO" "Created RstFP ${RstFP}"

    Edit_txt "${RstFP}"

    Create_pdf_from_file "${RstFP}" "${PdfRstFP}"

    Display_pdf "${PdfRstFP}"

    # Optional: Create Pdf of whole Url (tends to fail miserably due to font and image conversion errors).
    if [[ ! -z "${PdfUrlFP}" ]]; then

        Create_pdf_from_url "${Url}" "${PdfUrlFP}"

        LogEcho "INFO" "Created PdfUrlFP ${PdfUrlFP}"

        Display_pdf "${PdfUrlFP}"
    fi

    rm "${tmpFP}"

    return 0
}

function Create_Bibliae_bibliacatolica-com-br_url_data_files() {

    if [ -z "${BookID}" ]; then
        LogEcho "INFO" "Creating Toml files for TranslationID '${TranslationID}' (${TranslationName}: all books, chapters and verses)..."
    else
        if [ -z "${ChapNum}" ]; then
            LogEcho "INFO" "Creating Toml files for TranslationID '${TranslationID}' (${TranslationName}) BookID '${BookID}' (all chapters and verses)..."
        else
            if [ -z "${VerseRange}" ]; then
                LogEcho "INFO" "Creating Toml file for TranslationID '${TranslationID}' (${TranslationName}) BookID '${BookID}' (ChapNum '${ChapNum}' (all verses)..."
            else
                LogEcho "INFO" "Creating Toml file for TranslationID '${TranslationID}' (${TranslationName}) BookID '${BookID}' ChapNum '${ChapNum}' VerseRange '${VerseRange}'..."
            fi
        fi
    fi

    bookIDs=($(cat "${LookupBooksDataTypeSubFdTsvFP}" | cut -f1 | sed '1{/^BookID/d}'))
    bookCount="${#bookIDs[@]}"
    LogEcho "INFO" "BookCount: ${bookCount}" # Should always be 73 (Catholic Canon)

    outputFD="${DataTypeFD}/${DataTypeSubFD}/${TranslationID}"
    LogEcho "INFO" "outputFD: '${outputFD}'"

    # Create outputFD if doesn't exist (-p)
    mkdir -p "${outputFD}"

    bookNum=0
    filesCreatedCount=0

    for bookID in "${bookIDs[@]}"; do

        ((++bookNum))

        bookName=$(\grep -P "^${bookID}\t" "${LookupBooksTsvFP}" |
                   cut -f5)

        bookUrlToken=$(\grep -P "^${bookID}\t" "${LookupBooksDataTypeSubFdTsvFP}" |
                       cut -f$LanguageCodeBookNamesColNum |
                       perl -lpe "s/[.,º() ]/-/g" |
                       perl -lpe "s/\-+/-/g" |
                       iconv -f utf-8 -t ascii//translit |
                       tr '[:upper:]' '[:lower:]')

        LogEcho "INFO" "        BookUrlToken: '${bookUrlToken}'"

        logMsg="BookID/Name ${bookID}/'${bookName}' (${bookNum} of ${bookCount})"
        if [[ -z "${bookUrlToken}" ]]; then
            LogEcho "INFO" "    Skipping ${logMsg} since not included in Translation '${TranslationName}'."
            continue
        else
            if [[ -z "${BookID}" ]]; then
                LogEcho "INFO" "    Processing ${logMsg} ..."
            elif [[ "${BookID}" == "${bookID}" ]]; then
                LogEcho "INFO" "    Processing specified ${logMsg}..."
            else
                LogEcho "INFO" "    Skipping ${logMsg}..."
                continue
            fi
        fi

        chapCount=$( \grep -P "^${bookID}\t" "${LookupBooksTsvFP}" | cut -f3 )
        LogEcho "INFO" "        ChapCount: ${chapCount}"

        for chapNum in $( eval echo {1..$chapCount}); # https://stackoverflow.com/questions/17181787/how-to-use-variables-in-a-bash-for-loop
        do
            if [[ -z "${ChapNum}" ]]; then
                LogEcho "INFO" "        Processing ChapNum ${chapNum} of ${chapCount}..."
            elif [[ "${chapNum}" == "${ChapNum}" ]]; then
                LogEcho "INFO" "        Processing specified ChapNum ${ChapNum}..."
                if [[ ! -z "${VerseRange}" ]]; then # TODO: THIS TEST ISN'T WORKING FOR UNKNOWN REASON
                    LogEcho "WARNING" "         VerseRange '${VerseRange}' specified but verse selection is not not implemented; all verses will be added."
                fi
            else
                LogEcho "INFO" "        Skipping ChapNum ${chapNum} of ${chapCount}..."
                continue
            fi

            tomlFP="${outputFD}/${bookID}_${chapNum}.toml"

            # https://www.bibliacatolica.com.br/biblia-ave-maria/genesis/1/
            chapUrl="https://www.bibliacatolica.com.br/${TranslationUrlToken}/${bookUrlToken}/${chapNum}/"

            LogEcho "INFO" "            Using ChapURL ${chapUrl}..."

            lynx -dump "${chapUrl}" |
                perl -lpe 's/^\s+//' |
                gawk '!/\[/' |
                gawk '!/http/' |
                perl -p0e "s/.+?^(1\.)/\1/ms" | # Content should now start at verse 1
                perl -p0e "s/____.+/\n'''/ms" | # Content should now end at horizontal line
                perl -lpe "s/^(1\..*)$/\[\Q$chapNum\E\]\n\\1/" |
                perl -lpe "s/^1\.\s*(.*)$/\"1\" = ''':sup:\`1\` \1/" |
                perl -lpe "s/^(\d+)\.\s*(.*)$/\n'''\n\"\1\" = ''':sup:\`\1\` \2/" |
                perl -lpe "s/^(Notas de.+)/'''\n\"Notes\" = '''\n\1/" |
                gawk 'NF' >| $tomlFP

            LogEcho "INFO" "            Created TomlFP ${tomlFP}"

            ((++filesCreatedCount))

        done # for chapNum

        LogEcho "INFO" "    Processing of BookID '${bookID}' (${bookName}) complete."

    done # for bookID


    if [[ $filesCreatedCount -eq 0 ]]; then
        LogEcho "ERROR" "No Toml files created."
    elif [[ $filesCreatedCount -eq 1 ]]; then
        LogEcho "INFO" "Specified Toml file created (as above: ${tomlFP})."
        Edit_txt "${tomlFP}"
    else
        LogEcho "INFO" "Specified Toml files created."
    fi

    return 0
}

function Create_Bibliae-ebible-org_url_data_files() {

    LogEcho "INFO" "Creating data files for TranslationID '${TranslationID}' (${TranslationName})"

    outFD="${DataTypeFD}/${DataTypeSubFD}/${TranslationID}"

    [[ -d "${outFD}" ]] && LogEcho "ERROR" "Directory '${outFD}' already exists. Cannot repopulate existing ebible-org data repository. Exiting." && return 1

    mkdir -p ${outFD}
    cd ${outFD}

    zipFB="${TranslationID}_readaloud.zip"
    zipFU="https://ebible.org/Scriptures/${zipFB}"
    LogEcho "INFO" "    zipFU: '${zipFU}'"

    wget ${zipFU}

    # Zipped files are named *.txt
    LogEcho "INFO" "Unzipping zipFB '${zipFB}'"
    unzip ${zipFB}

    for fp in ./*.txt; do

        txtFP=`realpath ${fp}`
        LogEcho "INFO" "    Processing txtFP '${txtFP}'"

        txtFB=`basename "${txtFP}" .txt`
        bookID=`echo "${txtFB}" | cut -d_ -f3`
        chapNum=`echo "${txtFB}" | cut -d_ -f4 | perl -lpe "s/^0+//"`
        tomlFP="${outFD}/${bookID}_${chapNum}.toml"

        LogEcho "INFO" "    Creating tomlFP '${tomlFP}'"

        echo "[${chapNum}]" >| "${tomlFP}"
        cat "${txtFP}" | gawk 'FNR>2{printf "\x22%d\x22 = \047\047\047\n:sup:`%d` %s\n\047\047\047\n",FNR-2,FNR-2,$0}' >> "${tomlFP}"
        # https://unix.stackexchange.com/questions/222709/how-to-print-quote-character-in-awk
    done

    return 0
}

function Create_Calendaria_url_data_files() {

    [[ -z "${IcsUrl}" ]] && LogEcho "ERROR" "IcsUrl not defined so cannot create any files; exiting." && return 1
    [[ -z "${Rite}" ]] && Rite='NOE' && LogEcho "INFO" "Rite not defined; defaulting to ${Rite}."
    [[ -z "${TsvFP}" ]] && LogEcho "ERROR" "TsvFP not defined so cannot create it; exiting." && return 1
    [[ -z "${VcsFP}" ]] && LogEcho "ERROR" "VcsFP not defined so cannot create it; exiting." && return 1

    wget -O "${VcsFP}" "${IcsUrl}" > /dev/null 2>&1

    [[ -z "${VcsFP}" ]] && LogEcho "ERROR" "wget did not download VcsFP ${VcsFP}; exiting." && return 1

    LogEcho "INFO" "Created VcsFP ${VcsFP}"

    Create_tsv_from_vcs "${VcsFP}" "${TsvFP}"

    return 0
}

function Create_Missale_url_data_files() {

    [[ -z "${RstFP}" ]] && LogEcho "ERROR" "No RstFP specified. Cannot create data files." && return 1
    [[ -z "${TomlFP}" ]] && LogEcho "ERROR" "No TomlFP specified. Cannot create data files." && return 1
    [[ -z "${Url}" ]] && LogEcho "ERROR" "No Url specified. Cannot create data files." && return 1

    rstFP=$(mktemp --suffix ".rst")

    lynx -dump "${Url}" >| "${rstFP}"

    Detox_txt "${rstFP}"

    # ToDo: look at sponge from moreutils to obviate this mktemp
    tmpFP=$(mktemp --suffix ".tmp") # https://stackoverflow.com/questions/10982911/creating-temporary-files-in-bash

    ContentEndRE='The English translation of Psalm Responses';

    case "${PropersType}" in

        adventmass)

            cat "${rstFP}" |
                gawk 'NF' | # Delete blank lines.
                perl -p0e "s/.+?(FIRST SUNDAY OF ADVENT)/\1/ms" | # Remove all content up to this line which marks beginning of propers content.
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |           # Remove all content after this line which marks end of propers content.
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP # Final delete of blank lines and write all edited content to text file
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        christmasmass)

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?(THE NATIVITY OF THE LORD)/\1/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        eastermass)

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?(THE MASS DURING THE DAY)/\1/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -lpe 's/^THE MASS DURING THE DAY$/EASTER SUNDAY/' |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        immaculateheart)

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?(The Immaculate Heart of the Blessed Virgin Mary)/IMMACULATE HEART OF OUR LADY/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        lentmass)

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?(ASH WEDNESDAY)/\1/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -lpe 's/^(TAKE THIS|FOR TH|THE BLOOD OF|WHICH WILL BE|DO THIS)(.+)$/  \1\2/' | # Indent words of consecration on Good Friday so as not be confused with propers.
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        motherofthechurch)

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?(The Blessed Virgin Mary, Mother of the Church)/MARY, MOTHER OF THE CHURCH/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        ordinarymass)

            ContentBeginRE=''

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?(FIRST WEEK IN ORDINARY TIME)/\1/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        pentecostmass)

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?Simple form/PENTECOST SUNDAY:VIGIL/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -lpe 's/^At the Mass during the Day/PENTECOST SUNDAY/' |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| $tmpFP
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        trinity)

            ContentBeginRE='THE MOST HOLY TRINITY'

            cat "${rstFP}" |
                gawk 'NF' |
                perl -p0e "s/.+?THE MOST HOLY TRINITY/TRINITY SUNDAY/ms" |
                perl -p0e "s/\Q$ContentEndRE\E.+//ms" |
                perl -p0e 's/^(MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)\n(.+?)\n/\1 \U\2\E\n/gms' |
                gawk 'NF' >| "${tmpFP}"
            cat "${tmpFP}" >| "${RstFP}"
            ;;

        *)
            LogEcho "ERROR" "PropersType ${PropersType} not yet implemented."
            ;;
    esac

    # Final detox
    cat "${RstFP}" >| "${tmpFP}"
    Detox_txt "${tmpFP}"
    cat "${tmpFP}" >| "${RstFP}"

    LogEcho "INFO" "Created RstFP ${RstFP}"

    Edit_txt "${RstFP}"

    echo "[${PropersKey}]" >| "${TomlFP}"

    cat "${RstFP}" >> "${TomlFP}"

    cat "${TomlFP}" |
        gawk 'NF' |
        gawk '!/^=+$/' | # Remove reStructuredText Document Heading markup
        perl -lpe "s/(\Q${propersHeader}\E)/\"Propers-Header\" = '''\n\1/" |
        perl -lpe "s/^(.+First Reading:.*)$/'''\n\"First-Reading\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Second Reading:.*)$/'''\n\"Second-Reading\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Responsorial Psalm:.*)$/'''\n\"Responsorial-Psalm\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Gospel Acclamation:.*)$/'''\n\"Gospel-Acclamation\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Gospel:.*)$/'''\n\"Gospel\" = '''\n\1\n/" >| "${tmpFP}"
    cat "${tmpFP}" >| "${TomlFP}"

    echo "'''" >> "${TomlFP}"

    LogEcho "INFO" "Created TomlFP ${TomlFP}"

    Edit_txt "${TomlFP}"

    return 0
}

function Create_Propria_url_data_files() {

    [[ -z "${PdfRstFP}" ]] && LogEcho "ERROR" "No PdfRstFP specified. Cannot create data files." && return 1
    [[ -z "${RstFP}" ]] && LogEcho "ERROR" "No RstFP specified. Cannot create data files." && return 1
    [[ -z "${TomlFP}" ]] && LogEcho "ERROR" "No TomlFP specified. Cannot create data files." && return 1
    [[ -z "${Url}" ]] && LogEcho "ERROR" "No Url specified. Cannot create data files." && return 1

    rstFP=$(mktemp --suffix ".rst")

    # Create RST file
    lynx -dump "${Url}" >| "${rstFP}"

    Detox_txt "${rstFP}"

    # ToDo: look at sponge from moreutils to obviate this second tmp file
    tmpFP=$(mktemp --suffix ".tmp") # https://stackoverflow.com/questions/10982911/creating-temporary-files-in-bash

    cat "${rstFP}" |
        perl -p0e "s/.+Readings at .ass//ms" |
        gawk '!/Liturgical .olour/' >| "${tmpFP}"
    cat "${tmpFP}" >| "${rstFP}"

    # Derive and prepend header as RST bold
    propersHeader="${Rite} ${EventType} Propers for "
    propersHeader+=`echo "${PropersKey}" | perl -lpe 's/-/ /g'`
    echo "**${propersHeader}**" >| "${RstFP}"

    cat "$rstFP" >> "${RstFP}"

    cat "${RstFP}" |
        perl -p0e "s/You can also view this page.+//ms" |
        perl -lpe "s/^First .eading:?(.+)/\n\n\*\*First Reading:\*\* \1\n\n/" |
        perl -p0e "s/^First .eading:?\n(.+?)\n/\*\*First Reading:\*\* \1\n\n/ms" |
        perl -lpe "s/^Second .eading:?(.+)/\n\n\*\*Second Reading:\*\* \1\n\n/" |
        perl -p0e "s/^Second .eading:?\n(.+?)\n/\n\n\*\*Second Reading:\*\* \1\n\n/ms" |
        perl -lpe "s/^Responsorial Psalm:?(.+)/\n\n\*\*Responsorial Psalm:\*\* \1\n\n/" |
        perl -p0e "s/^Responsorial Psalm:?\n(.+?)\n/\n\n\*\*Responsorial Psalm:\*\* \1\n\n/ms" |
        perl -lpe "s/^Gospel Acclamation:?(.+)/\n\n\*\*Gospel Acclamation:\*\* \1\n\n/" |
        perl -p0e "s/^Gospel Acclamation:?\n(.+?)\n/\n\n\*\*Gospel Acclamation:\*\* \1\n\n/ms" |
        perl -lpe "s/^Gospel:?(.+)/\n\n\*\*Gospel:\*\* \1\n\n/" |
        perl -p0e "s/^Gospel:?\n(.+?)\n/\n\n\*\*Gospel\*\*: \1\n\n/ms" |
        sed "3,$ s/$/\n/" >| "${tmpFP}" # Add a blank line after all lines after the inserted title; otherwise the text is compressed.

    Detox_txt "${tmpFP}" # Consecutive blank lines inserted above will be compressed to one via 'uniq' command in detox_txt function

    cat "${tmpFP}" >| "${RstFP}"

    LogEcho "INFO" "Created RstFP ${RstFP}"

    Edit_txt "${RstFP}"

    # Create TOML file
    echo "[${PropersKey}]" >| "${TomlFP}"

    cat "${RstFP}" >> "${TomlFP}"

    cat "${TomlFP}" |
        gawk 'NF' |
        perl -lpe "s/(\Q${propersHeader}\E)/\"Propers-Header\" = '''\n\1/" |
        perl -lpe "s/^(.+First Reading:.*)$/'''\n\"First-Reading\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Second Reading:.*)$/'''\n\"Second-Reading\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Responsorial Psalm:.*)$/'''\n\"Responsorial-Psalm\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Gospel Acclamation:.*)$/'''\n\"Gospel-Acclamation\" = '''\n\1\n/" |
        perl -lpe "s/^(.+Gospel:.*)$/'''\n\"Gospel\" = '''\n\1\n/" >| "${tmpFP}"
    cat "${tmpFP}" >| "${TomlFP}"

    echo "'''" >> "${TomlFP}"

    LogEcho "INFO" "Created TomlFP ${TomlFP}"

    Edit_txt "${TomlFP}"

    Create_pdf_from_file "${RstFP}" "${PdfRstFP}"

    LogEcho "INFO" "Created PdfRstFP ${PdfRstFP}"

    Display_pdf "${PdfRstFP}"

    # Optional: Create Pdf of whole Url (tends to fail miserably due to font and image conversion errors).
    if [[ ! -z "${PdfUrlFP}" ]]; then

        Create_pdf_from_url "${Url}" "${PdfUrlFP}"

        LogEcho "INFO" "Created PdfUrlFP ${PdfUrlFP}"

        Display_pdf "${PdfUrlFP}"
    fi

    return 0
}
