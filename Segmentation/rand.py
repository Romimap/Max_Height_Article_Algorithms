import random as r

for i in range(15):
    print(f"trochoidalwave(\
    {(r.random()*0.2 + 0.05):.2f},\
    {(r.random()*0.5 + 0.05):.2f},\
    vec2({(r.random()*2.0-1.0):.2f}, {(r.random()*2.0-1.0):.2f}),\
    TIME * 0.1,\
    vertex);")