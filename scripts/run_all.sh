#!/bin/bash

STUDY_LIST=$1
STUDY_PATH=/g/scb/bork/data/spire/studies

PARAMS_FILE=../../config/spire_params.yml
CONFIG_FILE=../../config/spire_run.config


while [[ -s ${STUDY_LIST} ]]; do

	study=$(head -n 1 ${STUDY_LIST})

	path=${STUDY_PATH}/${study}
	mkdir -p studies/${study}
	cd studies/${study}
	bash ../../run.sh ${path} ${PARAMS_FILE} ${CONFIG_FILE}
	retcode=$?
	cd -
	if [[ "${retcode}" == "0" ]]; then
		# sed -i '1d' ${STUDY_LIST};
		sed -i "/^"${study}"$/d" ${STUDY_LIST}
	fi
	# break
done


