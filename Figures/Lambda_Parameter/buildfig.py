import cv2 as cv
import numpy as np
import utils as ut
import os


def do(TEX1, TEX2):
    MAX0 = ut.load(f"batch/eq8_{TEX1}_{TEX2}_0.png")
    MAX1 = ut.load(f"batch/eq8_{TEX1}_{TEX2}_1.png")
    MAX2 = ut.load(f"batch/eq8_{TEX1}_{TEX2}_2.png")
    MAX3 = ut.load(f"batch/eq8_{TEX1}_{TEX2}_3.png")

    W = 2048
    L = 512
    H = L * 4

    OUT = np.zeros((H, W, 3))

   
    for x in range(W):
        for y in range(L):
            for c in range(3):
                OUT[y, x, c] = MAX0[y, x, c]
                OUT[y + L, x, c] = MAX1[y, x, c]
                OUT[y + L * 2, x, c] = MAX2[y, x, c]
                OUT[y + L * 3, x, c] = MAX3[y, x, c]


    for c in range(3):
        for x in range(W):
            for y in range(L - 2, L + 2):
                OUT[y, x, c] = 1
            for y in range(L * 2 - 2, L * 2 + 2):
                OUT[y, x, c] = 1
            for y in range(L * 3 - 2, L * 3 + 2):
                OUT[y, x, c] = 1

    ut.save(f"batch/lambda_{TEX1}_{TEX2}.png", OUT)