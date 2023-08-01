import cv2 as cv
import numpy as np
import utils as ut
import sys
import time
from tqdm import tqdm

start = time.time()


def do(TEX1, TEX2):
    T1 = ut.load(f"tex/{TEX1}_T.png")
    T2 = ut.load(f"tex/{TEX2}_T.png")

    V1 = np.zeros(T1.shape)
    V2 = np.zeros(T1.shape)
    for y in tqdm(range(V1.shape[0]), desc="V map"):
        for x in range(V1.shape[1]):
            v2 = x / (T1.shape[1] - 1.0)
            v1 = 1.0 - v2
            for c in range(V1.shape[2]):
                V1[y, x, c] = v1
                V2[y, x, c] = v2



    for i in range(8):
        L = ut.add(ut.mul(T1, V1), ut.mul(T2, V2))
        ut.save(f"batch/eq2_{TEX1}_{TEX2}.png", L)

        return

        ut.save(f"eq18_T_mipmap{i}.png", T)
        print("T done")