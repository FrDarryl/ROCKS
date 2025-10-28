source ${ROCKS_BIN}/Initialise.sh

for vcsFP in $ROCKS_DATA/Calendaria/*.vcs; do
    bothFB=$(basename $vcsFP .vcs)
    tsvFP="${ROCKS_LOOKUP}/Lookup_${bothFB}.tsv"
    Create_tsv_from_vcs $vcsFP $tsvFP
done
