from matrix import rref, get_pivot
from random import randrange
from sympy import Matrix, Float, Integer
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


def _find_reasonable_pivot_naive(col, iszerofunc=lambda x: x == 0, simpfunc=None):
    """
    Helper that computes the pivot value and location from a
    sequence of contiguous matrix column elements. As a side effect
    of the pivot search, this function may simplify some of the elements
    of the input column. A list of these simplified entries and their
    indices are also returned.
    This function mimics the behavior of _find_reasonable_pivot(),
    but does less work trying to determine if an indeterminate candidate
    pivot simplifies to zero. This more naive approach can be much faster,
    with the trade-off that it may erroneously return a pivot that is zero.
    ``col`` is a sequence of contiguous column entries to be searched for
    a suitable pivot.
    ``iszerofunc`` is a callable that returns a Boolean that indicates
    if its input is zero, or None if no such determination can be made.
    ``simpfunc`` is a callable that simplifies its input. It must return
    its input if it does not simplify its input. Passing in
    ``simpfunc=None`` indicates that the pivot search should not attempt
    to simplify any candidate pivots.
    Returns a 4-tuple:
    (pivot_offset, pivot_val, assumed_nonzero, newly_determined)
    ``pivot_offset`` is the sequence index of the pivot.
    ``pivot_val`` is the value of the pivot.
    pivot_val and col[pivot_index] are equivalent, but will be different
    when col[pivot_index] was simplified during the pivot search.
    ``assumed_nonzero`` is a boolean indicating if the pivot cannot be
    guaranteed to be zero. If assumed_nonzero is true, then the pivot
    may or may not be non-zero. If assumed_nonzero is false, then
    the pivot is non-zero.
    ``newly_determined`` is a list of index-value pairs of pivot candidates
    that were simplified during the pivot search.
    """

    # indeterminates holds the index-value pairs of each pivot candidate
    # that is neither zero or non-zero, as determined by iszerofunc().
    # If iszerofunc() indicates that a candidate pivot is guaranteed
    # non-zero, or that every candidate pivot is zero then the contents
    # of indeterminates are unused.
    # Otherwise, the only viable candidate pivots are symbolic.
    # In this case, indeterminates will have at least one entry,
    # and all but the first entry are ignored when simpfunc is None.
    indeterminates = []
    for i, col_val in enumerate(col):
        col_val_is_zero = iszerofunc(col_val)
        if col_val_is_zero == False:
            # This pivot candidate is non-zero.
            return i, col_val, False, []
        elif col_val_is_zero is None:
            # The candidate pivot's comparison with zero
            # is indeterminate.
            indeterminates.append((i, col_val))

    if len(indeterminates) == 0:
        # All candidate pivots are guaranteed to be zero, i.e. there is
        # no pivot.
        return None, None, False, []

    if simpfunc is None:
        # Caller did not pass in a simplification function that might
        # determine if an indeterminate pivot candidate is guaranteed
        # to be nonzero, so assume the first indeterminate candidate
        # is non-zero.
        return indeterminates[0][0], indeterminates[0][1], True, []

    # newly_determined holds index-value pairs of candidate pivots
    # that were simplified during the search for a non-zero pivot.
    newly_determined = []
    for i, col_val in indeterminates:
        tmp_col_val = simpfunc(col_val)
        if id(col_val) != id(tmp_col_val):
            # simpfunc() simplified this candidate pivot.
            newly_determined.append((i, tmp_col_val))
            if iszerofunc(tmp_col_val) == False:
                # Candidate pivot simplified to a guaranteed non-zero value.
                return i, tmp_col_val, False, newly_determined

    return indeterminates[0][0], indeterminates[0][1], True, newly_determined

