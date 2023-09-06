from math import erf, sqrt
from tqdm import tqdm
from random import random as rand
import matplotlib.pyplot as plt



def Phi(x):
    return 0.5 * (1.0 + erf(x / sqrt(2.0)))

def CDF(x, mu, sig):
    return Phi((x - mu) / sig)

def invCDF(y, mu, sig):
    x = 0.0
    offset = 5.0 * sig
    for i in range(256):
        if y > CDF(x, mu, sig):
            x += offset
        else:
            x -= offset
        offset /= 2.0
    return x

maxdistrib = []
for i in tqdm(range(100000), desc="iterations"):
    a = invCDF(rand(), 0.0, 4.0)
    b = invCDF(rand(), 1.5, 1.0)
    c = invCDF(rand(), 2.0, 0.5)

    m = max(a, max(b, c))
    maxdistrib.append(m)

plt.hist(maxdistrib, bins=512)
plt.show()
