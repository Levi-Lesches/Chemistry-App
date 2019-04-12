import "../helpers/range.dart";

class Node {
	final String element;
	final List<Node> bonds = [];
	Node (this.element);
	void addBonds (List<Node> nodes) => bonds.addAll(nodes);
	static void bond (Node a, Object b) {
		if (b is List<Node>) {
			a.bonds.addAll (b);
			for (final Node node in b) node.bonds.add (a);
		}
		else {
			a.bonds.add (b);
			(b as Node).bonds.add (a);
		}
	}
}

Iterable<MapEntry<int, V>> sortMap<V>(Map<int, V> map) sync* {
	final int length = (map.length - 1) ~/ 2;
	for (final int index in range (length + 1, start: -length)) 
		yield MapEntry<int, V>(index, map [index]);
}

Iterable<MapEntry<int, List<Node>>> paint(List<Node> nodes) {
	final Map<int, List<Node>> levels = {};
	void expand(Node pivot, {int previous, int lastLevel, int level = 0}) {
		if (!levels.containsKey (level)) {
			if (previous != null) levels [level] = List.filled(previous, null);
			else levels [level] = [];
		}
		levels [level].add(pivot);

		final List<int> directions = [];
		if (
			levels.containsKey(level - 1) && 
			levels [level - 1].length == levels [level].length
		) directions.addAll ([level + 1, level, level]);
		else if (
			levels.containsKey(level + 1) &&
			levels [level + 1].length == levels [level].length
		) directions.addAll([level - 1, level, level]);
		else directions.addAll ([level, level + 1, level - 1]);

		final List<Node> agenda = pivot.bonds.where (
			(Node node) => 
				previous == null || node != levels [lastLevel] [previous]
		);

		final int index = levels [level].length - 1;
		for (final int length in const [3, 2, 1]) {
			if (agenda.length >= length) expand (
				agenda [length - 1],
				previous: index,
				lastLevel: level, 
				level: directions [length - 1]
			);
		}
	}

	expand (
		nodes.reduce (
			(Node a, Node b) => a.bonds.length < b.bonds.length ? a : b
		)
	);

	final int maxLength = levels.values.map(
		(List<Node> row) => row.length
	).reduce (
		(int a, int b) => a > b ? a : b
	);

	for (final int level in levels.keys) {
		if (levels [level].length != maxLength) levels [level].add (null);
	}
	return sortMap(levels);
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

	Node.bond (c2, <Node>[h3, h5, h6]);
	Node.bond (c1, <Node>[c2, h1, h2, h4]);
	paint ([c1, c2, h1, h2, h3, h4, h5, h6]);
}