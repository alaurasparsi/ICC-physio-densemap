#!/usr/bin/env bash
# Stefano Moia
# last modification: 23.11.2026
# script for minimally preprocess anat and func data

# After navigating in the project folder

git clone https://github.com/smoia/EuskalIBUR_preproc.git

mkdir -p containers

cd EuskalIBUR_preproc

apptainer build -f ../containers/EuskalIBUR_preproc.sif EuskalIBUR_preproc.def

# Make sure the bash files are executable
chmod +x *.sh
chmod +x */*.sh

cd ../containers

# Check options
apptainer exec -e --no-home -B {{ path to scripts }}:/scripts EuskalIBUR_preproc.sif /scripts/00.pipelines/00.full_preproc.sh -h


# Preprocessing
apptainer exec -e --no-home \
		-B {{ path to data }}:/data \
		-B {{ path to scripts }}:/scripts \
		EuskalIBUR_preproc.sif \
		/scripts/00.pipelines/00.full_preproc.sh \
		-sub ${sub} -ses ${ses} -wdr /data -prjname preproc_nonuis \
		-tasks "rest_run-01" \
		-only_optcom -skip_meicaden -skip_applynuisance -skip_greyplots -tmp /tmp


# As a set of screens - do it only on HPCs and/or modify accordingly

for sub in $(seq -f %03g 1 10); do
	screen_name="preproc_${sub}"
	screen -dmS "$screen_name" \
		-L -Logfile ~/Scrivania/Workbench/logs/${screen_name}.log \
		bash -c "
		for ses in \$(seq -f %02g 1 10); do
			apptainer exec -e --no-home \
				-B {{ path to data }}:/data \
				-B {{ path to scripts }}:/scripts \
				EuskalIBUR_preproc.sif \
				/scripts/00.pipelines/00.full_preproc.sh \
				-sub ${sub} -ses \${ses} -wdr /data -prjname preproc_nonuis \
				-tasks \"rest_run-01\" \
				-only_optcom -skip_meicaden -skip_applynuisance -skip_greyplots -tmp /tmp;
		done
	"
done
