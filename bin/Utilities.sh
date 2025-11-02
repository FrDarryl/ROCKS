#!/bin/env bash

function Create_pdf_from_file() {

    [[ $# -ne 2 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} InFP PdfFP" && return 1

    inFP=`realpath "${1}"`
    pdfFP=`realpath "${2}"`

    [[ ! -f "${inFP}" ]] && LogEcho "ERROR" "inFP ${inFP} does not exist or is not readable. Cannot create pdfFP ${pdfFP}." && return 1

    [[ -f "${pdfFP}" ]] && LogEcho "WARN" "pdfFP ${pdfFP} already exists. Pandoc will clobber it."

           #-V babelfonts: \
                #chinese: "Noto Serif Chinese" \
                #greek: "Noto Sans Greek" \
                #hebrew: "Noto Sans Hebrew" \
                #malayalam: "Noto Sans Malayalam" \
                #portuguese: "Noto Sans Portuguese" \
                #russian: "Noto Sans Russian"' \
    pandoc -f rst \
           -t pdf \
           --pdf-engine=xelatex \
           --wrap=preserve \
           -V geometry:'margin=.7cm' \
           -V fontsize=10pt \
           -V mainfont:'Noto Serif' \
           -V lang:'en-GB' \
           -V font-family:'Noto Serif, Noto Serif Greek, Noto Sans Hebrew, Noto Sans Hungarian, Noto Sans Malayalam, Noto Sans Portuguese' \
           -o "${pdfFP}" "${inFP}"

    [[ ! -f "${pdfFP}" ]] && LogEcho "ERROR" "Pandoc did not create pdfFP ${pdfFP} from inFP ${inFP}." && return 1

    LogEcho "INFO" "Created pdfFP ${pdfFP}"

    return 0
}

function Create_pdf_from_url() {

    [[ $# -ne 2 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} Url PdfFP" && return 1

    url="${1}"
    urlResp=`wget -S --spider "${url}"  2>&1 | grep 'HTTP/1.1 200 OK'`
    [[ ! "${urlResp}" =~ '200 OK' ]] && LogEcho "ERROR" "       Specified Url ${url} not reachable." && return 1

    pdfFP=`realpath ${2}`
    [[ -f "${pdfFP}" ]] && LogEcho "WARN" "pdfFP ${pdfFP} already exists. Pandoc will replace/overwrite it."

    pandoc -t pdf \
           --pdf-engine=xelatex \
           --wrap=preserve \
           -V geometry:'margin=.7cm' \
           -V mainfont:'Noto Serif' \
           -V fontsize:'11pt 5pt' \
           -V lang:'en-GB' \
           -V font-family:'Noto Serif, Noto Serif Greek, Noto Sans Hebrew, Noto Sans Hungarian, Noto Sans Malayalam, Noto Sans Portuguese' \
           -o "${pdfFP}" "${url}"

    [[ ! -f "${pdfFP}" ]] && LogEcho "ERROR" "Pandoc did not create pdfFP ${pdfFP} from url ${url}." && return 1

    return 0
}

function Create_tsv_from_vcs() {

    [[ $# -ne 2 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} VcsFP TsvFP" && return 1

    vcsFP="${1}"
    tsvFP="${2}"

    [[ ! -f "${vcsFP}" ]] && LogEcho "ERROR" "vcsFP ${vcsFP} does not exist or is not readable. Cannot create tsvFP ${tsvFP}." && return 1

    [[ -f "${tsvFP}" ]] && LogEcho "WARN" "tsvFP ${tsvFP} already exists and will be replaced."

    Rite=$(basename "${vcsFP}" | perl -lpe 's/^(...).+$/$1/')
    LogEcho "INFO" "Rite: ${Rite}"

    LogEcho "INFO" "Reading ${vcsFP}..."

    tsvLine="Date	DOW	Rite	PropersID_Selected	PropersID_Alt	PropersID_Default	PropersID_Option1	PropersID_Option2	PropersID_Option3	PropersID_Option4	BlankColumn"
    echo "${tsvLine}" >| "${tsvFP}"

    while read -r inputLine; do

        # Remove DOS newline
        vcsLine=$(echo "${inputLine}" | perl -lpe "s/\r//")
        #$_ =~ s/([^[:ascii:]]+)/unidecode($1)/ge;

        # This line has the event calendar date
        if [[ "${vcsLine}" =~ DTSTART ]]; then
            ordoDate=$(echo "${vcsLine}" | perl -lpe "s/DTSTART.+?(\d{4})(\d{2})(\d{2})/\1-\2-\3/")
            ordoDow=$(date -d "${ordoDate}" +%A | perl -lpe 's/^(...).+$/\1/')
            LogEcho "INFO" "    Found Vcalendar (vcs) event with OrdoDate ${ordoDate} which is a '${ordoDow}'."
        fi

        # Skip until SUMMARY which has the event PropersID info
        [[ ! "${vcsLine}" =~ SUMMARY: ]] && continue

        LogEcho "INFO" "        vcsLine:   '${vcsLine}'"

        # Reusable PropersID conversion Perl script; shared with Missale processing.
        propersIDs=$(Detox_propersIDs.pl "${ordoDate}" "${ordoDow}" "${Rite}" "${vcsLine}")
        LogEcho "INFO" "        propersIDs: '${propersIDs}'"

        firstPropersID=$(echo "${propersIDs}" | cut -d '|' -f 1)

        pipeLine="${ordoDate}|${ordoDow}|${Rite}|${firstPropersID}||${propersIDs}|"

        tsvLine=$(echo "${pipeLine}" | perl -lpe "s/\|/\t/g")
        LogEcho "INFO" "            Writing tsvLine ${tsvLine}"

        echo "${tsvLine}" >> "${tsvFP}"

    done <${vcsFP}

    # Old method: Ordo.pl Create_Ordo -r="${Rite}" -y="${Year}" -u="${IcsUrl}" -o="${TsvFP}" > /dev/null 2>&1

    [[ -z "${tsvFP}" ]] && LogEcho "ERROR" "TsvFP ${tsvFP} not created; exiting." && return 1
    LogEcho "INFO" "Created tsvFP ${tsvFP}"

    return 0
}

function Detox_txt() {

    [[ $# -ne 1 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} TxtFP" && return 1

    txtFP="${1}"

    [[ ! -f "${txtFP}" ]] && LogEcho "ERROR" "txtFP ${txtFP} does not exist or not writable." && return 1

    cat "${txtFP}" |
        perl -lpe 's/∙/-/g' |
        perl -lpe 's/℟/R/g' |
        perl -lpe 's/_+//' |
        gawk '!/^_$/' |
        perl -lpe 's/^\s+//' |
        perl -lpe 's/\[\d+\]//g' |
        gawk '!/^[0-9:\-]+$/' |
        gawk '!/^\[.+\]$/' |
        gawk '!/avatar/' |
        gawk '!/click link/' |
        gawk '!/Current time:/' |
        gawk '!/BUTTON/' |
        gawk '!/Email/' |
        gawk '!/Facebook/' |
        gawk '!/Free ebook/' |
        gawk '!/full episode/' |
        gawk '!/Getting your Trinity/' |
        gawk '!/GIVE the GIFT/' |
        gawk '!/How to listen/' |
        gawk '!/Listen to this episode/' |
        gawk '!/Orthodox.+Faithful/' |
        gawk '!/^Newsletter$/' |
        gawk '!/^Notify$/' |
        gawk '!/Paid episode/' |
        gawk '!/Sign up to get/' |
        gawk '!/Subscribe/' |
        perl -lpe 's/Tweet .his//g' |
        gawk '!/Twitter/' |
        gawk '!/Leave a comment$/' |
        gawk '!/^Share$/' |
        gawk '!/^Updates/' |
        perl -lpe "s/^\*/\n\n\*/g" | # Compress consecutive spaces
        perl -lpe "s/ +/ /g" | # Compress consecutive spaces
        perl -lpe "s/ $//g" |  # Delete trailing spaces
        uniq | # Remove consecutive identical lines (mainly for blank lines)
        sed '1{/^$/d}' | # Delete first and/or last lines if empty
        sed '${/^$/d}' >| "${txtFP}"

    return 0
}

function Display_pdf() {

    [[ $# -ne 1 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} PdfFP" && return 1

    [[ ! "${PdfDisplayEnabled}" == 'TRUE' ]] && return 1

    pdfFP="${1}"

    [[ ! -f "${pdfFP}" ]] && LogEcho "ERROR" "pdfFP ${pdfFP} does not exist or not readable." && return 1

    Query_file_command "Display" "${PDF_READER_APP}" "${pdfFP}"

    return 0
}

function Edit_txt() {

    [[ $# -ne 1 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} TxtFP" && return 1

    [[ ! "${EditingEnabled}" == "TRUE" ]] && return 1

    txtFP="${1}"

    [[ ! -f "${txtFP}" ]] && LogEcho "ERROR" "txtFP ${txtFP} does not exist or not writable." && return 1

    Query_file_command "Edit" "${EDITOR}" "${txtFP}"

    return 0
}

function Print_rst_bold_string() {
    echo "**${1}**"
}

function Print_rst_header_string() {
    headerString="${1}"
    echo "$headerString"
    len=${#headerString}
    rstLine=''
    for i in $(seq $len); do rstLine+='='; done
    echo $rstLine
}

function Print_rst_italic_string() {
    echo "*${1}*"
}

function Print_utf_date_today_string() {
    echo "$(date +'%Y-%m-%d')"
}

function Query_file_command() {

    [[ $# -ne 3 ]] && LogEcho "ERROR" "Usage: ${FUNCNAME} CmdPrompt Cmd FP" && return 1

    [[ ! "${ROCKS_INTERACTIVE}" == "TRUE" ]] && return 1

    cmdPrompt="${1}"
    cmd="${2}"
    fp="${3}"

    tput bold

    while true; do
        read -p "QUERY: ${cmdPrompt} ${fp}? y|[n]: " yn
        case $yn in
            [Yy]* ) $cmd "$fp"; break;;
            [Nn]* ) break;;
            '' ) break;;
            * ) echo "QUERY: Please answer y or n.";;
        esac
    done

    tput sgr0

    return 0
}

#===================
# Start of execution
#===================
# Panddoc User Manual:
#     https://pandoc.org/MANUAL.html
#
# ReStructuredText (rst) documentation:
#     https://docs.open-mpi.org/en/v5.0.x/developers/rst-for-markdown-expats.html ('-expats'? It should be '-experts' as native-born residents can also benefit.)
#     https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html
#
# rst tags used in Utilities:
#     Bold        **Text**
#
#     Italics     *Text*
#
#     Literal      ::
#                      Line1
#                      Line2
#
#                  (resume normal parsing)
#
#     MainHeader  Text
#                 ====
