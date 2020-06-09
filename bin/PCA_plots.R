# PCA_plots.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 31st May 2020
# PCA plot with cg probes as variables

library(ggplot2)
library(data.table)
args <- commandArgs()

out_folder <- args[7]
PCA_X <- as.numeric(args[8])
PCA_Y <- as.numeric(args[9])

# Loading and transforming cell proportions data
new_sample <- fread(args[6], header=TRUE)
new_sample$V1 <- NULL
print(head(new_sample))

# Doing the PCA
cg.pca <- prcomp(new_sample, center = TRUE)

# Store the PCA data
cg.pcax <- cg.pca$x[,PCA_X]
cg.pcay <- cg.pca$x[,PCA_Y]
cg_PCA <- as.data.frame(cbind(cg.pcax, cg.pcay))
cg_PCA$sample_name <- rownames(new_sample)
write.csv(cg_PCA, file = "tmp/PCA_res.csv")

PC1 <- summary(cg.pca)$importance[(PCA_X*3)-1]
PC2 <- summary(cg.pca)$importance[(PCA_Y*3)-1]
PC_vect <- c(PCA_X, PCA_Y, PC1, PC2)
write.csv(PC_vect, file = "tmp/PC_vect.csv")

#Plot with index of samples
pdf(paste0(out_folder, "/05_PCA_index.pdf"))
ggplot(data = cg_PCA, aes(x = cg.pcax, y = cg.pcay)) + 
	geom_text(aes(label = rownames(cg_PCA))) +
	coord_fixed(ratio=1, xlim=range(cg_PCA$cg.pcax), ylim=range(cg_PCA$cg.pcay)) +
	theme(axis.text=element_text(size=10), axis.title=element_text(size=12,face="bold")) + 
	labs(title = "PCA plot", x = paste0("PC", PCA_X, ": ", round(PC1*100, 2), "%"), y = paste0("PC", PCA_Y, ": ", round(PC2*100, 2), "%"))
dev.off()
