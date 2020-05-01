# zscores.py
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Computes the Z-score at each probe for each sample

import pandas as pd
import pickle
import sys

out_folder = sys.argv[3]

#Importing beta-values
series_sample = pd.read_csv(sys.argv[1], index_col="cg_name").transpose().drop(["row_name"], axis=1).apply(pd.to_numeric) 

# Importing manifest (probes locations)
fields = ["IlmnID", "CHR", "MAPINFO"]
dtype_chr = {'CHR': 'str'}
manifest = pd.read_csv(sys.argv[2], usecols=fields, index_col=0, dtype=dtype_chr)

chrom_lst = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "X", "Y"]

# Get samples names and create a dataframe for each sample
samples = series_sample.index.to_list()
for i in samples:
	foo = f"top_z_{i}"
	exec(foo + f" = pd.DataFrame(columns=['{i}', 'CHR', 'MAPINFO'])")


# For each chromosome, get the beta-values of the controls and compute the z-score with the samples. 
# Save those scores by chromosome and save a list of postions with z-score greater than 5.
for i in chrom_lst:
	series_controls = pd.read_csv(f"data/bin/chrom_means/chrom_{i}_means.csv.gz", compression="gzip", usecols=[0, 2, 3], index_col=0).transpose()
	cols_tokeep = series_controls.columns
	new_ss = series_sample.loc[:, cols_tokeep]
	z_scores = (abs(new_ss-series_controls.loc['MEAN'])/series_controls.loc['STD']).transpose()
	for j in range(len(series_sample)):
		z_total = z_scores.iloc[:, j].to_frame()
		z_total_mapped = z_total.join(manifest)
		top_z = z_total_mapped.loc[z_total_mapped[z_total_mapped.columns[0]] > 5]
		z_total_mapped.to_csv(f'{out_folder}/{z_total_mapped.columns[0]}/{z_total_mapped.columns[0]}_z_{i}.csv.gz', compression='gzip')
		with open(f"{out_folder}/{z_total_mapped.columns[0]}/{z_total_mapped.columns[0]}_index_{i}.txt", "wb") as fp:
			pickle.dump(z_total_mapped.MAPINFO.to_list(), fp)
		exec(f"top_z_{z_total_mapped.columns[0]} = top_z_{z_total_mapped.columns[0]}.append(z_total_mapped)")

# Assemble all the probes having a z-score greater than 5, for each sample and save that list in a dataframe.
for i in samples:
	exec(f"top_z_{i}_final = top_z_{i}.loc[top_z_{i}['{i}'] > 5].sort_values(by='{i}', axis=0, ascending=False)")
	exec(f"top_z_{i}_final.to_csv('{out_folder}/{i}/top_z_scores.csv.gz', compression='gzip')")
	exec(f"mean_z_{i} = top_z_{i}.iloc[:,0].mean()")
	with open(f"{out_folder}/{i}/z_score_mean.pickle", "wb") as fp:
		exec(f"pickle.dump(mean_z_{i}, fp)")


