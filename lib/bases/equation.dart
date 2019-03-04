import "side.dart";
import "element.dart";
import "molecule.dart";
import "../helpers/counter.dart";

// Test this function
List<E> filter<E> (List <E> list, bool Function (E) test) {
	final List<E> result = list.where(test).toList();
	return result.isEmpty ? list : result;
}

void sort<E> (List<E> list, int Function (E) key, {bool reverse = false}) => 
	list.sort(
		(E a, E b) {
			final int result1 = key (a), result2 = key (b);
			if (reverse) return result2 - result1;
			else return result1 - result2;
		}
	);

int boolToInt(bool value) => value ? 1 : 0;

class Equation {
	final Side left, right;
	Element lastElement;

	Equation._ (this.left, this.right) {verify();}

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

	bool avoidRepeat(Element element) => 
		lastElement == null || element != lastElement;

	bool get balanced => left.elements == right.elements;

	Element get element => filter<Element> (
		left.elements.elements.where(
			(Element element) => 
				left.elements [element] != right.elements [element]
		).toList(),
		avoidRepeat
	) [0];

	List<Side> getSides (Element element) {
		final List<Side> sides = [left, right];
		sort<Side> (
			sides,
			(Side side) => side.elements [element]
		);
		return sides;
	}

	Molecule getMolecule (List<Side> sides, Element element) {
		// This function works by compiling a list of candidate molecules.
		// Then it sorts them by manu different criterium.
		// This is from least importand to most important
		// Note: Dart's sort function is not necessarily stable, so...
		final Side side = sides [0], otherSide = sides [1];
		final List<Molecule> molecules = side.molecules.elements.where(
			(Molecule molecule) => molecule.elements.contains (element)
		);
		sort<Molecule> (  // Prefer molecules that make other elements even
			molecules,
			(Molecule molecule) => molecule.elements.where (
				(CounterEntry<Element> _element) => 
					(side.elements [_element.value] + _element.count).isEven
			).length,
			reverse: true
		);

		sort<Molecule> (  // Prefer molecules where element will be even
			molecules, 
			(Molecule molecule) => boolToInt (
				(side.elements [element] + molecule.elements [element]).isEven 
				== side.elements [element].isEven
			),
			reverse: true
		);

		sort<Molecule> (  // Prefer molecules with the least elements
			molecules, 
			(Molecule molecule) => molecule.elements.length - 1
		);

		sort<Molecule> (  // Prefer molecules with the least stable elements
			molecules, 
			(Molecule molecule) => molecule.elements.where (
				(CounterEntry<Element> _element) => (
					otherSide.elements [_element.value] == 
					side.elements [_element.value]
				)
			).length
		);

		return molecules [0]; 
	}

}

Equation balance (String input) {
	final Equation equation = Equation (input);
	equation.balance();
	return equation;
}