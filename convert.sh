#!/usr/bin/env bash
set -euo pipefail

dir=$1

IFS='
'

for file in $(find "${dir}" -type f)
do
    relative_path=$(realpath --relative-to="${dir}" "${file}")
    top_level_dir=$(echo "${relative_path}" | cut -d"/" -f1)

    year=$(echo "${top_level_dir}" | perl -pe 's/.*(20[0-9]{2}).*/\1/')
    orig_month=$(echo "${top_level_dir}" | perl -pe "s/${year}//; s/[^a-z0-9]//; lc")

    case "${orig_month}" in
        01 | jan*)
            month="01";
            ;;
        02 | feb*)
            month="02";
            ;;
        03 | mar*)
            month="03";
            ;;
        04 | apr*)
            month="04";
            ;;
        05 | may*)
            month="05";
            ;;
        06 | jun*)
            month="06";
            ;;
        07 | jul*)
            month="07";
            ;;
        08 | aug*)
            month="08";
            ;;
        09 | sept*)
            month="09";
            ;;
        10 | oct*)
            month="10";
            ;;
        11 | nov*)
            month="11";
            ;;
        12 | dec*)
            month="12";
            ;;
        *)
            echo "Invalid month ${year}/'${orig_month}' at '${top_level_dir}'" >&2
            continue;
    esac

    remaining_path=$(echo "${relative_path}" | cut -d"/" -f2-)
    rest=$(dirname "${remaining_path}" | perl -pe 's@/@-@g')

    if [[ "${rest}" == "." ]]
    then
        base_dir="${year}-${month}"
    else
        base_dir="${year}-${month}-${rest}"
    fi

    filename=$(basename "${relative_path}")
    new_file="${base_dir}/${filename}"

    ext=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')

    if [[ "${ext}" == "jpg" ]];
    then
        echo "Checking ${file}..."
        date=$(exiv2 -g Date -pt "${file}")

        if [[ "${date}" == "" ]]
        then
            exiv2 -M"set Exif.Image.DateTime ${year}:${month}:01 00:00:00" "${file}"
        fi
    fi

    dir=$(dirname "${new_file}")

    mkdir -p "${dir}"
    mv "${file}" "${new_file}"
done
