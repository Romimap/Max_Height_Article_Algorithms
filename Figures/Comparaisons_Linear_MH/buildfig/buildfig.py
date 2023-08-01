import cv2 as cv
import numpy as np
import utils as ut
import os


def do(TEX1, TEX2):
    T1 = ut.load(f"tex/{TEX1}_T.png")
    T2 = ut.load(f"tex/{TEX2}_T.png")
    S1 = ut.load(f"tex/{TEX1}_S.png")
    S2 = ut.load(f"tex/{TEX2}_S.png")



    LIN = ut.load(f"batch/eq2_{TEX1}_{TEX2}.png")
    MAX = ut.load(f"batch/eq8_{TEX1}_{TEX2}.png")

    C = 1024
    W = C * 2
    L = 512
    H = L * 3

    OUT = np.zeros((H, W, 3))

    for x in range(W):
        for y in range(L):
            TEX = 0
            if x < C: TEX = T1 if x < y * 2 else S1
            else: TEX = T2 if (x - C) < y * 2 else S2
            
            for c in range(3):
                OUT[y, x, c] = TEX[y, x, c]

    for x in range(W):
        for y in range(L):
            for c in range(3):
                OUT[y + L, x, c] = LIN[y, x, c]
                OUT[y + L * 2, x, c] = MAX[y, x, c]


    for c in range(3):
        for x in range(W):
            for y in range(L - 2, L + 2):
                OUT[y, x, c] = 1
            for y in range(L * 2 - 2, L * 2 + 2):
                OUT[y, x, c] = 1

        for x in range(C - 2, C + 2):
            for y in range(L):
                OUT[y, x, c] = 1

    ut.save(f"batch/comparaison_{TEX1}_{TEX2}.png", OUT)