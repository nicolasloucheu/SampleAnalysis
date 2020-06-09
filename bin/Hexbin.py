# Hexbin.py
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 30th May 2020
# Creating Hexbin plot from PCA data

import sys
import numpy as np
import math
import matplotlib.pyplot as plt
import matplotlib.path as mplPath
import pandas as pd


# Import and format data
points = pd.read_csv(sys.argv[1], index_col = 0).drop(["sample_name"], axis=1)
PC_vect = pd.read_csv(sys.argv[2], index_col = 0)
PC_num = list(PC_vect['x'])[0:2]
PC_num = [int(x) for x in PC_num]
PC_0 = list(PC_vect['x'])[2:4]
PC_vect = list(map(lambda x: str(round(x*100, 2))+"%", PC_0))
out_folder = sys.argv[3]
color_map = plt.cm.viridis_r
x = list(points["cg.pcax"])
y = list(points["cg.pcay"])


# Defining limits of plot
xbnds = np.array([min(x)-abs(min(x))/2, max(x)+abs(max(x))/2])
ybnds = np.array([min(y)-abs(min(y))/2, max(y)+abs(max(y))/2])
bnds0 = min(xbnds[0], ybnds[0])
bnds1 = max(xbnds[1], ybnds[1])
extent = [bnds0, bnds1, bnds0, bnds1]
lenx = abs(xbnds[0]) + abs(xbnds[1])
leny = abs(ybnds[0]) + abs(ybnds[1])
fut_leny = (leny/lenx)*16

# Creating the plot
fig=plt.figure(figsize=(20,fut_leny))
plt.title("Hexbin Plot", fontsize = 15)
ax = fig.add_subplot(111)
# Set gridsize just to make them visually large
image = plt.hexbin(x, y, cmap=color_map, gridsize=13, extent=extent, mincnt=1, bins = 'log')
counts = image.get_array()
verts = image.get_offsets()
paths = image.get_paths()

for offc in range(verts.shape[0]):
	current_center = verts[offc]
	current_shape = mplPath.Path(paths[0].vertices + current_center)
	if counts[offc] == 1:
		for i in range(len(points)):
			if current_shape.contains_point((x[i], y[i])):
				plt.annotate(points.index[i], current_center, ha='center', va = 'center', fontsize = 13, color = "k")
	if counts[offc] == 2:
		to_plot = []
		for i in range(len(points)):
			if current_shape.contains_point((x[i], y[i])):
				to_plot.append(i)
		plt.annotate(points.index[to_plot[0]], (current_center[0], current_center[1]+(leny/55.9)), ha='center', va = 'center', fontsize = 13, color = "k")
		plt.annotate(points.index[to_plot[1]], (current_center[0], current_center[1]-(leny/55.9)), ha='center', va = 'center', fontsize = 13, color = "k")
ax.set_xlim(xbnds)
ax.set_ylim(ybnds)
ax.set_xlabel(f"PC{PC_num[0]} ({PC_vect[0]} explained var.)", fontsize = 13)
ax.set_ylabel(f"PC{PC_num[1]} ({PC_vect[1]} explained var.)", fontsize = 13)
plt.grid(alpha = 0.5)
cb = plt.colorbar(image, spacing='uniform', extend='max', format='%1.2f')
cb.update_ticks
fig.savefig(str(out_folder)+"/06_hexbin.pdf", bbox_inches="tight")
