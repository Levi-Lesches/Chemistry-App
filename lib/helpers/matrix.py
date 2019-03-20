from sympy import Matrix

def get_pivot (col: list) -> (int, int): 
	result_index = None
	result = None
	for index, value in enumerate (col): 
		if value != 0: return index, value
		else: 
			result_index = index
			result = value

	else: return result_index, result

def row_reduce(self) -> ("Matrix", list):
	"""
		- normalize_last = False
		- isZeroFunc = lambda x: x == 0
		- zero_above = True
		- normalize = True
		- simpFunc: ignore

		IGNORE THE LAST RETURN VARIABLE
	"""
	cols = self.cols
	matrix = list (self)

	def get_col (index): return matrix [index::cols]

	def swap_rows (row1, row2): 
		index1_1 = row1 * cols
		index1_2 = (row1 + 1) * cols
		index2_1 = row2 * cols
		index2_2 = (row2 + 1) * cols
		matrix [index1_1 : index1_2], matrix [index2_1 : index2_2] = (
			matrix [index2_1 : index2_2], matrix [index1_1 : index1_2]
		)

	def cross_cancel (row, value, pivot_row, pivot_value): 
		offset = (pivot_row - row) * cols
		for n in range (row * cols, (row + 1) * cols): 
			matrix [n] = pivot_value * matrix [n] - value * matrix [n + offset]

	pivot_row = 0
	pivot_col = 0
	pivots = []

	while pivot_col < cols and pivot_row < self.rows:
		offset, value = get_pivot (get_col (pivot_col) [pivot_row:])
		offset = int (offset)
		value = int (value)

		if offset is None: 
			raise TypeError ("matrix.row_reduce: found a None value")

		pivots.append (pivot_col)

		if offset != 0: swap_rows (pivot_row, offset + pivot_row)

		# normalize
		matrix [pivot_row * cols + pivot_col] = 1
		for index in range (
			pivot_row * cols + pivot_col + 1,
			(pivot_row + 1) * cols
		): matrix [index] = matrix [index] / value

		value = 1

		for row in range (self.rows): 
			if row == pivot_row: continue

			val = matrix [row * cols + pivot_col]
			if val == 0: continue
			else: cross_cancel (row, val, pivot_row, value)

		pivot_row += 1

	return Matrix._new(self.rows, self.cols, matrix), pivots

# def _eval_rref(self, )