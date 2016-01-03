include <peg.scad>

_selector_grammar = 
_index_peg_refs
(

	//  selector 
	//      #= or
	//      /  operation
	//	operation 	
	//		#= child
	//		/  descendant
	//		/  not
	//		/  and
	//		/  primitive
	//	or 			= operation SPACE? "," SPACE?  selector
	//	descendant 	= primitive SPACE operation
	//	child		= primitive SPACE? ">" SPACE? operation
	//	and 		= primitive operation
	//	not 		= ":"? "not" primitive
	//	primitive 
	//		= wildcard
	//		/ class
	//		/ "(" selector ")"
	//	wildcard	= "*"
	//	class 		= "."? \\w+
	//	SPACE 		#= #\\s+

	["grammar",
		["private_rule", "selector",
			["choice",
				["ref", "or"],
				["ref", "operation"],
			]
		],
		["private_rule", "operation",
			["choice",
				["ref", "child"],
				["ref", "descendant"],
				["ref", "not"],
				["ref", "and"],
				["ref", "primitive"],
			]
		],
		["rule", "not",
			["sequence",
				["private", ["zero_to_one", ["literal", ":"]]],
				["private", ["literal", "not"]],
				["ref", "primitive"],
			]
		],
		["rule", "child",
			["sequence",
				["ref", "primitive"],
				["private", ["literal", ">"]],
				["ref", "operation"],
			]
		],
		["rule", "descendant",
			["sequence",
				["ref", "primitive"],
				["ref", "SPACE"],
				["ref", "operation"],
			]
		],
		["rule", "or",
			["sequence",
				["ref", "operation"],
				["private", ["literal", ","]],
				["ref", "selector"],
			]
		],
		["rule", "and",
			["sequence",
				["ref", "primitive"],
				["ref", "operation"],
			]
		],
		["private_rule", "primitive",
			["choice",
				["ref", "wildcard"],
				["ref", "class"],
				["sequence",
					["private", ["literal","("]],
					["ref", "operation"],
					["private", ["literal",")"]],
				]
			]
		],
		["rule", "wildcard",
			["private", ["literal", "*"]]
		],
		["rule", "class",
			["sequence",
				["zero_to_one", ["private", ["literal", "."]]],
				["one_to_many", ["character_set_shorthand", "w"]]
			]
		],
		["private_rule", "SPACE",
			["private", ["one_to_many", ["character_set_shorthand", "s"]]]
		],
	]
);

echo(_unit_test("operation SPACE", 
	[
		_match_parsed_peg( " ", _selector_grammar, peg_op=_get_rule(_selector_grammar, "SPACE")	)[_PARSED], [],
		_match_parsed_peg( "", _selector_grammar, peg_op=_get_rule(_selector_grammar, "SPACE")	)[_PARSED], undef,
	]
));

echo(_unit_test("operation primitives", 
	[
		_match_parsed_peg( "*", _selector_grammar, peg_op=_get_rule(_selector_grammar, "wildcard")	)[_PARSED], [["wildcard"]],
		_match_parsed_peg( ".foo", _selector_grammar, peg_op=_get_rule(_selector_grammar, "class")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( "foo", _selector_grammar, peg_op=_get_rule(_selector_grammar, "class")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( "*", _selector_grammar, peg_op=_get_rule(_selector_grammar, "primitive")	)[_PARSED], [["wildcard"]],
		_match_parsed_peg( "foo", _selector_grammar, peg_op=_get_rule(_selector_grammar, "primitive")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( ".foo", _selector_grammar, peg_op=_get_rule(_selector_grammar, "primitive")	)[_PARSED], [["class", "foo"]],
	]
));
echo("operation operation", 
	[
		_match_parsed_peg( "foo.bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "and") )[_PARSED] == [["and", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( ".foo.bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "and") )[_PARSED] == [["and", ["class", "foo"], ["class", "bar"]]],
		
		_match_parsed_peg( "foo,bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( "foo,.bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( ".foo,bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( ".foo,.bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],

		_match_parsed_peg( "foo>bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "child") )[_PARSED] == [["child", ["class", "foo"], ["class", "bar"]]],
		
		_match_parsed_peg( "foo bar", _selector_grammar, peg_op=_get_rule(_selector_grammar, "descendant") )[_PARSED] == [["descendant", ["class", "foo"], ["class", "bar"]]],
		
		_match_parsed_peg( "not(foo)", _selector_grammar, peg_op=_get_rule(_selector_grammar, "not") )[_PARSED] == [["not", ["class", "foo"]]],
		
		// _match_parsed_peg( "(foo)", _selector_grammar, peg_op=_get_rule(_selector_grammar, "and") )[_PARSED], [["class", "foo"]]
		
	]
);


echo("operation operation pairing", 
	[
		_match_parsed_peg( "foo.bar.baz", _selector_grammar, peg_op=_get_rule(_selector_grammar, "operation") )[_PARSED]
			== [["and", 
					["class", "foo"], 
					["and", 
						["class", "bar"], 
						["class", "baz"]
					]
				]],
		_match_parsed_peg( "foo,bar.baz", _selector_grammar, peg_op=_get_rule(_selector_grammar, "operation") )[_PARSED],

		_match_parsed_peg( "foo.bar,baz", _selector_grammar, peg_op=_get_rule(_selector_grammar, "operation") )[_PARSED],

	]
);