import utils as ut
import cv2 as cv
import numpy as np


def mixmax(T1, T2, S1, S2, V1, V2, mip_level, base_variance):
    #S1, S2 centered
    S1 = ut.offset(S1, -ut.mean(S1)[0])
    S2 = ut.offset(S2, -ut.mean(S2)[0])

    #Means over P
    mean_T1 = ut.mipmap(T1, mip_level)
    mean_T2 = ut.mipmap(T2, mip_level)
    mean_S1 = ut.mipmap(S1, mip_level)
    mean_S2 = ut.mipmap(S2, mip_level)
    mean_V1 = ut.mipmap(V1, mip_level)
    mean_V2 = ut.mipmap(V2, mip_level)

    #Variances over P
    variance_S1 = ut.mipmapvar(S1, mip_level)
    variance_S2 = ut.mipmapvar(S2, mip_level)

    MU = ut.sub(ut.add(mean_S2, mean_V2), ut.add(mean_S1, mean_V1))
    VAR = ut.isqrt(ut.addf(ut.add(variance_S1, variance_S2), 2.0 * base_variance))

    Z = ut.div(MU, VAR)

    W2 = ut.Phi(Z) #(w1 = 1 - phi(Z), w2 = 1 - w1)
    W1 = ut.oneminus(W2)

    T = ut.add(ut.mul(W1, mean_T1), ut.mul(W2, mean_T2))

    return T

V1 = np.zeros((1024, 2048, 3))
V2 = np.zeros((1024, 2048, 3))
for x in range(2048):
    t = x / 2047
    for y in range(1024):
        for c in range(3):
            V1[y, x, c] = t
            V2[y, x, c] = 1.0 - t

ut.save("mm.png", mixmax(ut.load("textures/Brick_T.png"), ut.load("textures/Sand_T.png"), ut.load("textures/Brick_S.png"), ut.load("textures/Sand_S.png"), V1, V2, 0, 0.005))


def mixmax_groundtruth(T1, T2, S1, S2, V1, V2, mip_level, base_variance):
    #S1, S2 centered
    S1 = ut.offset(S1, -ut.mean(S1)[0])
    S2 = ut.offset(S2, -ut.mean(S2)[0])

    MU = ut.sub(ut.add(S2, V2), ut.add(S1, V1))
    VAR = ut.isqrt(ut.addf(ut.add(S1, S2), 2.0 * base_variance))

    Z = ut.div(MU, VAR)

    W1 = ut.oneminus(ut.Phi(Z))
    W2 = ut.oneminus(W1)

    T = ut.add(ut.mul(W1, T1), ut.mul(W2, T2))

    return ut.mipmap(T, mip_level)


def mixmax_naive(T1, T2, S1, S2, V1, V2, mip_level):
    #S1, S2 centered
    S1 = ut.offset(S1, -ut.mean(S1)[0])
    S2 = ut.offset(S2, -ut.mean(S2)[0])

    #Means over P
    mean_T1 = ut.mipmap(T1, mip_level)
    mean_T2 = ut.mipmap(T2, mip_level)
    mean_S1 = ut.mipmap(S1, mip_level)
    mean_S2 = ut.mipmap(S2, mip_level)
    mean_V1 = ut.mipmap(V1, mip_level)
    mean_V2 = ut.mipmap(V2, mip_level)


    T = np.zeros(mean_T1.shape)

    for y in range(T.shape[0]):
        for x in range(T.shape[1]):
            t = 1 if mean_S1[y, x, 0] + mean_V1[y, x, 0] > mean_S2[y, x, 0] + mean_V2[y, x, 0] else 0
            for c in range(T.shape[2]):
                T[y, x, c] = mean_T1[y, x, c] * t + mean_T2[y, x, c] * (1.0 - t)

    return T

def linear(T1, T2, V1, V2, mip_level):
    #Means over P
    mean_T1 = ut.mipmap(T1, mip_level)
    mean_T2 = ut.mipmap(T2, mip_level)
    mean_V1 = ut.mipmap(V1, mip_level)
    mean_V2 = ut.mipmap(V2, mip_level)

    V1T1 = ut.mul(mean_V1, mean_T1)
    V2T2 = ut.mul(mean_V2, mean_T2)

    T = ut.add(V1T1, V2T2)

    return T
