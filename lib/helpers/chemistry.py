from my_stuff.misc import init

SINGLE = "Single"
DOUBLE = "Double"
TRIPLE = "Triple"

class Position: 
	@init
	def __init__(self, row = 0, col = 0): pass
	def __iter__(self): return iter ( (self.row, self.col) )
	def __repr__(self): return f"Position ({self.row}, {self.col})"

class Node: 
	@init
	def __init__(self, element: str): self.bonds = []
	def __repr__(self): return self.element
	def bond (a, b): 
		if type (b) is list or type (b) is tuple: 
			a.bonds.extend (b)
			for node in b: node.bonds.append(a)
		else: 
			a.bonds.append (b)
			b.bonds.append (a)

# class Bond: 
# 	@init
# 	def __init__(self, element1: str, element2: str, type: str = SINGLE): pass


class Matrix: 
	def __init__(self): self.matrix = {0: []}
	def __len__(self): return len (self.matrix)
	def __contains__(self, pos: Position): return pos.row in self.matrix
	def __setitem__(self, pos: Position, value): self.matrix [pos.row] [pos.col] = value
	def __iter__(self): return iter (self.matrix.values())

	def __getitem__(self, pos: Position):
		return self.matrix [pos.row]

	def output(self): return sorted (self.matrix.items())
	def is_valid (self, pos: Position): return (
		pos in self and pos.col + 1 <= len (self.matrix [pos.row])
	)

	def add_row(self, pos: Position): 
		assert pos.row not in self.matrix, f"Row {pos.row} already exists"
		self.matrix [pos.row] = [None] * pos.col

	def get_rows(self): return iter (self.matrix.values())


def paint (nodes): 
	matrix: Matrix = Matrix()

	def expand (pivot: Node, previous: Node = None, current: Position = Position()): 
		if current not in matrix: matrix.add_row (current)
		if matrix.is_valid (current): matrix [current] = pivot
		else: matrix [current].append (pivot)

		# 
		for row in matrix.get_rows():
			# row = matrix.get_row (row)
			if len (row) < current.col: 
				row.append (None)

		row, col = current
		directions: [Position] = None

		pos1 = Position (row - 1, col)
		pos2 = Position (row + 1, col)
		if (
			matrix.is_valid(pos1) and 
			len (matrix [pos1]) == len (matrix [current])
			and matrix [pos1] [pos1.col] is not None
		):
			directions = [
				Position (row + 1, col), 
				Position (row, col - 1), 
				Position (row, col + 1)
			]
		elif (
			matrix.is_valid (pos2) and 
			len (matrix [pos2]) == len (matrix [current]) and
			matrix [pos2] [pos2.col] is not None
		):
			directions = [
				Position (row - 1, col),
				Position (row, col + 1),
				Position (row, col - 1)
			]
		else: directions = [
			Position (row, col + 1),
			Position (row + 1, col),
			Position (row - 1, col)
		]

		agenda: [Node] = sorted (
			[
				node 
				for node in pivot.bonds
				if previous is None or node != previous
			], 
			key = lambda node: len (node.bonds),
			reverse = True
		)

		index: int = len (matrix.matrix [row]) - 1
		for length in (3, 2, 1): 
			if len (agenda) >= length: expand (
				agenda [length - 1],
				previous = pivot, 
				current = directions [length - 1]
			)

	def evaluate(pivot: Node):
		result = 0
		for node in pivot.bonds: 
			for node2 in node.bonds: 
				for node3 in node2.bonds: result += len (node3.bonds)
		return result


	expand (min (filter (lambda node: len (node.bonds) == 1, nodes), key = evaluate))
	max_length = max (map (len, matrix))
	for row in matrix: 
		if len (row) != max_length: 
			row.append (None)
	return matrix.output()

def present(nodes: [Node]): 
	result = ""
	temp = paint (nodes)
	print (temp)
	for index, (_, row) in enumerate (temp):
		row_sep = "\n"
		for index2, node in enumerate (row): 
			if node is None: 
				result += "  "
				row_sep += "  "
			else: 
				result += repr (node)
				if (
					index2 != len (row) - 1 and 
					row [index2 + 1] is not None
				): result +=  "-"
				if index != len (temp) - 1 and temp [index + 1] [1] [index2] is not None: 
					row_sep +=  "| "
				else: row_sep += "  "
		result += (row_sep + "\n")
	print (result)

c1 = Node("C")
c2 = Node("C")
h1 = Node("H")
h2 = Node("H")
h3 = Node("H")
h4 = Node("H")
h5 = Node("H")
h6 = Node("H")
Node.bond (c1, [c2, h1, h2, h4])
Node.bond (c2, [h3, h5, h6])
present ([c1, c2, h1, h2, h3, h4, h5, h6])

c = Node ("C")
o1 = Node ("O")
o2 = Node ("O")
Node.bond (c, [o1, o2])
present ([c, o1, o2])

h1 = Node ("H")
h2 = Node ("H")
o = Node ("O")
Node.bond (o, [h1, h2])
present ([o, h1, h2])

n = Node ("N")
h1 = Node ("H")
h2 = Node ("H")
h3 = Node ("H")
Node.bond (n, [h1, h2, h3])
present ([n, h1, h2, h3])

h1 = Node ("H")
h2 = Node ("H")
h3 = Node ("H")
h4 = Node ("H")
h5 = Node ("H")
h6 = Node ("H")
o = Node ("O")
c1 = Node ("C")
c2 = Node ("C")
Node.bond (c1, [h1, o, c2, h5])
Node.bond (c2, [h3, h4, h6])
Node.bond (o, h2)
present ([o, h1, h2, h3, h4, h5, h6, c1, c2])

h1 = Node ("H")
h2 = Node ("H")
h3 = Node ("H")
h4 = Node ("H")
h5 = Node ("H")
h6 = Node ("H")
h7 = Node ("H")
h8 = Node ("H")
h9 = Node ("H")
h10 = Node ("H")
h11 = Node ("H")
h12 = Node ("H")

c1 = Node ("C")
c2 = Node ("C")
c3 = Node ("C")
c4 = Node ("C")
c5 = Node ("C")
c6 = Node ("C")

o1 = Node ("O")
o2 = Node ("O")
o3 = Node ("O")
o4 = Node ("O")
o5 = Node ("O")
o6 = Node ("O")

Node.bond (c1, [c2, h1, o1, h3])
Node.bond (o1, h2)
Node.bond (c2, [o2, h5, c3])
Node.bond (o2, h4)
Node.bond (c3, [h7, o3, c4])
Node.bond (o3, h6)
Node.bond (c4, [o4, h9, c5])
Node.bond (o4, h8)
Node.bond (c5, [o5, h11, c6])
Node.bond (o5, h10)
Node.bond (c6, [h12, o6])

present ([c1, c2, c3, c4, c5, c6, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, o1, o2, o3, o4, o5, o6])