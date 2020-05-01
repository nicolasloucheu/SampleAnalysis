# Distances.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 30th April 2020
# Compute distances between samples distributions and plot a heatmap

library(philentropy)
library(gplots)
library(data.table)

args <- commandArgs()

#Import and formatting of beta-values
series_matrix <- as.data.frame(fread(args[6], header=TRUE))
out_folder <- args[7]
series_matrix <- na.omit(series_matrix)
IDs <- series_matrix$row_name
series_matrix$row_name <- NULL
series_matrix <- as.data.frame(series_matrix)

# Creating function to divide each sample beta-value distribution into 20 bins
sample_frequencies <- function(x){
  results_freq <- data.frame(row.names = rownames(x), 
                             bin1 = rep(0, as.numeric(length(x[,1]))), 
                             bin2 = rep(0, as.numeric(length(x[,1]))), 
                             bin3 = rep(0, as.numeric(length(x[,1]))), 
                             bin4 = rep(0, as.numeric(length(x[,1]))), 
                             bin5 = rep(0, as.numeric(length(x[,1]))), 
                             bin6 = rep(0, as.numeric(length(x[,1]))), 
                             bin7 = rep(0, as.numeric(length(x[,1]))),
                             bin8 = rep(0, as.numeric(length(x[,1]))), 
                             bin9 = rep(0, as.numeric(length(x[,1]))), 
                             bin10 = rep(0, as.numeric(length(x[,1]))),
                             bin11 = rep(0, as.numeric(length(x[,1]))), 
                             bin12 = rep(0, as.numeric(length(x[,1]))), 
                             bin13 = rep(0, as.numeric(length(x[,1]))),
                             bin14 = rep(0, as.numeric(length(x[,1]))), 
                             bin15 = rep(0, as.numeric(length(x[,1]))), 
                             bin16 = rep(0, as.numeric(length(x[,1]))), 
                             bin17 = rep(0, as.numeric(length(x[,1]))), 
                             bin18 = rep(0, as.numeric(length(x[,1]))), 
                             bin19 = rep(0, as.numeric(length(x[,1]))), 
                             bin20 = rep(0, as.numeric(length(x[,1]))))
  for ( a in 1:length(x[,1])){
    results_freq[a,] <- hist(as.numeric(x[a,]), breaks = 20)$counts
  }
  return(results_freq)
}

# Dividing each sample beta-value distribution into 20 bins
frequencies <- sample_frequencies(series_matrix)

# Computing the distance matrix from the bin frequencies for each sample
dist_mat <- distance(frequencies, method = "euclidean")
rownames(dist_mat) <- rownames(frequencies)
colnames(dist_mat) <- rownames(frequencies)

# Creating HeatMap and saving it
pdf(paste0(out_folder, "/07_HeatMap.pdf"))
heatmap.2(dist_mat, col = bluered(100), trace = "none", density.info = "none", main = "HeatMap")
dev.off()
