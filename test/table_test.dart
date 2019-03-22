import "package:chemistry/periodic_table.dart";
import "package:chemistry/bases/element.dart";
import "package:chemistry/helpers/range.dart";

void main() {
	for (final int index in range (periodicTable.elements.length)) {
		final int atomicNumber = index + 1;
		final Element element = periodicTable.elements [index];

		final Element elementByNumber = periodicTable [atomicNumber];
		assert (
			elementByNumber == element, 
			"Cannot search by Atomic number:\n"
			"	Used $atomicNumber to get $element but got $elementByNumber"
		);

		final String symbol = element.symbol;
		final Element elementBySymbol = periodicTable [symbol];
		assert (
			elementBySymbol == element, 
			"Cannot search by element:\n"
			"	Used $symbol to get $element but got $elementBySymbol"
		);

		final String name = element.name;
		final Element elementByName = periodicTable [name];
		assert (
			elementByName == element,
			"Cannot search by name:\n"
			"	Used $name to get $element but got $elementByName"
		);
	}
}