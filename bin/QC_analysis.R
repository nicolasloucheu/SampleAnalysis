# QC_analysis.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 28th April 2020
# Preprocessing and display first 3 QC graphs

library(ENmix)
library(minfi)
library(ggbiplot)
library(data.table)

args <- commandArgs()

rgSet <- readRDS(args[6])
out_folder <- args[7]

# Preprocessing (MethylSet must be used for plotQC and 
# densityPlot while RGChannelSet can be used for 
# densityBeanPlot and further analysis)
MSet <- preprocessRaw(rgSet)

GRSet <- preprocessFunnorm(rgSet)
series_matrix <- data.frame(t(getBeta(GRSet)))
series_matrix$row_name <- rownames(series_matrix)
transposed_sm <- as.data.frame(t(series_matrix))
transposed_sm$cg_name <- rownames(transposed_sm)

# Making 3 QC plots
qc <- getQC(MSet)
pdf(paste0(out_folder, "/01_QCplot.pdf"))
plotQC(qc)
dev.off()

pdf(paste0(out_folder, "/02_DensityPlot.pdf"))
densityPlot(MSet)
dev.off()

pdf(paste0(out_folder, "/03_DensityBeanPlot.pdf"))
densityBeanPlot(rgSet)
dev.off()

# Saving series_matrix (beta-values)
fwrite(series_matrix, "tmp/series_matrix.csv")
fwrite(transposed_sm, "tmp/tr_series_matrix.csv")
