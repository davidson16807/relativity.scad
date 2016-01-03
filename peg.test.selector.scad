include <peg.scad>

_css_peg = 
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
				["ref", "descendant"],
				["ref", "child"],
				["ref", "and"],
				["ref", "primitive"],
			]
		],
		["private_rule", "primitive",
			["choice",
				["ref", "wildcard"],
				["ref", "not"],
				["ref", "class"],
				["sequence",
					["private", ["literal","("]],
					["ref", "operation"],
					["private", ["literal",")"]],
				]
			]
		],
		["rule", "or",
			["sequence",
				["ref", "operation"],
				["private", ["literal", ","]],
				["ref", "selector"],
			]
		],
		["rule", "descendant",
			["sequence",
				["ref", "primitive"],
				["ref", "SPACE"],
				["ref", "operation"],
			]
		],
		["rule", "child",
			["sequence",
				["ref", "primitive"],
				["private", ["literal", ">"]],
				["ref", "operation"],
			]
		],
		["rule", "not",
			["sequence",
				["private", ["zero_to_one", ["literal", ":"]]],
				["private", ["literal", "not"]],
				["ref", "primitive"],
			]
		],
		["rule", "and",
			["sequence",
				["ref", "primitive"],
				["ref", "operation"],
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

echo(_unit_test("selector SPACE", 
	[
		_match_parsed_peg( " ", _css_peg, peg_op=_get_rule(_css_peg, "SPACE")	)[_PARSED], [],
		_match_parsed_peg( "", _css_peg, peg_op=_get_rule(_css_peg, "SPACE")	)[_PARSED], undef,
	]
));

echo(_unit_test("selector primitives", 
	[
		_match_parsed_peg( "*", _css_peg, peg_op=_get_rule(_css_peg, "wildcard")	)[_PARSED], [["wildcard"]],
		_match_parsed_peg( ".foo", _css_peg, peg_op=_get_rule(_css_peg, "class")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( "foo", _css_peg, peg_op=_get_rule(_css_peg, "class")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( "not(foo)", _css_peg, peg_op=_get_rule(_css_peg, "not") )[_PARSED], [["not", ["class", "foo"]]],
		_match_parsed_peg( ":not(foo)", _css_peg, peg_op=_get_rule(_css_peg, "not") )[_PARSED], [["not", ["class", "foo"]]],
		_match_parsed_peg( "*", _css_peg, peg_op=_get_rule(_css_peg, "primitive")	)[_PARSED], [["wildcard"]],
		_match_parsed_peg( "foo", _css_peg, peg_op=_get_rule(_css_peg, "primitive")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( ".foo", _css_peg, peg_op=_get_rule(_css_peg, "primitive")	)[_PARSED], [["class", "foo"]],
		_match_parsed_peg( "not(foo)", _css_peg, peg_op=_get_rule(_css_peg, "primitive") )[_PARSED], [["not", ["class", "foo"]]],
		_match_parsed_peg( ":not(foo)", _css_peg, peg_op=_get_rule(_css_peg, "primitive") )[_PARSED], [["not", ["class", "foo"]]],
	]
));
echo("selector operation", 
	[
		_match_parsed_peg( "foo.bar", _css_peg, peg_op=_get_rule(_css_peg, "and") )[_PARSED] == [["and", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( ".foo.bar", _css_peg, peg_op=_get_rule(_css_peg, "and") )[_PARSED] == [["and", ["class", "foo"], ["class", "bar"]]],
		
		_match_parsed_peg( "foo,bar", _css_peg, peg_op=_get_rule(_css_peg, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( "foo,.bar", _css_peg, peg_op=_get_rule(_css_peg, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( ".foo,bar", _css_peg, peg_op=_get_rule(_css_peg, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],
		_match_parsed_peg( ".foo,.bar", _css_peg, peg_op=_get_rule(_css_peg, "or") )[_PARSED] == [["or", ["class", "foo"], ["class", "bar"]]],

		_match_parsed_peg( "foo>bar", _css_peg, peg_op=_get_rule(_css_peg, "child") )[_PARSED] == [["child", ["class", "foo"], ["class", "bar"]]],
		
		_match_parsed_peg( "foo bar", _css_peg, peg_op=_get_rule(_css_peg, "descendant") )[_PARSED] == [["descendant", ["class", "foo"], ["class", "bar"]]],
		
		// _match_parsed_peg( "(foo)", _css_peg, peg_op=_get_rule(_css_peg, "and") )[_PARSED], [["class", "foo"]]
		
	]
);


echo("selector operation pairing", 
	[
		_match_parsed_peg( "foo.bar.baz", _css_peg, peg_op=_get_rule(_css_peg, "operation") )[_PARSED]
			== [["and", 
					["class", "foo"], 
					["and", 
						["class", "bar"], 
						["class", "baz"]
					]
				]],
		_match_parsed_peg( "foo>bar.baz", _css_peg, peg_op=_get_rule(_css_peg, "operation") )[_PARSED]
			== [["child", 
					["class", "foo"], 
					["and", 
						["class", "bar"], 
						["class", "baz"]
					]
				]],
		_match_parsed_peg( "foo.bar>baz", _css_peg, peg_op=_get_rule(_css_peg, "operation") )[_PARSED]
			== [["and", 
					["class", "foo"], 
					["child", 
						["class", "bar"], 
						["class", "baz"]
					]
				]],
		_match_parsed_peg( "not(foo)>bar", _css_peg, peg_op=_get_rule(_css_peg, "operation") )[_PARSED]
			== [["child", 
					["not", ["class", "foo"]], 
					["class", "bar"]
				]],
		_match_parsed_peg( "bar:not(foo)", _css_peg, peg_op=_get_rule(_css_peg, "operation") )[_PARSED]
			== [["and", 
					["class", "bar"], 
					["not", ["class", "foo"]]
				]],
	]
);


function _parse_css(css) = 
	_match_parsed_peg(css, _css_peg)[_PARSED];

echo("selector or", 
	[
		_parse_css( "foo,.bar.baz" )
			== [["or", 
					["class", "foo"], 
					["and", ["class", "bar"], ["class", "baz"]]
				]],
		_parse_css( "foo.bar,.baz" )
			== [["or", 
					["and", ["class", "foo"], ["class", "bar"]], 
					["class", "baz"]
				]],
		_parse_css( ".foo.bar,.baz.qux" )
			== [["or", 
					["and", ["class", "foo"], ["class", "bar"] ], 
					["and", ["class", "baz"], ["class", "qux"] ]
				]],
		_parse_css( ".foo.bar.baz,.qux.norf" )
			== [["or", 
					["and", 
						["class", "foo"], 
						["and", ["class", "bar"], ["class", "baz"]]
					],
					["and", 
						["class", "qux"], 
						["class", "norf"]
					]
				]],
		_parse_css( ".foo.bar,.baz.qux.norf" )
			== [["or", 
					["and", ["class", "foo"], ["class", "bar"]], 
					["and", 
						["class", "baz"], 
						["and", ["class", "qux"], ["class", "norf"]]
					]
				]],
	]
);