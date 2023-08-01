import max_eq8 as eqmax

TESTS = ["Brick", "Forest", "Grass", "Gravel", "Paving", "Moss", "Sand"]

for i, TEX1 in enumerate(TESTS):
    for j, TEX2 in enumerate(TESTS):
        if i < j:
            eqmax.do(TEX1, TEX2, 0.0000, 0)