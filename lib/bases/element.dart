import "isotope.dart";
import "package:chemistry/constants.dart";

class Element {
	final int number, electrons, protons, group, period, series;
	final String symbol, name, block, eleconfig, oxistates, description;
	final List<double> ionEnergy;
	final Map <int, Isotope> isotopes;
	final double mass, eleneg, eleaffin;
	final double covrad, atmrad, vdwrad;
	final double tboil, tmelt, density;

	const Element (
		this.number, 
		this.symbol,
		this.name, 
		{
			this.mass, 
			this.ionEnergy, this.isotopes, this.eleneg, this.eleaffin,  // particles
			this.group, this.period, this.block, this.series,  // table
			this.covrad, this.atmrad, this.vdwrad, // radii
			this.tboil, this.tmelt, this.density,  // element properties
			this.eleconfig, this.oxistates,
			this.description
		}
	) : electrons = number, protons = number;

	@override String toString() => name;
	@override int get hashCode => symbol.hashCode; 

	@override 
	bool operator == (other) => (
		other.runtimeType == Element 
		&& this.symbol == other.symbol
	);

	String details() {
		final List <String> energyList = [];
		for (int index = 0; index < ionEnergy.length; index++) {
			if (index != 0 && index % 5 == 0) 
				energyList.add ("\n" + (" " * 15));
			energyList.add( ("${ionEnergy [index]}, "));
		}
		final String energy = energyList.join (" ");

		final List <String> isotopeList = [];
		for (MapEntry entry in isotopes.entries) {
			final int index = entry.key;
			final Isotope isotope = entry.value;
			isotopeList.add (
				"$index: Isotope (${isotope.mass}, ${isotope.abundance}, $index)"
			);
		}
		final String isotopeString = isotopeList.join(",\n\t\t\t\t");

		return """
			Element(
				$number, '$symbol', '$name',
				group: $group, period: $period, block: $block, series: $series,
				mass: $mass, electronegativity: $eleneg, 
				electron affinity: $eleaffin, covalent radius: $covrad, 
				radius: $atmrad, van-der-waal radius: $vdwrad, 
				boiling point: $tboil, melting point: $tmelt, density: $density,
				electron configurtion: $eleconfig, 
				oxistates: $oxistates,
				ion energy: $energy,
				isotopes: $isotopeString
			)
		""";
	}

	int nominalMass() {
		int mass = 0;
		double abundance = 0;
		for (MapEntry entry in isotopes.entries) {
			int num = entry.key;
			Isotope isotope = entry.value;
			if (isotope.abundance > abundance) {
				abundance = isotope.abundance;
				mass = num;
			}
		}
		return mass;
	}

	int neutrons () => nominalMass() - protons;

	double exactMass() {
		final List <double> masses = [];
		for (Isotope isotope in isotopes.values) masses.add (
			isotope.mass * isotope.abundance
		);
		return masses.reduce((double a, double b) => a + b);
	}

	Map <List<int>, int> eleconfigMap() {
		final Map <List<dynamic>, int> result = {};

		for (
			String electron in eleconfig
				.split(" ").sublist (result.isEmpty ? 1 : 0)
		) {
			result [
				[
					int.parse (electron[0]), 
					electron[1]
				]
			] = electron.length > 2
				? int.parse(electron.substring(2))
				: 1;
		}

		return result;
	}

	List <int> electronShells () {
		final List<int> result = List.filled (7, 0);
		for (MapEntry <List<int>, int> entry in eleconfigMap().entries) {
			final int key = entry.key [0];
			final int value = entry.value;
			result [key - 1] += value;
		}
		result.removeWhere((int electrons) => electrons == 0);
		return result;
	}

	void verify() {
		assert (PERIODS.containsKey(period));
		assert (GROUPS.containsKey (group));
		assert (BLOCKS.containsKey (block));
		assert (SERIES.containsKey (series));

		assert (
			number == protons, 
			"Atomic number ($number) must equal protons ($protons) for $name" 
		);

		assert (
			protons == electrons,
			"Protons ($protons) must equal electrons ($electrons) for $name"
		);

		if (ionEnergy.length > 1) {
			double ionev = ionEnergy [0];
			for (double ionevTemp in ionEnergy.sublist (1)) {
				assert (
					ionevTemp >= ionev,
					"Ion energy not increasing for $name"
				);
				ionev = ionevTemp;
			}
		}

		double mass = 0, frac = 0;
		for (Isotope isotope in isotopes.values) {
			mass += (isotope.abundance * isotope.mass);
			frac += isotope.abundance;
		}
		assert (
			(mass - this.mass).abs() < 0.03,
			"Average mass of isotope masses ($mass) != $name's mass ($mass)"
		);

		assert (
			(frac - 1.0).abs() < 1e-9,
			"Sum of isotope abundances != 1 for $name"
		);
	}

	List <int> getCharge() {
		switch (group) {
			case 1: return [1];
			case 2: return [2];
			case 3: return [3];
			case 17: return [-1];
			case 16: return [-2];
			case 15: return [-3];
			case 18: return [];
			default: 
				if (symbol == "Al") return [3];
				else {
					final List <int> result = [];
					bool append = false;
					for (String charge in oxistates.split (", ")) {
						if (charge.contains ("*")) append = true;
						if (append) result.add (int.parse (charge.replaceAll ("*", "")));
					}
					return result;
				}
		}
	}
}