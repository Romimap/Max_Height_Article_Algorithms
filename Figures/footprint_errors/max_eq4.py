import cv2 as cv
import numpy as np
import utils as ut
import sys
import time
from tqdm import tqdm

start = time.time()

def do(TEX1, TEX2, LAMBDA):
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
        MU1 = ut.add(ut.mipmap(S1, i), ut.mipmap(V1, i))
        MU2 = ut.add(ut.mipmap(S2, i), ut.mipmap(V2, i))
        MU = ut.sub(MU2, MU1)

        VAR1 = ut.mipmapvar(S1, i)
        VAR2 = ut.mipmapvar(S2, i)
        VAR = ut.isqrt(ut.addf(ut.add(VAR1, VAR2), LAMBDA))

        Z = ut.div(MU, VAR)

        W1 = ut.oneminus(ut.Phi(Z))
        W2 = ut.oneminus(W1)

        W1T1 = ut.mul(W1, ut.mipmap(T1, i))
        W2T2 = ut.mul(W2, ut.mipmap(T2, i))

        T = ut.add(W1T1, W2T2)

        ut.save(f"batch/eq8_{TEX1}_{TEX2}_mipmap{i}.png", T)

do("Brick", "Moss", 0)
