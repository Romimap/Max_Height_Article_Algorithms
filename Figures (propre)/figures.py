import numpy as np
import methods as mt
import utils as ut


def figure_1():
    w = 1024
    h = 1024

    #interpolation fields
    V1 = np.zeros((h, w, 3))
    V2 = np.zeros((h, w, 3))
    for x in range(V1.shape[1]):
        t = (x / (V1.shape[1] - 1))
        t = t * 0.4 + 0.3
        for y in range(V1.shape[0]):
            for c in range(3):
                V1[y, x, c] = t
                V2[y, x, c] = 1 - t

    print("Textures and Priority maps")
    #Textures and Priority maps
    texture_names = ["Paving", "Forest", "Gravel", "Brick", "Sand", "Grass"]
    N = len(texture_names)
    textures = []
    priority_maps = []

    for name in texture_names:
        print(name)
        T = ut.load(f"textures/{name}_T.png")
        S = ut.load(f"textures/{name}_S.png")


        textures.append(T)
        priority_maps.append(S)

    print("transitions")
    #Transitions
    transitions = []
    for i in range(N - 1):
        print(i)
        T1 = ut.cut(textures[i + 1], 0, w, 0, h)
        T2 = ut.cut(textures[i], w, 2 * w, 0, h)
        S1 = ut.cut(priority_maps[i + 1], 0, w, 0, h)
        S2 = ut.cut(priority_maps[i], w, 2 * w, 0, h)
        T = mt.mixmax(T1, T2, S1, S2, V1, V2, 0, 0.0005)
        transitions.append(T)
        ut.save(f"t{i}.png", T)

    print("build figure")
    #build figure
    T = np.zeros((h, w * (N - 1), 3))
    for i in range(len(transitions)):
        print(i)
        for y in range(h):
            for x in range(w):
                for c in range(3):
                    T[y, x + (w * i), c] = transitions[i][y, x, c]

    ut.save("t.png", T)


figure_1()
