# PCA_comp.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 8th June 2020
# Generate PCA predictions of new samples on the PCA graph from the control samples (from cell proportions)

library(ggplot2)

args <- commandArgs()
props <- read.csv(args[6], row.names = 1)
new_sample <- read.csv(args[7], row.names = 1)
rownames(props) <- NULL
out_folder <- args[8]
PCA_X <- as.numeric(args[9])
PCA_Y <- as.numeric(args[10])

# Compute PCA on controls
props.pca <- prcomp(props, center=TRUE, scale.=TRUE)
print(props)
print(summary(props.pca)$importance)

# Save coordinates
pcax <- props.pca$x[,PCA_X]
pcay <- props.pca$x[,PCA_Y]
PCA_res <- as.data.frame(cbind(pcax, pcay))
rownames(PCA_res) <- c(1:689)

# Make the prediction of coordinates for new samples
pred <- predict(props.pca, newdata = new_sample)
pred <- as.data.frame(pred)
rownames(pred) <- paste0("NEW_", c(1:length(pred$PC1)))


# Save the coordinates of the PCA and the percentages of explained variance for each PC (PC_vect)
predicted <- data.frame(pcax=pred$PC1, pcay=pred$PC2)
rownames(predicted) <- rownames(pred)
all_samples <- rbind(PCA_res, predicted)
PC1 <- summary(props.pca)$importance[(PCA_X*3)-1]
PC2 <- summary(props.pca)$importance[(PCA_Y*3)-1]
PC_vect <- c(PCA_X, PCA_Y, PC1, PC2)

write.csv(PC_vect, "tmp/PC_vect_comp.csv")
write.csv(all_samples, "tmp/all_samples_comp.csv")
write.csv(PCA_res, "tmp/PCA_res_comp.csv")


#Plot with index of samples
pdf(paste0(out_folder, "/09_PCA_comp.pdf"))
ggplot(data = PCA_res, aes(x = pcax, y = pcay)) + 
	geom_text(aes(label = rownames(PCA_res))) +
	geom_text(data = predicted, mapping = aes(x=pcax, y=pcay), label = rownames(predicted), colour="red", vjust = "inward", hjust = "inward", size = 2.5) +
	coord_fixed(ratio=1, xlim=range(pcax), ylim=range(pcay)) +
	theme(axis.text=element_text(size=10), axis.title=element_text(size=12,face="bold")) + 
	labs(title = "PCA plot", x = paste0("PC", PCA_X,": ", round(PC1*100, 2), "%"), y = paste0("PC", PCA_Y,": ", round(PC2*100, 2), "%"))
dev.off()
