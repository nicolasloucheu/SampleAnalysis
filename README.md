# Sample_Analysis v0.02
#### Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
#### Date: 1st May 2020


The script executes some subscripts that generates graphs and data files needed for the report about the quality of Illumina Methylation 450k or EPIC blood samples based on their cellular proportions.

## HOW TO USE IT

In the bash pipeline file, modify the fileds between "Modify those lines" and "Stop modifying". Set the "INPUT_FILE" variable name either to the .tar file containing the idats, the folder containing an idat folder with idats files, or a csv file with the cellular proportions of each sample.  
Also , you have to specify the platform used by changing the "PLATFORM" variable either to "450k" or "epic".  
You can also specify the normalization method used by specifying either "FunNorm" or "Quantiles for respectively functional normalization or quantile normalization.

## DATA AVAILABLE

In the data folder are two directories with idat files. GSE110554_RAW contains EPIC data (Whole-blood from GSE110554) and GSETEST contains 450k data (Whole-blood samples from GSE88824).

## REQUIREMENTS

This pipeline requires R and Python.

The library used in R are :  
1 - minfi  
2 - ggbiplot  
3 - data.table  
4 - philentropy  
5 - gplots  
6 - ggplot2  
7 - reshape2  
8 - GEOquery  
9 - FlowSorted.Blood.EPIC  
10 - ENmix  

The modules used in Python are :  
1 - sys  
2 - numpy  
3 - math  
4 - matplotlib  
5 - pandas  
6 - seaborn  
7 - os  
8 - pickle  

## SUBSCRIPTS

#### 01 - load_csv.R

Packages : None  
Other scripts required : None  
Names of file(s) generated : tmp/new_sample.csv + "output"/new_sample.csv

Loads CSV file containing cellular proportions of the samples

#### 02 - load_tar_idats.R

Packages : requires R packages 1;9  
Other scripts required : None  
Names of file(s) generated : tmp/new_sample.csv + "output"/new_sample.csv + tmp/rgSet

Loads TAR file containing idats of samples, and convert it to a RGChannelSet object (contains information about methylation at each site) and a dataframe with the cellular proportions of each sample

#### 03 - load_folder_idats.R 

Packages : requires packages 1;8-9  
Other scripts required : None  
Names of file(s) generated : tmp/new_sample.csv + "output"/new_sample.csv + tmp/rgSet

Loads a folder containing a folder named "idats" which contains the idats files of samples. Converts it to a RGChannelSet (contains information about methylation at each site) and a dataframe with the cellular proportions of each sample

#### 04 - IDs_gen.R

Packages : None  
Other scripts required : (Either 01, 02 or 03)  
Names of file(s) generated : "output"/link_IDs.csv

Generates a link between the name of samples and the ID displayed in graphs

#### 05 - QC_analysis.R 

Packages : requires R packages 1-3;10  
Other scripts required : (Either 02 or 03)  
Names of file(s) generated : "output"/01_QCplot.pdf + "output"/02_DensityPlot.pdf + "output"/03_DensityBeanPlot.pdf + "output"/04_qcReport.pdf + tmp/series_matrix.csv +
tmp/tr_series_matrix.csv

Generates graphs of quality check and a file containing the beta-values of each sample at each site

#### 06 - PCA_plots.R 

Packages : requires R packages 2-3  
Other scripts required : 05  
Names of file(s) generated : tmp/PCA_res.csv + tmp/PC_vect.csv + "output"/05_PCA_index.pdf

Generates a PCA plot of the samples to be analysed

#### 07 - Hexbin.py

Packages : requires Python modules 1-5  
Other scripts required : 06  
Names of file(s) generated : "output"/06_hexbin.pdf

Generates a Hexbin plot from the PCA results

#### 08 - Distances.R

Packages : requires R packages 3-5  
Other scripts required : 05  
Names of file(s) generated :  "output"/07_HeatMap.pdf

Generates a HeatMap of the distances of the distribution of the samples

#### 09 - boxplot_comp.R

Packages : requires R packages 6-7  
Other scripts required : (Either 01, 02 or 03)  
Names of file(s) generated : "output"/significant.csv + "output"/08_boxplot_comp.pdf

Generates a boxplot comparison between samples and controls

#### 10 - PCA_comp.R

Packages : requires R package 2  
Other scripts required : (Either 01, 02 or 03)  
Names of file(s) generated : "output"/09_PCA_comp.pdf + tmp/PC_vect_comp.csv + tmp/all_samples_comp.csv + tmp/PCA_res_comp.csv

Generates a PCA plot from the controls with the prediction of the new samples added to it

#### 11 - Hexbin_comp.py

Packages : requires Python modules 1-5  
Other scripts required : 10  
Names of file(s) generated : "output"/10_hexbin_comp.pdf

Generates the HexBin plot from the PCA conducted on script 10

#### 12 - Violin.py

Packages : requires Python modules 1;4-6  
Other scripts required : (Either 01, 02 or 03)  
Names of file(s) generated : tmp/props_full.csv + tmp/new_sample_full.csv + "output"/11_Violin.pdf

Generates a violin/boxplot comparison between samples and controls (similar to script 09)

#### 13 - divide_samples.py

Packages : requires Python modules 1, 5, 7, 8  
Other scripts required : 05  
Names of file(s) generated : "output"/"sample"/"sample"_chrom_"chromosome".csv.gz (beta-values) + "output"/"sample"/"sample"_chrom_"chromosome"_lst.txt (indexes)

Generates a csv file with beta-values for each chromosome for each sample + files containing indexes of positions (pickle)

#### 14 - zscores.py

Packages : requires Python modules 1, 5, 8  
Other scripts required : 05  
Names of file(s) generated : "output"/"sample"/"sample"_z_"chromosome".csv.gz (z-scores) + "output"/"sample"/"sample"_index_"chromosome".txt (z-scores indexes) + "output"/"sample"/top_z_score.csv.gz (list of z-scores greater than 5) + "output"/"sample"/z_score_mean.pickle (mean of z-scores for the sample)

Generate csv files containing z-scores for each sample for each chromosome + csv file containing all the probes with a z-score greater than 5 + mean of z-scores for each sample



## OUTPUT

The name of the output is generated as folows : "Name of input file/folder"_"date(YYYYMMDD)"_"time(HHMM)"  
This folder contains all the graphs  
This folder contains one folder per sample containing information necessary for the visualization tool  
