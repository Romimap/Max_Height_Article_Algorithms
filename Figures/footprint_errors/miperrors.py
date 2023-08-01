import max_eq8 as eq8
import max_eq4 as eq4
import errors as err
import max_naive as naive

TESTS = ["Brick", "Forest", "Grass", "Gravel", "Paving", "Moss", "Sand"]

for i, TEX1 in enumerate(TESTS):
    for j, TEX2 in enumerate(TESTS):
        if i < j:
            #eq8.do(TEX1, TEX2, 0.0000)
            #eq4.do(TEX1, TEX2)
            #err.do(TEX1, TEX2)
            naive.do(TEX1, TEX2)
