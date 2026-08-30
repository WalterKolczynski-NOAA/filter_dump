#! /bin/bash

set -au

# date
if [[ ${HOSTNAME} =~ ufe ]]; then
	# Ursa
	source /apps/lmod/lmod/init/bash
	module use /apps/modules/modulefiles
	module load contrib
	module load rocoto/1.3.7
	PATH="${PATH}:/apps/slurm/default/bin"
elif [[ ${HOSTNAME} =~ hfe ]]; then
	# Hera
	source /apps/lmod/lmod/init/bash
	module use /apps/modules/modulefiles
	module load contrib
	module load rocoto/1.3.7
	PATH="${PATH}:/apps/slurm/default/bin"
else
	echo "Host ${HOSTNAME} not recognized"
	exit 1
fi

set -x

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

rocotorun -d "filter_dump.db" -w "filter_dump.xml"
