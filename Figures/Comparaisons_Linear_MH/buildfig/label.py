import cv2 as cv
import numpy as np
import utils as ut

def do(TEX1, TEX2):
    FIG = ut.load(f"batch/comparaison_{TEX1}_{TEX2}.png")
    LABEL = ut.load(f"tex/Layer_Text.png")

    for y in range(FIG.shape[0]):
        for x in range(FIG.shape[1]):
            t = LABEL[y, x, 3]
            for c in range(FIG.shape[2]):
                FIG[y, x, c] = FIG[y, x, c] * (1.0 - t) + LABEL[y, x, c] * t

    ut.save(f"batch/comparaison_label_{TEX1}_{TEX2}.png", FIG)


TESTS = ["Brick", "Forest", "Grass", "Gravel", "Paving", "Moss", "Sand"]

for i, TEX1 in enumerate(TESTS):
    for j, TEX2 in enumerate(TESTS):
        if i < j:
            do(TEX1, TEX2)