# PCA_comp.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Generate PCA predictions of new samples on the PCA graph from the control samples (from cell proportions)

library(ggbiplot)

args <- commandArgs()
props <- read.csv(args[6], row.names = 1)
new_sample <- read.csv(args[7], row.names = 1)
rownames(props) <- NULL
out_folder <- args[8]

# Compute PCA on controls
props.pca <- prcomp(props, center=TRUE, scale.=TRUE)

# Save coordinates
pcax <- props.pca$x[,1]
pcay <- props.pca$x[,2]
PCA_res <- as.data.frame(cbind(pcax, pcay))
rownames(PCA_res) <- c(1:689)

# Make the prediction of coordinates for new samples
pred <- predict(props.pca, newdata = new_sample)
pred <- as.data.frame(pred)
rownames(pred) <- paste0("NEW_", c(1:length(pred$PC1)))

# Plot the PCA
pdf(paste0(out_folder, "/09_PCA_comp.pdf"))
ggbiplot(props.pca, 
         labels=rownames(props),
         var.axes = FALSE) + 
  theme(axis.text=element_text(size=10), 
        axis.title=element_text(size=12,face="bold")) + 
  labs(title = "PCA plot") +
  geom_text(data = pred, 
            mapping = aes(x=pred[,1], y=pred[,2]), 
            label = rownames(pred), 
            colour="red", 
            vjust = "inward", 
            hjust = "inward", 
            size = 2.5) + 
  xlim(min(-7, min(pred$PC1)), 
       max(4, max(pred$PC1))) + 
  ylim(min(-6.5, min(pred$PC2)), 
       max(4.25, max(pred$PC2)))
dev.off()

# Save the coordinates of the PCA and the percentages of explained variance for each PC (PC_vect)
predicted <- data.frame(pcax=pred$PC1, pcay=pred$PC2)
rownames(predicted) <- rownames(pred)
all_samples <- rbind(PCA_res, predicted)
PC1 <- summary(props.pca)$importance[2]
PC2 <- summary(props.pca)$importance[5]
PC_vect <- c(PC1, PC2)
write.csv(PC_vect, "tmp/PC_vect_comp.csv")
write.csv(all_samples, "tmp/all_samples_comp.csv")
write.csv(PCA_res, "tmp/PCA_res_comp.csv")
