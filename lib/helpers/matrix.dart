import "dart:collection" show IterableMixin;

import "range.dart";

class Fraction {
	final int num, denom;
	final bool negative;
	const Fraction._ (this.num, this.denom, this.negative);

	factory Fraction (int num int denom) {
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

class Slice {
	final int start, end;
	const Slice (this.start, this.end);
}

class Pivot {
	final int index, value;
	Pivot (Pair<int> pair) : index = pair.index, value = pair.value;
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
			(fraction.num * (lcd ~/ fraction.denom)).abs()
	).toList();
}

class Matrix with IterableMixin <List<int>>{
	final int rows, cols;
	final List <List<int>> matrix;
	Matrix._ (this.rows, this.cols, this.matrix);

	Iterator <List<int>> get iterator => matrix.iterator;

	factory Matrix (List <List<int>> matrix) {
		int cols, rows = 0;
		for (final List<int> row in matrix) {
			if (cols == null) cols = row.length;
			else if (row.length != cols) throw "Inconsistent Dimensions";
			rows++;
		} 
		return Matrix._ (rows, cols, matrix);
	}

	factory Matrix.fromDimensions (rows, cols, List<int> list) {
		final List <List<int>> matrix = [];
		int index = 0;

		for (final int _ in range (rows)) {
			final List<int> row = [];
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


	operator [] (Slice slice) => matrix [slice.start] [slice.end];
	operator == (dynamic other) => other is Matrix && other.matrix == matrix;
	int get hashCode => matrix.hashCode;
	int get length => rows * cols;

	String toString() => 
		"Matrix(" + 
		this.map (
			(List<int> row) => 
				"\n\t" + row.map ((int num) => num.toString()).join(", ")
		).join ("") + 
		"\n)";

	List<int> get flatten {
		final List<int> result = [];
		for (List<int> row in this) {
			for (int num in row) result.add (num);
		}
		return result;
	}

	static Pivot getPivot(List<int> col) {
		Pair result;

		for (final Pair<int> pair in enumerate<int> (col)) {
			if (pair.value != 0) return Pivot (pair);
			else result = pair;
		}

		if (col.every ((int num) => num == 0)) return Pivot.empty();
		else return Pivot (result);
	}

	Matrix get rref {
		final List<int> matrix = this.flatten;

		List<int> getCol (int index) => matrix.getRange (index, cols);

		void swapRows (int a, int b) {
			final int start1 = a * cols;
			final int end1 = (a + 1) * cols;
			final int start2 = b * cols;
			final int end2 = (b + 1) * cols;

			final List<int> temp = matrix.getRange(start1, end1);
			matrix.replaceRange(start1, end1, matrix.getRange (start2, end2));
			matrix.replaceRange(start2, end2, temp);
		}

		void crossCancel (
			int row, 
			int value, 
			int pivotRow, 
			int pivotValue
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
			final List<int> col = getCol (pivotCol);
			final Pivot pivot = getPivot (col.getRange (pivotRow, col.length));

			if (pivot.index == null) {
				pivotCol++;
				continue;
			}

			pivots.add(pivotCol);
			if (pivot.index != 0) swapRows (pivotRow, pivot.index + pivotRow);

			for (final int row in range (rows)) {
				if (row == pivotRow) continue;

				final int value = matrix [row * cols + pivotCol];
				if (value == 0) continue;
				else crossCancel (row, value, pivotRow, pivot.value);
			}
			pivotRow++;
		}

		List<Fraction> result = matrix.map (
			(int value) => Fraction (value, 1)
		).toList();

		for (Pair<int> pair in enumerate (pivots)) {
			final int temp = pair.index * cols + pair.value;
			final int value = matrix [temp];
			result [temp] = Fraction (1, 1);


			for (final int index2 in range (
				(pair.index + 1) * cols, 
				start: temp + 1)
			) result [index2] = Fraction (matrix [index2], value);
		}

		return Matrix.fromDimensions(rows, cols, matrix);
	}



}