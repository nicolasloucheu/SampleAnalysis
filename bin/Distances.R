# Distances.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 9th June 2020
# Compute distances between samples distributions and plot a heatmap

library(philentropy)
library(gplots)
library(data.table)

args <- commandArgs()

#Import and formatting of beta-values
m_matrix <- as.data.frame(fread(args[6], header=TRUE))
rownames(m_matrix) <- m_matrix$cg_name
m_matrix$cg_name <- NULL
m_matrix <- do.call(data.frame, lapply(m_matrix, function(x) replace(x, is.infinite(x),0)))
colnames(m_matrix) <- c(1:length(m_matrix))

out_folder <- args[7]

cor_matrix <- cor(m_matrix)

# Creating HeatMap and saving it
pdf(paste0(out_folder, "/07_HeatMap.pdf"), width=20, height=20)
heatmap.2(cor_matrix, col = bluered(100), trace = "none", density.info = "none", main = "HeatMap", keysize=1, key.par = list(cex=1.5))
dev.off()
