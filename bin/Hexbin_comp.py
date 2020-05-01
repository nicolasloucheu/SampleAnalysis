# Hexbin_comp.py
# Author: Nicolas Loucheu - ULB (nicolas.loucheu@ulb.ac.be)
# Date: 1st May 2020
# Hexbin of PCA comparison

import sys
import numpy as np
import math
import matplotlib.pyplot as plt
import pandas as pd

points = pd.read_csv(sys.argv[1], index_col = 0)
control_points = pd.read_csv(sys.argv[2], index_col = 0)
# Choose colorscale
color_map = plt.cm.viridis_r

# Get coordinates from imports
x = list(points["pcax"])
y = list(points["pcay"])

# Get percentages of explained variance for each PC
PC_vect = pd.read_csv(sys.argv[3], index_col = 0)
PC_vect = list(map(lambda x: str(round(x*100, 2))+"%", list(PC_vect["x"])))

out_folder = sys.argv[4]

# Compute limits of axes
xbnds = np.array([min(x)-abs(min(x))/2, max(x)+abs(max(x))/2])
ybnds = np.array([min(y)-abs(min(y))/2, max(y)+abs(max(y))/2])
bnds0 = min(xbnds[0], ybnds[0])
bnds1 = max(xbnds[1], ybnds[1])
extent = [bnds0, bnds1, bnds0, bnds1]
lenx = abs(xbnds[0]) + abs(xbnds[1])
leny = abs(ybnds[0]) + abs(ybnds[1])
fut_leny = (leny/lenx)*16

# Plot the HexBin
fig=plt.figure(figsize=(20,fut_leny))
plt.title("Hexbin Plot showing control and new samples", fontsize = 15)
ax = fig.add_subplot(111)
# Set gridsize just to make them visually large
image = plt.hexbin(x,y,cmap=color_map,gridsize=13,extent=extent,mincnt=1, bins = 'log')
counts = image.get_array()
ncnts = np.count_nonzero(np.power(10,counts))
verts = image.get_offsets()
for offc in range(verts.shape[0]):
    binx,biny = verts[offc][0],verts[offc][1]
    # If only one sample lies in the hexagon, annotate with its name (red if new sample, black otherwise)
    if counts[offc] == 1:
        best_dist = float("inf")
        for i in range(len(points)):
            dist = math.hypot(x[i]-binx, y[i]-biny)
            if dist < best_dist:
                best_dist = dist
                best_index = i
        plt.annotate(points.index[best_index], (binx, biny), ha='center', va = 'center', fontsize = 13, color = "k" if points.index[best_index] in map(str, list(control_points.index)) else "r", 
                     weight = "normal" if points.index[best_index] in map(str, list(control_points.index)) else "bold")
    # If two samples lie in the hexagon, annotate with their names (red if new sample, black otherwise)
    if counts[offc] == 2:
        best_dist = float("inf")
        best_index = []
        for i in range(len(points)):
            dist = math.hypot(x[i]-binx, y[i]-biny)
            if dist < best_dist:
                best_dist = dist
                best_index.append(i)
        plt.annotate(points.index[best_index[-1]], (binx, biny+(leny/55.9)), ha='center', va = 'center', fontsize = 13, 
                     color = "k" if points.index[best_index[-1]] in map(str, list(control_points.index)) else "r", 
                     weight = "normal" if points.index[best_index[-1]] in map(str, list(control_points.index)) else "bold") 
        plt.annotate(points.index[best_index[-2]], (binx, biny-(leny/55.9)), ha='center', va = 'center', fontsize = 13, 
                     color = "k" if points.index[best_index[-2]] in map(str, list(control_points.index)) else "r", 
                     weight = "normal" if points.index[best_index[-2]] in map(str, list(control_points.index)) else "bold") 
ax.set_xlim(xbnds)
ax.set_ylim(ybnds)
ax.set_xlabel(f"standardized PC1 ({PC_vect[0]} explained var.)", fontsize = 13)
ax.set_ylabel(f"standardized PC2 ({PC_vect[1]} explained var.)", fontsize = 13)
plt.grid(alpha = 0.5)
cb = plt.colorbar(image, spacing='uniform', extend='max', format='%.0f')
fig.savefig(str(out_folder)+"/10_hexbin_comp.pdf", bbox_inches="tight")
