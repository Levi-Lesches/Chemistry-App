int findClosingParen (String text, int startIndex) {
	int count = 1;
	for (
			final Match match in 
			RegExp (r"\(|\)").allMatches(text, startIndex + 1)
	) {
		if (match.group (0) == "(") count++;
		else {
			count--;
			if (count == 0) return match.start;
		}
	}
	return null;
}

int consumeInt (String text, int startIndex) => isInt (text [startIndex])
	? RegExp (r"\d+").matchAsPrefix(text, startIndex).end - 1
	: startIndex;

int getInt (String text, int index) => int.parse (
	text.substring (
		index, 
		consumeInt (text, index) + 1
	)
);

String title (String word) => word [0].toUpperCase() + word.substring (1);

bool isInt (String letter) => int.tryParse(letter) != null;

String getBaseName (String name) {
	String result;
	if (name.endsWith ("orus")) result = name.substring (0, name.length - 4);
	else if (
		name.endsWith ("ium") ||
		name.endsWith("ine") || 
		name.endsWith("gen") || 
		name.endsWith("ide")
	) result = name.substring (0, name.length - 3);
	else if (
		name.endsWith("on") || 
		name.endsWith ("ur") || 
		name.endsWith("ic")
	) result = name.substring(0, name.length - 2);
	else result = name;

	if (
		["a", "e", "i", "o", "u", "y"].contains (result [result.length - 1])
	) result = result.substring(0, result.length - 1);

	return result;
}