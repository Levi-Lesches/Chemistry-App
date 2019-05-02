// TODO: get numbers and letters on the keyboard

import "package:flutter/material.dart";
import "package:flutter/services.dart" show TextInputFormatter;

import "package:chemistry/helpers/range.dart" show range;
import "package:chemistry/helpers/editor.dart";

import "package:chemistry/data/molecule.dart";

class MoleculeEditor extends StatelessWidget {
	final List<TextInputFormatter> moleculeFormatter = [MoleculeFormatter()];
	final ValueEditor<Molecule> editor;
	final TextEditingController controller = TextEditingController();
	MoleculeEditor(this.editor);

	@override Widget build (BuildContext context) => TextField (
		controller: controller,
		keyboardType: TextInputType.url,
		textCapitalization: TextCapitalization.characters,
		inputFormatters: moleculeFormatter,
		onEditingComplete: () => editor.value = Molecule (controller.text)
	);
}

class MoleculeFormatter extends TextInputFormatter {
	static final RegExp lettersRegex = RegExp (r"\w");
	static final RegExp numbersRegex = RegExp (r"\d");
	static final RegExp invalidRegex = RegExp (r"[^\w^\d]");
	static const Map<String, String> subscripts = {
		'0': "\u2070",   
    "1": "\u00B9",
    "2": "\u00B2",
		"3": "\u00B3",
		"4": "\u2074",
		"5": "\u2075",
		"6": "\u2076",
		"7": "\u2077",
		"8": "\u2078",
		"9": "\u2079",
	};

	@override 
	TextEditingValue formatEditUpdate(
		TextEditingValue _, 
		TextEditingValue text
	) {
		String newText = text.text.replaceAll(invalidRegex, "");
		String result = "";
		// This part adds subscripts
		for (final int index in range (result.length)) {
			final String character = newText [index];
			if (!lettersRegex.hasMatch(newText)) {
				result += character;
			} else if (numbersRegex.hasMatch(character)) 
				result += subscripts [character];
		}
		return TextEditingValue (text: result);
	}
}
