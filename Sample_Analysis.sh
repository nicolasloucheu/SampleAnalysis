#!/usr/bin/bash -l
# Sample_Analysis.sh
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Main script taking as input raw data from Illumina Infinium 450k or EPIC and returning different plots and dataframes for further visualization
# v0.02 - Includes EPIC data support

#PBS -l nodes=1:skylake
#PBS -l mem=32gb
#PBS -m abe

cd $PBS_O_WORKDIR 

"""
#MODIFY THOSE LINES
"""

#Select input data
INPUT_FILE=data/GSESOTOS/

# Select platform ("450k" or "epic")
PLATFORM="450k"

# Select normalisation method ("FunNorm" or "Quantiles")
NORM_METH="FunNorm"

# Select the PCA components to put on the PCA graph made from sample cell proportions values (number between 1 and 8)
# First (x-axis)
FIRST_PCA=1
# Second (y-axis)
SECOND_PCA=2

# Select the PCA components to put on the PCA graph made on the control cell proportions values (number between 1 and 8)
# First (x-axis)
FIRST_C_PCA=1
# Second (y-axis)
SECOND_C_PCA=2

"""
#STOP MODIFYING
"""

# Parse name of input
BASE_NAME=$(basename $INPUT_FILE)
if [[ $INPUT_FILE == *"."* ]]; then
	FOLDER_BASE=$(echo $BASE_NAME | cut -d '.' -f 1)
else
	FOLDER_BASE=$(echo $BASE_NAME)
fi

# Get date and create new folder for results
CURRENT_DATE=`date +"%Y%m%d_%H%M"`
OUT_FOLDER="outputs/${FOLDER_BASE}_${CURRENT_DATE}"
mkdir -p tmp
mkdir -p outputs
rm tmp/*
mkdir "$OUT_FOLDER"

# Import R
module load R/3.6.0-foss-2019a
# Import python (3.7.2 for depencies with matplotlib (not available for 3.7.4))
module load Python/3.7.2-GCCcore-8.2.0
# Import SciPy bundle containing numpy
module load SciPy-bundle/2019.03-foss-2019a
# Import matplotlib
module load matplotlib/3.0.3-foss-2019a-Python-3.7.2
# Import seaborn
module load Seaborn/0.9.0-foss-2019a-Python-3.7.2

# Create RGChannelSet and/or cell proportions dataframe
if [[ $INPUT_FILE == *".csv"* ]]; then
	Rscript bin/load_csv.R $INPUT_FILE $OUT_FOLDER
elif [[ $INPUT_FILE == *"GSE"* ]]; then
	if [[ $INPUT_FILE == *".tar"* ]]; then
		Rscript bin/load_tar_idats.R $INPUT_FILE $OUT_FOLDER $PLATFORM
	else 
		Rscript bin/load_folder_idats.R $INPUT_FILE $OUT_FOLDER $PLATFORM
	fi
fi


# See README.txt if you want to modify those lines
if [ -f "tmp/rgSet" ] && [ -f "tmp/new_sample.csv" ]; then
	Rscript bin/IDs_gen.R tmp/new_sample.csv $OUT_FOLDER
	Rscript bin/QC_analysis.R tmp/rgSet $OUT_FOLDER $NORM_METH
	Rscript bin/PCA_plots.R tmp/new_sample.csv $OUT_FOLDER $FIRST_PCA $SECOND_PCA
	python bin/Hexbin.py tmp/PCA_res.csv tmp/PC_vect.csv $OUT_FOLDER
	Rscript bin/Distances.R tmp/series_matrix.csv $OUT_FOLDER
	Rscript bin/boxplot_comp.R data/bin/proportions_output.csv tmp/new_sample.csv $OUT_FOLDER
	Rscript bin/PCA_comp.R data/bin/proportions_output.csv tmp/new_sample.csv $OUT_FOLDER $FIRST_C_PCA $SECOND_C_PCA
	python bin/Hexbin_comp.py tmp/all_samples_comp.csv tmp/PCA_res_comp.csv tmp/PC_vect_comp.csv $OUT_FOLDER
	python bin/Violin.py tmp/new_sample.csv data/bin/proportions_output.csv $OUT_FOLDER
	python bin/divide_samples.py tmp/tr_series_matrix.csv data/bin/hg38_manifest.csv $OUT_FOLDER
	python bin/zscores.py tmp/tr_series_matrix.csv data/bin/hg38_manifest.csv $OUT_FOLDER
elif [ -f "tmp/new_sample.csv" ] && ! [ -f "tmp/rgSet" ]; then
	Rscript bin/boxplot_comp.R data/bin/proportions_output.csv tmp/new_sample.csv $OUT_FOLDER
	Rscript bin/PCA_comp.R data/bin/proportions_output.csv tmp/new_sample.csv $OUT_FOLDER
	python bin/Hexbin_comp.py tmp/all_samples_comp.csv tmp/PCA_res_comp.csv tmp/PC_vect_comp.csv $OUT_FOLDER
	python bin/Violin.py tmp/new_sample.csv data/bin/proportions_output.csv $OUT_FOLDER
	python bin/divide_samples.py tmp/series_matrix.csv data/bin/hg38_manifest.csv $OUT_FOLDER
	python bin/zscores.py tmp/series_matrix.csv data/bin/hg38_manifest.csv $OUT_FOLDER
else
	echo "An error occured: no files found"
fi

rm Rplots.pdf
