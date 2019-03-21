import "range.dart";

class Fraction {
	final int num, denom;
	final bool negative;
	const Fraction._ (this.num, this.denom, this.negative);

	factory Fraction (int num, int denom) {
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