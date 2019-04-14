import "package:chemistry/bases/model.dart";
import "../compare.dart";

import "package:flutter_test/flutter_test.dart";

void main() {
	test ("Model", modelTest);
}

List<List<String>> toString(List<List<Node>> model) => model.map (
	(List<Node> row) => row.map (
		(Node node) => node?.element
	).toList()
).toList();

void modelTest() {
	compare<List<List<String>>> (
		toString(paint(c2h6())),
		const [
			[null, "H", "H", null],
			["H",  "C", "C",  "H"],
			[null, "H", "H", null]
		]
	);

	compare<List<List<String>>> (
		toString (paint (co2())),
		const [
			["O", "C", "O"]
		]
	);

	compare<List<List<String>>> (
		toString (paint (h2o())),
		const [
			["H", "O", "H"]
		]
	);

	compare<List<List<String>>> (
		toString (paint (nh3())),
		const [
			["H",  "N",  "H"],
			[null, "H", null]
		]
	);

	compare<List<List<String>>> (
		toString (paint (c2h6o())),
		const [
			[null, null, "H", "H", null],
			["H",   "O", "C", "C",  "H"],
			[null, null, "H", "H", null]
		]
	);

	compare<List<List<String>>> (
		toString (paint (c6h12o6())),
		const [
			[null, null,  "H", "H", "H", "H", "H", null, null],
			["H",   "O",  "C", "C", "C", "C", "C",  "C",  "H"],
			[null, null,  "H", "O", "O", "O", "O",  "O", null],
			[null, null, null, "H", "H", "H", "H", null, null]
		]
	);
}

List<Node> c2h6() {
	final Node c1 = Node ("C");
	final Node c2 = Node ("C");
	final Node h1 = Node ("H");
	final Node h2 = Node ("H");
	final Node h3 = Node ("H");
	final Node h4 = Node ("H");
	final Node h5 = Node ("H");
	final Node h6 = Node ("H");

	Node.bond(c1, [c2, h1, h2, h4]);
	Node.bond(c2, [h3, h5, h6]);
	return [c1, c2, h1, h2, h3, h4, h5, h6];
}

List<Node> co2() {
	final Node c = Node ("C");
	final Node o1 = Node ("O");
	final Node o2 = Node ("O");

	Node.bond (c, [o1, o2]);
	return [c, o1, o2];
}

List<Node> h2o() {
	final Node h1 = Node ("H");
	final Node h2 = Node ("H");
	final Node o = Node ("O");
	Node.bond (o, [h1, h2]);
	return [o, h1, h2];
}

List<Node> nh3() {
	final Node n = Node ("N");
	final Node h1 = Node ("H");
	final Node h2 = Node ("H");
	final Node h3 = Node ("H");
	Node.bond(n, [h1, h2, h3]);
	return [n, h1, h2, h3];
}

List<Node> c2h6o() {
	final Node h1 = Node ("H");
	final Node h2 = Node ("H");
	final Node h3 = Node ("H");
	final Node h4 = Node ("H");
	final Node h5 = Node ("H");
	final Node h6 = Node ("H");
	final Node o = Node ("O");
	final Node c1 = Node ("C");
	final Node c2 = Node ("C");
	Node.bond (c1, [h1, o, c2, h5]);
	Node.bond (c2, [h3, h4, h6]);
	Node.bond (o, h2);
	return [h1, h2, h3, h4, h5, h6, o, c1, c2];
}

List<Node> c6h12o6() {
	final Node h1 = Node ("H");
	final Node h2 = Node ("H");
	final Node h3 = Node ("H");
	final Node h4 = Node ("H");
	final Node h5 = Node ("H");
	final Node h6 = Node ("H");
	final Node h7 = Node ("H");
	final Node h8 = Node ("H");
	final Node h9 = Node ("H");
	final Node h10 = Node ("H");
	final Node h11 = Node ("H");
	final Node h12 = Node ("H");

	final Node c1 = Node ("C");
	final Node c2 = Node ("C");
	final Node c3 = Node ("C");
	final Node c4 = Node ("C");
	final Node c5 = Node ("C");
	final Node c6 = Node ("C");

	final Node o1 = Node ("O");
	final Node o2 = Node ("O");
	final Node o3 = Node ("O");
	final Node o4 = Node ("O");
	final Node o5 = Node ("O");
	final Node o6 = Node ("O");

	Node.bond (c1, [c2, h1, o1, h3]);
	Node.bond (o1, h2);
	Node.bond (c2, [o2, h5, c3]);
	Node.bond (o2, h4);
	Node.bond (c3, [h7, o3, c4]);
	Node.bond (o3, h6);
	Node.bond (c4, [o4, h9, c5]);
	Node.bond (o4, h8);
	Node.bond (c5, [o5, h11, c6]);
	Node.bond (o5, h10);
	Node.bond (c6, [h12, o6]);

	return [c1, c2, c3, c4, c5, c6, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, o1, o2, o3, o4, o5, o6];
}

