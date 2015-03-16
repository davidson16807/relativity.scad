include <strings.scad>

test = "foo  (1, bar2)";
regex_test = "foooobazfoobarbaz";

	



	


     
echo([	"after:",
	after("foo", -1) == "foo",
	after("foo", 0) == "oo",
	after("foo", 1) == "o",
	after("foo", 2) == "",
	after("foo", 3) == "",
	after("foo", undef) == undef,
      ]);
echo([	"before:",
	before("foo", -1) == "",
	before("foo", 0) == "",
	before("foo", 1) == "f",
	before("foo", 2) == "fo",
	before("foo", 3) == "foo",
	before("foo", undef) == undef
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

echo([	"substring:",
	substring("foobar", 2, 2) == "ob",
	substring("foobar", 2, undef) == "obar",
	]);

echo([	"join:",
	join(["foo", "bar", "baz"], ", ") == "foo, bar, baz",
	join(["foo", "bar", "baz"], "") == "foobarbaz",
	join(["foo"], ",") == "foo",
	join([], "") == "",
]);
echo(["is_in:",
    is_in("r", "foobar"),
    !is_in("x", "foobar")
    ]);
*echo(["lower:", lower("!@#$1234FOOBAR!@#$1234") == "!@#$1234foobar!@#$1234"]);
*echo(["upper:", upper("!@#$1234foobar!@#$1234") == "!@#$1234FOOBAR!@#$1234"]);
echo(["equals:", 
	equals("foo", "bar") == false,
	equals("foo", "foo") == true,
	equals("foo", "FOo") == false,
	equals("foo", "FOo", ignore_case=true) == true,
	]);
echo([	"starts_with:", 
	starts_with("foobar", "foo"),
	starts_with("foobar", "oo", 1)]);
	
echo(["ends_with:", ends_with("foobar", "bar")]);


echo(["index_of", 	
	index_of("foobar", "o") == 1,
	index_of("foobar", "o", 1) == 2,
	index_of("foobar", "o", -1) == undef,
	index_of("foobar foobar", "oo")==1,
	index_of("foobar foobar", "oo", 1)==8,
	index_of("foobar", "Bar") == undef,
	index_of("foobar", "Bar", ignore_case=true) == 3]);

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

echo(["replace", 	
	replace("foobar", "oo", "ee") == "feebar",
	replace("foobar foobar", "oo", "ee") == "feebar feebar",
	replace("foobar", "OO", "ee", ignore_case=true) == "feebar",
	replace("foobar foobar", "OO", "ee", ignore_case=true) == "feebar feebar",
]);

echo([	"tokenize:",
	tokenize(" ") == [""],
	tokenize(test)[-1] == undef,
	tokenize(test)[0] == "foo",
	tokenize(test)[1] == "(",
	tokenize(test)[2] == "1",
	tokenize(test)[3] == ",",
	tokenize(test)[4] == "bar2",
	tokenize(test)[5] == ")",
	tokenize(test)[6] == undef,
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

echo([
	"reverse:",
	reverse("bar") == "rab",
	reverse("ba") == "ab",
	reverse("") == "",
	reverse(undef) == undef,
]);
	






















echo([
	"_parse_rx:",
	"atomic operations",
	_parse_rx("a?") == ["?", "a"],
	_parse_rx("a*") == ["*", "a"],
	_parse_rx("a+") == ["+", "a"],
	_parse_rx("foo") == ["&", ["&", "f", "o"], "o"], 
	_parse_rx("a|b") == ["|", "a", "b"],
	
	"variable repetition",
	_parse_rx(".{3}") == ["{", 
		".", 
		["3", []]
	], 
	_parse_rx(".{3,5}") == ["{",
		 ".", 
		 ["5", 
			["3", []]]
	], 
	"charsets",
	_parse_rx(".[abcdef]") == ["&",
		 ".", 
		 ["[", 
			["f", ["e", ["d", ["c", ["b", ["a", []]]]]]]
		 ]
	], 
	_parse_rx("[a-z]") == ["[", [["-", "a", "z"], []]],
	_parse_rx(".[^abcdef]") == ["&",
		 ".", 
		 ["[^", 
			["f", ["e", ["d", ["c", ["b", ["a", []]]]]]]
		 ]
	], 
	_parse_rx("^[a-z]") == ["&", "^", ["[", [["-", "a", "z"], []]]],
	"escape characters",
	_parse_rx("\\d") == "\\d",
	_parse_rx("\\d\\d") == ["&", "\\d", "\\d"],
	_parse_rx("\\d?") ==  ["?", "\\d"],
	_parse_rx("\\s\\d?") == ["&", "\\s", ["?", "\\d"]],
	_parse_rx("\\d?|b*\\d+") == ["|",["?","\\d"],["&",["*","b"],["+","\\d"]]],
	_parse_rx("a|\\(bc\\)") == ["|","a",["&",["&",["&","\\(","b"],"c"],"\\)"]],
	"order of operations",
	_parse_rx("ab?") == ["&", "a", ["?", "b"]],
	_parse_rx("(ab)?") == ["?", ["&", "a", "b"]],
	_parse_rx("a|b?") ==  ["|", "a", ["?", "b"]],
	_parse_rx("(a|b)?") ==  ["?", ["|", "a", "b"]],
	_parse_rx("a|bc") ==  ["|", "a", ["&", "b", "c"]],
	_parse_rx("ab|c") == ["|", ["&", "a", "b"], "c"],
	_parse_rx("(a|b)c") == ["&", ["|", "a", "b"], "c"],
	_parse_rx("a|(bc)") == ["|", "a", ["&", "b", "c"]],
	_parse_rx("a?|b*c+") == ["|",["?","a"],["&",["*","b"],["+", "c"]]],
	_parse_rx("a?|b*c+d|d*e+") == 
	["|", 
		["|", 
			["?", "a"], 
			["&", ["&", ["*", "b"], ["+", "c"]], "d"]], 
		["&", ["*", "d"], ["+", "e"]]
	],
	"edge cases",
	_parse_rx("a") == "a",
	_parse_rx("")  == undef,
	_parse_rx(undef) == undef,
	"invalid syntax",
	_parse_rx("((()))"),
	_parse_rx( "(()))"),
	_parse_rx("((())"),
	_parse_rx("a?*+"),
]);

echo([
	"_match_parsed_rx:",
	"literals",
	//literals
	_match_parsed_rx("foo", "f", 0) == 1,
	_match_parsed_rx("f", "f", 0) == 1,
	_match_parsed_rx("foo", "&fo", 0) == 2,
	_match_parsed_rx("foo", "&fx", 0) == undef,
	_match_parsed_rx("foo", "&xf", 0) == undef,
	_match_parsed_rx("foo", "&xy", 0) == undef,
	_match_parsed_rx("foo", "|fx", 0) == 1,
	_match_parsed_rx("foo", "|xf", 0) == 1,
	_match_parsed_rx("foo", "|xy", 0) == undef,
	_match_parsed_rx("foo", "?x", 0) == 0,
	_match_parsed_rx("foo", "?f", 0) == 1,
	_match_parsed_rx("f", "*o", 0) == 0,
	_match_parsed_rx("of", "*o", 0) == 1,
	_match_parsed_rx("oof", "*o", 0) == 2,
	_match_parsed_rx("oof", ["&","*o","f"], 0) == 3,
	_match_parsed_rx("oooofaa", ["&","*o","f"], 0) == 5,
	_match_parsed_rx("f", "+o", 0) == undef,
	_match_parsed_rx("of", "+o", 0) == 1,
	_match_parsed_rx("oof", "+o", 0) == 2,
	_match_parsed_rx("oof", ["&","+o","f"], 0) == 3,
	_match_parsed_rx("oooofaa", ["&","+o","f"], 0) == 5,
	"wildcard",
	//wildcard
	_match_parsed_rx("FOO", ".", 0, 0, ignore_case=true) == 1,
	_match_parsed_rx("F", "+.", 0, 0, ignore_case=true)==1,
	"anchor",
	//anchor
	_match_parsed_rx("FOO", ["&", "^", "&fo"], 0, 0, ignore_case=true) == 2,
	_match_parsed_rx(" FOO", ["&", "^", "&fo"], 1, 0, ignore_case=true) == undef,
	_match_parsed_rx("FOO", ["&", "f", ["&", "o", "&o$"]], 0, 0, ignore_case=true) == 3,
	_match_parsed_rx("FOO ", ["&", "f", ["&", "o", "&o$"]], 0, 0, ignore_case=true) == undef,
	"edge cases",
	//edge cases
	_match_parsed_rx("F", "f", 0, 0, ignore_case=true)==1,
	_match_parsed_rx(undef, "f", 0, 0, ignore_case=true)==undef,
	_match_parsed_rx("F", undef, 0, 0, ignore_case=true)==undef,
	
	_match_parsed_rx("f", ["[", [["-", "a", "z"], []]], 0) ==1,
	_match_parsed_rx("o", ["[", [["-", "a", "z"], []]], 0) ==1,
	_match_parsed_rx("g", ["[", [["-", "a", "z"], []]], 0) ==1,
	_match_parsed_rx("0", "\\d", 0) ==1,
	_match_parsed_rx("a", "\\d", 0) ==1,
	
]);


echo([
	"_match_regex",
	_match_regex("foobarbaz", "[foba]{2,5}") == 5,
	_match_regex("foobarbaz", "[foba]{6,10}") == undef,
	_match_regex("foobarbaz", "[fobar]{2,6}") == 6,
	_match_regex("foobarbaz", "[fobar]{2,10}") == 8,
	_match_regex("foobarbaz", "[a-z]*") == 9,
	_match_regex("foobarbaz", "[f-o]*") == 3,
	_match_regex("012345", "[^a-z]*") == 6,
	_match_regex("foobarbaz", "[^a-z]*") == undef,
	_match_regex("foobarbaz", "[^f-o]*") == undef,
]);

echo([
	"regex:",
	contains("foo bar baz", "ba[rz]", regex=true) == true,
	contains("foo bar baz", "spam", regex=true) == false,
	index_of("foo bar baz", "ba[rz]", regex=true) == [4,7],
	index_of("foo bar baz", "ba[rz]", 1, regex=true) == [8,11],
	grep("foo bar baz", "ba[rz]", regex=true) == "bar",
	grep("foo bar baz", "ba[rz]", 1, regex=true) == "baz",
	grep("foo 867-5309 baz", "\\d\\d\\d-?\\d\\d\\d\\d", regex=true), 
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

