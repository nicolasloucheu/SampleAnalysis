# IDs_gen.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 28th April 2020
# Generate a csv file linking the sample name with the IDs shown in figures
args <- commandArgs()

new_sample <- read.csv(args[6], row.names = 1)
out_folder <- args[7]

#Getting IDs from cell proportions file
IDs <- rownames(new_sample)
IDs_index <- c(1:length(IDs))

#Making a dataframe with IDs and Sample names
linkin <- data.frame(IDs, IDs_index)

# Saving that dataframe
write.csv(linkin, paste0(out_folder, "/link_IDs.csv"))
