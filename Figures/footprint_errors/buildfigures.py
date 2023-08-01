import utils as ut
import numpy as np

TESTS = ["Brick", "Forest", "Grass", "Gravel", "Paving", "Moss", "Sand"]

for i, TEX1 in enumerate(TESTS):
    for j, TEX2 in enumerate(TESTS):
        if i < j:
            textures = []

            textures.append(ut.load(f"batch/eq4_{TEX1}_{TEX2}_mipmap0.png"))
            textures.append(ut.load(f"batch/eq4_{TEX1}_{TEX2}_mipmap2.png"))
            textures.append(ut.load(f"batch/eq4_{TEX1}_{TEX2}_mipmap4.png"))
            textures.append(ut.load(f"batch/eq4_{TEX1}_{TEX2}_mipmap6.png"))

            textures.append(ut.load(f"batch/eq8_{TEX1}_{TEX2}_mipmap0.png"))
            textures.append(ut.load(f"batch/eq8_{TEX1}_{TEX2}_mipmap2.png"))
            textures.append(ut.load(f"batch/eq8_{TEX1}_{TEX2}_mipmap4.png"))
            textures.append(ut.load(f"batch/eq8_{TEX1}_{TEX2}_mipmap6.png"))

            textures.append(ut.load(f"batch/abserr_{TEX1}_{TEX2}_mipmap0.png"))
            textures.append(ut.load(f"batch/abserr_{TEX1}_{TEX2}_mipmap2.png"))
            textures.append(ut.load(f"batch/abserr_{TEX1}_{TEX2}_mipmap4.png"))
            textures.append(ut.load(f"batch/abserr_{TEX1}_{TEX2}_mipmap6.png"))

            textures.append(ut.load(f"batch/relerr_{TEX1}_{TEX2}_mipmap0.png"))
            textures.append(ut.load(f"batch/relerr_{TEX1}_{TEX2}_mipmap2.png"))
            textures.append(ut.load(f"batch/relerr_{TEX1}_{TEX2}_mipmap4.png"))
            textures.append(ut.load(f"batch/relerr_{TEX1}_{TEX2}_mipmap6.png"))
            
            FIG = np.zeros((512*4, 512*4, 3))

            index = 0
            for y0 in range(0, 512*4, 512):
                for x0 in range(0, 512*4, 512):
                    T = textures[index]
                    h = T.shape[0]
                    w = T.shape[1]
                    for x in range(512):
                        for y in range(512):
                            xt = int((x / 512) * w)
                            yt = int((y / 512) * h)
                            for c in range(3):
                                FIG[y + y0, x + x0, c] = T[yt, xt, c]   
                                if x < 2 or x > 509: FIG[y + y0, x + x0, c] = 1
                                if y < 2 or y > 509: FIG[y + y0, x + x0, c] = 1
                    index += 1
            
            ut.save(f"batch/figure_{TEX1}_{TEX2}.png", FIG)                    