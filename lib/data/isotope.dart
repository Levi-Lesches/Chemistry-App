class Isotope {
	final double mass, abundance;
	final int massNumber;

	const Isotope ([
		this.mass = 0,
		this.abundance = 1,
		this.massNumber	= 0
	]);

	@override String toString() => "Isotope ($mass, $abundance)";

	String details() => "$massNumber, $mass, ${abundance * 100}";

	@override operator == (dynamic other) => (
		other.runtimeType == Isotope &&
		this.mass == other.mass &&
		this.abundance == other.abundance &&
		this.massNumber == other.massNumber
	);

	@override int get hashCode => this.massNumber.hashCode;

}