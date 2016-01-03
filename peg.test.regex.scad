include <peg.scad>

_regex_grammar = 
_index_peg_refs
(
	["grammar",
		["private_rule", "operation",
			["sequence",
				["choice",
					["ref", "choice"],
					["ref", "sequence"],
					["ref", "postfix"],
				],
				// ["negative_lookahead", ["wildcard"]],
			]
		],
		["private_rule", "postfix",
			["choice",
				["ref", "many_to_many"],
				["ref", "one_to_many"],
				["ref", "zero_to_many"],
				["ref", "zero_to_one"],
				["ref", "primitive"]
			],
		],

		//BINARY OPERATIONS
		["rule", "choice",
			["sequence",
				["choice", 
					["ref", "sequence"],
					["ref", "postfix"]
				],
				["one_to_many",
					["sequence",
						["private", ["literal", "|"]],
						["choice", 
							["ref", "sequence"],
							["ref", "postfix"]
						],
					]
				]
			]
		],
		["rule", "sequence",
			["sequence",
				["ref", "postfix"],
				["one_to_many",
					["ref", "postfix"],
				 ]
			]
		],

		["rule", "positive_lookahead",
			["sequence",
				["private", ["literal", "(?="]],
				["ref", "operation"],
				["private", ["literal", ")"]],
			]
		],
		["rule", "negative_lookahead",
			["sequence",
				["private", ["literal", "(?!"]],
				["ref", "operation"],
				["private", ["literal", ")"]],
			]
		],

		//UNARY POSTFIX OPERATIONS
		["rule", "one_to_many",
			["sequence",
				["ref", "primitive"],
				["private", ["literal", "+"]]
			]
		],
		["rule", "zero_to_many",
			["sequence",
				["ref", "primitive"],
				["private", ["literal", "*"]]
			]
		],
		["rule", "zero_to_one",
			["sequence",
				["ref", "primitive"],
				["private", ["literal", "?"]]
			]
		],
		["rule", "many_to_many",
			["sequence",
				["ref", "primitive"],
				["private", ["literal", "{"]],
				["character_set_shorthand", "d"],
				["zero_to_one",
					["sequence",
						["private", ["literal", ","]],
						["character_set_shorthand", "d"],
					],
				],
				["private", ["literal", "}"]],
			]
		],

		//PRIMITIVES
		["private_rule", "primitive",
			["choice",
				["ref", "wildcard"],
				["ref", "character_set_shorthand"],
				["ref", "negative_character_set"],
				["ref", "positive_character_set"],
				["ref", "negative_lookahead"],
				["ref", "positive_lookahead"],
				["sequence",
					["private", ["literal", "("]],
					["ref", "operation"],
					["private", ["literal", ")"]],
				],
				["ref", "literal"],
			],
		],

		["rule", "wildcard",
			["private", ["literal", "."]],
		],
		["rule", "literal", 
			["negative_character_set", 
				"{","}","[","]","(",")", 
				"|","*","+","?",".","\\","."
			],
		],
		["rule", "positive_character_set",
			["sequence",
				["private", ["literal", "["]],
				["one_to_many",
					["choice",
						["ref", "character_range"],
						["ref", "character_set_shorthand"],
						["ref", "character_literal"]
					]
				],
				["private", ["literal", "]"]],
			]
		],
		["rule", "negative_character_set",
			["sequence",
				["private", ["literal", "[^"]],
				["one_to_many",
					["choice",
						["ref", "character_range"],
						["ref", "character_set_shorthand"],
						["ref", "character_literal"]
					]
				],
				["private", ["literal", "]"]],
			]
		],
		["rule", "character_literal",
			["negative_character_set", "]"]
		],
		["rule", "character_range",
			["sequence",
				["character_set_shorthand", "w"],
				["private", ["literal", "-"]],
				["character_set_shorthand", "w"],
			],
		],
		["rule", "character_set_shorthand",
			["sequence", 
				["private", ["literal", "\\"]],
				["positive_character_set",
					"s","S","d","D","w","W", "\\", "]", "(", ")"
				]
			]
		],
	]
);
echo(_unit_test("regex primitives",
	[
		_match_parsed_peg( "", _regex_grammar, peg_op=_get_rule(_regex_grammar, "wildcard")	)[_PARSED], undef,
		_match_parsed_peg( ".", _regex_grammar, peg_op=_get_rule(_regex_grammar, "wildcard")	)[_PARSED], [["wildcard"]],
		_match_parsed_peg( "a", _regex_grammar, peg_op=_get_rule(_regex_grammar, "literal")	)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _regex_grammar, peg_op=_get_rule(_regex_grammar, "character_set_shorthand")	)[_PARSED], [["character_set_shorthand", "w"]],
   		_match_parsed_peg( "[a]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "positive_character_set") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( "[ab]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "positive_character_set")	)[_PARSED], [["positive_character_set", ["character_literal", "a"], ["character_literal", "b"]]],
		_match_parsed_peg( "[a-z]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "positive_character_set")	)[_PARSED], [["positive_character_set", ["character_range", "az"]]],
		_match_parsed_peg( "[\\w]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "positive_character_set")	)[_PARSED], [["positive_character_set", ["character_set_shorthand", "w"]]],
		_match_parsed_peg( "[^a]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( "[^ab]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_literal", "a"], ["character_literal", "b"]]],
		_match_parsed_peg( "[^a-z]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_range", "az"]]],
		_match_parsed_peg( "[^\\w]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "negative_character_set")	)[_PARSED], [["negative_character_set", ["character_set_shorthand", "w"]]],
		_match_parsed_peg( ".", _regex_grammar, peg_op=_get_rule(_regex_grammar, "primitive")	)[_PARSED], [["wildcard"]], 
		_match_parsed_peg( "a", _regex_grammar, peg_op=_get_rule(_regex_grammar, "primitive")	)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _regex_grammar, peg_op=_get_rule(_regex_grammar, "primitive")	)[_PARSED], [["character_set_shorthand", "w"]],
		_match_parsed_peg( "[a]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "primitive") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
	]
));

