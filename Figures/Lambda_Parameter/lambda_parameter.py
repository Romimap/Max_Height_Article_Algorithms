import max_eq8 as eqmax
import buildfig as bfig

TESTS = ["Brick", "Forest", "Grass", "Gravel", "Paving", "Moss", "Sand"]

for i, TEX1 in enumerate(TESTS):
    for j, TEX2 in enumerate(TESTS):
        if i < j and (i, j) not in [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6)]:
            eqmax.do(TEX1, TEX2, 0.0001, 0)
            eqmax.do(TEX1, TEX2, 0.0010, 1)
            eqmax.do(TEX1, TEX2, 0.0100, 2)
            eqmax.do(TEX1, TEX2, 0.1000, 3)
            bfig.do(TEX1, TEX2)