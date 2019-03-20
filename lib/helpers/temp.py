from matrix import rref, get_pivot
from random import randrange
from sympy import Matrix
from itertools import product

combos = tuple (product (range (1, 6), repeat = 5))
length = len (combos)
random = lambda: randrange (length)
get_combo = lambda: combos [random()]

def test(n):
	for _ in range (n): 
		row1 = get_combo()
		row2 = get_combo()
		row3 = get_combo()
		row4 = get_combo()
		row5 = get_combo()

		rows = [row1, row2, row3, row4, row5]

		matrix = Matrix (rows)
		assert rref (matrix) [0] == matrix.rref() [0], f"{rref (matrix)}\n{matrix.rref()}"


test(1_000)