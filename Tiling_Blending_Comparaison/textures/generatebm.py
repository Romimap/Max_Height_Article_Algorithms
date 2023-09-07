import cv2 as cv
import numpy as np
import os
from tqdm import tqdm

for dir in next(os.walk('.'))[1]:
    img = cv.imread(f"{dir}/S.png")
    out = np.zeros(img.shape)
    mean = 0
    N = img.shape[0] * img.shape[1]
    for y in tqdm(range(img.shape[0]), desc=f"{dir}", ) :
        for x in range(img.shape[1]):
            mean += img[y, x, 0] / N
            
    for y in tqdm(range(img.shape[0]), desc=f"{dir}") :
        for x in range(img.shape[1]):
            t = img[y, x, 0]
            t -= mean
            t /= 255.0
            out[y, x, 2] = t * 255.0 + 128.0
            out[y, x, 1] = t * t * 255.0 + 128.0
    cv.imwrite(f"{dir}/BM.png", out)