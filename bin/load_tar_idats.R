# load_tar_idats.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 28th April 2020
# Load idats from a folder full of idats and transform it into rgChannelSet and new_sample.csv which is the result of the deconvolution

library(GEOquery)
library(minfi)
library(FlowSorted.Blood.EPIC)

args <- commandArgs()
file_tar <- args[6]
out_folder <- args[7]
platform <- args[8]

# Untar the tar file
untar_dir <- paste0(tools::file_path_sans_ext(file_tar), "/idat")
untar(file_tar, exdir = untar_dir)
idatFiles <- list.files(untar_dir, pattern = "idat.gz*", full = TRUE)
sapply(idatFiles, gunzip, overwrite = TRUE)

# Get RGChannelSet object from idat raw files
rgSet <- read.metharray.exp(untar_dir)

# From this RGChannelSet, get the cell proportions (code depends on platform)
if (platform == "epic"){
	new_sample <- estimateCellCounts2(rgSet, referencePlatform="IlluminaHumanMethylationEPIC")
} else {
	new_sample <- estimateCellCounts2(rgSet, referencePlatform="IlluminaHumanMethylation450k")
}

# Save these objects
write.csv(new_sample, "tmp/new_sample.csv")
write.csv(new_sample, paste0(out_folder, "/new_sample.csv"))
save(rgSet, file = "tmp/rgSet")
