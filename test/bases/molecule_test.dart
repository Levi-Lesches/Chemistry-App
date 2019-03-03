import "package:flutter_test/flutter_test.dart";

import "package:chemistry/constants.dart";
import "package:chemistry/periodic_table.dart";
import "package:chemistry/bases/molecule.dart";
import "package:chemistry/helpers/names.dart";
import "package:chemistry/helpers/counter.dart";
import "../compare.dart";


void main() {
	group ("Ions test: ", Ions.main);
	group ("Name testing", TestNaming.main);
	test ("Charge calculations", testChargeCalc);
	test ("Basic counting test", testCounter);
	test ("Coefficients test: ", testCoefficients);
}

final Molecule m1 = Molecule ("MgCl");
final Molecule m2 = Molecule ("SnCl4");
final Molecule m3 = Molecule ("HgBr2");
final Molecule m4 = Molecule ("H2O");
final Molecule m5 = Molecule ("CO");
final Molecule m6 = Molecule ("CO2");
final Molecule m7 = Molecule ("N4Se4");
final Molecule m8 = Molecule ("O2");

class Ions {

	static void main() {
		test ("Charge test: ", testCharges);
		test ("Type test: ", testType);
		test ("Polyatommic identification test: ", testPolyatomicID);
	}

	static void testCharges() {
		for (String element in <String>["Li", "Na", "K", "Rb", "Cs", "Fr"])
			compare<List <int>> (periodicTable [element].getCharge(), [1]);

		for (String element in <String>["Be", "Mg", "Ca", "Sr", "Ba", "Ra"])
			compare<List <int>> (periodicTable [element].getCharge(), [2]);

		for (String element in <String>["Sc", "Y", "La", "Ac", "Al"])
			compare<List <int>> (periodicTable [element].getCharge(), [3]);

		for (String element in <String>["N", "P"])
			compare<List <int>> (periodicTable [element].getCharge(), [-3]);

		for (String element in <String>["O", "S", "Se", "Te"])
			compare<List <int>> (periodicTable [element].getCharge(), [-2]);

		for (String element in <String>["F", "Cl", "Br", "I", "At"])
			compare<List <int>> (periodicTable [element].getCharge(), [-1]);

		// Noble gasses
		for (String element in <String>["He", "Ne", "Ar", "Kr", "Xe", "Rn"])
			compare<bool> (periodicTable [element].getCharge().isEmpty, true);

		compare<List <int>> (periodicTable ["H"].getCharge(), [1]);
	}

	static void testType() {
		compare<MoleculeType> (m1.type, MoleculeType.ionic);
		compare<MoleculeType> (m2.type, MoleculeType.ionic);
		compare<MoleculeType> (m3.type, MoleculeType.ionic);
		compare<MoleculeType> (m4.type, MoleculeType.molecular);
		compare<MoleculeType> (m5.type, MoleculeType.molecular);
		compare<MoleculeType> (m6.type, MoleculeType.molecular);
		compare<MoleculeType> (m7.type, MoleculeType.molecular);
		compare<MoleculeType> (m8.type, MoleculeType.element);
	}

	static void testPolyatomicID() {
		compare <PolyatomicIon> (
			polyatomicIons ["BrO4"], 
			const PolyatomicIon ("Perbromate", -1)
		);
		compare <PolyatomicIon> (
			polyatomicIons ["ClO3"], 
			const PolyatomicIon ("Chlorate", -1)
		);
	}
}

class TestNaming {
	static void main() {
		test ("Ionic names: ", testIonicNaming);
		test ("Polyatommic names: ", testPolyatomicNames);
		test ("Molecular names: ", testMolecularNames);
	}

	static void testIonicNaming() {
		compare <String> (Molecule ("Ba").name, "Barium");
		compare <String> (Molecule ("H").name, "Hydrogen");
		compare <String> (Molecule ("C2").name, "Carbon");
		compare <String> (Molecule ("SnO2").name, "Tin(IV) Oxide");
		compare <String> (Molecule ("HgBr2").name, "Mercury(II) Bromide");
		compare <String> (Molecule ("Cr2S3").name, "Chromium(III) Sulfide");
		compare <String> (Molecule ("RbI").name, "Rubidium Iodide");
		compare <String> (Molecule ("BaBr2").name, "Barium Bromide");
		compare <String> (Molecule ("MgCl").name, "Magnesium Chloride");
	}

