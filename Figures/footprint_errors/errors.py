import utils as ut
import numpy as np
import cv2 as cv
from tqdm import tqdm
from math import sqrt


def norm (a):
    s = 0
    for i in range(len(a)):
        s += a[i]**2
    return sqrt(s)

def remap (OldValue, OldMin, OldMax, NewMin, NewMax):
    OldRange = (OldMax - OldMin)  
    NewRange = (NewMax - NewMin)  
    NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
    return NewValue


def viridis (t):
    colorgradient = [
        [68, 1, 84,     0.000],
        [59, 82, 139,   0.025],
        [33, 145, 140,  0.050],
        [94, 201, 98,   0.075],
        [253, 231, 37,  0.100],
        [255, 128, 0,   0.250],
        [255, 0, 0,     0.500],
        [255, 255, 255, 1.000]
    ]
    for i in range(len(colorgradient)):
        for c in range(3):
            colorgradient[i][c] /= 255.0

    id = 0
    interp = 0.0
    for i in range(len(colorgradient)):
        if t < colorgradient[i][3]:
            id = i
            interp = remap(t, colorgradient[id - 1][3], colorgradient[id][3], 0.0, 1.0)
            break
    
    color = (
        colorgradient[id - 1][2] * (1.0 - interp) + colorgradient[id][2] * interp,
        colorgradient[id - 1][1] * (1.0 - interp) + colorgradient[id][1] * interp,
        colorgradient[id - 1][0] * (1.0 - interp) + colorgradient[id][0] * interp
    )

    return color

def do(TEX1, TEX2):
    for i in {0, 2, 4, 6}:
        EQ4 = ut.load(f"batch/eq4_{TEX1}_{TEX2}_mipmap{i}.png")
        EQ8 = ut.load(f"batch/eq8_{TEX1}_{TEX2}_mipmap{i}.png")

        AERR = np.zeros(EQ4.shape)
        RERR = np.zeros(EQ4.shape)

        for y in tqdm(range(AERR.shape[0]), desc=f"error mip {i}"):
            for x in range(AERR.shape[1]):
                ab = [] # a - b
                b = [] # b

                for c in range(EQ4.shape[2]):
                    ab.append(EQ8[y, x, c] - EQ4[y, x, c])
                    b.append(EQ4[y, x, c])

                absolute = norm(ab)
                relative = norm(ab) / norm(b)

                absolute /= sqrt(3) # 0 to 1 absolute error

                acolor = viridis(absolute)
                for c in range(EQ4.shape[2]):
                    AERR[y, x, c] = acolor[c]
                
                rcolor = viridis(relative)
                for c in range(EQ4.shape[2]):
                    RERR[y, x, c] = rcolor[c]
        
        ut.save(f"batch/abserr_{TEX1}_{TEX2}_mipmap{i}.png", AERR)
        ut.save(f"batch/relerr_{TEX1}_{TEX2}_mipmap{i}.png", RERR)

def colormap ():
    CMAP = np.zeros([64, 2048, 3])
    for y in tqdm(range(CMAP.shape[0]), desc=f"cmap"):
        for x in range(CMAP.shape[1]):
            t = x / (CMAP.shape[1] - 1)
            col = viridis(t)
            for c in range(CMAP.shape[2]):
                CMAP[y, x, c] = col[c]
                if (y + 5) % 8 < 2:
                    if x == 1024: CMAP[y, x, c] = 0
                    if x == 512: CMAP[y, x, c] = 0
                    if x == 204: CMAP[y, x, c] = 0
                    if x == 102: CMAP[y, x, c] = 0

    ut.save("colormap.png", CMAP)

colormap()
                


