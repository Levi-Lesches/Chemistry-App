from matrix import Matrix
from itertools import product

print (
	Matrix ([
		[3, -4, -2],
		[1, -2, 0],
		[4, -7, -1]
	]).nullspace()
)

print (
	Matrix ([
		[-1, 0, 1, 0],
		[-4, 0, 0, 1],
		[0, -2, 4, 1],
		[0, -1, 4, 0]
	]).nullspace()
)

print (
	Matrix ([
		[2, 0, -1, 0],
		[3, 0, 0, -1],
		[0, 2, 0, -2]
	]).nullspace()
)

print (
	Matrix ([
		[2, 0, -2],
		[0, 2, -1]
	]).nullspace()
)

print (
	Matrix ([
		[1, 0, -6, 0],
		[0, 2, -12, 0],
		[2, 1, -6, -2]
	]).nullspace()
)