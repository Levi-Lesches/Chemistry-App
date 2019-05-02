import "package:flutter/material.dart";

import "package:chemistry/data/side.dart";
import "package:chemistry/data/molecule.dart";
import "package:chemistry/data/equation.dart";

import "package:chemistry/helpers/editor.dart";

import "molecule_editor.dart" show MoleculeEditor;

class SideEditor extends StatefulWidget {
	final ValueEditor<Side> editor;
	SideEditor (this.editor);

	@override
	SideEditorState createState() => SideEditorState();
}

class SideEditorState extends State<SideEditor> {
	final List<MoleculeEditor> molecules = [];
	static final Widget plus = Icon(Icons.add); 
	Widget addButton;
	int index;

	@override void initState() {
		super.initState();
		addButton = IconButton (
			icon: Icon (Icons.add),
			onPressed: addMolecule
		);
	}

	@override Widget build (BuildContext context) => Row (
		children: widgets
	);

	List<Widget> get widgets {
		final List<Widget> result = [];
		for (final MoleculeEditor molecule in molecules) {
			result.add (molecule);
			result.add (plus);
		}
		result.removeLast();  // get rid of the last plus sign
		result.add (addButton);
		return result;
	}

	Side get value => Side.fromMolecules (
		molecules
			.map (
				(MoleculeEditor input) => input.editor.value
			)

	);

	void addMolecule() => setState(
		() => molecules.add (
			MoleculeEditor(ValueEditor<Molecule>())
		)
	);
}

class EquationEditor extends StatelessWidget {
	static const Icon arrow = Icon (Icons.arrow_forward);

	final SideEditor reactants = SideEditor(ValueEditor<Side>());
	final SideEditor products = SideEditor(ValueEditor<Side>());

	@override Widget build(BuildContext context) => ListView (
		scrollDirection: Axis.horizontal,
		children: [reactants, arrow, products]
	);

	Equation get equation => Equation.fromSides (
		reactants.editor.value,
		products.editor.value
	);
}
