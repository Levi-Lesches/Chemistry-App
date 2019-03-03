Map <int, String> _letters = {
	1000: "M",
	900: "CM",
	500: "D",
	400: "CD",
	100: "C",
	90: "XC",
	50: "L",
	40: "XL",
	10: "X",
	9: "IX",
	5: "V",
	4: "IV",
	1: "I"
};

toRoman (int number) {
	if (!_isDecimal (number)) 
		throw "Roman: Number needs to be from 1-3,999. Got $number";

	String result = "";
	_letters.forEach (
		(int num, String letter) {
			while (number >= num) {
				number -= num;
				result += letter;
			}
		}
	);
	return result;
}

toDecimal (String roman) {
	roman = roman.toUpperCase();
	int result = 0;
	_letters.forEach (
		(int num, String letter) {
			while (roman.startsWith (letter)) {
				roman = roman.substring (letter.length, roman.length);
				result += num;
			}
		}
	);
	return result;
}

bool verify (String roman) {
	for (int index = 0; index < roman.length; index++) {
		if (!_letters.containsValue (roman [index])) return false;
		else if (
			index < roman.length - 3
			&& roman [index + 1] == roman [index]
			&& roman [index + 2] == roman [index]
			&& roman [index + 3] == roman [index]
		) return false;
	}
	return true;
}

bool _isDecimal (int number) => number > 0 && number < 3999;

