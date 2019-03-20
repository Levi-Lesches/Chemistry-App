class PivotResult {
	final int index, value;
	const PivotResult(this.index, this.value)
}

PivotResult getPivot(List<int> col) {
	final int result_index, result;
	for (int index = 0; index < col.length; index++) {
		final int value = col [index];
		if (value != 0) return PivotResult (index, value);
		else {
			result_index ??= index;
			result ??= value;
		}
	}
	return PivotResult (index, value);
}