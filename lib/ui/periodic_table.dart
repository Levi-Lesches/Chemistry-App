import "../periodic_table.dart";
import "../bases/element.dart" show Element;

import "package:flutter/material.dart" hide Element;  // reserved for chemistry

class PeriodicTableSheet extends StatefulWidget {
	final void Function(Element) onPressed;
	PeriodicTableSheet ({@required this.onPressed});

	@override TableSheetState createState() => TableSheetState();
}

class TableSheetState extends State<PeriodicTableSheet> {
	int elementIndex = 0;
	static Widget empty = Container();

	@override Widget build (BuildContext context) {
		return GridView.builder(
			scrollDirection: Axis.horizontal,
			shrinkWrap: true,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
				crossAxisCount: 18, 
			),
			itemBuilder: buildCell,
			itemCount: 7 * 18  // build the full grid
		);
	}

	Widget buildCell(BuildContext _, int index) {
		// check for empty cells
		index++;
		final int period = index ~/ 18;
		final int group = index % 18;
		const List<int> transitions = [1, 2, 13, 14, 15, 16, 17, 18];
		const List<int> breakoffs = [1, 2, 3, 18];
		switch (period) {
			case 1: 
				if (!(const [1, 18]).contains (group)) return empty; break;
			case 2:
			case 3: 
				if (!transitions.contains (group)) return empty; break;
			case 8: 
			case 9: 
				if (breakoffs.contains (group)) return empty; break;
		}

		final Element element = periodicTable [index];
		return GestureDetector (
			onTap: () => widget.onPressed (element),
			child: Container (
				decoration: BoxDecoration (border: Border.all()),
				child: Center (child: Text (element.symbol))
			)
		);
	}

}