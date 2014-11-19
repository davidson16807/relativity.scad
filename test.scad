include <strings.scad>

test = "foo  (1, bar2)";
regex_test = "foooobazfoobarbaz";

function all(booleans, index=0) = 
	index >= len(booleans)?
		true
	: !booleans[index]?
		false
	: 
		all(booleans, index+1)
	;
	
echo([
	"regex:",
	contains("foo bar baz", "ba[rz]", regex=true) == true,
	contains("foo bar baz", "spam", regex=true) == false,
	index_of("foo bar baz", "ba[rz]", regex=true) == [4,7],
	index_of("foo bar baz", "ba[rz]", 1, regex=true) == [8,11],
	grep("foo bar baz", "ba[rz]", regex=true) == "bar",
	grep("foo bar baz", "ba[rz]", 1, regex=true) == "baz",
	grep("foo 867-5309 baz", "\\d\\d\\d-?\\d\\d\\d\\d", regex=true) == "867-5309", 
	replace("foo bar baz", "ba[rz]", "spam", regex=true) == "foo spam spam",
	split(regex_test, "fo+", 0, regex=true) == "",
	split(regex_test, "fo+", 1, regex=true) == "baz",
	split(regex_test, "fo+", 2, regex=true) == "barbaz",
	split(regex_test, "fo+", 3, regex=true) == undef,
	split("bazfoobar", "fo+", 0, regex=true) == "baz",
	split("bazfoobar", "fo+", 1, regex=true) == "bar",
	split("bazfoobar", "fo+", 2, regex=true) == undef,
	split("", "fo+", 0, regex=true) == "",
	split("", "fo+", 1, regex=true) == undef,
	
	contains("foo bar baz", "BA[RZ]", regex=true, ignore_case=true) == true,
	contains("foo bar baz", "SPAM", regex=true, ignore_case=true) == false,
	index_of("foo bar baz", "BA[RZ]", regex=true, ignore_case=true) == [4,7],
	index_of("foo bar baz", "BA[RZ]", 1, regex=true, ignore_case=true) == [8,11],
	grep("foo bar baz", "BA[RZ]", regex=true, ignore_case=true) == "bar",
	grep("foo bar baz", "BA[RZ]", 1, regex=true, ignore_case=true) == "baz",
	replace("foo bar baz", "BA[RZ]", "spam", regex=true, ignore_case=true) == "foo spam spam",
	split(regex_test, "FO+", 0, regex=true, ignore_case=true) == "",
	split(regex_test, "FO+", 1, regex=true, ignore_case=true) == "baz",
	split(regex_test, "FO+", 2, regex=true, ignore_case=true) == "barbaz",
	split(regex_test, "FO+", 3, regex=true, ignore_case=true) == undef,
]);
echo([
	"match_regex:",
	_explicitize_regex_alternation("(fo+(bar)?baz)+", 0) == "(fo+(bar)?baz)+",
	_explicitize_regex_concatenation("(fo+(bar)?baz)+", 0) == "(f&o+&(b&a&r)?&b&a&z)+",
	_infix_to_prefix("(f&o+&(b&a&r)?&b&a&z)+", _regex_ops, i=21) == "+&f&+o&?&b&ar&b&az",
	_match_regex_tree("foooobazfoobarbaz", _prefix_to_tree("+&f&+o&?&b&ar&b&az", "\\?*+", "&|"), 0) == 17,
	_match_regex("foooobazfoobarbaz", "(fo+(bar)?baz)+") == 17,
	
	_match_regex_tree("foooobazfoobarbaz", _prefix_to_tree("+&F&+O&?&B&AR&B&AZ", "\\?*+", "&|"), 0, ignore_case=true) == 17,
	_match_regex("foooobazfoobarbaz", "(FO+(BAR)?BAZ)+", ignore_case=true) == 17,
	
	_explicitize_regex_alternation("(give me (f[aeiou]+|dabajabaza!))+", 0) == "(give me (f(a|e|i|o|u)+|dabajabaza!))+",
	_explicitize_regex_concatenation("(give me (f(a|e|i|o|u)+|dabajabaza!))+", 0) == "(g&i&v&e& &m&e& &(f&(a|e|i|o|u)+|d&a&b&a&j&a&b&a&z&a&!))+",
	_match_regex("give me foo give me fie give me dabajabaza!", "(give me (f[aeiou]+ |dabajabaza!))+") == 43,
]);

