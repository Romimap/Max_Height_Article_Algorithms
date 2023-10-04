import cv2 as cv
import numpy as np
import os
from tqdm import tqdm

def luminance(c):
    return c[0] * 0.114 + c[1] * 0.587 + c[2] * 0.299

for dir in next(os.walk('.'))[1]:
    img = cv.imread(f"{dir}/T.png")
    out = np.zeros(img.shape)
    
    for y in tqdm(range(img.shape[0]), desc=f"{dir}", ) :
        for x in range(img.shape[1]):
            s = pow(luminance(img[y, x]) / 255.0, 2.0) * 255.0
            for c in range(img.shape[2]):
                out[y, x, c] = s
     
    cv.imwrite(f"{dir}/S.png", out)