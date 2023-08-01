import linear_eq2 as eqlin
import max_eq8 as eqmax
import buildfig as bfig

TESTS = ["Brick", "Forest", "Grass", "Gravel", "Paving", "Moss", "Sand"]

for i, TEX1 in enumerate(TESTS):
    for j, TEX2 in enumerate(TESTS):
        if i < j:
            eqlin.do(TEX1, TEX2)
            eqmax.do(TEX1, TEX2)
            bfig.do(TEX1, TEX2)