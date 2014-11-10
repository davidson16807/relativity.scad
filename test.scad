include <strings.scad>

function all(booleans, index=0) = 
	index >= len(booleans)?
		true
	: !booleans[index]?
		false
	: 
		all(booleans, index+1)
	;
	
echo([
	"match_regex:",
	_explicitize_concatenation("(fo+(bar)?baz)+", 0) == "(f&o+&(b&a&r)?&b&a&z)+",
	_infix_to_prefix("(f&o+&(b&a&r)?&b&a&z)+", "?*+&|", i=21) == "+&f&+o&?&b&ar&b&az",
	_compile_regex("(fo+(bar)?baz)+") == "+&f&+o&?&b&ar&b&az",
	_match_prefix_regex("foooobazfoobarbaz", "+&f&+o&?&b&ar&b&az", 0, 0) == 17,
	match_regex("foooobazfoobarbaz", "(fo+(bar)?baz)+") == 17,
]);

echo([	"_explicitize_concatenation:",
	_explicitize_concatenation("fo+o"),
]);

echo([
	"_infix_to_prefix:",
	_infix_to_prefix("A+B^C", "^+", i=4) == "+A^BC",
	_infix_to_prefix("A+B^C", "+^", i=4) == "^+ABC",
	_infix_to_prefix("(A+B^C)*D+E^5", "^*/+-", i=12) == "+*+A^BCD^E5",
	_infix_to_prefix("a?", "?*+&|") == "?a",
	_infix_to_prefix("a&b?", "?*+&|") == "&a?b",
	_infix_to_prefix("(a&b)?", "?*+&|") == "?&ab",
	_infix_to_prefix("a|b?", "?*+&|") == "|a?b",
	_infix_to_prefix("(a|b)?", "?*+&|") == "?|ab",
	_infix_to_prefix("a|b&c", "?*+&|") == "|a&bc",
	_infix_to_prefix("a&b|c", "?*+&|") == "|&abc",
	_infix_to_prefix("(a|b)&c", "?*+&|") == "&|abc",
	_infix_to_prefix("a|(b&c)", "?*+&|") == "|a&bc",
	_infix_to_prefix("a?|b*&c+", "?*+&|") == "|?a&*b+c",
	_infix_to_prefix("", "?*+&|") == "",
	_infix_to_prefix("((()))", "?*+&|") == "",
	_infix_to_prefix( "(()))", "?*+&|"),
	_infix_to_prefix("((())", "?*+&|"),
	_infix_to_prefix("a?*+", "?*+&|"),
]);

echo([
	"reverse:",
	reverse("bar") == "rab",
	reverse("ba") == "ab",
	reverse("") == "",
	reverse(undef) == undef,
]);

echo([
	"_match_prefix_regex:",
	_match_prefix_regex("foo", "f", 0, 0) == 1,
	_match_prefix_regex("foo", "&fo", 0, 0) == 2,
	_match_prefix_regex("foo", "&fx", 0, 0) == undef,
	_match_prefix_regex("foo", "&xf", 0, 0) == undef,
	_match_prefix_regex("foo", "&xy", 0, 0) == undef,
	_match_prefix_regex("foo", "|fx", 0, 0) == 1,
	_match_prefix_regex("foo", "|xf", 0, 0) == 1,
	_match_prefix_regex("foo", "|xy", 0, 0) == undef,
	_match_prefix_regex("foo", "?x", 0, 0) == 0,
	_match_prefix_regex("foo", "?f", 0, 0) == 1,
	_match_prefix_regex("f", "*o", 0, 0) == 0,
	_match_prefix_regex("of", "*o", 0, 0) == 1,
	_match_prefix_regex("oof", "*o", 0, 0) == 2,
	_match_prefix_regex("oof", "&*of", 0, 0) == 3,
	_match_prefix_regex("f", "+o", 0, 0) == undef,
	_match_prefix_regex("of", "+o", 0, 0) == 1,
	_match_prefix_regex("oof", "+o", 0, 0) == 2,
	_match_prefix_regex("oof", "&+of", 0, 0) == 3,
	_match_prefix_regex("oooofaa", "&*of", 0, 0) == 5,
	_match_prefix_regex("foo", ".", 0, 0) == 1,
	_match_prefix_regex("f", "+.", 0, 0)==1,
]);