echo([	"_explicitize_regex_alternation:",
	//happy path
	_explicitize_regex_alternation("[foo]") == "(f|o|o)",
	_explicitize_regex_alternation("foo[bar]baz") == "foo(b|a|r)baz",
	_explicitize_regex_alternation("foo[bar]") == "foo(b|a|r)",
	_explicitize_regex_alternation("[foo]bar") == "(f|o|o)bar",
	//edge cases
	_explicitize_regex_alternation("f") == "f",
	_explicitize_regex_alternation("") == "",
]);

echo([	"_explicitize_regex_concatenation:",
	//happy path
	_explicitize_regex_concatenation("foo") == "f&o&o",
	_explicitize_regex_concatenation("fo+o") == "f&o+&o",
	_explicitize_regex_concatenation("fo|o") == "f&o|o",
	_explicitize_regex_concatenation("fo|o") == "f&o|o",
	_explicitize_regex_concatenation("fo+") == "f&o+",
	_explicitize_regex_concatenation("fo|") == "f&o|",
	//escape characters
	_explicitize_regex_concatenation("\\d\\s") == "\\d&\\s",
	//_explicitize_regex_concatenation("\\\\\\\\") == "\\\\&\\\\",
	_explicitize_regex_concatenation("&&") == "\&&\&",
	//edge cases
	_explicitize_regex_concatenation("f") == "f",
	_explicitize_regex_concatenation("") == "",
]);

echo([
	"_infix_to_postfix:",
	//order of operations: binary
	_infix_to_postfix("A+B^C", "^+") == "ABC^+",
	_infix_to_postfix("A+B^C", "+^") == "AB+C^",
	_infix_to_postfix("(A+B^C)*D+E^5", "^*/+-") == "ABC^+D*E5^+",
	//order of operations: unary+binary
	_infix_to_postfix("a?", _regex_ops) == "a?",
	_infix_to_postfix("a&b?", _regex_ops) == "ab?&",
	_infix_to_postfix("(a&b)?", _regex_ops) == "ab&?",
	_infix_to_postfix("a|b?", _regex_ops) == "ab?|",
	_infix_to_postfix("(a|b)?", _regex_ops) == "ab|?",
	_infix_to_postfix("a|b&c", _regex_ops) == "abc&|",
	_infix_to_postfix("a&b|c", _regex_ops) == "ab&c|",
	_infix_to_postfix("(a|b)&c", _regex_ops) == "ab|c&",
	_infix_to_postfix("a|(b&c)", _regex_ops) == "abc&|",
	_infix_to_postfix("a?|b*&c+", _regex_ops) == "a?b*c+&|",
	//invalid syntax
	_infix_to_postfix("((()))", _regex_ops),
	_infix_to_postfix( "(()))", _regex_ops),
	_infix_to_postfix("((())", _regex_ops),
	_infix_to_postfix("a?*+", _regex_ops),
	//edge cases
	_infix_to_postfix("a", _regex_ops) == "a",
	_infix_to_postfix("", _regex_ops) == "",
	_infix_to_postfix(undef, _regex_ops) == undef,
	_infix_to_postfix("foo", undef) == undef,
	_infix_to_postfix("\\d?|b*&\\d+", _regex_ops) == "d\\?b*d\\+&|",
]);
echo([
	"_infix_to_prefix:",
	//order of operations: binary
	_infix_to_prefix("A+B^C", "^+") == "+A^BC",
	_infix_to_prefix("A+B^C", "+^") == "^+ABC",
	_infix_to_prefix("(A+B^C)*D+E^5", "^*/+-") == "+*+A^BCD^E5",
	//order of operations: unary+binary
	_infix_to_prefix("a?", _regex_ops) == "?a",
	_infix_to_prefix("a&b?", _regex_ops) == "&a?b",
	_infix_to_prefix("(a&b)?", _regex_ops) == "?&ab",
	_infix_to_prefix("a|b?", _regex_ops) == "|a?b",
	_infix_to_prefix("(a|b)?", _regex_ops) == "?|ab",
	_infix_to_prefix("a|b&c", _regex_ops) == "|a&bc",
	_infix_to_prefix("a&b|c", _regex_ops) == "|&abc",
	_infix_to_prefix("(a|b)&c", _regex_ops) == "&|abc",
	_infix_to_prefix("a|(b&c)", _regex_ops) == "|a&bc",
	_infix_to_prefix("a?|b*&c+", _regex_ops) == "|?a&*b+c",
	//escape characters
	_infix_to_prefix("\\d?", _regex_ops) == "?\\d",
	_infix_to_prefix("\\s&\\d?", _regex_ops) == "&\\s?\\d",
	_infix_to_prefix("\\d?|b*&\\d+", _regex_ops) == "|?\\d&*b+\\d",
	//invalid syntax
	_infix_to_prefix("((()))", _regex_ops) == "",
	_infix_to_prefix( "(()))", _regex_ops),
	_infix_to_prefix("((())", _regex_ops),
	_infix_to_prefix("a?*+", _regex_ops),
	//edge cases
	_infix_to_prefix("a", _regex_ops) == "a",
	_infix_to_prefix("", _regex_ops) == "",
	_infix_to_prefix(undef, _regex_ops) == undef,
	_infix_to_prefix("foo", undef) == undef,
]);