def _find_reasonable_pivot(col, iszerofunc=lambda x: x == 0, simpfunc=lambda x: x):
    """ Find the lowest index of an item in ``col`` that is
    suitable for a pivot.  If ``col`` consists only of
    Floats, the pivot with the largest norm is returned.
    Otherwise, the first element where ``iszerofunc`` returns
    False is used.  If ``iszerofunc`` doesn't return false,
    items are simplified and retested until a suitable
    pivot is found.
    Returns a 4-tuple
        (pivot_offset, pivot_val, assumed_nonzero, newly_determined)
    where pivot_offset is the index of the pivot, pivot_val is
    the (possibly simplified) value of the pivot, assumed_nonzero
    is True if an assumption that the pivot was non-zero
    was made without being proved, and newly_determined are
    elements that were simplified during the process of pivot
    finding."""

    newly_determined = []
    col = list(col)
    # a column that contains a mix of floats and integers
    # but at least one float is considered a numerical
    # column, and so we do partial pivoting
    if all(isinstance(x, (Float, Integer)) for x in col) and any(
            isinstance(x.p, Float) for x in col):
        col_abs = [abs(x) for x in col]
        max_value = max(col_abs)
        if iszerofunc(max_value):
            # just because iszerofunc returned True, doesn't
            # mean the value is numerically zero.  Make sure
            # to replace all entries with numerical zeros
            if max_value != 0:
                newly_determined = [(i, 0) for i, x in enumerate(col) if x != 0]
            return (None, None, False, newly_determined)
        index = col_abs.index(max_value)
        return (index, col[index], False, newly_determined)

    # PASS 1 (iszerofunc directly)
    possible_zeros = []
    for i, x in enumerate(col):
        is_zero = iszerofunc(x)
        # is someone wrote a custom iszerofunc, it may return
        # BooleanFalse or BooleanTrue instead of True or False,
        # so use == for comparison instead of `is`
        if is_zero == False:
            # we found something that is definitely not zero
            return (i, x, False, newly_determined)
        possible_zeros.append(is_zero)

    # by this point, we've found no certain non-zeros
    if all(possible_zeros):
        # if everything is definitely zero, we have
        # no pivot
        return (None, None, False, newly_determined)

    # PASS 2 (iszerofunc after simplify)
    # we haven't found any for-sure non-zeros, so
    # go through the elements iszerofunc couldn't
    # make a determination about and opportunistically
    # simplify to see if we find something
    for i, x in enumerate(col):
        if possible_zeros[i] is not None:
            continue
        simped = simpfunc(x)
        is_zero = iszerofunc(simped)
        if is_zero == True or is_zero == False:
            newly_determined.append((i, simped))
        if is_zero == False:
            return (i, simped, False, newly_determined)
        possible_zeros[i] = is_zero

    # after simplifying, some things that were recognized
    # as zeros might be zeros
    if all(possible_zeros):
        # if everything is definitely zero, we have
        # no pivot
        return (None, None, False, newly_determined)

    # PASS 3 (.equals(0))
    # some expressions fail to simplify to zero, but
    # ``.equals(0)`` evaluates to True.  As a last-ditch
    # attempt, apply ``.equals`` to these expressions
    for i, x in enumerate(col):
        if possible_zeros[i] is not None:
            continue
        if x.equals(S.Zero):
            # ``.iszero`` may return False with
            # an implicit assumption (e.g., ``x.equals(0)``
            # when ``x`` is a symbol), so only treat it
            # as proved when ``.equals(0)`` returns True
            possible_zeros[i] = True
            newly_determined.append((i, S.Zero))

    if all(possible_zeros):
        return (None, None, False, newly_determined)

    # at this point there is nothing that could definitely
    # be a pivot.  To maintain compatibility with existing
    # behavior, we'll assume that an illdetermined thing is
    # non-zero.  We should probably raise a warning in this case
    i = possible_zeros.index(None)
    return (i, col[i], True, newly_determined)

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
		pivot_offset, pivot_val, \
		assumed_nonzero, newly_determined = _find_reasonable_pivot_naive(
			get_col(piv_col)[piv_row:], iszerofunc, simpfunc)

		# pivot_offset, pivot_val = get_pivot(get_col (piv_col) [piv_row:])
		# assumed_nonzero = False
		# newly_determined = []

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

def test(n):
	for _ in range (n): 
		row1 = get_combo()
		row2 = get_combo()
		row3 = get_combo()
		row4 = get_combo()
		row5 = get_combo()

		rows = [row1, row2, row3, row4, row5]

		for row in rows: 

			index1, val1, assumed1, determined1 = _find_reasonable_pivot_naive (row)
			index2, val2 = get_pivot (row)
			index3, val3, assumed2, determined2 = _find_reasonable_pivot (row)

			assert (index1 == index2 == index3) and (val1 == val2 == val3)
			assert (assumed1 == assumed2) and assumed2 is False
			assert (determined1 == determined2) and determined2 == []


		matrix = Matrix (rows)
		result1, _, __ = _row_reduce (
			matrix, 
			iszerofunc = lambda x: x == 0,
			simpfunc = lambda x: x,
			normalize_last = True,
			normalize = True,
			zero_above = True
		)

		result3, pivots = rref (matrix)
		assert result1 == result3, f"{result1}\n{result3}"

		assert rref (matrix) [0] == matrix.rref() [0], f"{rref (matrix)}\n{matrix.rref()}"


test(1_000)