	static void testPolyatomicNames() {
		compare <String> (Molecule ("Cr(NO3)2").name, "Chromium(II) Nitrate");
		compare <String> (Molecule ("Ba(OH)2").name, "Barium Hydroxide");
		compare <String> (Molecule ("CuNO2").name, "Copper(I) Nitrite");
		compare <String> (Molecule ("KClO3").name, "Potassium Chlorate");
		compare <String> (Molecule ("Mg(C2H3O2)2").name, "Magnesium Acetate");
		compare <String> (Molecule ("Pb(C2H3O2)2").name, "Lead Acetate");
		compare <String> (Molecule ("PbSO4").name, "Lead Sulfate");
		compare <String> (Molecule ("NaBrO4").name, "Sodium Perbromate");
		compare <String> (Molecule ("CoSO4").name, "Cobalt(II) Sulfate");
		compare <String> (Molecule ("NH4I").name, "Ammonium Iodide");
		compare <String> (Molecule ("Fe(OH)3").name, "Iron(III) Hydroxide");
		compare <String> (Molecule ("KClO").name, "Potassium Hypochlorite");
		compare <String> (Molecule ("CN").name, "Carbon Mononitride (Cyanide)");
		compare <String> (Molecule ("NH4").name, "Ammonium");
		compare <String> (Molecule ("O2").name, "Oxygen (Peroxide)");
		compare <String> (Molecule ("Cu2SO4").name, "Copper(I) Sulfate" );
		compare <String> (Molecule ("Mg(NO3)2").name, "Magnesium Nitrate");
		compare <String> (Molecule ("Fe(NO3)3").name, "Iron(III) Nitrate");
		compare <String> (Molecule ("Cu(NO3)2").name, "Copper(II) Nitrate");
	}

	static void testMolecularNames() {
		compare <String> (Molecule ("H2O").name, "Dihydrogen Monoxide");
		compare <String> (Molecule ("CO2").name, "Carbon Dioxide");
		compare <String> (Molecule ("C4H5").name, "Tetracarbon Pentahydride");
	}
}

void testCounter() {
	compare <Map <String, int>> (
		m1.elementNames.counter,
		Counter <String> (["Magnesium", "Chlorine"]).counter
	);
	compare <Map <String, int>> (
		m2.elementNames.counter, 
		{
			"Tin": 1,
			"Chlorine": 4
		}
	);
	compare <Map <String, int>> (
		m3.elementNames.counter, 
		{
			"Mercury": 1, 
			"Bromine": 2
		}
	);
	compare <Map <String, int>> (
		m4.elementNames.counter, 
		{
			"Hydrogen": 2, 
			"Oxygen": 1
		}
	);
	compare <Map <String, int>> (
		m5.elementNames.counter, 
		{
			"Carbon": 1, 
			"Oxygen": 1
		}
	);
	compare <Map <String, int>> (
		m6.elementNames.counter, 
		{
			"Carbon": 1, 
			"Oxygen": 2
		}
	);
	compare <Map <String, int>> (
		m7.elementNames.counter, 
		{
			"Nitrogen": 4, 
			"Selenium": 4
		}
	);
	compare <Map <String, int>> (
		m8.elementNames.counter, 
		{"Oxygen": 2}
	);
	compare <Map <String, int>> (
		Molecule ("CO(OH(NO3))H2O").elementNames.counter,
		{
			"Carbon": 1,
			"Oxygen": 6,
			"Hydrogen": 3,
			"Nitrogen": 1
		}
	);
}

void testChargeCalc () {
	// SnO2
	compare<int> (
		Molecule.calcCharge (
			possibleCharges: periodicTable ["Sn"].getCharge(),
			count: 1,
			otherCharge: periodicTable ["O"].getCharge() [0],
			otherCount: 2 
		),
		4
	);

	// HgBr2
	compare<int> (
		Molecule.calcCharge (
			possibleCharges: periodicTable ["Hg"].getCharge(),
			count: 1,
			otherCharge: periodicTable ["Br"].getCharge() [0],
			otherCount: 2
		),
		2
	);

	// Cr2S3
	compare<int> (
		Molecule.calcCharge (
			possibleCharges: periodicTable ["Cr"].getCharge(),
			count: 2,
			otherCharge: periodicTable ["S"].getCharge() [0],
		otherCount: 3
		),
		3
	);

	// RbI
	compare<int> (
		Molecule.calcCharge (
			possibleCharges: periodicTable ["Rb"].getCharge(),
			count: 1,
			otherCharge: periodicTable ["I"].getCharge() [0],
		otherCount: 1
		),
		1
	);

	// BaBr2
	compare<int> (
		Molecule.calcCharge (
			possibleCharges: periodicTable ["Ba"].getCharge(),
			count: 1, 
			otherCharge: periodicTable ["Br"].getCharge() [0],
		otherCount: 2
		),
		2
	);
}

void testCoefficients() {
	compare <int> (Molecule ("2H2O").coefficient, 2);
	compare <int> (Molecule ("5CO").coefficient, 5);
	compare <int> (Molecule ("CO2").coefficient, 1);
}