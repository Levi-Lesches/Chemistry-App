import "helpers/names.dart";
import "helpers/strings.dart";

const Map <int, String> PERIODS = {
	1: "K",
	2: "L", 
	3: "M",
	4: "N",
	5: "O",
	6: "P",
	7: "Q"
};

const Map <String, String> BLOCKS = {
	"s": "",
	"p": "",
	"d": "",
	"f": "",
	"g": "",
};

const Map <int, List<String>> GROUPS = {
    1: ['IA', 'Alkali metals'],
    2: ['IIA', 'Alkaline earths'],
    3: ['IIIB', ''],
    4: ['IVB', ''],
    5: ['VB', ''],
    6: ['VIB', ''],
    7: ['VIIB', ''],
    8: ['VIIIB', ''],
    9: ['VIIIB', ''],
    10: ['VIIIB', ''],
    11: ['IB', 'Coinage metals'],
    12: ['IIB', ''],
    13: ['IIIA', 'Boron group'],
    14: ['IVA', 'Carbon group'],
    15: ['VA', 'Pnictogens'],
    16: ['VIA', 'Chalcogens'],
    17: ['VIIA', 'Halogens'],
    18: ['VIIIA', 'Noble gases']
};

const Map <int, String> SERIES = {
	1: 'Nonmetals',
	2: 'Noble gases',
	3: 'Alkali metals',
	4: 'Alkaline earth metals',
	5: 'Metalloids',
	6: 'Halogens',
	7: 'Poor metals',
	8: 'Transition metals',
	9: 'Lanthanides',
	10: 'Actinides'
};

const Map <int, String> PREFIXES = {
	1: "Mono",
	2: "Di",
	3: "Tri",
	4: "Tetra",
	5: "Penta",
	6: "Hexa",
	7: "Hepta",
	8: "Octa",
	9: "Nona",
	10: "Deca"
};


final Map <String, PolyatomicIon> polyatomicIons = _polyatomicIons();

Map <String, PolyatomicIon> _polyatomicIons() {
	final Map <String, PolyatomicIon> starter = {
		"C2H3O2": PolyatomicIon ("Acetate", -1),
		"CO3": PolyatomicIon ("Carbonate", -2),
		"PO4": PolyatomicIon ("Phosphate", -3),
		"OH": PolyatomicIon ("Hydroxide", -1),
		"NO2": PolyatomicIon ("Nitrite", -1),
		"NO3": PolyatomicIon ("Nitrate", -1),
		"HCO3": PolyatomicIon ("Hydrogen carbonate", -1),
		"CrO4": PolyatomicIon ("Chromate", -2),
		"CrO7": PolyatomicIon ("Dichromate", -2),
		"HPO4": PolyatomicIon ("Hydrogen phosphate", -2),
		"H2PO4": PolyatomicIon ("Dihydrogen phosphate", -1),
		"NH4": PolyatomicIon ("Ammonium", 1),
		"SO3": PolyatomicIon ("Sulfite", -2),
		"SO4": PolyatomicIon ("Sulfate", -2),
		"HSO3": PolyatomicIon ("Hydrogen sulfite", -1),
		"HSO4": PolyatomicIon ("Hydrogen sulfate", -1),
		"MnO4": PolyatomicIon ("Permanganate", -1),
		"CN": PolyatomicIon ("Cyanide", -1),
		"O2": PolyatomicIon ("Peroxide", -2),
		"Hg2": PolyatomicIon ("Mercury(I)", 2)
	};

	[
		Prefix ("F", "flour"),
		Prefix ("Cl", "chlor"),
		Prefix ("Br", "brom"),
		Prefix ("I", "iod"),
		Prefix ("At", "ast")
	].forEach(
		(Prefix prefix) {
			starter ["${prefix.symbol}O"]
				= PolyatomicIon ("Hypo${prefix.prefix}ite", -1);

			starter ["${prefix.symbol}O2"]
				= PolyatomicIon ("${title (prefix.prefix)}ite", -1);

			starter ["${prefix.symbol}O3"]
			 	= PolyatomicIon ("${title (prefix.prefix)}ate", -1);

		 	starter ["${prefix.symbol}O4"]
		 		= PolyatomicIon ("Per${prefix.prefix}ate", -1);
		}
	);

	return starter;
}

const List <String> VOWELS = ["a", "e", "i", "o", "u"];

enum MoleculeType {ionic, molecular, acid, element}