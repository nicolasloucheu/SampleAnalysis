# PCA_plots.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 31st May 2020
# PCA plot with cg probes as variables

library(ggplot2)
library(data.table)
args <- commandArgs()

out_folder <- args[7]

# Loading and transforming beta-values data
series_matrix <- fread(args[6], header=TRUE)
series_matrix <- na.omit(series_matrix)
IDs <- series_matrix$row_name
rownames(series_matrix) <- IDs
series_matrix$row_name <- NULL

# Doing the PCA
cg.pca <- prcomp(series_matrix, center = TRUE)

# Store the PCA data
cg.pcax <- cg.pca$x[,1]
cg.pcay <- cg.pca$x[,2]
cg_PCA <- as.data.frame(cbind(cg.pcax, cg.pcay))
cg_PCA$sample_name <- rownames(series_matrix)
write.csv(cg_PCA, file = "tmp/PCA_res.csv")

PC1 <- summary(cg.pca)$importance[2]
PC2 <- summary(cg.pca)$importance[5]
PC_vect <- c(PC1, PC2)
write.csv(PC_vect, file = "tmp/PC_vect.csv")


rownames(series_matrix) <- NULL

#Plot with index of samples
pdf(paste0(out_folder, "/05_PCA_index.pdf"))
ggplot(data = cg_PCA, aes(x = cg.pcax, y = cg.pcay)) + 
	geom_text(aes(label = rownames(cg_PCA))) +
	coord_fixed(ratio=1, xlim=range(cg_PCA$cg.pcax), ylim=range(cg_PCA$cg.pcay)) +
	theme(axis.text=element_text(size=10), axis.title=element_text(size=12,face="bold")) + 
	labs(title = "PCA plot", x = paste0("PC1: ", round(PC1*100, 2), "%"), y = paste0("PC2: ", round(PC2*100, 2), "%"))
dev.off()
