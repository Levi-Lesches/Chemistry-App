class Position {
	final int row, col;
	const Position (this.row, this.col);
}

class Node {
	final String element; 
	final List bonds = [];
	Node (this.element);
	static bond (Node a, Object b) {
		if (b is List<Node>) {
			b = b as List;
			a.bonds.addAll(b);
			for (final Node node in b) node.bonds.add(a);
		} else {
			(b as Node).bonds.add(a);
			a.bonds.add(b);
		}
	}
}

class Model {
	final Map <int, List<Node>> model = {0: []};
	operator []= (Position pos, Node value) => model [pos.row] [pos.col] = value;
	operator [] (Position pos) => model [pos.row];

	bool contains (Position pos) => model.containsKey (pos.row);
	bool isValid (Position pos) => (
		this.contains (pos) && pos.col + 1 <= model [pos.row].length
	);

	List<MapEntry<int, List<Node>>> get output {
		final List<MapEntry<int, List<Node>>> result = model.entries.toList();
		result.sort (
			(MapEntry<int, List<Node>> a, MapEntry<int, List<Node>> b) => 
				a.key.compareTo(b.key)
		);
		return result;
	}

	void addRow (Position pos) {
		assert (!model.containsKey (pos.row), "Row ${pos.row} already exists.");
		model [pos.row] = List.filled (pos.col, null, growable: true);
	}
}