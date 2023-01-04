import time
from dataclasses import dataclass
import colorsys as csys
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

w, h = 512, 512
data = np.zeros((h, w, 3), dtype=np.uint8)
#data[0:256, 0:256] = [255, 0, 0] # red patch in upper left
#img = Image.fromarray(data, 'RGB')
##img.save('my.png')
#img.show()

@dataclass(frozen=True)
class C:
    a : int
    b : int = 0

def add(c1:C,c2:C) -> C:
    if isinstance(c1,C) and isinstance(c2,C):
        return C(c1.a+c2.a, c1.b+c2.b)
    if isinstance(c1,C) and not(isinstance(c2,C)):
        return C(c1.a+c2, c1.b)
    if not(isinstance(c1,C)) and isinstance(c2,C):
        return C(c1+c2.a, c2.b)
    if not(isinstance(c1,C)) and not(isinstance(c2,C)):
        return C(c1 + c2)

def mult(c1:C,c2:C) -> C:
    if isinstance(c1,C) and isinstance(c2,C):
        return C(c1.a*c2.a - c1.b*c2.b, c1.a*c2.b+c1.b*c2.a)
    if isinstance(c1,C) and not(isinstance(c2,C)):
        return C(c1.a*c2, c1.b*c2)
    if not(isinstance(c1,C)) and isinstance(c2,C):
        return C(c1*c2.a, c1*c2.b)
    if not(isinstance(c1,C)) and not(isinstance(c2,C)):
        return C(c1 * c2)

def eval_poly(coeffs, c:C):
    if len(coeffs) == 1:
        return coeffs[0] if isinstance(coeffs[0],C) else C(coeffs[0])
    return add(coeffs[0], mult(c, eval_poly(coeffs[1:],c)))

def mag(c:C): return (c.a**2+c.b**2)**.5
def ang(c:C): return np.arctan(c.b/c.a) if c.a != 0 else 0
def complex_num_to_hsv(c:C):
    return ang(c), (2/np.pi)*np.arctan(mag(c)), 1.0
def complex_num_to_rgb(c:C):
    return list(map(lambda x:x*256, csys.hsv_to_rgb(*complex_num_to_hsv(c))))

# def f(c:C): return C(c.a, c.a+c.b)

#data[0:256, 0:256] = complex_num_to_rgb(1,2)

courseness = 3
for i in range(5):
    f = lambda c: eval_poly([-(50*i)**2,0,1], c)
    for x in range(-w//2,w//2,courseness):
        for y in range(-h//2,h//2,courseness):
            c = complex_num_to_rgb(f(C(x,y)))
            data[x+w//2:x+w//2+courseness,y+h//2:y+h//2+courseness] = c
    img = Image.fromarray(data, 'RGB')
    img.save('out.png')
