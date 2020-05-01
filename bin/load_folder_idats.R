# load_folder_idats.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 28th April 2020
# Load idats from a folder full of idats and transform it into rgChannelSet and new_sample.csv which is the result of the deconvolution

library(minfi)
library(FlowSorted.Blood.EPIC)

args <- commandArgs()
folder <- args[6]
out_folder <- args[7]
platform <- args[8]

# Get RGChannelSet object from idat raw files
if ("/idat" %in% folder){
	rgSet <- read.metharray.exp(folder)
} else {
	rgSet <- read.metharray.exp(paste0(folder, "/idat"))
}


# From this RGChannelSet, get the cell proportions (code depends on platform)
if (platform == 'epic'){
	new_sample <- estimateCellCounts2(rgSet, referencePlatform="IlluminaHumanMethylationEPIC")
} else {
	new_sample <- estimateCellCounts2(rgSet, referencePlatform="IlluminaHumanMethylation450k")
}

# Save these objects
write.csv(new_sample, "tmp/new_sample.csv")
write.csv(new_sample, paste0(out_folder, "/new_sample.csv"))
saveRDS(rgSet, file = "tmp/rgSet")
