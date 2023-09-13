import numpy as np
import methods as mt
import utils as ut


def figure_teaser():
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
        ut.save(f"teaser_{i}_{texture_names[i]}_{texture_names[i + 1]}.png", T)


def figure_aliasing_artefact_base_variance():
    T1 = ut.load("textures/Brick_T.png")
    T2 = ut.load("textures/Forest_T.png")
    S1 = ut.load("textures/Brick_S.png")
    S2 = ut.load("textures/Forest_S.png")
    V1 = ut.load("textures/v_constant.png")
    V2 = V1

    T1 = ut.cut(T1, 0, 512, 0, 512)
    T2 = ut.cut(T2, 0, 512, 0, 512)
    S1 = ut.cut(S1, 0, 512, 0, 512)
    S2 = ut.cut(S2, 0, 512, 0, 512)

    T_without = mt.mixmax(T1, T2, S1, S2, V1, V2, 0, 0)
    T_with = mt.mixmax(T1, T2, S1, S2, V1, V2, 0, 0.00010)

    ut.save("without_base_variance.png", T_without)
    ut.save("with_base_variance.png", T_with)
    ut.save("without_base_variance_crop.png", ut.cut(T_without, 256, 512, 256, 512))
    ut.save("with_base_variance_crop.png", ut.cut(T_with, 256, 512, 256, 512))


def figure_base_variance_variations():
    w = 2048
    h = 512
    T1 = ut.cut(ut.load("textures/Brick_T.png"), 0, w, 0, h)
    T2 = ut.cut(ut.load("textures/Sand_T.png"), 0, w, 0, h)
    S1 = ut.cut(ut.load("textures/Brick_S.png"), 0, w, 0, h)
    S2 = ut.cut(ut.load("textures/Sand_S.png"), 0, w, 0, h)
    V1 = np.zeros((h, w, 3))
    V2 = np.zeros((h, w, 3))
    for x in range(V1.shape[1]):
        t = (x / (V1.shape[1] - 1))
        t = t * 0.4 + 0.3
        for y in range(V1.shape[0]):
            for c in range(3):
                V1[y, x, c] = t
                V2[y, x, c] = 1 - t

    base_variances = [0.00000, 0.00005, 0.00050, 0.00500, 0.05000]

    for v in base_variances:
        print("base_variance_" + "{:05d}".format(int(v * 100000)) + ".png")
        T = mt.mixmax(T1, T2, S1, S2, V1, V2, 0, v)
        ut.save("base_variance_" + "{:05d}".format(int(v * 100000)) + ".png", T)

#figure_teaser()
figure_aliasing_artefact_base_variance()
#figure_base_variance_variations()
