import 'package:flutter_test/flutter_test.dart';

import "package:chemistry/helpers/strings.dart";

import "../compare.dart";


void main () {
	test ("Get closing paren: ", closingParenTest);
	test ("Get int: ", consumeIntTest);
	test ("Title: ", titleTest);
	test ("Is int: ", isIntTest);
	test ("Element base names: ", baseNameTest);
}

void closingParenTest() {
	compare<int> (findClosingParen ("HEY", 0), null);
	compare<int> (findClosingParen ("Hey (there)", 4), 10);	
	compare<int> (findClosingParen ("This (is (cool))", 5), 15);
}


void consumeIntTest () {
	final str1 = "HEY user543";
	final str2 = "My number is 52 and I like it";

	compare<int> (consumeInt ("HEY", 0), 0);
	compare<bool> (isInt ("HEY" [consumeInt ("HEY", 0)]), false);

	compare<int> (consumeInt (str1, 8), 10);
	compare<int> (getInt (str1, 8), 543);

	compare<int> (consumeInt (str2, 13), 14);
	compare<int> (getInt (str2, 13), 52);
	compare<bool> (isInt (str2 [consumeInt (str2, 13) + 1]), false);
}

void isIntTest() {
	compare<bool> (isInt ("4"), true);
	compare<bool> (isInt ("A"), false);
	// the function should never get > 1 letter, but still...
	compare<bool> (isInt ("ABC"), false);
	compare<bool> (isInt ("A0"), false);
	compare<bool> (isInt ("43"), true);
}

void titleTest() {
	compare<String> (title ("hey there"), "Hey there");
	compare<String> (title ("helium"), "Helium");
	compare<String> (title ("440"), "440");
	compare<String> (title ("Helium"), "Helium");
}

void baseNameTest() {
	compare<String> (getBaseName ("Chlorine"), "Chlor");
	compare<String> (getBaseName ("Tin"), "Tin");
	compare<String> (getBaseName ("Actinide"), "Actin");
	compare<String> (getBaseName ("Oxygen"), "Ox");
	compare<String> (getBaseName ("Lithium"), "Lith");
	compare<String> (getBaseName ("Chromium"), "Chrom");
	compare <String> (getBaseName ("Hydrogen"), "Hydr");
	compare <String> (getBaseName ("Phosphorus"), "Phosph");
	compare <String> (getBaseName ("Sulfur"), "Sulf");
	compare <String> (getBaseName ("Carbon"), "Carb");

}