#!/bin/env bash

translation=$1

filesDir="${ROCKS_BIBLIAE}/${translation}"

[[ -d "${filesDir}" ]] && echo "Directory ${filesDir} already exists. Cannot repopulate existing ebible data repository. Exiting." && exit 1

mkdir -p ${filesDir}
cd ${filesDir}

zipFilename="${translation}_readaloud.zip"

zipFileUrl="https://ebible.org/Scriptures/${zipFilename}"
wget ${zipFileUrl}

# Zipped files are named *.txt
unzip ${zipFilename}

Convert_translation_txt_files_to_toml_files.sh ${translation}
