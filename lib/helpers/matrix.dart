import "dart:collection" show IterableMixin;

import "range.dart";

class Fraction {
	final int num, denom;
	final bool negative;
	const Fraction._ (this.num, this.denom, this.negative);

	factory Fraction (int num, int denom) {
		if (denom == 0) throw IntegerDivisionByZeroException();
		final bool negative = num >= 0 != denom >= 0;
		num = num.abs();
		denom = denom.abs();
		for (final int n in range (1, start: num, step: -1)) {
			if (num % n == 0 && denom % n == 0) {
				num ~/= n;  // integer division
				denom ~/= n;
			}
		}

		return Fraction._ (num, denom, negative);
	}
}

int lcm (List<Fraction> fractions) {
	int maxDenom;
	Set<int> denoms = Set<int>();

	// find the largest denominator
	for (final Fraction fraction in fractions) {
		denoms.add (fraction.denom);
		if (maxDenom == null || fraction.denom > maxDenom) 
			maxDenom = fraction.denom;
	}

	// keep adding the denominator until all values are integers
	int result = maxDenom;
	while (denoms.any((int denom) => result % denom != 0)) {
		result += maxDenom;
	}
	return result;
}

List<int> expandFractions (List<Fraction> nullspace) {
	int lcd = lcm (nullspace);  // technically, LCD is not right, but idc
	return nullspace.map(
		(Fraction fraction) => 
			(fraction.num * (lcd ~/ fraction.denom)).abs()
	).toList();
}

class Matrix with IterableMixin <List<double>>{
	final int rows, cols;
	final List <List<double>> matrix;
	Matrix._ (this.rows, this.cols, this.matrix);

	Iterator <List<double>> get iterator => matrix.iterator;

	factory Matrix (List <List<double>> matrix) {
		int cols, rows = 0;
		for (final List<double> row in matrix) {
			if (cols == null) cols = row.length;
			else if (row.length != cols) throw "Inconsistent Dimensions";
			rows++;
		} 
		return Matrix._ (rows, cols, matrix);
	}
}