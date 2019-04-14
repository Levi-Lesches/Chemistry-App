class Position {
	final int row, col;
	const Position ([this.row = 0, this.col = 0]);
}

class Node {
	final String element; 
	final List<Node> bonds = [];
	Node (this.element);
	// operator == (dynamic other) => other is Node && other.element == this.element;
	// int get hashCode => element.hashCode;
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
	int get evaluate {
		int result = 0;
		for (final Node node in bonds) {
			for (final Node node2 in node.bonds) {
				for (final Node node3 in node2.bonds)
					result += node3.bonds.length;
			}
		} 
		return result;
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

	List<List<Node>> get output {
		final List<MapEntry<int, List<Node>>> result = model.entries.toList();
		result.sort (
			(MapEntry<int, List<Node>> a, MapEntry<int, List<Node>> b) => 
				a.key.compareTo(b.key)
		);
		return result.map(
			(MapEntry<int, List<Node>> entry) => entry.value
		).toList();
	}

	void addRow (Position pos) {
		assert (!model.containsKey (pos.row), "Row ${pos.row} already exists.");
		model [pos.row] = List.filled (pos.col, null, growable: true);
	}

	Iterable<List<Node>> get rows => model.values;
}

List<List<Node>> paint(List<Node> nodes) {
	final Model model = Model();

	void expand(Node pivot, {Node previous, Position current = const Position()}) {
		if (!model.contains (current)) model.addRow (current);
		if (model.isValid(current)) model [current] = pivot;
		else model [current].add (pivot);

		for (final List<Node> row in model.rows) {
			if (row.length < current.col) row.add (null);
		}

		final int row = current.row;
		final int col = current.col;
		final up = Position (row - 1, col);
		final down = Position (row + 1, col);
		List<Position> directions;

		if (
			model.isValid (up) && 
			model [up].length == model [current].length &&
			model [up] [up.col] != null
		) directions = [
			down,
			Position (row, col - 1),
			Position (row, col + 1)
		]; else if (
			model.isValid (down) &&
			model [down].length == model [current].length &&
			model [down] [down.col] != null
		) directions = [
			up,
			Position (row, col + 1),
			Position (row, col - 1)
		]; else directions = [
			Position (row, col + 1),
			down,
			up
		];

		final List<Node> agenda = pivot.bonds.where(
			(Node node) => previous == null || node != previous
		).toList();
		agenda.sort(
			(Node a, Node b) => a.bonds.length.compareTo (b.bonds.length) * -1, 
		);

		for (final int length in const [3, 2, 1]) {
			if (agenda.length >= length) expand (
				agenda [length - 1],
				previous: pivot,
				current: directions [length - 1]
			);
		}
	}

	expand (
		nodes
		.where (
			(Node node) => node.bonds.length == 1
		)
		.reduce (
			(Node a, Node b) => a.evaluate < b.evaluate ? a : b
		)
	);
	final int maxLength = model.model.values
		.map(
			(List<Node> row) => row.length
		)
		.reduce(
			(int a, int b) => a > b ? a : b
		);

	for (final int key in model.model.keys) {
		if (model.model [key].length != maxLength)
			model.model [key].add(null);
	}
	return model.output;
}