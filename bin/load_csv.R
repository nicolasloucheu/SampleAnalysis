# load_csv.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 28th April 2020
# Load csv file so it can give it to the next steps

args <- commandArgs()
file_csv <- args[6]
out_folder <- args[7]

# Loading csv file
new_sample <- read.csv(file_csv, row.names = 1)

# Saving it for further analysis
write.csv(new_sample, "tmp/new_sample.csv")
write.csv(new_sample, paste0(out_folder, "/new_sample.csv"))
