import ctypes
ctypes.cdll.LoadLibrary("./libFilters.so")
filters = ctypes.CDLL("./libFilters.so")

import numpy as np

mi_suma = filters.pysum
mi_suma.argtypes = [ctypes.c_int, ctypes.c_int]
mi_suma.restype = ctypes.c_int

sounds = (np.random.rand(9)+0.5)*10
print(sounds)

irrFilter = filters.irrFilterSSE
irrFilter.argtypes = [ctypes.POINTER(ctypes.c_float * len(sounds)), ctypes.POINTER(ctypes.c_float * len(sounds)), ctypes.c_int]
irrFilter.restype = ctypes.c_void_p

array_type = ctypes.c_float * len(sounds)
p_sounds = ctypes.pointer(array_type(*sounds))
filtred_sounds = ctypes.pointer((array_type(*np.zeros(len(sounds)))))

irrFilter(p_sounds, filtred_sounds, len(sounds))
type(filtred_sounds) == type(p_sounds)
print(filtred_sounds.contents[0])

