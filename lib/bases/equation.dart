import "side.dart";
import "element.dart";
import "molecule.dart";
import "../helpers/counter.dart";

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
		final Side _left = Side (sides [0]);
		final Side _right = Side (sides [1]); 
		return Equation._(_left, _right);
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

	bool get balanced => left.elements == right.elements;

	void balance() {
		final List<List<int>> matrix = [];
		for (CounterEntry<Element> element in elements) {
			final List<int> row = [];
			for (CounterEntry<Molecule> molecule in left.molecules) {
				if (molecule.value.elements.contains(element.value))
					row.add (-1 * molecule.value.elements [element.value]);
				else row.add(0);
			}
			for (CounterEntry<Molecule> molecule in right.molecules) { 
				if (molecule.value.elements.contains(element.value)) 
					row.add (molecule.value.elements [element.value]);
				else row.add (0);
			}
			matrix.add (row);
		}
	}
}

Equation balance (String input) {
	final Equation equation = Equation (input);
	equation.balance();
	return equation;
}