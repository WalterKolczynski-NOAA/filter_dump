#! /usr/bin/env bash

source preamble.sh

if [[ $# -ne 3 ]]; then
	echo "$(basename "${BASH_SOURCE[0]}") requires exactly three arguments"
	exit 1
fi

module load globus-cli

set -x

root_dir=$1
date=$2
hour=$3

for dump in dump_nr dump_ioda_nr; do
	for run in gdas gfs; do
		rm -Rf "${root_dir}/${dump}/${run}.${date}/${hour}"
	done
	# Delete empty directories
	find "${root_dir}/${dump}" -type d -empty -delete
done
