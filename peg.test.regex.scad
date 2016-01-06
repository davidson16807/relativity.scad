include <strings.scad>

echo(_unit_test("regex primitives",
	[
		_match_parsed_peg( "", _rx_peg, peg_op=_get_rule(_rx_peg, "wildcard")	)[_PARSED], undef,
		_match_parsed_peg( ".", _rx_peg, peg_op=_get_rule(_rx_peg, "wildcard")	)[_PARSED], [["wildcard"]],
		_match_parsed_peg( "a", _rx_peg, peg_op=_get_rule(_rx_peg, "literal")	)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _rx_peg, peg_op=_get_rule(_rx_peg, "character_set_shorthand")	)[_PARSED], [["character_set_shorthand", "w"]],
   		_match_parsed_peg( "[a]", _rx_peg, peg_op=_get_rule(_rx_peg, "positive_character_set") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( "[ab]", _rx_peg, peg_op=_get_rule(_rx_peg, "positive_character_set")	)[_PARSED], [["positive_character_set", ["character_literal", "a"], ["character_literal", "b"]]],
		_match_parsed_peg( "[a-z]", _rx_peg, peg_op=_get_rule(_rx_peg, "positive_character_set")	)[_PARSED], [["positive_character_set", ["character_range", "az"]]],
		_match_parsed_peg( "[\\w]", _rx_peg, peg_op=_get_rule(_rx_peg, "positive_character_set")	)[_PARSED], [["positive_character_set", ["character_set_shorthand", "w"]]],
		_match_parsed_peg( "[^a]", _rx_peg, peg_op=_get_rule(_rx_peg, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( "[^ab]", _rx_peg, peg_op=_get_rule(_rx_peg, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_literal", "a"], ["character_literal", "b"]]],
		_match_parsed_peg( "[^a-z]", _rx_peg, peg_op=_get_rule(_rx_peg, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_range", "az"]]],
		_match_parsed_peg( "[^\\w]", _rx_peg, peg_op=_get_rule(_rx_peg, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_set_shorthand", "w"]]],
		_match_parsed_peg( ".", _rx_peg, peg_op=_get_rule(_rx_peg, "primitive")	)[_PARSED], [["wildcard"]], 
		_match_parsed_peg( "a", _rx_peg, peg_op=_get_rule(_rx_peg, "primitive")	)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _rx_peg, peg_op=_get_rule(_rx_peg, "primitive")	)[_PARSED], [["character_set_shorthand", "w"]],
		_match_parsed_peg( "[a]", _rx_peg, peg_op=_get_rule(_rx_peg, "primitive") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
	]
));

echo(_unit_test("regex postfix", 
	[
		_match_parsed_peg( ".", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix")	)[_PARSED], [["wildcard"]], 
		_match_parsed_peg( "a", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix")	)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix")	)[_PARSED], [["character_set_shorthand", "w"]],
		_match_parsed_peg( "[a]", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( ".*", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix") )[_PARSED], [["zero_to_many", ["wildcard"]]],
		_match_parsed_peg( ".+", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix") )[_PARSED], [["one_to_many", ["wildcard"]]],
		_match_parsed_peg( ".{3}", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix") )[_PARSED], [["many_to_many", ["wildcard"], "3"]],
		_match_parsed_peg( ".{3,5}", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix") )[_PARSED], [["many_to_many", ["wildcard"], "35"]],
		_match_parsed_peg( ".?", _rx_peg, peg_op=_get_rule(_rx_peg, "postfix") )[_PARSED], [["zero_to_one", ["wildcard"]]],
	]
));

echo(_unit_test(
	"regex operation",
	[
		_match_parsed_peg( "ab", _rx_peg, peg_op=_get_rule(_rx_peg, "sequence") )[_PARSED], [["sequence", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "a|b", _rx_peg, peg_op=_get_rule(_rx_peg, "choice") )[_PARSED], [["choice", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "a|bc", _rx_peg, peg_op=_get_rule(_rx_peg, "choice") )[_PARSED], [["choice", ["literal", "a"], ["sequence", ["literal", "b"], ["literal", "c"]]]],
		_match_parsed_peg( "ab|c", _rx_peg, peg_op=_get_rule(_rx_peg, "choice") )[_PARSED], [["choice", ["sequence", ["literal", "a"], ["literal", "b"]], ["literal", "c"]]],
		_match_parsed_peg( "ab|cd", _rx_peg, peg_op=_get_rule(_rx_peg, "choice") )[_PARSED], [["choice", ["sequence", ["literal", "a"], ["literal", "b"]], ["sequence", ["literal", "c"], ["literal", "d"]]]],

		_match_parsed_peg( ".", _rx_peg)[_PARSED], [["wildcard"]],
		_match_parsed_peg( "a", _rx_peg)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _rx_peg)[_PARSED], [["character_set_shorthand", "w"]],
		_match_parsed_peg( "[a]", _rx_peg)[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( "a+", _rx_peg)[_PARSED], [["one_to_many", ["literal", "a"]]],
		_match_parsed_peg( "ab", _rx_peg)[_PARSED], [["sequence", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "a|b", _rx_peg)[_PARSED], [["choice", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "(a)", _rx_peg)[_PARSED], [["literal", "a"]],

		_match_parsed_peg( "(?=a)", _rx_peg, peg_op=_get_rule(_rx_peg, "positive_lookahead") )[_PARSED], [["positive_lookahead", ["literal", "a"]]],
		_match_parsed_peg( "(?!a)", _rx_peg, peg_op=_get_rule(_rx_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["literal", "a"]]],
		_match_parsed_peg( "(?=a)", _rx_peg)[_PARSED], [["positive_lookahead", ["literal", "a"]]],
		_match_parsed_peg( "(?!a)", _rx_peg)[_PARSED], [["negative_lookahead", ["literal", "a"]]],

	]
));

function _parse_rx(rx) = 
	_match_parsed_peg(rx, _rx_peg)[_PARSED];

echo(_unit_test("regex phonenumber",
	[
		_parse_rx( "\\d+-\\d+"),
			  [["sequence", 
					["one_to_many", ["character_set_shorthand", "d"]], 
					["literal", "-"], 
					["one_to_many", ["character_set_shorthand", "d"]]
				]],
		_parse_rx( "(\\([0-9]{3}\\)|1?-?[0-9]{3}-?)?[0-9]{3}-?[0-9]{4}"),
			  [["sequence", 
					["zero_to_one", 
						["choice", 
							["sequence", 
								["character_set_shorthand", "("], 
								["many_to_many", ["positive_character_set", ["character_range", "09"]], "3"], 
								["character_set_shorthand", ")"]
							], 
							["sequence", 
								["zero_to_one", ["literal", "1"]], 
								["zero_to_one", ["literal", "-"]], 
								["many_to_many", ["positive_character_set", ["character_range", "09"]], "3"], 
								["zero_to_one", ["literal", "-"]]
							]
						],
					], 
					["many_to_many", ["positive_character_set", ["character_range", "09"]], "3"], 
					["zero_to_one", ["literal", "-"]], 
					["many_to_many", ["positive_character_set", ["character_range", "09"]], "4"]
				]],
	]
));

