import "dart:collection" show IterableMixin;

class Counter <T> with IterableMixin <CounterEntry <T>> {
	List <T> get elements => List.from (counter.keys);
	final Map <T, int> counter = {};

	Counter ([_elements = const []]) {
		for (T element in _elements) {
			if (!counter.containsKey(element)) counter [element] = 1;
			else counter [element] += 1;
		}
	}

	Counter.fromMap(Map map) {counter.addAll(map.cast <T, int>());}

	Counter operator * (int coefficient) {
		for (T element in counter.keys) 
			counter [element] *= coefficient;
		return this;
	}

	Counter operator + (Counter<T> other) {
		for (T element in other.counter.keys) 
			this [element] += other [element];
		return this;
	}

	int operator []  (T element) => counter [element] ?? 0;
	void operator []= (T element, int value) {counter [element] = value;}

	@override
	Iterator <CounterEntry<T>> get iterator => counter.entries.map (
		(MapEntry<T, int> entry) => CounterEntry<T>(entry.key, entry.value)
	).iterator;


	@override
	String toString() {
		List <String> result = [];
		for (CounterEntry<T> entry in this) {
			result.add ("${entry.value}: ${entry.count}");
		}
		return "{${result.join (", ")}}";
	}

	@override operator == (dynamic other) => (
		other.runtimeType == Counter &&
		this.counter == other.counter
	);

	@override int get hashCode => this.counter.hashCode;
}

class CounterEntry<T> {
	final T value;
	final int count;
	const CounterEntry (this.value, this.count);
}