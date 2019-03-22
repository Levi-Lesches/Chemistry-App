
import "package:flutter/foundation.dart";

import "element.dart";

import "../helpers/strings.dart";
import "../helpers/counter.dart";
import "../helpers/roman.dart" as Roman;
import "../helpers/names.dart";
import "../helpers/range.dart";

import "package:chemistry/constants.dart";
import "package:chemistry/periodic_table.dart" show periodicTable;

int getCoefficient (String text, int index) => isInt (text [index])
	? getInt (text, index)
	: 1;

class Molecule {
	final String formula;
	Counter <Element> elements;
	Counter <String> elementNames;
	List <Element> elementsList;
	String baseFormula, name;
	double mass;
	MoleculeType type;
	int coefficient;

	Molecule (this.formula) {
		elements = getElements();
		elementNames = getElementNames();
		elementsList = elements.elements;
		baseFormula = getBaseFormula();
		mass = getMass();
		type = getType();
		name = getName();
		coefficient = moleculeCoefficient();
	}

	@override toString() => "Molecule ($formula)";

	Counter <Element> getElements([formula]) {
		formula = formula ?? this.formula;
		Counter <Element> result = Counter();

		// Recursion -- recurse over each parenthesis
		Counter <Element> subElements = Counter();
		final List <int> skips = [];
		// final RegExp regex = RegExp (r"\((\w|\()+\)(\)|\d)*");
		// group 1: alphanum | opening | closing
		// group 2: coefficient
		final RegExp regex = RegExp (r"\(([\w\(\)]+)\)(\d*)");
		final Iterable <Match> nestedParens = regex.allMatches(formula);
		for (final Match nestedFormula in nestedParens) {
			final String match = nestedFormula.group (1);
			final num = nestedFormula.group (2);
			final int coefficient = num.isEmpty 
				? 1
				: int.parse (num);

			Counter <Element> sub = getElements (match);
			sub *= coefficient;
			List <int> indices = range (
				nestedFormula.end - 2,
				start: nestedFormula.start 
			);
			skips.addAll(indices);
			subElements += sub;
		}

		// Base case:
		final int coefficient = getCoefficient (formula, 0);
		// group 0: Uppercase -> Maybe (lowercase)
		// group 1: 0 <= (digit)
		final RegExp elementRegex = RegExp(r"([A-Z][a-z]?)(\d*)");

		for (final Match match in elementRegex.allMatches (formula)) {
			if (skips.contains (match.start)) continue;
			final Element element = periodicTable [match.group (1)];
			final String num = match.group(2);
			final int count = num.isEmpty || num == null
				? 1
				: int.parse (num);
			result [element] += count;
		}

		result += subElements;
		result *= coefficient;
		return result;
	}

	Counter <String> getElementNames () {
		final Counter <String> result = Counter();
		for (final CounterEntry<Element> entry in this.elements) {
			final Element element = entry.value;
			final int count = entry.count;
			final String name = element.name;
			result [name] = count;
		}
		return result;
	}

	String getBaseFormula () {
		String result = formula.substring (consumeInt (formula, 0));
		if (result.startsWith("(")) {
			assert (
				result.endsWith (")"),
				"Opening parenthesis not closed -- $formula"
			);
			result = result.substring (1, -1);
		}
		return result;
	}

	double getMass() => elementsList.fold <double> (
		0,
		(double prev, Element element) => prev + element.mass
	);

	MoleculeType getType() {
		if (elementsList.length == 1) return MoleculeType.element;
		else if (
			<int> [1, 2, 3].contains (elementsList [0].group)
			&& <int> [5, 6, 7].contains (elementsList [1].group)
			&& elementsList [0].symbol == "Be"
			|| [3, 4, 7, 8].contains (elementsList [0].series)
			|| baseFormula.startsWith ("NH4")
		) return MoleculeType.ionic;
		else return MoleculeType.molecular;
	}

	String getName() {
		switch (type) {
			case MoleculeType.molecular: return getMolecularName(); break;
			case MoleculeType.element: return getElementName(); break;
			case MoleculeType.ionic: return getIonicName(); break;
			case MoleculeType.acid: return getAcidName(); break;
			default: throw "Unknown molecule type: $formula.";
		}
	}

	String getMolecularName() {
		assert (
			elementsList.length > 1,
			"Misclassified molecule $formula as molecule and not element."
		);
		if (elementsList.length > 2)
			return "Unknown (Compound has > 2 elements)";

		Element element1 = elementsList [0], element2 = elementsList [1];
		int count1 = elements [element1], count2 = elements [element2];
		assert (
			count1 > 0 && count2 > 0,
			"Received 0 elements -- $formula."
		);
		if (count1 > 10 || count2 > 10)
			return "Unknown (Element count > 10 not supported)";

		String prefix1 = PREFIXES [count1], prefix2 = PREFIXES [count2];
		String name1 = element1
			.name
			.toLowerCase()
			.replaceFirstMapped (
				prefix1 [prefix1.length - 1],
				(Match match) => match.start == 0
					? ""
					: match.group (0)
			);
		String name2 = element2
			.name
			.toLowerCase()
			.replaceFirst (prefix2 [prefix2.length - 1], "");
		String baseName = getBaseName (name2);

		if (prefix1 == "Mono") {
			prefix1 = "";
			name1 = title (name1);
		}

		String specialName = polyatomicIons.keys.contains (baseFormula)
			? " (${polyatomicIons [baseFormula].name})"
			: "";

		return "$prefix1$name1 $prefix2${baseName}ide$specialName";
	}