echo([
	"reverse:",
	reverse("bar") == "rab",
	reverse("ba") == "ab",
	reverse("") == "",
	reverse(undef) == undef,
]);

echo([
	"_prefix_to_tree:",
	_prefix_to_tree("", "", "") == undef,
	_prefix_to_tree("f", "", "") == undef
]);

echo([
	"_match_regex_tree:",
	"ignore_case=false",
	"literal",
	_match_regex_tree("foo", "f", 0) == 1,
	_match_regex_tree("f", "f", 0) == 1,
	"concatenation",
	_match_regex_tree("foo", "&fo", 0) == 2,
	_match_regex_tree("foo", "&fx", 0) == undef,
	_match_regex_tree("foo", "&xf", 0) == undef,
	_match_regex_tree("foo", "&xy", 0) == undef,
	"alternation",
	_match_regex_tree("foo", "|fx", 0) == 1,
	_match_regex_tree("foo", "|xf", 0) == 1,
	_match_regex_tree("foo", "|xy", 0) == undef,
	"option",
	_match_regex_tree("foo", "?x", 0) == 0,
	_match_regex_tree("foo", "?f", 0) == 1,
	"kleene star",
	_match_regex_tree("f", "*o", 0) == 0,
	_match_regex_tree("of", "*o", 0) == 1,
	_match_regex_tree("oof", "*o", 0) == 2,
	_match_regex_tree("oof", ["&","*o","f"], 0) == 3,
	_match_regex_tree("oooofaa", ["&","*o","f"], 0) == 5,
	"kleene plus",
	_match_regex_tree("f", "+o", 0) == undef,
	_match_regex_tree("of", "+o", 0) == 1,
	_match_regex_tree("oof", "+o", 0) == 2,
	_match_regex_tree("oof", ["&","+o","f"], 0) == 3,
	_match_regex_tree("oooofaa", ["&","+o","f"], 0) == 5,
	"wildcard",
	_match_regex_tree("foo", ".", 0) == 1,
	_match_regex_tree("f", "+.", 0)==1,
	"anchor",
	_match_regex_tree("foo", ["&", "^", "&fo"], 0) == 2,
	_match_regex_tree(" foo", ["&", "^", "&fo"], 1, 0) == undef,
	_match_regex_tree("foo", ["&", "f", ["&", "o", "&o$"]], 0, 0) == 3,
	_match_regex_tree("foo ", ["&", "f", ["&", "o", "&o$"]], 0, 0) == undef,
	"edge cases",
	_match_prefix_regex("f", "f", 0, 0)==1,
	_match_prefix_regex(undef, "f", 0, 0)==undef,
	_match_prefix_regex("f", undef, 0, 0)==undef,
	
	"_match_regex_tree:",
	"ignore_case=true",
	"literal",
	_match_regex_tree("FOo", "f", 0, ignore_case=true) == 1,
	_match_regex_tree("F", "f", 0, ignore_case=true) == 1,
	"concatenation",
	_match_regex_tree("FOo", "&fo", 0, ignore_case=true) == 2,
	_match_regex_tree("FOo", "&fx", 0, ignore_case=true) == undef,
	_match_regex_tree("FOo", "&xf", 0, ignore_case=true) == undef,
	_match_regex_tree("FOo", "&xy", 0, ignore_case=true) == undef,
	"alternation",
	_match_regex_tree("FOo", "|fx", 0, ignore_case=true) == 1,
	_match_regex_tree("FOo", "|xf", 0, ignore_case=true) == 1,
	_match_regex_tree("FOo", "|xy", 0, ignore_case=true) == undef,
	"option",
	_match_regex_tree("FOo", "?x", 0, ignore_case=true) == 0,
	_match_regex_tree("FOo", "?f", 0, ignore_case=true) == 1,
	"kleene star",
	_match_regex_tree("F", "*o", 0, ignore_case=true) == 0,
	_match_regex_tree("OF", "*o", 0, ignore_case=true) == 1,
	_match_regex_tree("oOF", "*o", 0, ignore_case=true) == 2,
	_match_regex_tree("oOF", ["&","*o","f"], 0, ignore_case=true) == 3,
	_match_regex_tree("oOoOFaa", ["&","*o","f"], 0, ignore_case=true) == 5,
	"kleene plus",
	_match_regex_tree("f", "+o", 0, ignore_case=true) == undef,
	_match_regex_tree("Of", "+o", 0, ignore_case=true) == 1,
	_match_regex_tree("oOF", "+o", 0, ignore_case=true) == 2,
	_match_regex_tree("oOF", ["&","+o","f"], 0, ignore_case=true) == 3,
	_match_regex_tree("oOoOFaa", ["&","+o","f"], 0, ignore_case=true) == 5,
	"wildcard",
	//wildcard
	_match_regex_tree("FOo", ".", 0, ignore_case=true) == 1,
	_match_regex_tree("f", "+.", 0, ignore_case=true)==1,
	"anchor",
	//anchor
	_match_regex_tree("FOo", ["&", "^", "&fo"], 0, ignore_case=true) == 2,
	_match_regex_tree(" FOo", ["&", "^", "&fo"], 1, ignore_case=true) == undef,
	_match_regex_tree("FOo", ["&", "f", ["&", "o", "&o$"]], 0, ignore_case=true) == 3,
	_match_regex_tree("FOo ", ["&", "f", ["&", "o", "&o$"]], 0, ignore_case=true) == undef,
	"edge cases",
	//edge cases
	_match_prefix_regex("F", "f", 0, ignore_case=true)==1,
	_match_prefix_regex(undef, "f", 0, ignore_case=true)==undef,
	_match_prefix_regex("F", undef, 0, ignore_case=true)==undef,
]);

