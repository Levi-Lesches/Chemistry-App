Iterable range(int stop, {int start = 0, int step = 1}) sync* {
	while (start < stop) {
		yield start;
		start += step;
	}
}