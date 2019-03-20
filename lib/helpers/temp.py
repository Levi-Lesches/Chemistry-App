from matrix import row_reduce, get_pivot
from random import randrange
from sympy import Matrix
from itertools import product

# def rref(self, iszerofunc=_iszero, simplify=False, pivots=True, normalize_last=True):
# 	"""Return reduced row-echelon form of matrix and indices of pivot vars.
# 	Parameters
# 	==========
# 	iszerofunc : Function
# 		A function used for detecting whether an element can
# 		act as a pivot.  ``lambda x: x.is_zero`` is used by default.
# 	simplify : Function
# 		A function used to simplify elements when looking for a pivot.
# 		By default SymPy's ``simplify`` is used.
# 	pivots : True or False
# 		If ``True``, a tuple containing the row-reduced matrix and a tuple
# 		of pivot columns is returned.  If ``False`` just the row-reduced
# 		matrix is returned.
# 	normalize_last : True or False
# 		If ``True``, no pivots are normalized to `1` until after all
# 		entries above and below each pivot are zeroed.  This means the row
# 		reduction algorithm is fraction free until the very last step.
# 		If ``False``, the naive row reduction procedure is used where
# 		each pivot is normalized to be `1` before row operations are
# 		used to zero above and below the pivot.
# 	Notes
# 	=====
# 	The default value of ``normalize_last=True`` can provide significant
# 	speedup to row reduction, especially on matrices with symbols.  However,
# 	if you depend on the form row reduction algorithm leaves entries
# 	of the matrix, set ``normalize_last=False``
# 	Examples
# 	========
# 	>>> from sympy import Matrix
# 	>>> from sympy.abc import x
# 	>>> m = Matrix([[1, 2], [x, 1 - 1/x]])
# 	>>> m.rref()
# 	(Matrix([
# 	[1, 0],
# 	[0, 1]]), (0, 1))
# 	>>> rref_matrix, rref_pivots = m.rref()
# 	>>> rref_matrix
# 	Matrix([
# 	[1, 0],
# 	[0, 1]])
# 	>>> rref_pivots
# 	(0, 1)
# 	"""
# 	simpfunc = simplify if isinstance(
# 		simplify, FunctionType) else _simplify

# 	ret, pivot_cols = self._eval_rref(iszerofunc=iszerofunc,
# 									  simpfunc=simpfunc,
# 									  normalize_last=normalize_last)

# 	if pivots: return ret, pivot_cols
# 	else: return ret

# def _eval_rref(self, iszerofunc, simpfunc, normalize_last=True):
# 	reduced, pivot_cols, swaps = self._row_reduce(
# 		iszerofunc, 
# 		simpfunc,
# 		normalize_last,
# 		normalize = True,
# 		zero_above = True
# 	)
# 	return reduced, pivot_cols

def _row_reduce(self, iszerofunc, simpfunc, normalize_last=True, normalize=True, zero_above=True):
	"""Row reduce ``self`` and return a tuple (rref_matrix,
	pivot_cols, swaps) where pivot_cols are the pivot columns
	and swaps are any row swaps that were used in the process
	of row reduction.
	Parameters
	==========
	iszerofunc : determines if an entry can be used as a pivot
	simpfunc : used to simplify elements and test if they are
		zero if ``iszerofunc`` returns `None`
	normalize_last : indicates where all row reduction should
		happen in a fraction-free manner and then the rows are
		normalized (so that the pivots are 1), or whether
		rows should be normalized along the way (like the naive
		row reduction algorithm)
	normalize : whether pivot rows should be normalized so that
		the pivot value is 1
	zero_above : whether entries above the pivot should be zeroed.
		If ``zero_above=False``, an echelon matrix will be returned.
	"""
	rows, cols = self.rows, self.cols
	mat = list(self)
	def get_col(i):
		return mat[i::cols]

	def row_swap(i, j):
		mat[i*cols:(i + 1)*cols], mat[j*cols:(j + 1)*cols] = \
			mat[j*cols:(j + 1)*cols], mat[i*cols:(i + 1)*cols]

	def cross_cancel(a, i, b, j):
		# a = pivot_val
		# i = row
		# b = val
		# j = pivot_row
		"""Does the row op row[i] = a*row[i] - b*row[j]"""
		q = (j - i)*cols
		for p in range(i*cols, (i + 1)*cols):
			mat[p] = a*mat[p] - b*mat[p + q]

	piv_row, piv_col = 0, 0
	pivot_cols = []
	swaps = []
	# use a fraction free method to zero above and below each pivot
	while piv_col < cols and piv_row < rows:
		# pivot_offset, pivot_val, \
		# assumed_nonzero, newly_determined = _find_reasonable_pivot(
		# 	get_col(piv_col)[piv_row:], iszerofunc, simpfunc)

		pivot_offset, pivot_val = get_pivot(get_col (piv_col) [piv_row:])
		assumed_nonzero = None
		newly_determined = []

		# _find_reasonable_pivot may have simplified some things
		# in the process.  Let's not let them go to waste
		for (offset, val) in newly_determined:
			offset += piv_row
			mat[offset*cols + piv_col] = val

		if pivot_offset is None:
			piv_col += 1
			continue

		pivot_cols.append(piv_col)
		if pivot_offset != 0:
			row_swap(piv_row, pivot_offset + piv_row)
			swaps.append((piv_row, pivot_offset + piv_row))

		# if we aren't normalizing last, we normalize
		# before we zero the other rows
		if normalize_last is False:
			i, j = piv_row, piv_col
			mat[i*cols + j] = 1
			for p in range(i*cols + j + 1, (i + 1)*cols):
				mat[p] = mat[p] / pivot_val
			# after normalizing, the pivot value is 1
			pivot_val = 1

		# zero above and below the pivot
		for row in range(rows):
			# don't zero our current row
			if row == piv_row:
				continue
			# don't zero above the pivot unless we're told.
			if zero_above is False and row < piv_row:
				continue
			# if we're already a zero, don't do anything
			val = mat[row*cols + piv_col]
			if iszerofunc(val):
				continue

			cross_cancel(pivot_val, row, val, piv_row)  #EDIT
		piv_row += 1

	# normalize each row
	if normalize_last is True and normalize is True:
		for piv_i, piv_j in enumerate(pivot_cols):
			pivot_val = mat[piv_i*cols + piv_j]
			mat[piv_i*cols + piv_j] = 1
			for p in range(piv_i*cols + piv_j + 1, (piv_i + 1)*cols):
				mat[p] = mat[p] / pivot_val

	return self._new(self.rows, self.cols, mat), tuple(pivot_cols), tuple(swaps)

combos = tuple (product (range (1, 6), repeat = 5))
length = len (combos)
random = lambda: randrange (length)
get_combo = lambda: combos [random()]

for _ in range (1_000): 
	row1 = get_combo()
	row2 = get_combo()
	row3 = get_combo()
	row4 = get_combo()
	row5 = get_combo()
	matrix = Matrix ([
		row1, 
		row2, 
		row3,
		row4, 
		row5
	])
	result1 = _row_reduce (
		matrix, 
		iszerofunc = lambda x: x == 0,
		simpfunc = None,
		normalize_last = False,
		normalize = True,
		zero_above = True
	) [:-1] 
	result2 = row_reduce (matrix)

	result2 = result2 [0], tuple (result2 [1])

	assert result1 == result2, f"{result1}\n{result2}"