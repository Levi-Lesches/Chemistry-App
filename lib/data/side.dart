import "molecule.dart";
import "element.dart";

import "package:chemistry/helpers/counter.dart";

class Side {
	final Counter <Molecule> molecules;
	Counter <Element> get elements => getElements (molecules);
	static final RegExp regex = RegExp ("(\d*[A-Z][a-z]?\d*)+( \+ (\d*[A-Z][a-z]?\d*)+)*");

	Side (formula) : molecules = getMolecules (formula);

	@override String toString() => molecules.map(
		(CounterEntry<Molecule> entry) => 
			"${entry.count == 1 ? '' : entry.count}"
			"${entry.value.baseFormula}"
	).join(" + ");

	Side.fromMolecules (Iterable<Molecule> molecules) : 
		molecules = Counter<Molecule>(molecules);

	static Counter <Molecule> getMolecules(String formula) => Counter.fromMap(
		Map.fromIterable (
			formula.split (" + ").map<Molecule> (
				(String molecule) => Molecule (molecule)
			),
			key: (molecule) => Molecule (molecule.baseFormula),
			value: (molecule) => molecule.coefficient
		)
	);

	static Counter <Element> getElements (Counter <Molecule> molecules) {
		final Counter<Element> result = Counter();
		for (final CounterEntry<Molecule> molecule in molecules) {
			for (CounterEntry<Element> element in molecule.value.elements) {
				result [element.value] += element.count * molecule.count;
			}
		}
		return result;
	}
}
