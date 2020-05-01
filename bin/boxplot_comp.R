# boxplot_comp.R
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Generate graph of comparison between new samples and controls (on cell proportions) and returns a table with significant differences

library(ggplot2)
library(reshape2)

args <- commandArgs()
out_folder <- args[8]
new_sample <- read.csv(args[7], row.names = 1)
props <- read.csv(args[6], row.names = 1)

# Add column with group
props$group <- "control"
new_sample$group <- "new samples"
# Bind both datasets
props.an <- rbind(props, new_sample)
props.an$group <- as.factor(props.an$group)

# Compute boxplot results
bx_df <- melt(props.an, id.vars = "group", 
              measure.vars = c("counts.CD8T", "counts.CD4T", "counts.NK", "counts.Bcell", "counts.Mono", "counts.Neu"))


# Compute multiple student tests
x <- tryCatch(
  {
    data.frame(p.value= sapply(props.an[,2:6], function(i) t.test(i ~ props.an$group)$p.value))
  },
  error=function(cond) {
    message("Error message:")
    message(cond)
    # Choose a return value in case of error
    return("error")
  }
)

# Write the significant t-tests in a dataframe and save it
if (x != "error"){
  x$cell_type <- rownames(x)
  rownames(x) <- NULL
  significant <- x[x$p.value < 0.05,]
}
write.csv(significant, paste0(out_folder, "/significant.csv"))

# Plot the boxplot and save it
pdf(paste0(out_folder, "/08_boxplot_comp.pdf"))
ggplot(data = bx_df, aes(x=variable, y=value)) + geom_boxplot(aes(fill=group)) +
  labs(fill = "", x = "Cell type", y = "Proportion (%)", title = "Boxplot comparison (control vs new samples)") +
  theme(legend.title = element_text(size = 12), 
        legend.text = element_text(size = 10),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 12),
        legend.position="top") + 
  scale_fill_manual(values=c("#d2f0f2", "#cf2a28"))
dev.off()
