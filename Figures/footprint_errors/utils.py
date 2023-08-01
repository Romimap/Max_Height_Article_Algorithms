import cv2 as cv
import numpy as np
from math import sqrt, erf
from tqdm import tqdm

def load (path):
    img = cv.imread(path, cv.IMREAD_UNCHANGED)
    out = np.zeros(img.shape)
    for y in tqdm(range(img.shape[0]), desc=f"Loading {path} ({img.shape[1]} x {img.shape[0]}, {img.shape[2]})"):
        for x in range(img.shape[1]):
            for c in range(img.shape[2]):
                out[y, x, c] = img[y, x, c] / 255.0
    return out

def save (path, img):
    out = np.zeros(img.shape)
    for y in tqdm(range(img.shape[0]), desc=f"Saving {path}"):
        for x in range(img.shape[1]):
            for c in range(img.shape[2]):
                out[y, x, c] = img[y, x, c] * 255.0
                out[y, x, c] = min(255, max(0, out[y, x, c]))
    cv.imwrite(path, out)


def cut(img, x1, x2, y1, y2):
    out = np.zeros((y2 - y1, x2 - x1, img.shape[2]))
    for y in tqdm(range(y2 - y1), desc="Cutting "):
        for x in range(x2 - x1):
            for c in range(out.shape[2]):
                out[y, x, c] = img[y + y1, x + x1, c]
    return out


def mean (img, x1 = -1, x2 = -1, y1 = -1, y2 = -1):
    if y1 == -1: y1 = 0
    if x1 == -1: x1 = 0
    if y2 == -1: y2 = img.shape[0]
    if x2 == -1: x2 = img.shape[1]

    S = img.shape[2]*[0]
    N = 0
    for y in range(y1, y2):
        for x in range(x1, x2):
            N += 1
            for c in range(img.shape[2]):
                S[c] += img[y, x, c]
    for c in range(img.shape[2]):
        S[c] /= float(N)
    return S

def var (img, x1 = -1, x2 = -1, y1 = -1, y2 = -1, m = -1):
    M = mean(img) if m == -1 else m 
    if y1 == -1: y1 = 0
    if x1 == -1: x1 = 0
    if y2 == -1: y2 = img.shape[0]
    if x2 == -1: x2 = img.shape[1]

    S = img.shape[2]*[0]
    N = 0
    for y in range(y1, y2):
        for x in range(x1, x2):
            N += 1
            for c in range(img.shape[2]):
                S[c] += (img[y, x, c] - M[c])**2
    for c in range(img.shape[2]):
        S[c] /= float(N)
    return S

def offset (img, offset):
    out = np.zeros(img.shape)
    for y in tqdm(range(img.shape[0]), desc="Offset"):
        for x in range(img.shape[1]):
            for c in range(img.shape[2]):
                out[y, x, c] = img[y, x, c] + offset
    return out

def mul (imgA, imgB):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = imgA[y, x, c] * imgB[y, x, c]
    return out


def mulf (imgA, t):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = imgA[y, x, c] * t
    return out


def div (imgA, imgB):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = imgA[y, x, c] / imgB[y, x, c]
    return out

def add (imgA, imgB):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = imgA[y, x, c] + imgB[y, x, c]
    return out


def addf (imgA, t):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = imgA[y, x, c] + t
    return out


def oneminus (imgA):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = 1 - imgA[y, x, c]
    return out


def sub (imgA, imgB):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = imgA[y, x, c] - imgB[y, x, c]
    return out

def isqrt (imgA):
    out = np.zeros(imgA.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = sqrt(imgA[y, x, c])
    return out

def Phi (img):
    out = np.zeros(img.shape)
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            for c in range(out.shape[2]):
                out[y, x, c] = 0.5 + 0.5 * erf(img[y, x, c] / sqrt(2))
    return out


def euclidianDistance(imgA, imgB):
    out = np.zeros((imgA.shape[0], imgA.shape[1], 1))
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            a = (imgA[y, x, 0] - imgB[y, x, 0])**2
            b = (imgA[y, x, 1] - imgB[y, x, 1])**2
            c = (imgA[y, x, 2] - imgB[y, x, 2])**2
            d = sqrt(a + b + c)
            out[y, x, 0] = d
    return out

def RelativeEuclidianDistance(imgA, imgB):
    out = np.zeros((imgA.shape[0], imgA.shape[1], 1))
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            a = (imgA[y, x, 0] - imgB[y, x, 0])**2
            b = (imgA[y, x, 1] - imgB[y, x, 1])**2
            c = (imgA[y, x, 2] - imgB[y, x, 2])**2
            d = sqrt(a + b + c)

            ra = imgA[y, x, 0]**2
            rb = imgA[y, x, 1]**2
            rc = imgA[y, x, 2]**2
            rd = sqrt(ra + rb + rc)

            out[y, x, 0] = (d / rd)
    return out

def mipmap (img, level):
    size = 2**level
    out = np.zeros((img.shape[0]//size, img.shape[1]//size, img.shape[2]))
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            x1 = x * size
            x2 = x1 + size
            y1 = y * size
            y2 = y1 + size
            M = mean(img, x1, x2, y1, y2)
            for c in range(out.shape[2]):
                out[y, x, c] = M[c]
    return out


def mipmapvar (img, level):
    size = 2**level
    out = np.zeros((img.shape[0]//size, img.shape[1]//size, img.shape[2]))
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            x1 = x * size
            x2 = x1 + size
            y1 = y * size
            y2 = y1 + size
            V = var(img, x1, x2, y1, y2, mean(img, x1, x2, y1, y2))
            for c in range(out.shape[2]):
                out[y, x, c] = V[c]
    return out