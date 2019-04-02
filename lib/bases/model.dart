// import "element.dart";

import "../helpers/range.dart";
// import "periodic_table.dart";

class Node {
	final String element;
	final List<Node> bonds = [];
	Node (this.element);
	void addBond (List<Node> nodes) => bonds.addAll(nodes);
}

Iterable<MapEntry<int, V>> sortMap<V>(Map<int, V> map) sync* {
	final int length = (map.length - 1) ~/ 2;
	for (final int index in range (length + 1, start: -length)) yield MapEntry<int, V>(index, map [index]);
}

Map<int, List<Node>> paint(List<Node> nodes) {
	final Map<int, List<Node>> levels = {};
	void recurse (Node pivot, {Node previous, int level = 0}) {
		if (!levels.containsKey(level)) levels [level] = [];
		levels [level].add (pivot);
		if (pivot == null) return;
		Map<int, Node> agenda = pivot.bonds.where(
			(Node node) => node != previous
		).toList().asMap();
		for (final int index in range (3))
			recurse (agenda [index], previous: previous, level: index - 1);
	}

	recurse (nodes.firstWhere((Node node) => node.bonds.length == 1));
	return levels;
}

void main() {
	final Node c1 = Node("C");
	final Node c2 = Node("C");
	final Node h1 = Node("H");
	final Node h2 = Node("H");
	final Node h3 = Node("H");
	final Node h4 = Node("H");
	final Node h5 = Node("H");
	final Node h6 = Node("H");
	c1.addBond([h1, h2, h4, c2]);
	c2.addBond([c1, h3, h5, h6]);
	h1.addBond([c1]);
	h2.addBond([c1]);
	h3.addBond([c2]);
	h4.addBond([c1]);
	h5.addBond([c2]);
	h6.addBond([c2]);
	print (paint ([c1, c2, h1, h2, h3, h4, h5, h6]));
}