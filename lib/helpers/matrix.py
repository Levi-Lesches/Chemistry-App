from my_stuff.misc import init

def lcm (nums) -> int: 
    max_denom = float("-inf")
    denoms = set()
    for fraction in nums: 
        denoms.add(fraction.denom)
        if fraction.denom > max_denom: max_denom = fraction.denom

    result = max_denom
    while any (result % denom for denom in denoms): 
        result += max_denom

    return result

def expand_fractions(nullspace: [Fraction]) -> [int]: 
    lcd = lcm (nullspace)
    return [
        abs (val.num * (lcd // val.denom))
        for val in nullspace
    ]


class Fraction: 
    @init
    def init (self, num, denom, negative): pass
    def __repr__(self): return f"{'-' if self.negative else ''}({self.num}/{self.denom})"
    def __new__(cls, num, denom): 
        if denom == 0: raise ZeroDivisionError()
        negative: bool = num >= 0 != denom >= 0
        num = abs (num)
        denom = abs (denom)
        for n in range (num, 1, -1):  # simplify
            if not num % n and not denom % n: 
                num //= n
                denom //= n

        fraction: Fraction = object.__new__(cls)
        fraction.init(num, denom, negative)
        return fraction


class Matrix: 
    @init
    def __init__(self, matrix): self.rows, self.cols = self.set_shape()
    def __getitem__(self, p): return self.matrix [p[0]] [p[1]]
    def __eq__(self, other): return self.matrix == other.matrix
    def __len__(self): return self.rows * self.cols
    def __iter__(self): return iter (self.matrix)
    def __str__(self): return repr (self)
    def __repr__(self): return (
        "Matrix(" + 
        "".join (
            [
                f"\n\t{', '.join (map (str, row))}"
                for row in self
            ]
        ) + 
        "\n)"
    )

    def flatten(self): return [num for row in self for num in row]

    def set_shape(self): 
        rows = 0
        cols = None
        for row in self.matrix:
            if cols is None: cols = len (row)
            elif len (row) != cols: raise SyntaxError("Inconsistent dimensions")
            rows += 1
        return rows, cols

    def fromDimensions(rows, cols, List):
        result = []
        index = 0
        for row in range (rows):
            values = []
            for col in range (cols): 
                values.append (List [index])
                index += 1
            result.append (values)
        if index != len (List): raise SyntaxError("fromDimensions failed")
        return Matrix (result)

    def get_pivot (self, col: list) -> (int, int): 
        result_index = None
        result = None
        for index, value in enumerate (col): 
            if value != 0: return index, value
            else: 
                result_index = index
                result = value

        else:
            if all (num == 0 for num in col): return None, None
            else: return result_index, result

    def rref(self):
        cols = self.cols
        matrix = self.flatten()

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
            offset, value = self.get_pivot (get_col (pivot_col) [pivot_row:])

            if offset is None: 
                pivot_col += 1
                continue

            pivots.append (pivot_col)
            if offset != 0: swap_rows (pivot_row, offset + pivot_row)

            for row in range (self.rows): 
                if row == pivot_row: continue

                val = matrix [row * cols + pivot_col]
                if val == 0: continue
                else: cross_cancel (row, val, pivot_row, value)

            pivot_row += 1

        for index, col in enumerate (pivots):
            temp = index * cols + col
            value = matrix [temp]
            matrix [temp] = 1
            for index2 in range (temp + 1, (index + 1) * cols): 
                matrix [index2] = Fraction (matrix [index2], value)

        return Matrix.fromDimensions(self.rows, self.cols, matrix)

    def nullspace(self): 
        rref = self.rref()
        nullspace = [rref [n, -1] for n in range (rref.rows)]
        nullspace.extend ([1 for _ in range (rref.cols - len (nullspace))])

        for index, value in enumerate (nullspace): 
            if value == 0: nullspace [index] = 1

        return expand_fractions(nullspace)
