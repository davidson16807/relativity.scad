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



*echo([	"tokenize:",
	tokenize(" ") == [],
	tokenize(test)[0] == "foo",
	tokenize(test)[1] == "(",
	tokenize(test)[2] == "1",
	tokenize(test)[3] == ",",
	tokenize(test)[4] == "bar2",
	tokenize(test)[5] == ")",
	tokenize(test)[6] == undef,
    
	tokenize(" ", ignore_space=false) == [" "],
	tokenize(test, ignore_space=false)[0] == "foo",
	tokenize(test, ignore_space=false)[1] == "  ",
	tokenize(test, ignore_space=false)[2] == "(",
	tokenize(test, ignore_space=false)[3] == "1",
	tokenize(test, ignore_space=false)[4] == ",",
	tokenize(test, ignore_space=false)[5] == " ",
	tokenize(test, ignore_space=false)[6] == "bar2",
	tokenize(test, ignore_space=false)[7] == ")",
	tokenize(test, ignore_space=false)[8] == undef,
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
	






















*echo([
	"_parse_rx:",
	"atomic operations",
	_parse_rx("a?"),
	_parse_rx("a*"),
	_parse_rx("a+"),
	_parse_rx("foo"),
	_parse_rx("a|b"),
	
	"variable repetition",
	_parse_rx(".{3}"),
	_parse_rx(".{3,5}"),
	"charsets",
	_parse_rx(".[abcdef]"),
	_parse_rx("[a-z]"),
	_parse_rx(".[^abcdef]"),
	_parse_rx("^[a-z]"),
	"escape characters",
	_parse_rx("\\d"),
	_parse_rx("\\d\\d"),
	_parse_rx("\\d?"),
	_parse_rx("\\s\\d?"),
	_parse_rx("\\d?|b*\\d+"),
	_parse_rx("a|\\(bc\\)"),
	"order of operations",
	_parse_rx("ab?"),
	_parse_rx("(ab)?"),
	_parse_rx("a|b?"),
	_parse_rx("(a|b)?"),
	_parse_rx("a|bc"),
	_parse_rx("ab|c"),
	_parse_rx("(a|b)c"),
	_parse_rx("a|(bc)"),
	_parse_rx("a?|b*c+"),
	_parse_rx("a?|b*c+d|d*e+"),
	"edge cases",
	_parse_rx("a"),
	_parse_rx("") ,
	_parse_rx(undef),
	"invalid syntax",
	// _parse_rx("((()))"),
	// _parse_rx( "(()))"),
	// _parse_rx("((())"),
	//_parse_rx("a?*+"),
]);



echo([
	"_match_regex",
	_match_regex("foobarbaz", "[foba]{2,5}") == 5,
	_match_regex("foobarbaz", "[foba]{6,9}") == undef,
	_match_regex("foobarbaz", "[fobar]{2,6}") == 6,
	_match_regex("foobarbaz", "[fobar]{2,9}") == 8,
	_match_regex("foobarbaz", "[a-z]*") == 9,
	_match_regex("foobarbaz", "[f-o]*") == 3,
	_match_regex("012345", "[^a-z]*") == 6,
	_match_regex("foobarbaz", "[^a-z]*"),// == undef,
	_match_regex("foobarbaz", "[^f-o]*"),
]);

echo([
	"contains:",
	contains("foo bar baz", "ba[rz]", regex=true) == true,
	contains("foo bar baz", "spam", regex=true) == false,
	contains("foo bar baz", "BA[RZ]", regex=true, ignore_case=true) == true,
	contains("foo bar baz", "SPAM", regex=true, ignore_case=true) == false,
]);
echo([
    "index_of:",
	index_of("foobar", "o") == [[1,2], [2,3]],
	index_of("foobar foobar", "oo") == [[1,3], [8,10]],
	index_of("foobar", "Bar") == [],
	index_of("foobar", "Bar", ignore_case=true) == [[3,6]],
	index_of("foo bar baz", "ba[rz]", regex=true) == [[4,7], [8,11]],
	index_of("foo bar baz", "BA[RZ]", regex=true, ignore_case=true) == [[4,7], [8,11]],
	index_of("", "x") == []
]);
echo([
    "grep:",
	grep("foo bar baz", "ba[rz]") == ["bar", "baz"],
	grep("foo bar baz", "BA[RZ]") == [],
	grep("foo 867-5309 baz", "\\d\\d\\d-?\\d\\d\\d\\d") == ["867-5309"], 
	grep("foo bar baz", "BA[RZ]", ignore_case=true) == ["bar", "baz"],
]);
echo([
    "replace:",
	replace("foobar", "oo", "ee") == "feebar",
	replace("foobar foobar", "oo", "ee") == "feebar feebar",
	replace("foobar", "OO", "ee", ignore_case=true) == "feebar",
	replace("foobar foobar", "OO", "ee", ignore_case=true) == "feebar feebar",
	replace("foo bar baz", "ba[rz]", "boo", regex=true) == "foo boo boo",
	replace("foo bar baz", "BA[RZ]", "spam", regex=true, ignore_case=true) == "foo spam spam",
]);
echo([
    "split:",
	split("", " "),
	split(test, " "),
	split(test, " "),
	split("foo", " "),
	split(regex_test, "fo+", regex=true),
	split("bazfoobar", "fo+", regex=true),
	split("", "fo+", regex=true) ,
	split("", "fo+", regex=true) ,
	split(regex_test, "FO+", regex=true, ignore_case=true) == ["baz", "barbaz"],
]);
