import "molecule.dart";
import "element.dart";

import "../helpers/counter.dart";

class Side {
	final String formula;
	final Counter <Molecule> molecules;
	Counter <Element> get elements => getElements (molecules);

	Side (this.formula) : molecules = getMolecules (formula);

	@override String toString() => molecules.map(
		(CounterEntry<Molecule> entry) => 
			"${entry.count == 1 ? '' : entry.count}"
			"${entry.value.baseFormula}"
	).join(" + ");

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

	void increase (Molecule molecule) {molecules [molecule] += 1;}

	int getSideParity (Molecule molecule) => molecule.elements.where (
		(CounterEntry<Element> element) => 
			(element.count + elements [element.value]).isEven
	).length;
}