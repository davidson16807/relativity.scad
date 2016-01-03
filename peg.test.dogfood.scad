include <peg.scad>

_peg_peg = 
_index_peg_refs
(
	["grammar",
		//grammar 		= (rule/private_rule)+
		//rule 			= \\w+ #'=' operation
		//private_rule 	= \\w+ #'=' operation
		//operation
		//	#= choice
		//	/ sequence
		//	/ prefix
		//prefix		
		//	#= positive_lookahead
		//	/ negative_lookahead
		//	/ postfix
		//postfix
		//	#= one_to_many
		//	/ zero_to_many
		//	/ zero_to_one
		//	/ primitive
		//primitive
		//	#= wildcard
		//	/ literal
		//	/ charset
		//	/ #"(" operation #")"
		//	/ ref

		["rule", "grammar",
			["sequence",
				["one_to_many", 
					["choice",
						["ref", "rule"],
						["ref", "private_rule"]
					]
				],
				["negative_lookahead", ["wildcard"]]
			]
		],
		["rule", "rule",
			["sequence",
				["private", ["ref", "SPACE"]],
				["one_to_many",
	                ["character_set_shorthand", "w"],
				],
				["private", ["ref", "SPACE"]],
				["private", ["literal", "="]],
				["ref", "operation"],
				["private", ["ref", "SPACE"]],
			]
		],
		["rule", "private_rule",
			["sequence",
				["private", ["ref", "SPACE"]],
				["one_to_many",
	                ["character_set_shorthand", "w"],
				],
				["private", ["ref", "SPACE"]],
				["private", ["literal", "#="]],
				["ref", "operation"],
				["private", ["ref", "SPACE"]],
			]
		],
		["private_rule", "operation",
			["choice",
				["ref", "choice"],
				["ref", "sequence"],
				["ref", "prefix"]
			]
		],
		["private_rule", "prefix",
			["sequence",
				["ref", "SPACE"],
				["choice",
					["ref", "positive_lookahead"],
					["ref", "negative_lookahead"],
					["ref", "private"],
					["ref", "postfix"]
				],
				["ref", "SPACE"],
			]
		],
		["private_rule", "postfix",
			["sequence",
				["ref", "SPACE"],
				["choice",
					["ref", "one_to_many"],
					["ref", "zero_to_many"],
					["ref", "zero_to_one"],
					["ref", "many_to_many"],
					["ref", "primitive"]
				],
				["ref", "SPACE"],
			]
		],

		//choice 				(sequence/prefix) (#"/" (sequence/prefix))+
		//sequence				prefix (!rule prefix)+
		//positive_lookahead 	#"&" postfix
		//negative_lookahead 	#"!" postfix
		//one_to_many 			primitive #"+"
		//zero_to_many			primitive #"*"
		//zero_to_one			primitive #"?"

		//BINARY OPERATIONS
		["rule", "choice",
			["sequence",
				["choice", 
					["ref", "sequence"],
					["ref", "prefix"]
				],
				["one_to_many",
					["sequence",
						["private", ["literal", "/"]],
						["choice", 
							["ref", "sequence"],
							["ref", "prefix"]
						],
					]
				]
			]
		],
		["rule", "sequence",
			["sequence",
				["ref", "prefix"],
				["one_to_many",
					["sequence", 
						["negative_lookahead", ["ref", "rule"]],
						["ref", "prefix"]
					]
				 ]
			]
		],

		//UNARY PREFIX OPERATIONS
		["rule", "private",
			["sequence",
				["ref", "SPACE"],
				["private", ["literal", "#"]],
				["ref", "postfix"],
			]
		],
		["rule", "positive_lookahead",
			["sequence",
				["ref", "SPACE"],
				["private", ["literal", "&"]],
				["ref", "postfix"],
			]
		],
		["rule", "negative_lookahead",
			["sequence",
				["ref", "SPACE"],
				["private", ["literal", "!"]],
				["ref", "postfix"],
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
				["one_to_many", ["character_set_shorthand", "d"]],
				["private", ["literal", ","]],
				["one_to_many", ["character_set_shorthand", "d"]],
				["private", ["literal", "}"]],
			]
		],

		//PRIMITIVES
		["private_rule", "primitive",
			["sequence",
				["ref", "SPACE"],
				["choice",
					["ref", "wildcard"],
					["ref", "character_set_shorthand"],
					["ref", "negative_character_set"],
					["ref", "positive_character_set"],
					["ref", "literal"],
					["sequence",
						["private", ["literal", "("]],
						["ref", "SPACE"],
						["ref", "operation"],
						["ref", "SPACE"],
						["private", ["literal", ")"]],
					],
					["ref", "ref"]
				],
				["ref", "SPACE"]
			]
		],
		//wildcard = #"."
		//ref	= [a-zA-Z0-9_-]+
		//literal	
		//	=
		//		 ( "'" ( "\\\\" / "\\'" / [^'])* "'" )
		//		/( '"' ( "\\\\" / '\\"' / [^"])* '"' )
		//	  
		//positive_character_set
		//	= #"[" 
		//		(
		//			  "\\\\"
		//			/ "\]" 
		//			/ character_range
		//			/ character_set_shorthand
		//			/ [^]] 
		//		) +
		//	#"]"
		//negative_character_set
		//	= #"[^" 
		//		(
		//			  "\\\\"
		//			/ "\]" 
		//			/ character_range
		//			/ character_set_shorthand
		//			/ [^]] 
		//		) +
		//	#"]"
		//character_range			
		//	= [a-z] #"-" [a-z]
		//	/ [A-Z] #"-" [A-Z]
		//	/ [0-9] #"-" [0-9]
		//character_set_shorthand
		//	= #"\\" [sSdDwW]

		["rule", "wildcard",
			["private", ["literal", "."]],
		],
		["rule", "ref",
			["sequence",
				["one_to_many",
	            	["character_set_shorthand", "w"],
				],
				["ref", "SPACE"],
				["negative_lookahead", 
					["choice", 
						["literal", "="],
						["literal", "#="], 
					],
				],
			]
		],
		["rule", "literal", 
			["choice",
				["sequence",
					["private", ["literal", "'"]],
					["zero_to_many",
						["choice", 
							["literal", "\\\\"],
							["literal", "\\'"],
							["negative_character_set", "'"]
						]
					],
					["private", ["literal", "'"]]
				],
				["sequence",
					["private", ["literal", "\""]],
					["zero_to_many",
						["choice", 
							["literal", "\\\\"],
							["literal", "\\\""],
							["negative_character_set", "\""]
						]
					],
					["private", ["literal", "\""]]
				]
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
			["choice", 
				["sequence",
					["character_range", "az"],
					["private", ["literal", "-"]],
					["character_range", "az"]
				],
				["sequence",
					["character_range", "AZ"],
					["private", ["literal", "-"]],
					["character_range", "AZ"]
				],
				["sequence",
					["character_range", "09"],
					["private", ["literal", "-"]],
					["character_range", "09"]
				]
			]
		],
		["rule", "character_set_shorthand",
			["sequence", 
				["private", ["literal", "\\"]],
				["positive_character_set",
					"s","S","d","D","w","W", "\\", "]"
				]
			]
		],

		// SPACE #= #\\s*

		["private_rule", "SPACE",
			["private",
				["zero_to_many", ["character_set_shorthand", "s"]]
			]
		],



	]
);





echo(_unit_test(
	"SPACE dogfood",
    [
    _match_parsed_peg( " ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "SPACE") )[_PARSED], [],
    _match_parsed_peg( "", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "SPACE") )[_PARSED], [],
    ]
));

echo(_unit_test(
	"ref dogfood",
    [
    _match_parsed_peg( "foo", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "ref") )[_PARSED], [["ref", "foo"]],
    _match_parsed_peg( "", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "ref") )[_PARSED], undef,
    ]
));
echo(_unit_test(
	"literal dogfood",
    [
    _match_parsed_peg( "'foo'", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "literal") )[_PARSED], [["literal", "foo"]],
    _match_parsed_peg( "''", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "literal") )[_PARSED], [["literal"]],
    _match_parsed_peg( "\"foo\"", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "literal") )[_PARSED], [["literal", "foo"]],
    _match_parsed_peg( "\"\"", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "literal") )[_PARSED], [["literal"]],
    _match_parsed_peg( "", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "literal") )[_PARSED], undef,
    ]
));
echo(_unit_test(
	"wildcard dogfood",
    [
    _match_parsed_peg( ".", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "wildcard") )[_PARSED], [["wildcard"]],
    _match_parsed_peg( "a", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "wildcard") )[_PARSED], undef,
    ]
));
echo(_unit_test(
	"character_set_shorthand dogfood",
    [
    _match_parsed_peg( "\\s", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_set_shorthand") )[_PARSED], [["character_set_shorthand", "s"]],
    _match_parsed_peg( "\\d", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_set_shorthand") )[_PARSED], [["character_set_shorthand", "d"]],
    _match_parsed_peg( "\\w", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_set_shorthand") )[_PARSED], [["character_set_shorthand", "w"]],
    _match_parsed_peg( "\\\\", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_set_shorthand") )[_PARSED], [["character_set_shorthand", "\\"]],
    _match_parsed_peg( "foo", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_set_shorthand") )[_PARSED], undef
    ]
));
echo(_unit_test(
	"character_range dogfood",
    [
    _match_parsed_peg( "a-z", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_range") )[_PARSED], [["character_range", "az"]],
    _match_parsed_peg( "A-Z", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_range") )[_PARSED], [["character_range", "AZ"]],
    _match_parsed_peg( "0-9", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "character_range") )[_PARSED], [["character_range", "09"]],
    ]
));
echo(_unit_test(
	"positive_character_set dogfood",
    [
    _match_parsed_peg( "[a]", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "positive_character_set") )[_PARSED], [["positive_character_set", ["character_literal", "a"]]],
    _match_parsed_peg( "[ab]", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "positive_character_set") )[_PARSED], [["positive_character_set", ["character_literal", "a"], ["character_literal", "b"]]],
    _match_parsed_peg( "[a-zA-Z0-9_\\\\\\]]", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "positive_character_set") )[_PARSED],
    [["positive_character_set", 
    	["character_range", "az"],
    	["character_range", "AZ"],
    	["character_range", "09"],
    	["character_literal", "_"],
    	["character_set_shorthand", "\\"],
    	["character_set_shorthand", "]"]
	]],

    ]
));
echo(_unit_test(
	"negative_character_set dogfood",
    [
    _match_parsed_peg( "[^a]", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_character_set") )[_PARSED], [["negative_character_set", ["character_literal", "a"]]],
    _match_parsed_peg( "[^ab]", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_character_set") )[_PARSED], [["negative_character_set", ["character_literal", "a"], ["character_literal", "b"]]],
    ]
));

echo(_unit_test(
	"primitive dogfood",
	[
	_match_parsed_peg("foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["ref", "foo"]],
	_match_parsed_peg(" foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["ref", "foo"]],
	_match_parsed_peg(" foo ", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["ref", "foo"]],
	_match_parsed_peg("'foo'", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["literal", "foo"]],
	_match_parsed_peg(".", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["wildcard"]],
	_match_parsed_peg("[abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["positive_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]],
	_match_parsed_peg("[^abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "primitive")
	)[_PARSED], [["negative_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]]
	]
));
echo(_unit_test(
	"zero_to_one dogfood",
    [
    _match_parsed_peg( "a?", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["ref", "a"]]],
    _match_parsed_peg( " a?", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["ref", "a"]]],
    _match_parsed_peg( "a ?", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["ref", "a"]]],
    _match_parsed_peg( "a? ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["ref", "a"]]],
    _match_parsed_peg( "foo?", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["ref", "foo"]]],
    _match_parsed_peg( "'foo'?", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["literal", "foo"]]],
    _match_parsed_peg( "[ab]?", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_one") )[_PARSED], [["zero_to_one", ["positive_character_set", ["character_literal", "a"], ["character_literal", "b"]]]],
    ]
));

echo(_unit_test(
	"zero_to_many dogfood",
    [
    _match_parsed_peg( "a*", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["ref", "a"]]],
    _match_parsed_peg( " a*", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["ref", "a"]]],
    _match_parsed_peg( "a *", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["ref", "a"]]],
    _match_parsed_peg( "a* ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["ref", "a"]]],
    _match_parsed_peg( "foo*", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["ref", "foo"]]],
    _match_parsed_peg( "'foo'*", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["literal", "foo"]]],
    _match_parsed_peg( "[ab]*", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "zero_to_many") )[_PARSED], [["zero_to_many", ["positive_character_set", ["character_literal", "a"], ["character_literal", "b"]]]],
    ]
));

