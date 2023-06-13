import cv2 as cv
import numpy as np
import os
from tqdm import tqdm

for dir in next(os.walk('.'))[1]:
    img = cv.imread(f"{dir}/T.png")
    out = np.zeros((128, 128, img.shape[2]))
    for y in tqdm(range(128), desc=f"{dir}") :
        for x in range(128):
            xo = int((x / 127) * (img.shape[1] - 1))
            yo = int((y / 127) * (img.shape[0] - 1))
            for c in range(img.shape[2]):
                out[y, x, c] = img[yo, xo, c]
    cv.imwrite(f"{dir}/icon.png", out)
