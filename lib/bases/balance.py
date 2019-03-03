from chemicals import Molecule
from collections import Counter

from my_stuff.misc import init
from my_stuff.nums import is_even
from my_stuff.lists import find_in_list

def filter_list (List: list, func: type) -> list:
	new_list = [
		element 
		for element in List
		if func (element)
	]
	
	return new_list if new_list else List

class Side: 
	def __init__ (self, formula: str):
		self.molecules: [Molecule] = self.get_molecules(formula)
		self.elements: {"Element": int} = self.get_elements()

	def __repr__ (self): return f"Side ({self})"
	def __str__ (self): return " + ".join ([
		f"{format (count, ',') if count != 1 else ''}{molecule._base_molecule}" 
		for molecule, count in self.molecules.items()
	])

	def get_molecules (self, formula: str) -> [Molecule]: return {
		Molecule (molecule._base_molecule): molecule.coefficient
		for molecule in map (Molecule, formula.split (" + "))
	}

	def get_elements (self) -> {"Element": int}: 
		elements: Counter = Counter()
		for molecule, coefficient, in self.molecules.items():
			for element, count in molecule.elements.items():
				elements [element] += count * coefficient

		return elements

	def increase (self, molecule: Molecule) -> None: 
		self.molecules [molecule] += 1
		self.elements: {"Element": int} = self.get_elements()

	def get_side_parity (self, molecule): return len ([
		None
		for element, count in molecule.elements.items()
		if is_even (count + self.elements [element])
	])

class Equation: 
	def __init__ (self, formula: str): 
		self.sides: (Side, Side) = tuple (map (Side, formula.split(" --> ")))
		self.left, self.right = self.sides
		self.verify()
		self.last_element = None

	def __repr__ (self): return f"Equation ({self})"
	def __str__ (self): return " --> ".join (map (str, self.sides))

	def balanced (self) -> bool: return self.left.elements == self.right.elements
	def verify (self) -> None: # check for inconsistencies
		if (
			any (
				element not in self.right.elements 
				for element in self.left.elements
			) or
			any (
				element not in self.left.elements
				for element in self.right.elements
			)
		): raise SyntaxError (f"There is an inconsistency in {self}")

	def get_displaced_element (self) -> "Element": return filter_list (
		[
			element 
			for element, count in self.left.elements.items()
			if self.right.elements [element] != count
		],
		lambda element: element != self.last_element
	) [0]



	def get_molecule (self, side: Side, element: "Element", even: bool) -> Molecule:
		molecules: [Molecule] = [
			molecule 
			for molecule in side.molecules
			if element in molecule.elements
		]
		other_side: Side = self.left if side is self.right else self.right
		molecules.sort (key = lambda molecule: molecule.elements [element]) # find least of
		molecules: [(Molecule, int)] = [
			(molecule, self.get_stable_count (molecule, other_side)) 
			for molecule in molecules
		]
		molecules.sort (key = lambda tup: tup [1]) # sort on stability
		preffered: (Molecule, None) = find_in_list (
			molecules, 
			lambda tup: is_even (tup [0].elements [element]) == even
		)
		if (
			preffered is None or # no matching parity
			(even and (preffered [1] != molecules [0] [1])) # different stability
		): preffered: Molecule = molecules [0]
		return preffered [0]

		"""
		least
		least stable
		even/odd rule -- self
		even/odd rule -- others

		"""

		molecules = [
			molecule 
			for molecule in side.molecules
			if element in molecule.elements
		]
		# sort on least of self
		molecules.sort (key = lambda molecule: molecule.elements [element])
		molecules.sort (  # sort on stability
			key = lambda molecule: self.get_stable_count (molecule, other_side)
		)
		parity_molecules = filter_list (
			molecules, 
			lambda molecule: is_even (molecule.elements [element] == even)
		)
		parity_molecules.sort (key = side.get_side_parity, reverse = True)
		return parity_molecules [0]


	def get_stable_count (self, molecule: Molecule, other_side: Side) -> int: return len ([
		element 
		for element in molecule.elements
		if (
			self.right.elements [element] == self.left.elements [element] and
			not any (
				len (molecule.elements) == 1 and element in molecule.elements # isolated
				for molecule in other_side.molecules
			)
		)
	])

	def balance (self) -> None: 
		counter: int = 0 # for stopping infinite loops
		while not self.balanced():
			if counter == 1000: raise ValueError (f"Cannot be balanced [{self}]")
			element: Element = self.get_displaced_element()
			self.last_element = element
			side: Side = min (self.sides, key = lambda side: side.elements [element])
			even: bool = is_even (side.elements [element]) 
			molecule: Molecule = self.get_molecule (side, element, even)
			side.increase (molecule)
			counter += 1

def balance (input_: str) -> Equation: 
	equation: Equation = Equation (input_) 
	equation.balance()
	return equation


if __name__ == '__main__': 
	from argparse import ArgumentParser
	parser = ArgumentParser()
	parser.add_argument ("formula", nargs = "*", help = "Equation to balance")
	args = parser.parse_args()
	# print (args.formula [0])
	eq = args.formula [0]
	print (type (eq))
	print (balance (eq))