import "dart:collection" show IterableMixin;

import "range.dart";

class Fraction {
	final int nom, denom;
	final bool negative;
	const Fraction._ (this.nom, this.denom, this.negative);

	factory Fraction (num nom, num denom) {
		assert (nom is int && denom is int, "Fraction received double");
		if (denom == 0) throw IntegerDivisionByZeroException();
		final bool negative = nom >= 0 != denom >= 0;
		nom = nom.abs();
		denom = denom.abs();
		for (final int n in range (1, start: nom, step: -1)) {
			if (nom % n == 0 && denom % n == 0) {
				nom ~/= n;  // integer division
				denom ~/= n;
			}
		}

		return Fraction._ (nom, denom, negative);
	}

	double get toNum => nom / denom;
}

class Slice {
	final int start, end;
	const Slice (this.start, this.end);
}

class Pivot {
	final int index;
	final double value;
	Pivot (Pair<double> pair) : index = pair.index, value = pair.value;
	Pivot.empty() : index = null, value = null;
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
			(fraction.nom * (lcd ~/ fraction.denom)).abs()
	).toList();
}

class Matrix with IterableMixin <List<double>>{
	final int rows, cols;
	final List <List<Fraction>> matrix;
	Matrix._ (this.rows, this.cols, this.matrix);

	Iterator <List<double>> get iterator => matrix.map(
		(List<Fraction> row) => row.map (
			(Fraction fraction) => fraction.toNum
		)
	).iterator;

	factory Matrix (List <List<int>> matrix) {
		final List<List<Fraction>> result = [];
		int cols, rows = 0;
		for (final List<int> row in matrix) {
			final List<Fraction> rowResult = [];
			if (cols == null) cols = row.length;
			else if (row.length != cols) throw "Inconsistent Dimensions";
			for (final int index in range (row.length))
				rowResult.add (Fraction (row [index], 1));
			
			rows++;
			result.add(rowResult);
		} 
		return Matrix._ (rows, cols, result);
	}

	factory Matrix.fromDimensions(
		rows, 
		cols, 
		List<Fraction> list
	) {
		final List <List<Fraction>> matrix = [];
		int index = 0;

		for (final int _ in range (rows)) {
			final List<Fraction> row = [];
			for (final int __ in range (cols))
				row.add (list [index++]);

			matrix.add(row);
		}

		if (index != list.length) throw IndexError(
			rows * cols,  // what was invalid
			matrix,  // what is being indexed
			"rows, cols",  // the invalid arguments
			"Invalid dimensions for matrix",  // Error message
			index  // current index
		);

		return Matrix._ (rows, cols, matrix);
	}


	Fraction operator [] (Slice slice) => matrix [slice.start] [slice.end];
	operator == (dynamic other) => other is Matrix && other.matrix == matrix;
	int get hashCode => matrix.hashCode;
	int get length => rows * cols;

	String toString() => 
		"Matrix(" + 
		matrix.map (
			(List<Fraction> row) => 
				"\n\t" + row.map ((Fraction num) => num.toString()).join(", ")
		).join ("") + 
		"\n)";

	List<double> get flatten {
		final List<double> result = [];
		for (List<double> row in this) {
			for (double num in row) result.add (num);
		}
		return result;
	}

	static Pivot getPivot(List<double> col) {
		Pair result;

		for (final Pair<double> pair in enumerate<double> (col)) {
			if (pair.value != 0) return Pivot (pair);
			else result = pair;
		}

		if (col.every ((double num) => num == 0)) return Pivot.empty();
		else return Pivot (result);
	}

	Matrix get rref {
		final List<double> matrix = this.flatten;

		List<double> getCol (int index) => matrix.getRange (index, cols);

		void swapRows (int a, int b) {
			final int start1 = a * cols;
			final int end1 = (a + 1) * cols;
			final int start2 = b * cols;
			final int end2 = (b + 1) * cols;

			final List<double> temp = matrix.getRange(start1, end1);
			matrix.replaceRange(start1, end1, matrix.getRange (start2, end2));
			matrix.replaceRange(start2, end2, temp);
		}

		void crossCancel (
			int row, 
			double value, 
			int pivotRow, 
			double pivotValue
		) {
			final int offset = (pivotRow - row) * cols;
			for (final int n in range ((row + 1) * cols, start: row * cols))
				matrix [n] = (
					pivotValue * matrix [n] - value * matrix [n + offset]
				);
		}

		int pivotRow = 0, pivotCol = 0;
		final List<int> pivots = [];

		while (pivotCol < cols && pivotRow < rows) {
			final List<double> col = getCol (pivotCol);
			final Pivot pivot = getPivot (col.getRange (pivotRow, col.length));

			if (pivot.index == null) {
				pivotCol++;
				continue;
			}

			pivots.add(pivotCol);
			if (pivot.index != 0) swapRows (pivotRow, pivot.index + pivotRow);

			for (final int row in range (rows)) {
				if (row == pivotRow) continue;

				final double value = matrix [row * cols + pivotCol];
				if (value == 0) continue;
				else crossCancel (row, value, pivotRow, pivot.value);
			}
			pivotRow++;
		}

		List<Fraction> result = matrix.map (
			(double value) => Fraction (value, 1)
		).toList();

		for (Pair<int> pair in enumerate (pivots)) {
			final int temp = pair.index * cols + pair.value;
			final double value = matrix [temp];
			result [temp] = Fraction (1, 1);


			for (final int index2 in range (
				(pair.index + 1) * cols, 
				start: temp + 1)
			) result [index2] = Fraction (matrix [index2], value);
		}

		return Matrix.fromDimensions(rows, cols, result);
	}

	// List<int> get nullspace {
	// 	Matrix rref = this.rref;
	// 	List<Fraction> result = [];
	// 	for (Pair<Fraction> pair in enumerate (this)) {

	// 	}
	// }

}