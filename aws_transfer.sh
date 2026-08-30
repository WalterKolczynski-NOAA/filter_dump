#! /usr/bin/env bash

source preamble.sh

if [[ $# -ne 5 ]]; then
	echo "$(basename "${BASH_SOURCE[0]}") requires exactly four arguments"
	exit 1
fi

module use /contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core
module load stack-oneapi/2024.2.1
module load awscli-v2/2.15.53

set -x

source=$1
aws_dest=$2
date=$3
hour=$4
aws_profile=$5

cd "${source}"

for dump in dump_nr dump_ioda_nr; do
	for run in gdas gfs; do
		dump_dir="${dump}/${run}.${date}/${hour}"
		aws s3 sync "${dump_dir}" "${aws_dest}/${dump_dir}" --profile "${aws_profile}"
	done
done
