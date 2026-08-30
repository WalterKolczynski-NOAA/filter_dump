#! /usr/bin/env bash

source preamble.sh

if [[ $# -ne 4 ]]; then
	echo "FATAL: $(basename "${BASH_SOURCE[0]}") requires exactly four arguments"
	exit 1
fi

source_dir=$1
dest_dir=$2
date=$3
hour=$4

shopt -s extglob
if ! compgen -G "${source_dir}/@(gdas|gfs).${date}/${hour}"; then
	echo "FATAL: Source directory '${source_dir}' does not contain gdas or gfs directories for ${date}/${hour}"
	exit 3
fi

rm -Rf "${dest_dir}/gdas.${date}/${hour}"
rm -Rf "${dest_dir}/gfs.${date}/${hour}"

# Get all files in the main dump that are unrestricted
while IFS= read -r -d '' ur_file; do
	dest_file="${ur_file/${source_dir}/${dest_dir}}"
	mkdir -p "$(dirname "${dest_file}")"
	rsync -a "${ur_file}" "${dest_file}"
done < <(find "${source_dir}/"@(gdas|gfs)".${date}/${hour}" -type f -not -group rstprod -print0)

# Remove existing lists of replaced restricted files
find "${dest_dir}/"@(gdas|gfs)".${date}/${hour}" -type f -name restricted_replacements.txt -delete

# Check for unrestricted versions of restricted files and copy if available
# Write the outcome for each to a file named restricted_replacements.txt
while IFS= read -r -d '' rst_file; do
	ur_file="${rst_file/.${date}/nr.${date}}"
	dest_file="${rst_file/${source_dir}/${dest_dir}}"
	rst_record="${dest_file/$(basename "${dest_file}")/restricted_replacements.txt}"
	mkdir -p "$(dirname "${dest_file}")"
	if [[ -a "${ur_file}" ]]; then
		rsync -a "${ur_file}" "${dest_file}"
		echo "Restricted file $(basename "${rst_file}") replaced with unrestricted version" >> "${rst_record}"
	else
		echo "No unrestricted version of $(basename "${rst_file}") available" >> "${rst_record}"
	fi
done < <(find "${source_dir}/"@(gdas|gfs)".${date}/${hour}" -type f -group rstprod -print0)

for run in gdas gdas; do
	if [[ ! -d "${dest_dir}/${run}.${date}/${hour}/atmos" ]]; then
		mkdir "${dest_dir}/${run}.${date}/${hour}/atmos"
		mv "${dest_dir}/${run}.${date}/${hour}/"* "${dest_dir}/${run}.${date}/${hour}/atmos" || true
	fi
done
