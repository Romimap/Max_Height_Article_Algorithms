import cv2 as cv
import numpy as np
import utils as ut
from tqdm import tqdm


def do(TEX1, TEX2):
    T1 = ut.cut(ut.load(f"tex/{TEX1}_T.png"), 0, 1024, 0, 1024)
    T2 = ut.cut(ut.load(f"tex/{TEX2}_T.png"), 0, 1024, 0, 1024)
    S1 = ut.cut(ut.load(f"tex/{TEX1}_S.png"), 0, 1024, 0, 1024)
    S2 = ut.cut(ut.load(f"tex/{TEX2}_S.png"), 0, 1024, 0, 1024)
    S1 = ut.offset(S1, -ut.mean(S1)[0])
    S2 = ut.offset(S2, -ut.mean(S2)[0])

    V1 = np.zeros(T1.shape)
    V2 = np.zeros(T1.shape)
    for y in tqdm(range(V1.shape[0]), desc="V map"):
        for x in range(V1.shape[1]):
            v2 = 0.5
            v1 = 1.0 - v2
            for c in range(V1.shape[2]):
                V1[y, x, c] = v1
                V2[y, x, c] = v2

    for i in tqdm([0, 2, 4, 6], desc="processing mip map levels"):
        TM1 = ut.mipmap(T1, i)
        TM2 = ut.mipmap(T2, i)
        SM1 = ut.mipmap(S1, i)
        SM2 = ut.mipmap(S2, i)
        VM1 = ut.mipmap(V1, i)
        VM2 = ut.mipmap(V2, i)

        T = np.zeros(TM1.shape)

        for y in tqdm(range(T.shape[0]), desc="maxp"):
            for x in range(T.shape[1]):
                w1 = 0
                if VM1[y, x, 0] + SM1[y, x, 0] > VM2[y, x, 0] + SM2[y, x, 0]: w1 = 1
                w2 = 1 - w1
                for c in range(T.shape[2]):
                    T[y, x, c] = w1 * TM1[y, x, c] + w2 * TM2[y, x, c]
        ut.save(f"batch/naive_{TEX1}_{TEX2}_mipmap{i}.png", T)

do("Brick", "Moss")
