#!/bin/env bash

function Usage() {
    >&2 echo "Usage: $0 -u URL (universalis.com/...) -p PropersID -o OutFilePath (replaces if it already exists)"
    exit 1
}

function RetrieveTextAndCreateOutFile() {
#   For text content cleanup,
#   (a) Awk is used to delete unneeded simple regex matching lines (e.g., blank lines), and
#   (b) Perl for substitution and removal of specific matching text.
#       Perl does anything Sed can do with regex, but better, i.e., PCRE.
#       cf. https://stackoverflow.com/questions/1030787/multiline-search-replace-with-perl
#   (c) Sed for easier working with STDIN as a file versus line-by-line
#       cf. https://stackoverflow.com/questions/9665472/how-to-use-variable-in-sed-search-pattern

    echo "Retrieving ${ContentType} from ${Url}..."

    lynx -dump $Url |
        awk 'NF' |                                  # Delete blank lines.
        perl -lpe 's/^\s+//' |                      # Remove leading whitespace on all lines.
        perl -p0e 's/.+(First reading)/$1/se' |     # Remove all content up to this line which marks beginning of Readings content.
        perl -p0e "s/\Q$ContentEndRE\E.+/'''/gms" | # Remove all content after this line which marks end of ''.
        perl -lpe 's/_+//se' |                      # Replace horizontal separator of underscores with blank line.
        awk '!/How to listen/' |                    # Delete server-generated information lines within Bible text.
        awk '!/^You can also view/' |               # ''
        awk '!/^English./' |                        # ''
        perl -lpe "s/^(First reading)/\"First-Reading\" = '''\nFirst Reading:/" |
        perl -lpe "s/^Second reading/'''\n\"Second-Reading\" = '''\nSecond Reading:/" |
        perl -lpe "s/^Responsorial Psalm/'''\n\"Responsorial-Psalm\" = '''\nResponsorial Psalm:/" |
        perl -lpe "s/^Gospel Acclamation/'''\n\"Gospel-Acclamation\" = '''\nGospel Acclamation:/" |
        perl -lpe "s/^Gospel$/'''\n\"Gospel\" = '''\nGospel:/" |
        awk 'NF' |                              # Final delete of created blank lines.
        sed -E "1i$ContentHeader" >| $OutFP     # Prepend content with TomlHeader and write all content to output file

    echo "Wrote retrieved ${ContentType} to ${OutFP}"

    return 1
}

#==========================
#Start of script processing
#==========================

OutFP=''
PropersID=''
Url=''

while getopts ":o:p:u:" opt; do
    case $opt in
        o) OutFP="$OPTARG"
        ;;

        i) PropersID="$OPTARG"
        ;;

        u) Url="$OPTARG"
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

[[ -z $OutFP ]]     && Usage;
[[ -z $PropersID ]] && Usage;
[[ -z $Url ]]       && Usage;
[[ ! "${Url}" =~ universalis\.com ]] && echo "URL invalid. Domain name must be universalis.com." && exit 1

ContentEndRE='Christian Art'
ContentHeader="[${PropersID}]"
ContentType='LiturgyPropers'

echo "User-Specified Arguments:"
echo "    URL:        ${Url}"
echo "    PropersID: ${PropersID}"
echo "    OutFP:     ${OutFP}"
echo "Url-specific Parameters:"
echo "    ContentType:  ${ContentType}"
echo "    ContentEndRE: ${ContentEndRE}"
echo "    ContentHeader:${ContentHeader}"

RetrieveTextAndCreateOutFile

exit 0