echo(_unit_test("regex postfix", 
	[
		_match_parsed_peg( ".", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix")	)[_PARSED], [["wildcard"]], 
		_match_parsed_peg( "a", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix")	)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix")	)[_PARSED], [["character_set_shorthand", "w"]],
		_match_parsed_peg( "[a]", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( ".*", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix") )[_PARSED], [["zero_to_many", ["wildcard"]]],
		_match_parsed_peg( ".+", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix") )[_PARSED], [["one_to_many", ["wildcard"]]],
		_match_parsed_peg( ".{3}", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix") )[_PARSED], [["many_to_many", ["wildcard"], "3"]],
		_match_parsed_peg( ".{3,5}", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix") )[_PARSED], [["many_to_many", ["wildcard"], "35"]],
		_match_parsed_peg( ".?", _regex_grammar, peg_op=_get_rule(_regex_grammar, "postfix") )[_PARSED], [["zero_to_one", ["wildcard"]]],
	]
));

echo(_unit_test(
	"regex operation",
	[
		_match_parsed_peg( "ab", _regex_grammar, peg_op=_get_rule(_regex_grammar, "sequence") )[_PARSED], [["sequence", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "a|b", _regex_grammar, peg_op=_get_rule(_regex_grammar, "choice") )[_PARSED], [["choice", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "a|bc", _regex_grammar, peg_op=_get_rule(_regex_grammar, "choice") )[_PARSED], [["choice", ["literal", "a"], ["sequence", ["literal", "b"], ["literal", "c"]]]],
		_match_parsed_peg( "ab|c", _regex_grammar, peg_op=_get_rule(_regex_grammar, "choice") )[_PARSED], [["choice", ["sequence", ["literal", "a"], ["literal", "b"]], ["literal", "c"]]],
		_match_parsed_peg( "ab|cd", _regex_grammar, peg_op=_get_rule(_regex_grammar, "choice") )[_PARSED], [["choice", ["sequence", ["literal", "a"], ["literal", "b"]], ["sequence", ["literal", "c"], ["literal", "d"]]]],

		_match_parsed_peg( ".", _regex_grammar)[_PARSED], [["wildcard"]],
		_match_parsed_peg( "a", _regex_grammar)[_PARSED], [["literal", "a"]],
		_match_parsed_peg( "\\w", _regex_grammar)[_PARSED], [["character_set_shorthand", "w"]],
		_match_parsed_peg( "[a]", _regex_grammar)[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
		_match_parsed_peg( "a+", _regex_grammar)[_PARSED], [["one_to_many", ["literal", "a"]]],
		_match_parsed_peg( "ab", _regex_grammar)[_PARSED], [["sequence", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "a|b", _regex_grammar)[_PARSED], [["choice", ["literal", "a"], ["literal", "b"]]],
		_match_parsed_peg( "(a)", _regex_grammar)[_PARSED], [["literal", "a"]],

		_match_parsed_peg( "(?=a)", _regex_grammar, peg_op=_get_rule(_regex_grammar, "positive_lookahead") )[_PARSED], [["positive_lookahead", ["literal", "a"]]],
		_match_parsed_peg( "(?!a)", _regex_grammar, peg_op=_get_rule(_regex_grammar, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["literal", "a"]]],
		_match_parsed_peg( "(?=a)", _regex_grammar)[_PARSED], [["positive_lookahead", ["literal", "a"]]],
		_match_parsed_peg( "(?!a)", _regex_grammar)[_PARSED], [["negative_lookahead", ["literal", "a"]]],

		_match_parsed_peg( "\\d+-\\d+", _regex_grammar)[_PARSED],
			  [["sequence", 
					["one_to_many", ["character_set_shorthand", "d"]], 
					["literal", "-"], 
					["one_to_many", ["character_set_shorthand", "d"]]
				]],
		_match_parsed_peg( "(\\([0-9]{3}\\)|1?-?[0-9]{3}-?)?[0-9]{3}-?[0-9]{4}", _regex_grammar	)[_PARSED],
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
