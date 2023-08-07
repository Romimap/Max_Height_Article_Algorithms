import utils as ut
import numpy as np
from tqdm import tqdm

	
def preprocessing_step(TEX): 
	S = ut.load(f"textures/{TEX}_S.png")
	h = S.shape[0]
	w = S.shape[1]

	ms = np.zeros(S.shape)
	
	s_mean = ut.mean(S)[0]
		
	for x in tqdm(range(w), desc="writing"):
		for y in range(h):
			s_centered = S[y, x, 0] - s_mean
			ms[y, x, 2] = (s_centered) + 0.5
			ms[y, x, 1] = (s_centered ** 2.0) + 0.5
			ms[y, x, 0] = 0
			if ms.shape[2] == 4: ms[y, x, 3] = 1

	ut.save(f"textures/{TEX}_BM.png", ms)

preprocessing_step("Bricks")
preprocessing_step("Moss")