	String getElementName() {
		String special = polyatomicIons.keys.contains (baseFormula)
			? " (${polyatomicIons [baseFormula].name})"
			: "";
		return elementsList [0].name + special;
	}

	String getIonicName() {
		Element cation = elementsList [0], anion;
		List <Element> anions = elementsList.sublist (1);
		String charge, cationName, anionName;
		if (baseFormula.startsWith ("NH4")) {
			cationName = "Ammonium";
			if (baseFormula == "NH4") return "Ammonium";
			else anion = elementsList [elementsList.length - 1];
		} else {
			// get cation
			List <int> cationCharges = cation.getCharge();
			if (cationCharges.length > 1) {  // Have roman numerals
				if (anions.length == 1) {  // not polyatomic
					anion = anions [0];
					List <int> anionCharges = anion.getCharge();
					if (anionCharges.length > 1) return "Unknown"
						"(Cation and anion both have > 1 possible charge)";
					int anionCharge = anionCharges [0];
					try {
						int cationCharge = calcCharge (
							possibleCharges: cationCharges,
							count: elements [cation],
							otherCharge: anionCharge,
							otherCount: elements [anion]
						);
						charge = "(${Roman.toRoman (cationCharge)})";
					} on RangeError {return "Unknown (Molecule is not neutral)";}
				} else {  // polyatomic ion
					final _PolyatomicPart polyatomicIon = getPolyatomicIon (cation);
					if (polyatomicIon == null) return "Unknown "
						"(Unrecognized polyatomic ion: $formula/$cation)";

					try {
						int cationCharge = calcCharge (
							possibleCharges: cationCharges,
							count: elements [cation],
							otherCharge: polyatomicIon.charge,
							otherCount: polyatomicIon.count
						);
						charge = "(${Roman.toRoman (cationCharge)})";
					} on RangeError {return "Unknown (Molecule is not neutral)";}
				}
				cationName = "${title (cation.name)}$charge";
			} else cationName = title (cation.name);
		}  // if not ammonium

		if (anion != null || anions.length == 1) {
			anion = anion ?? anions [0];
			anionName = "${title (getBaseName (anion.name))}ide";
		} else {
			_PolyatomicPart polyatomicIon = getPolyatomicIon (cation);
			if (polyatomicIon == null) return "Unknown"
				"(Unrecognized polyatomic ion: $formula/$cation)";
			else anionName = polyatomicIon.name;
		}

		return "$cationName $anionName";  // Phew
	}

	String getAcidName() => "Unknown (Acids not implemented)";

	static int calcCharge ({
			@required List <int> possibleCharges,
			@required int count,
			@required int otherCharge,
			@required int otherCount,
	}) {
		int targetCharge = otherCharge * otherCount;  // O2 -> -2
		targetCharge *= -1;  // eg, O2 needs +1 to cancel
		for (int charge in possibleCharges) {
			if (targetCharge / charge == count) return charge;
		}
		throw RangeError(
			"No possible charge can be computed for $count ions to cancel out"
			" a charge of ${targetCharge * -1}."
		);
	}

	_PolyatomicPart getPolyatomicIon (Element cation) {
		int index = formula.indexOf (cation.symbol) + cation.symbol.length;
		final String subFormula = formula.substring (index);

		// Maybe ("(", include = false)
		// Group (Captital -> Maybe (Lowercase) -> Maybe (digit), label = false)+
		// Group (Maybe (")") -> Maybe (digit), label = false) 
		final RegExp regex = RegExp (r"(?=\(?)(?:[A-Z][a-z]?\d?)+(?:\)?\d?)");
		final String match = regex.stringMatch (subFormula);
		if (match.contains(")")) {
			final List <String> temp = match.split (")");
			final PolyatomicIon polyatomicIon = polyatomicIons [temp [0]];
			return polyatomicIon == null 
				? null
				: _PolyatomicPart (
					polyatomicIon, 
					int.parse (temp [1])
				);
		} else {
			final PolyatomicIon polyatomicIon = polyatomicIons [match];
			return polyatomicIon == null 
				? null 
				: _PolyatomicPart (
					polyatomicIon,
					1
				);
		}
	}

	String details() => """
		Molecule $formula:
			Name: $name,
			Type of molecule: $type,
			Elements: $elementNames,
			Mass: $mass
			Base formula: $baseFormula,
		""";

	int moleculeCoefficient() => getCoefficient (formula, 0);
}

class _PolyatomicPart {
	final PolyatomicIon polyatomicIon;
	final int count, charge;
	final String name;


	_PolyatomicPart (this.polyatomicIon, this.count) :
		charge = polyatomicIon.charge,
		name = polyatomicIon.name;

	@override String toString() => "PolyatomicPart ($polyatomicIon, $count)";
}