echo(_unit_test(
	"one_to_many dogfood",
    [
    _match_parsed_peg( "a+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["ref", "a"]]],
    _match_parsed_peg( " a+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["ref", "a"]]],
    _match_parsed_peg( "a +", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["ref", "a"]]],
    _match_parsed_peg( "a+ ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["ref", "a"]]],
    _match_parsed_peg( "foo+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["ref", "foo"]]],
    _match_parsed_peg( "'foo'+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["literal", "foo"]]],
    _match_parsed_peg( "[ab]+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "one_to_many") )[_PARSED], [["one_to_many", ["positive_character_set", ["character_literal", "a"], ["character_literal", "b"]]]],
    ]
));

echo(_unit_test(
	"positive_lookahead dogfood",
    [
    _match_parsed_peg( "&a", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "positive_lookahead") )[_PARSED], [["positive_lookahead", ["ref", "a"]]],
    _match_parsed_peg( "&a+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "positive_lookahead") )[_PARSED], [["positive_lookahead", ["one_to_many", ["ref", "a"]]]],
    ]
));

echo(_unit_test(
	"negative_lookahead dogfood",
    [
    _match_parsed_peg( "!a", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["ref", "a"]]],
    _match_parsed_peg( "!a+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["one_to_many", ["ref", "a"]]]],
    _match_parsed_peg( " !a+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["one_to_many", ["ref", "a"]]]],
    _match_parsed_peg( "! a+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["one_to_many", ["ref", "a"]]]],
    _match_parsed_peg( "!a +", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["one_to_many", ["ref", "a"]]]],
    _match_parsed_peg( "!a+ ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "negative_lookahead") )[_PARSED], [["negative_lookahead", ["one_to_many", ["ref", "a"]]]],
    ]
));

echo(_unit_test(
	"postfix dogfood",
	[
	_match_parsed_peg("foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["ref", "foo"]],
	_match_parsed_peg("'foo'", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["literal", "foo"]],
	_match_parsed_peg(".", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["wildcard"]],
	_match_parsed_peg("[abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["positive_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]],
	_match_parsed_peg("[^abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["negative_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]],

	_match_parsed_peg("foo*", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["zero_to_many", ["ref", "foo"]]] ,
	_match_parsed_peg("'foo'*", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["zero_to_many", ["literal", "foo"]]] ,
	_match_parsed_peg(".*", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["zero_to_many", ["wildcard"]]] ,
	_match_parsed_peg("[a]*", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["zero_to_many", ["positive_character_set", ["character_literal", "a"]]]] ,

	_match_parsed_peg("foo+", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["one_to_many", ["ref", "foo"]]] ,
	_match_parsed_peg("foo?", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "postfix")
	)[_PARSED], [["zero_to_one", ["ref", "foo"]]] ,
	]
));

echo(_unit_test(
	"prefix dogfood",
	[
	_match_parsed_peg("foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["ref", "foo"]],
	_match_parsed_peg("'foo'", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["literal", "foo"]],
	_match_parsed_peg(".", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["wildcard"]],
	_match_parsed_peg("[abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["positive_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]],
	_match_parsed_peg("[^abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]],
	
	_match_parsed_peg("foo*", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["zero_to_many", ["ref", "foo"]]] ,
	_match_parsed_peg("foo+", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["one_to_many", ["ref", "foo"]]] ,
	
	
	_match_parsed_peg("!foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["ref", "foo"]]],
	_match_parsed_peg("!'foo'", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["literal", "foo"]]],
	_match_parsed_peg("!.", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["wildcard"]]],
	_match_parsed_peg("![abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["positive_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]]],
	_match_parsed_peg("![^abc]", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["negative_character_set", ["character_literal", "a"], ["character_literal", "b"], ["character_literal", "c"]]]],
	_match_parsed_peg("!foo*", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["zero_to_many", ["ref", "foo"]]]],
	_match_parsed_peg("!foo+", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["negative_lookahead", ["one_to_many", ["ref", "foo"]]]],

	_match_parsed_peg("&foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["positive_lookahead", ["ref", "foo"]]],

	_match_parsed_peg("#foo", _peg_peg, 0, 
		peg_op = _get_rule(_peg_peg, "prefix")
	)[_PARSED], [["private", ["ref", "foo"]]],
	
	]
));

echo(_unit_test(
	"choice dogfood",
    [
    _match_parsed_peg( "foo/bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["ref", "foo"], ["ref", "bar"]]],
    _match_parsed_peg( " foo/bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["ref", "foo"], ["ref", "bar"]]],
    _match_parsed_peg( "foo /bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["ref", "foo"], ["ref", "bar"]]],
    _match_parsed_peg( "foo/ bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["ref", "foo"], ["ref", "bar"]]],
    _match_parsed_peg( "foo/bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["ref", "foo"], ["ref", "bar"]]],
    _match_parsed_peg( " foo / bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["ref", "foo"], ["ref", "bar"]]],


    _match_parsed_peg( "foo / bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["ref", "foo"], ["ref", "bar"]]],
    _match_parsed_peg( "foo+ / bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["one_to_many", ["ref", "foo"]], ["ref", "bar"]]],
    _match_parsed_peg( "foo / bar+ ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["ref", "foo"], ["one_to_many", ["ref", "bar"]]]],,
    _match_parsed_peg( "!foo / bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["negative_lookahead", ["ref", "foo"]], ["ref", "bar"]]],
    _match_parsed_peg( "!foo+ / bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["negative_lookahead", ["one_to_many", ["ref", "foo"]]], ["ref", "bar"]]],
    _match_parsed_peg( "foo / !bar ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["ref", "foo"], ["negative_lookahead", ["ref", "bar"]]]],
    _match_parsed_peg( "foo / !bar+ ", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED], [["choice", ["ref", "foo"], ["negative_lookahead", ["one_to_many", ["ref", "bar"]]]]],
    ]
));

echo(_unit_test(
	"sequence dogfood",
    [
    _match_parsed_peg( "foo bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "sequence") )[_PARSED] 
    	, [["sequence", ["ref", "foo"], ["ref", "bar"]]],
	_match_parsed_peg( "foo+ bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "sequence") )[_PARSED] 
		, [["sequence", ["one_to_many", ["ref", "foo"]], ["ref", "bar"]]],
	_match_parsed_peg( "foo bar+", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "sequence") )[_PARSED] 
		, [["sequence", ["ref", "foo"], ["one_to_many", ["ref", "bar"]]]],
	_match_parsed_peg( "!foo bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "sequence") )[_PARSED] 
		, [["sequence", ["negative_lookahead", ["ref", "foo"]], ["ref", "bar"]]],
	_match_parsed_peg( "foo !bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "sequence") )[_PARSED] 
		, [["sequence", ["ref", "foo"], ["negative_lookahead", ["ref", "bar"]]]],

    _match_parsed_peg( "foo bar / baz qux", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "choice") )[_PARSED] 
    	, [["choice", ["sequence", ["ref", "foo"], ["ref", "bar"]], ["sequence", ["ref", "baz"], ["ref", "qux"]]]],

    ]
));

echo(_unit_test(
	"rule dogfood",
    [
    _match_parsed_peg( "foo=bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "rule") )[_PARSED] 
    	, [["rule", "foo", ["ref", "bar"]]],
    _match_parsed_peg( "foo =bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "rule") )[_PARSED] 
    	, [["rule", "foo", ["ref", "bar"]]],
    _match_parsed_peg( "foo= bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "rule") )[_PARSED] 
    	, [["rule", "foo", ["ref", "bar"]]],
    _match_parsed_peg( "foo=bar*", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "rule") )[_PARSED] 
    	, [["rule", "foo", ["zero_to_many", ["ref", "bar"]]]],

    _match_parsed_peg( "foo#=bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "private_rule") )[_PARSED] 
    	, [["private_rule", "foo", ["ref", "bar"]]],
    _match_parsed_peg( "foo #=bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "private_rule") )[_PARSED] 
    	, [["private_rule", "foo", ["ref", "bar"]]],
   	_match_parsed_peg( "foo#= bar", _peg_peg, 0, peg_op=_get_rule(_peg_peg, "private_rule") )[_PARSED] 
   		, [["private_rule", "foo", ["ref", "bar"]]],

    ]
));


//echo(_unit_test(
//	"grammar dogfood",
//    [
//
//        _match_parsed_peg( 
//        	"foo=bar baz=qux", 
//        	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//        	, [["grammar", 
//    	    		["rule", "foo", ["ref", "bar"]], 
//    	    		["rule", "baz", ["ref", "qux"]]
//        		]],
//	    _match_parsed_peg( 
//        	"grammar=rule+ rule=operation", 
//	    	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//	    	, [["grammar", 
//	    			["rule", "grammar", ["one_to_many", ["ref", "rule"]]], 
//	    			["rule", "rule", ["ref", "operation"]]
//    			]],
//	    _match_parsed_peg( 
//        	"grammar=rule+ rule=ref equals operation", 
//	    	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//			, [["grammar", 
//					["rule", "grammar", ["one_to_many", ["ref", "rule"]]], 
//					["rule", "rule", 
//						["sequence", 
//							["ref", "ref"], 
//							["ref", "equals"], 
//							["ref", "operation"]
//						]
//					]
//				]],
//	    _match_parsed_peg( 
//        	"grammar=(rule/private_rule)+ rule=ref equals operation", 
//	    	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//			, [["grammar", 
//					["rule", "grammar", 
//		    			["one_to_many", 
//		    				["choice", 
//		    					["ref", "rule"], 
//		    					["ref", "private_rule"]
//							]
//						]
//					], 
//					["rule", "rule", 
//						["sequence", 
//							["ref", "ref"], 
//							["ref", "equals"], 
//							["ref", "operation"]
//						]
//					]
//				]],
//
//	    _match_parsed_peg( 
//        	"grammar=(rule/private_rule)+ rule=ref '=' operation", 
//	    	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//	    	, [["grammar", 
//	    			["rule", "grammar", 
//	    				["one_to_many", 
//	    					["choice", 
//	    						["ref", "rule"], 
//	    						["ref", "private_rule"]
//    						]
//						]
//					], 
//					["rule", "rule", 
//						["sequence", 
//							["ref", "ref"], 
//							["literal", "="], 
//							["ref", "operation"]
//						]
//					]
//				]],
//
//	    _match_parsed_peg( 
//        	"grammar=(rule/private_rule)+ rule=ref+ '=' operation", 
//	    	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//	    	, [["grammar", 
//	    			["rule", "grammar", 
//	    				["one_to_many", 
//	    					["choice", ["ref", "rule"], ["ref", "private_rule"]]
//    					]
//					], 
//	    			["rule", "rule", 
//	    				["sequence", 
//	    					["one_to_many", ["ref", "ref"]], 
//	    					["literal", "="], 
//	    					["ref", "operation"]
//    					]
//					]
//				]],
//
//	    _match_parsed_peg( 
//        	"
//        	grammar=(rule/private_rule)+ 
//        	rule=\\w+ '=' operation
//        	", 
//	    	_peg_peg, 0, peg_op=_get_rule(_peg_peg, "grammar") )[_PARSED]
//	    	, [["grammar", 
//	    			["rule", "grammar", 
//	    				["one_to_many", ["choice", ["ref", "rule"], ["ref", "private_rule"]]]
//	    			], 
//	    			["rule", "rule", 
//	    				["sequence", 
//	    					["one_to_many", ["character_set_shorthand", "w"]], 
//	    					["literal", "="], 
//	    					["ref", "operation"]
//    					]
//    				]
//				]]
//	    ,
//    ]
//);
