import "side.dart";
import "element.dart";
import "molecule.dart";
import "../helpers/counter.dart";

List<E> filter<E> (List <E> list, bool Function (E) test) {
	final List<E> result = list.where(test).toList();
	return result.length >= 1 ? result : list;
}

class MoleculeCount {
	final Molecule molecule;
	final int count;
	const MoleculeCount(this.molecule, this.count);
}


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

	bool get balanced => left.elements == right.elements;

	Element getDisplacedElement() {
		final List<Element> temp = left.elements
			.where (
				(CounterEntry<Element> element) => 
					right.elements [element.value] != element.count)
			.map ((CounterEntry<Element> element) => element.value)
			.toList();
		return filter<Element> (
			temp, 
			(Element element) => element != lastElement
		) [0];
	}

	int getStableCount (Molecule molecule, Side otherSide) => 
		molecule.elementsList.where(
			(Element element) => (
				right.elements [element] == left.elements [element] &&
				!otherSide.molecules.elements.any(
					(Molecule molecule) => (
						molecule.elements.length == 1 &&
						molecule.elements.contains (element)
					)
				)
			)
		).length; 

	Molecule getMolecule (Side side, Element element, bool even) {
		List<Molecule> molecules = side.molecules.elements.where (
			(Molecule molecule) => molecule.elementsList.contains (element)
		).toList();

		final Side otherSide = side == right ? left : right;
		molecules.sort(
			(Molecule a, Molecule b) =>
				a.elements [element] - b.elements [element]
		);

		final List<MoleculeCount> moleculeCounts = molecules.map (
			(Molecule molecule) => MoleculeCount (
				molecule, getStableCount (molecule, otherSide)
			)
		).toList();
		moleculeCounts.sort (
			(MoleculeCount a, MoleculeCount b) => 
				a.count - b.count
		);

		MoleculeCount preffered = moleculeCounts.firstWhere(
			(MoleculeCount moleculeCount) => 
				moleculeCount.count.isEven == even,
			orElse: () => moleculeCounts [0]
		);
		if (
			preffered == null ||
			(even && (preffered.count != moleculeCounts [0].count))
		) preffered = moleculeCounts [0];
		return preffered.molecule;
	}

	void balance() {
		int counter = 0;  // stops infinite loops
		while (!balanced) {
			if (counter == 1000) throw "Cannot balance $this";
			final Element element = getDisplacedElement();
			lastElement = element;
			final Side side = left.elements [element] < right.elements [element]
				? left
				: right;
			final bool even = side.elements [element].isEven;
			final Molecule molecule = getMolecule (side, element, even);
			side.increase(molecule);
			counter++;
		}
	}
}

Equation balance (String input) {
	final Equation equation = Equation (input);
	equation.balance();
	return equation;
}