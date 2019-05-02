Iterable<int> range(int stop, {int start = 0, int step = 1}) sync* {
	if (start < stop) {
	    for (int x = start; x < stop; x += step) yield x;
	} else {
		for (int x = start; x > stop; x += step) yield x;
	}
}

class Pair<T> {
	final T value;
	final int index;
	const Pair (this.index, this.value);
}

Iterable<Pair<E>> enumerate<E> (Iterable<E> list) sync* {
	int index = 0;
	for (final E value in list) 
		yield Pair<E> (index++, value);
}