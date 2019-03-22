import "../compare.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chemistry/bases/equation.dart";

void main () {test ("Worksheet", testWorksheet);}

void testWorksheet() {
	final List<String> equations = [
		"H2 + O2 --> H2O",
		"N2 + H2 --> NH3",
		"N2 + H2O --> NH3 + NO",
		"S8 + O2 --> SO3",
		"N2 + O2 --> N2O",
		"HgO --> Hg + O2",
		"CO2 + H2O --> C6H12O6 + O2",
		"Zn + HCl --> ZnCl2 + H2",
		"SiCl4 + H2O --> H4SiO4 + HCl",
		"Na + H2O --> NaOH + H2",
		"H3PO4 --> H4P2O7 + H2O",
		"C10H16 + Cl2 --> C + HCl",
		"CO2 + NH3 --> OC(NH2)2 + H2O",
		"Si2H3 + O2 --> SiO2 + H2O3",
		"Al(OH)3 + H2SO4 --> Al2(SO4)3 + H2O",
		"Fe + O2 --> Fe2O3",
		"C7H6O2 + O2 --> CO + H2O",
		"H2SO4 + HI --> H2S + I2 + H2O",
		"FeS2 + O2 --> Fe2O3 + SO2",
		"Al + FeO --> Al2O3 + Fe",
		"Fe2O3 + H2 --> Fe + H2O",
		"Na2CO3 + HCl --> NaCl + H2O + CO2",
		"K + Br2 --> KBr",
		"C7H16 + O2 --> CO2 + H2O",
		"P4 + O2 --> P2O5",
		"C2H2 + O2 --> CO2 + H2O",
		"K2O + H2O --> KOH",
		"H2O2 --> H2O + O2",
		'Al + O2 --> Al2O3',
		'Na2O2 + H2O --> NaOH + O2',
		'SiO2 + HF --> SiF4 + H2O',
		'C + O2 --> CO',
		'KClO3 --> KCl + O2',
		'KClO3 --> KClO4 + KCl',
		"Fe2(SO4)3 + KOH --> K2SO4 + Fe(OH)3",
	];
	for (final String input in equations) {
		final Equation equation = Equation (input);
		compare<bool> (!equation.balanced, true);
		equation.balance();
		print (equation);
		assert (equation.balanced);
	}
}