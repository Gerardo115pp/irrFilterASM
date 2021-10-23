import ctypes
ctypes.cdll.LoadLibrary("./libFilters.so")
filters = ctypes.CDLL("./libFilters.so")

import numpy as np


__ASMirrFilterSSE = filters.irrFilterSSE # SSE version of the filter, expects an array of sound samples, an empty array for the result and the length of the array

def irrFilter(sounds: np.ndarray) -> np.ndarray:
    __ASMirrFilterSSE.argtypes = [ctypes.POINTER(ctypes.c_float * len(sounds)), ctypes.POINTER(ctypes.c_float * len(sounds)), ctypes.c_int]
    __ASMirrFilterSSE.restype = ctypes.c_void_p
    

    array_type = ctypes.c_float * len(sounds)
    p_sounds = ctypes.pointer(array_type(*sounds))
    result = ctypes.pointer((array_type(*np.zeros(len(sounds)))))
    
    __ASMirrFilterSSE(p_sounds, result, len(sounds))
    return np.array(result.contents)


