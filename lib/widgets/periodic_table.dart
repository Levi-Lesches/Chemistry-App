import "package:flutter/material.dart" hide Element;  // reserved for chemistry

import "package:chemistry/periodic_table.dart";

import "package:chemistry/data/element.dart" show Element;

import "package:chemistry/helpers/range.dart";

class PeriodicTableSheet extends StatefulWidget {
	final void Function(Element) onPressed;
	PeriodicTableSheet ({@required this.onPressed});

	@override TableSheetState createState() => TableSheetState();
}

class TableSheetState extends State<PeriodicTableSheet> {
	int elementIndex;
	static double n = 500;
	static Widget empty = Container(height: n, width: n);
	List<Widget> tiles;
	static Map<int, Color> colors = {
		1: Colors.teal[400],
		2: Colors.orange,
		3: Colors.redAccent[700],
		4: Colors.red [100],
		5: Colors.lightBlueAccent[400],
		6: Colors.indigo [600],
		7: Colors.purpleAccent[700],
		8: Colors.lightBlue,
		9: Colors.green,
		10: Colors.yellow,
	};

	@override void initState() {
		super.initState();
		elementIndex = 0;
		tiles = getTiles();
	}

	@override Widget build (BuildContext context) {
		// return SingleChildScrollView (/
			// scrollDirection: Axis.horizontal, 
			return GridView.count(
				// scrollDirection: Axis.horizontal,
				childAspectRatio: .5,
				shrinkWrap: true,
				physics: ClampingScrollPhysics(),
				children: tiles,
				crossAxisCount: 18,
				// mainAxisSpacing: 0.1,
				// crossAxisSpacing: 0.1
			// gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
			// 	crossAxisCount: 18, 
			// 	// crossAxisCount: 9
			// ),
			// itemBuilder: buildCell,
			// itemBuilder: debug,
			// itemCount: 9 * 18  // build the full grid
			// )
		);
	}

	List<Widget> getTiles() => range (9 * 18).map(buildCell).toList();

	Widget buildCell(int index) {
		// check for empty cells
		final int period = (index ~/ 18) + 1;
		final int group = (index % 18) + 1;
		const List<int> hydrogenAndHelium = [1, 18];
		const List<int> transitions = [1, 2, 13, 14, 15, 16, 17, 18];
		const int cutoff = 3;
		const List<int> breakoffs = [1, 2, 18];
		index++;
		switch (period) {
			case 1: 
				if (!hydrogenAndHelium.contains (group)) return empty; break;
			case 2:
			case 3: 
				if (!transitions.contains (group)) return empty; break;
			case 6:
			case 7: 
				if (group == cutoff) return empty; break;
			case 8: 
			case 9: 
				if (breakoffs.contains (group)) return empty; break;
		}

		elementIndex++;
		Element element;
		if ((period == 6 && group > 3) || (period == 7 && group <=2)) {
			element = periodicTable [elementIndex + 15];
		}
		else if (period == 7 && group > 2) {
			element = periodicTable [elementIndex + 30];
		}
		else if (period == 8)
			element = periodicTable [elementIndex - 32];
		else if (period == 9)
			element = periodicTable [elementIndex - 15];
		else element = periodicTable [elementIndex];



		return GestureDetector (
			onTap: () {
				print ("Row: $period, Column: $group");
				widget.onPressed (element);
			},
			child: Container (
				decoration: BoxDecoration (
					border: Border.all(),
					color: colors [element?.series ?? Colors.white]
				),
				width: n,
				height: n,
				alignment: Alignment.center,
				child: Text (element?.symbol ?? "N/A"),
			)
		);
	}

}