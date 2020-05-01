# Violin.py
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Compute a semi_violin / Boxplot graph comparing cell proportions of controls vs new samples

import sys
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

out_folder = sys.argv[3]

# Importing new samples cell proportions
new_sample = pd.read_csv(sys.argv[1], index_col = 0)
new_sample.index = ["NEW_" + str(x) for x in range(1, len(new_sample)+1)]
new_sample = new_sample.stack().reset_index().rename(columns={"level_0": "ID", "level_1": "cell_type", 0: "value"})
new_sample["group"] = "New samples"

# Importing controls cell proportions
props = pd.read_csv(sys.argv[2], index_col = 0)
props.index = [str(x) for x in range(1, len(props)+1)]
props = props.stack().reset_index().rename(columns={"level_0": "ID", "level_1": "cell_type", 0: "value"})
props["group"] = "Controls"

# Combine the two dataframes
df = props.append(new_sample)

# Save the dataframes
props.to_csv("tmp/props_full.csv")
new_sample.to_csv("tmp/new_sample_full.csv")

# Make the plot and save it
plt.figure(figsize=(16, 10))
sns.set(style="whitegrid", palette="pastel", color_codes=True)
sns.violinplot(x="cell_type", y="value", hue="group", inner="quart", split=True,
               palette={"Controls": "b", "New samples": "r"},
               data=df, legend=False)
ax = sns.boxplot(x="cell_type", y="value", hue="group", width = 0.5,
               palette={"Controls": "b", "New samples": "r"},
               data=df)
handles, labels = ax.get_legend_handles_labels()
l = plt.legend(handles[0:2], labels[0:2], loc="upper left")
ax.set_ylabel("Proportion (%)", fontsize = 13)
ax.set_xlabel("Cell type", fontsize = 13)
ax.set_title("Violin Plot", fontsize = 15)
fig = ax.get_figure()
fig.savefig(str(out_folder)+"/11_Violin.pdf", bbox_inches="tight")