echo([
	"_match_prefix",
	_match_prefix("++1+1++11+111", "", "+", 0) == 13,
]);

*echo([	"token:",
	token(" ", 0) == undef,
	token(test, -1) == undef,
	token(test, 0) == "foo",
	token(test, 1) == "(",
	token(test, 2) == "1",
	token(test, 3) == ",",
	token(test, 4) == "bar2",
	token(test, 5) == ")",
	token(test, 6) == undef,
]);

*echo([	"_token_end:",
	_token_end(" ", 0),
	_token_end(test, 0) ==3,
	_token_end(test, 3) ==6,
	_token_end(test, 6) ==7,
	_token_end(test, 7) ==8,
	_token_end(test, 8) ==13,
	_token_end(test, 13)==14,
	_token_end(test, 14)==14,
	]);

echo([	"trim:",
	trim(" foo ") == "foo",
	trim(" foo") == "foo",
	trim("foo ") == "foo",
	trim("foo") == "foo",
	trim("") == "",
	trim(" ") == "",
	trim("  ") == "",
	trim(undef) == undef,
]);

echo([	"split:",
	split("", " ", 0) == "",
	split(test, " ", -1) == undef,
	split(test, " ", 0) == "foo",
	split(test, " ", 1) == "",
	split(test, " ", 2) == "(1,",
	split(test, " ", 3) == "bar2)",
	split(test, " ", 4) == undef,
	split(test, " ", 5) == undef,
	split("foo", " ") == "foo",
	]);
	
echo(["find", 	
	find("foobar", "o") == 1,
	find("foobar", "o", 1) == 2,
	find("foobar", "o", -1) == undef,
	find("foobar foobar", "oo")==1,
	find("foobar foobar", "oo", 1)==8,
	find("foobar", "Bar") == undef,
	find("foobar", "Bar", ignore_case=true) == 3]);

echo([	"starts_with:", 
	starts_with("foobar", "foo"),
	starts_with("foobar", "oo", 1)]);
	
echo(["ends_with:", ends_with("foobar", "bar")]);

echo(["equals:", 
	equals("foo", "bar") == false,
	equals("foo", "foo") == true,
	equals("foo", "FOo") == false,
	equals("foo", "FOo", ignore_case=true) == true,
	]);
	
echo(["lower:", lower("!@#$1234FOOBAR!@#$1234") == "!@#$1234foobar!@#$1234"]);
echo(["upper:", upper("!@#$1234foobar!@#$1234") == "!@#$1234FOOBAR!@#$1234"]);

echo([	"join:",
	join(["foo", "bar", "baz"], ", ") == "foo, bar, baz",
	join(["foo", "bar", "baz"], "") == "foobarbaz",
	join(["foo"], ",") == "foo",
	join([], "") == "",
	
]);

echo([	"substring:",
	substring("foobar", 2, 2) == "ob",
	substring("foobar", 2, undef) == "obar",
	]);

echo([	"between:",
	between("bar", undef, undef) == undef,
	between("bar", undef, 1) == undef,
	between("bar", 1, undef) == undef,
	between("bar", -1, 1) == "b",
	between("bar", 1, 2) == "a",
	between("bar", 1, 3) == "ar",
	between("bar", 0, 2) == "ba",
	between("bar", 1, 1) == "",
	between("bar", -1, -1) == "",
	between("bar", 3, 3) == "",
	between("bar", 4, 4) == undef,
	between("foobar", 2, 4)=="ob",
	between("foobar", 4, 2) == undef,
      ]);
     
echo([	"before:",
	before("foo", -1) == "",
	before("foo", 0) == "",
	before("foo", 1) == "f",
	before("foo", 2) == "fo",
	before("foo", 3) == "foo",
	before("foo", undef) == undef
      ]);
      
echo([	"after:",
	after("foo", -1) == "foo",
	after("foo", 0) == "oo",
	after("foo", 1) == "o",
	after("foo", 2) == "",
	after("foo", 3) == "",
	after("foo", undef) == undef,
	after([1,2,3,4], 1)
      ]);
