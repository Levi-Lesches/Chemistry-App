import "package:chemistry/helpers/roman.dart" as Roman;

import "package:flutter_test/flutter_test.dart";

void main() {
	test ("Basic looping test: ", basicTest);
}

void basicTest() {
	for (int num in List.generate (3998, (int index) => index + 1)) {
		final String roman = Roman.toRoman (num);
		final int decimal = Roman.toDecimal(roman);
		expect (Roman.verify(roman), true);
		expect (decimal, num);
	}
}