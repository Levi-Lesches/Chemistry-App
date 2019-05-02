import "package:flutter/material.dart" hide Element;

import "package:chemistry/periodic_table.dart";

import "package:chemistry/data/molecule.dart";
import "package:chemistry/data/element.dart";

import "package:chemistry/widgets/periodic_table.dart";

class AddElement extends StatelessWidget {
	final TextEditingController controller;
	AddElement (this.controller);

	@override Widget build (BuildContext context) => FloatingActionButton.extended (
		icon: Icon (Icons.add),
		label: Text ("Add an element"),
		onPressed: () => showBottomSheet (
			context: context, 
			builder: (_) => PeriodicTableSheet (
				onPressed: (Element element) => controller.text += element.symbol
			)
		)
	);
}

class HomePage extends StatefulWidget {
	@override HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	String balanced;
	final TextEditingController controller = TextEditingController();
	PersistentBottomSheetController sheetController;
	final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
	FocusNode focusNode;

	@override void initState() {
		super.initState();
		focusNode = FocusNode();
		focusNode.addListener (
			() {
				if (sheetController != null) 
					sheetController.close();
				print ("closing");
			}
		);
	}

	@override void dispose() {
		focusNode.dispose();
		super.dispose();
	}

	@override Widget build (BuildContext context) => Scaffold (
		key: scaffoldKey,
		appBar: AppBar (title: Text ("Balancing Equations")),
		floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
		body: Padding (
			padding: EdgeInsets.all(20),
			child: Column (
				children: [
					TextFormField (
						focusNode: focusNode,
						autovalidate: true,
						validator: validate,
						textInputAction: TextInputAction.done,
						onFieldSubmitted: balance,
						controller: controller,
						decoration: InputDecoration (
							suffixIcon: IconButton (
								icon: Icon (Icons.done, color: Colors.green),
								onPressed: balance
							)
						)
					),
					SizedBox (height: 20),
					Text (balanced ?? "Enter an equation"),
				]
			)
		),
		floatingActionButton: FloatingActionButton.extended (
			icon: Icon (Icons.add),
			label: Text ("Add an element"),
			onPressed: () {
				focusNode.unfocus();
				sheetController = scaffoldKey.currentState.showBottomSheet(
					(_) => PeriodicTableSheet (
						onPressed: (Element element) => controller.text += element.symbol
					)
				);
				// Timer (Duration (seconds: 1), () => sheetController.close());
			}
		)
	);

	void balance([String input]) {
		input ??= controller.text;
		if (input == "" || input.isEmpty) {
			setState(() => balanced = "Please enter an equation");
			return;
		} else {
			// try {setState(() {balanced = Equation.balance(input).toString();});}
			try {setState(() => balanced = Molecule (input).details());}
			on AssertionError {setState((){balanced = "Invalid equation";});rethrow;}
		}
	}

	void add (String element) => setState (() {controller.text += element;});

	FlatButton button (String element) => FlatButton (
		child: Text (element),
		onPressed: () => add (element)
	);

	void back() => setState(() => controller.text = controller.text.substring(
		0, controller.text.length - 1
	));

	void clear() => setState(() => controller.text = "");

	String validate(String input) {
		if (input.isEmpty) return null;
		final RegExp regex = Molecule.regex;
		final List<Match> matches = regex.allMatches (input).toList();
		if (matches.isEmpty) return "Invalid formula";
		if (!(matches.first.start == 0 && matches.last.end == input.length)) 
			return "Invalid formula";
		else {
			for (final Match match in matches) {
				final String element = match.group (1);
				if (!periodicTable.containsSymbol (element)) 
					return "Unknown element: $element";
			}
			return null;
		}
	}
}
