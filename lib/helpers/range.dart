Iterable<int> range(int stop, {int start = 0, int step = 1}) sync* {
	for (int x = start; x < stop; x += step) yield x;
}

class Pair<T> {
	final T value;
	final int index;
	const Pair (this.index, this.value);
}

Iterable<Pair<E>> enumerate<E> (List<E> list) sync* {
	for (final int index in range (list.length)) {
		yield Pair<E> (index, list [index]);
	}
}