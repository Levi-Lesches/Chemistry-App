import "side.dart";
import "element.dart";
import "molecule.dart";
import "../helpers/counter.dart";
import "../helpers/matrix.dart";
import "../helpers/range.dart";

class Equation {
	final Side left, right;
	Counter<Element> elements;

	Equation._ (this.left, this.right) {
		verify();
		this.elements = left.elements;  // just cuz
	}

	factory Equation (String equation) {
		final List<String> sides = equation.split(" --> ");
		assert (sides.length == 2, "Equation recieved too many parts: $equation");
		final Side left = Side (sides [0]);
		final Side right = Side (sides [1]); 
		return Equation._(left, right);
	}

	@override String toString() => "$left --> $right";

	void verify() {
		if (
			left.elements.any(
				(CounterEntry<Element> element) => 
					!right.elements.contains (element.value)
			) || right.elements.any(
				(CounterEntry<Element> element) => 
					!left.elements.contains(element.value)
			)
		) throw "There is an inconsistency in $this";
	}

	Matrix get matrix {
		final List<List<int>> matrix = [];
		for (final CounterEntry<Element> element in left.elements) {
			final List<int> row = [];
			for (final CounterEntry<Molecule> molecule in left.molecules)
				row.add (
					(molecule.value.elementsList.contains(element.value))
						? molecule.value.elements [element.value] * -1
						: 0
				);

			for (final CounterEntry<Molecule> molecule in right.molecules) 
				row.add (
					(molecule.value.elementsList.contains (element.value))
						? molecule.value.elements [element.value]
						: 0
				);

			matrix.add (row);
		}
		return Matrix (matrix);
	}
	
	bool get balanced => left.elements == right.elements;

	void setCoefficients(List<int> nullspace) {
		int endIndex;
		for (final int index in range (left.molecules.length)) {
			final Molecule molecule = left.molecules.elements [index];
			left.molecules [molecule] = nullspace [index];
			endIndex = index;
		}

		for (final int index2 in range (right.molecules.length)) {
			final Molecule molecule = right.molecules.elements [index2];
			right.molecules [molecule] = nullspace [endIndex + index2 + 1];
		}
	}

	void balance() {
		setCoefficients(matrix.nullspace);
		assert (this.balanced);
	}
}

Equation balance (String input) {
	final Equation equation = Equation (input);
	equation.balance();
	return equation;
}