echo([
	"_match_prefix",
	_match_prefix("++1+1++11+111", "", "+", 0) == 13,
	_match_prefix("&^&fo", "\\?*+", "&|", 0),
	_match_prefix("&^&fo", "\\?*+", "&|", 1),
	_match_prefix("&^&fo", "\\?*+", "&|", 2),
	_match_prefix("&^&fo", "\\?*+", "&|", 3),
	_match_prefix("&^&fo", "\\?*+", "&|", 4),
	_match_prefix("&^&fo", "\\?*+", "&|", 5),
	_match_prefix("&^&fo", "\\?*+", "&|", 6),
]);

echo([	"token:",
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

echo([	"_token_end:",
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

	
echo(["replace", 	
	replace("foobar", "oo", "ee") == "feebar",
	replace("foobar foobar", "oo", "ee") == "feebar feebar",
	replace("foobar", "OO", "ee", ignore_case=true) == "feebar",
	replace("foobar foobar", "OO", "ee", ignore_case=true) == "feebar feebar",
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
	
echo(["index_of", 	
	index_of("foobar", "o") == 1,
	index_of("foobar", "o", 1) == 2,
	index_of("foobar", "o", -1) == undef,
	index_of("foobar foobar", "oo")==1,
	index_of("foobar foobar", "oo", 1)==8,
	index_of("foobar", "Bar") == undef,
	index_of("foobar", "Bar", ignore_case=true) == 3]);

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
	
*echo(["lower:", lower("!@#$1234FOOBAR!@#$1234") == "!@#$1234foobar!@#$1234"]);
*echo(["upper:", upper("!@#$1234foobar!@#$1234") == "!@#$1234FOOBAR!@#$1234"]);

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
      ]);
