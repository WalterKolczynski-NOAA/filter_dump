#! /usr/bin/env bash

source preamble.sh

if [[ $# -ne 5 ]]; then
	echo "$(basename "${BASH_SOURCE[0]}") requires exactly five arguments"
	exit 1
fi

module load globus-cli

set -Eeax

source_globus_id=$1
dest_globus_id=$2
source_dir=$3
date=$4
hour=$5

declare -a task_ids

for dump in dump_nr dump_ioda_nr; do
	for run in gdas gfs; do
		dump_dir="${dump}/${run}.${date}/${hour}"
		globus_out=$(globus transfer "${source_globus_id}:${source_dir}/${dump_dir}" "${dest_globus_id}:${dump_dir}" --recursive --notify failed,inactive --fail-on-quota-errors --label "${dump}/${run}.${date}${hour}")
		echo "${globus_out}"
		task_ids+=($(grep -Po '(?<=Task ID: ).*' <<< "${globus_out}"))
	done
done

for task_id in "${task_ids[@]}"; do
	echo "Waiting for ${task_id} to finish"
	globus task wait --polling-interval 60 --timeout 10800 --heartbeat "${task_id}"
done
