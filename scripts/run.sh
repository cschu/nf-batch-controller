#!/bin/bash

module load Anaconda3
module load Nextflow
source <($(which conda) shell.bash hook)
conda activate /scratch/schudoma/envs/mge

TIMESTAMP=$(date "+%Y%m%d_%H%M%S")

PROJECT_PATH=$1
PROJECT=$(basename ${PROJECT_PATH})
WORKFLOW=cschu/metaphlow
WORKFLOW_VERSION=main

WORKDIR=/scratch/schudoma/WORK/mp4/spire/${PROJECT}/
mkdir -p ${WORKDIR}
if [[ ! -L work ]]; then
	ln -sf $WORKDIR work
fi

PARAMS_FILE=$2
CONFIG_FILE=$3

INPUT_DIR=${PROJECT_PATH}/raw_data

nextflow pull ${WORKFLOW} -r ${WORKFLOW_VERSION}

nextflow run ${WORKFLOW} \
	-r ${WORKFLOW_VERSION} \
	-c ${CONFIG_FILE} \
	-params-file ${PARAMS_FILE} \
	-work-dir ${WORKDIR} \
	-with-trace trace.${TIMESTAMP}.txt \
	-with-report report.${TIMESTAMP}.html \
	--remote_input_dir ${INPUT_DIR} \
	--output_dir output \
	-resume


retcode=$?
has_ignored_processes=$(grep "ignoredCount=[1-9].\+;" .nextflow.log)

if [[ "${retcode}" == "0" && -z "${has_ignored_processes}" ]]; then
  status="finished"
  retcode=0
elif [[ ! -z "${has_ignored_processes}" ]]; then
  status="action required"
  retcode=0  # workflow was not able to automatically deal with whatever it encountered -> manual intervention needed; notify operator of that fact and move on to next study. otherwise might get stuck in an infinite loop.
else
  status="failed"
  retcode=1
fi

echo Pipeline ${status} in ${PWD}. | mail -s "${WORKFLOW}::${PROJECT} ${status}" $USER


exit ${retcode}
