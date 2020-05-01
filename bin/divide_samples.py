# divide_samples.py
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Dividing the beta-values of samples by chromosome to facilitate import in visualization tool

import os
import pandas as pd
import sys
import pickle

out_folder = sys.argv[3]
series_matrix = pd.read_csv(sys.argv[1], index_col="cg_name", nrows=1)
# Get sample names
colnames = list(series_matrix.columns)

# Import manifest (locations of probes in genome)
fields = ["IlmnID", "CHR", "MAPINFO"]
dtype_chr = {'CHR': 'str'}
manifest = pd.read_csv(sys.argv[2], usecols=fields, index_col=0, dtype=dtype_chr)

# Get a list of chromosomes
chrom = list(manifest.CHR.unique())
tmp = chrom.pop()

# For each sample, import beta-values, merge with manifest, divide by chromosomes and save it with an index file (pickle)
for i in range(len(colnames)):
    divided_bv = pd.read_csv(sys.argv[1], index_col="cg_name", usecols=["cg_name", colnames[i]]).drop(["row_name"], axis=0).apply(pd.to_numeric)
    tmp_df = divided_bv.join(manifest)
    if not os.path.exists(f"{out_folder}/{colnames[i]}"):
        os.mkdir(f"{out_folder}/{colnames[i]}")
    for j in range(len(chrom)):
        col_lst = []
        foo = f"{colnames[i]}_chrom_{str(chrom[j])}"
        exec(foo + " = pd.DataFrame(columns=[colnames[i]])")
        exec(f"{foo} = tmp_df.loc[tmp_df['CHR'] == chrom[j]]")
        exec(f"{foo} = {foo}.sort_values(by=['MAPINFO'])")
        exec(f"{foo}.to_csv('{out_folder}/{colnames[i]}/{foo}.csv.gz', compression='gzip')")
        with open(f"{out_folder}/{colnames[i]}/{foo}_lst.txt", 'wb') as fp:
            exec(f"pickle.dump(list({foo}['MAPINFO']), fp)")
