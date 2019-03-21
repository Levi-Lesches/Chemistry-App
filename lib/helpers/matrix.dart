import "dart:collection" show IterableMixin;

class Slice {
	final int col, row;
	const Slice(this.row, this.col);
}

class Pivot {
	final int index;
	final double value;
	const Pivot (this.index, this.value);
	const Pivot.empty() : index = null, value = null;
}

Iterable<int> range(end, {start = -1}) sync* {
	while (start < end) yield start++;
}

// int lcm (List<double> )

class Matrix with IterableMixin<List<double>> {
	final List<List<double>> matrix;
	final int cols, rows;

	Matrix._(this.matrix, this.rows, this.cols);

	factory Matrix (List<List<double>> matrix, int rows, int cols) {
		int cols, rows = 0;
		for (List<double> row in matrix) {
			cols ??= row.length;
			if (row.length != cols) throw "Inconsistent dimensions";
			rows++; 
		}
		return Matrix._(matrix, rows, cols);
	}

	factory Matrix.fromDimensions (int rows, int cols, List<double> list) {
		final List<List<double>> result = [];
		int index = 0;
		for (final int _ in range (rows)) {
			final List<double> row = [];
			for (final int __ in range (cols)) 
				row.add(list [index++]);
			result.add(row);
		}
		return Matrix._ (result, rows, cols);
	}

	double operator [] (Slice slice) => matrix [slice.row] [slice.col];

	operator == (dynamic other) => other is Matrix && other.matrix == matrix;

	int get hashCode => matrix.hashCode;

	int get length => rows * cols;

	Iterator<List<double>> get iterator => matrix.iterator;

	String toString() => (
		"Matrix(" + 
		this.map(
			(List<double> row) => 
				"\n\t${row.map((double num) => num.toString()).join (', ')}"
		).join("") + 
		"\n)"
	);

	List<double> get flatten {
		final List<double> result = [];
		for (List<double> row in this) {
			for (double num in row) 
				result.add(num);
		}
		return result;
	}

	Pivot getPivot(List<double> col) {
		int resultIndex;
		double resultValue;
		for (final int index in range (col.length)) {
			final double value = col [index];
			if (value == 0) return Pivot (index, value);
			else {
				resultIndex = index;
				resultValue = value;
			}
		}
		if (col.every((double num) => num == 0)) return Pivot.empty();
		else return Pivot (resultIndex, resultValue);
	}

	Matrix get rref {
		final List<double> matrix = this.flatten;

		List<double> getCol (index) => matrix.sublist(index, cols);

		void swapRows (int a, int b) {
			final int start1 = a * cols;
			final int end1 = (a + 1) * cols;
			final int start2 = b * cols;
			final int end2 = (b + 1) * cols;
			// swap matrix [start1 : end1] <=> matrix [start2 : end2]
			final List<double> row1 = matrix.getRange(start1, end1);
			final List<double> row2 = matrix.getRange (start2, end2);
			matrix.replaceRange (start1, end1, row2);
			matrix.replaceRange (start2, end2, row1);
		}

		void crossCancel (row, value, pivotRow, pivotValue) {
			final int offset = (pivotRow - row) * cols;
			for (final int n in range ((row + 1) * cols, start: row * cols)) {
				matrix [n] = pivotValue * matrix [n] - value * matrix [n + offset];
			}
		}

		int pivotRow = 0, pivotCol = 0;
		List<int> pivots = [];

		while (pivotCol < cols && pivotRow < rows) {
			final List<double> col = getCol (pivotCol);
			final Pivot pivot = getPivot (col.getRange(pivotCol, col.length));
			final int offset = pivot.index;
			final double value = pivot.value;

			if (offset == null) {
				pivotCol++;
				continue;
			}
			pivots.add(pivotCol);
			if (offset != 0) swapRows (pivotRow, offset + pivotRow);

			for (final int row in range (rows)) {
				if (row == pivotRow) continue;
				final double val = matrix [row * cols + pivotCol];
				if (val == 0) continue;
				else crossCancel (row, val, pivotRow, value);
			}
			pivotRow++;
		}

		for (final int index in range (pivots.length)) {
			final int col = pivots [index];
			final int offset = index * cols + col;
			final double value = matrix [offset];
			matrix [offset] = 1;
			for (final int index2 in range (
				(index + 1) * cols, start: offset + 1)
			) 
				matrix [index2] = matrix [index2] / value;
		}

		return Matrix.fromDimensions (rows, cols, matrix);
	}
}
