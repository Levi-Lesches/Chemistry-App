import "package:flutter/material.dart";
import "../bases/molecule.dart";

class HomePage extends StatefulWidget {
	@override HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	String balanced;
	final TextEditingController controller = TextEditingController();

	@override Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (title: Text ("Balancing Equations")),
		body: Padding (
			padding: EdgeInsets.all(20),
			child: ListView (
				children: [
					TextField (
						textInputAction: TextInputAction.done,
						onSubmitted: balance,
						controller: controller,
						decoration: InputDecoration (
							suffixIcon: IconButton (
								icon: Icon (Icons.done, color: Colors.green),
								onPressed: balance
							)
						)
					),
					Text (balanced ?? "Enter an equation"),
				]
			)
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
}