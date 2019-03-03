class PolyatomicIon {
	final String name;
	final int charge;

	const PolyatomicIon(this.name, this.charge);

	@override operator == (dynamic other) => (
		other.runtimeType == PolyatomicIon &&
		this.name == other.name &&
		this.charge == other.charge
	);

	@override int get hashCode => this.name.hashCode;

	@override String toString() => "PolyatomicIon ($name, $charge)";
}

class Prefix {
	final String symbol, prefix;

	const Prefix (this.symbol, this.prefix);
}