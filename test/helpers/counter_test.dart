import "package:flutter_test/flutter_test.dart";

import "package:chemistry/helpers/counter.dart";

const List <String> WORDS = ["Hello", "There", "Levi"];

void main () {
	test ("Attribute test: ", testAttributes);
	test ("Coefficients test: ", testCoefficient);
	test ("Addition test: ", testAddition);
	test ("Getter test: ", testGet);
	test ("Setter test: ", testSet);
	test ("Print test: ", testPrint);
}

void testAttributes() {
	final Counter<String> counter = Counter (WORDS);
	expect (counter.elements, WORDS);

	testValues(counter, 1);

	final List <String> elements = [];
	for (CounterEntry<String> entry in counter) 
		elements.add (entry.value);
	expect (elements, WORDS);		
}	

void testCoefficient() {
	Counter<String> counter = Counter (WORDS);

	counter *= 3;
	testValues(counter, 3);
}

void testAddition() {
	Counter<String> counter = Counter (WORDS);
	int count = 1;

	counter += Counter<String> (WORDS);
	count += 1;
	testValues(counter, count);
}

void testGet() {
	final Counter<String> counter = Counter (WORDS);

	for (String word in WORDS) 
		expect (counter [word], 1);
	expect (counter ["HFJDKHFS"], 0);
}

void testSet() {
	final Counter<String> counter = Counter (WORDS);

	counter ["ABC"] = 2;
	expect (counter ["ABC"], 2);

	counter [WORDS [0]] = 100;
	expect (counter [WORDS [0]], 100);
}

void testPrint() {
	final Counter counter = Counter (WORDS);
	expect (
		counter.toString(),
		"{Hello: 1, There: 1, Levi: 1}"
	);
}

void testValues (Counter counter, int count) {
	assert (counter != null, "TEST_VALUES: Counter is null");
	for (int value in counter.counter.values) 
		expect (value, count);
}