from random import random, randint
PROCESSSIZE = 2048 * 8

#Computing the cdf of the families distribution based on populations
f_prob = [1, 2, 14, 2, 1, 1, 3, 1, 15, 1, 2, 4, 1, 0.1, 0.1, 8]
s = sum(f_prob)
for i in range(16): #distribution
    f_prob[i] /= s
c = 0
for i in range(16): #cdf
    x = f_prob[i]
    f_prob[i] = c
    c += x


families = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
component = []

#generating an exemplar
for i in range(PROCESSSIZE):
    r = random()
    f = 15
    while f_prob[f] > r: #importance sampling
        f -= 1
    families[f].append(i)
    component.append({
        'priority': random(),
        'family' : f})

#synthesizing a blending based on 3 tiles
s_families = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
s_components = []
for i in range(PROCESSSIZE):
    c1 = component[randint(0, PROCESSSIZE - 1)]
    c2 = component[randint(0, PROCESSSIZE - 1)]
    c3 = component[randint(0, PROCESSSIZE - 1)]

    if c1['priority'] >= c2['priority'] and c1['priority'] >= c3['priority']:
        s_components.append(c1)
        s_families[c1['family']].append(i)

    elif c2['priority'] >= c1['priority'] and c2['priority'] >= c3['priority']:
        s_components.append(c2)
        s_families[c2['family']].append(i)

    elif c3['priority'] >= c2['priority'] and c3['priority'] >= c1['priority']:
        s_components.append(c3)
        s_families[c3['family']].append(i)

#printing the populations
for i in range(16):
    print(f"{len(families[i])} {len(s_families[i])}")

