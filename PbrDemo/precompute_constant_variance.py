import utils as ut
import cv2 as cv
import numpy as np

def compute_mean_variance(T, footprint_size):
    height = T.shape[0]
    width = T.shape[1]
    mean_variance = 0
    footprint_nb = 0

    for y1 in range(0, height, footprint_size):
        for x1 in range(0, width, footprint_size):
            x2 = x1 + footprint_size
            y2 = y1 + footprint_size

            mean = 0
            for py in range(y1, y2):
                for px in range(x1, x2):
                    mean += T[py % height, px % width, 0] / footprint_size**2

            var = 0
            for py in range(y1, y2):
                for px in range(x1, x2):
                    var += ((T[py % height, px % width, 0] - mean) ** 2) / footprint_size**2

            mean_variance += var
            footprint_nb += 1

    return mean_variance / footprint_nb

print("Rock")
T = ut.load("textures/Rock_S.png")

P = 1
while P <= 2048:
    print(str(P) + ": " + "{:.10f}".format(compute_mean_variance(T, P)))
    P *= 2


print("Sand")
T = ut.load("textures/Sand_S.png")

P = 1
while P <= 2048:
    print(str(P) + ": " + "{:.10f}".format(compute_mean_variance(T, P)))
    P *= 2


    
