include <peg.scad>







// PEG ENGINE TESTS
echo(_unit_test(
	"slice",
	[
	//TODO: more tests
	_slice(["literal", "a"], 1, -1), ["a"]
	]
));

echo(_unit_test(
	"empty_string",
	[
	_match_parsed_peg("", undef, 1, ["empty_string"]), undef,
	_match_parsed_peg(undef, undef, 0, ["empty_string"]), undef,
	_match_parsed_peg("", undef, 0, ["empty_string"])[_PARSED], [],
	_match_parsed_peg("a", undef, 0, ["empty_string"])[_PARSED], [],
	]
));

echo(_unit_test(
	"private",
	[
	_match_parsed_peg("a", undef, 0, ["private", ["literal", "a"]])[_PARSED], [] ,
	_match_parsed_peg("abc", undef, 0, 
		["private",
			["sequence", 
				["literal", "a"],
				["literal", "b"],
				["literal", "c"]
			]
		])[_PARSED], [] ,
        
        _match_parsed_peg("ab", undef, 0, peg_op=["sequence", ["private", ["literal", "a"]], ["literal", "b"]])[_PARSED], ["b"],
        _match_parsed_peg("ba", undef, 0, peg_op=["sequence", ["literal", "b"], ["private", ["literal", "a"]] ])[_PARSED], ["b"],
        _match_parsed_peg("abc", undef, 0, peg_op=["sequence", ["literal", "a"], ["private", ["literal", "b"]], ["literal", "c"] ])[_PARSED], ["ac"]
	]
));
echo(_unit_test(
	"wildcard",
	[
	_match_parsed_peg("a", undef, 0, ["wildcard"])[_PARSED], ["a"],
	_match_parsed_peg("ab", undef, 0, ["wildcard"])[_PARSED], ["a"],
	_match_parsed_peg("", undef, 0, ["wildcard"]), undef
	]
));
echo(_unit_test(
	"literal",
	[
	_match_parsed_peg("a", undef, 0, ["literal", "a"])[_PARSED], ["a"],
	_match_parsed_peg("ab", undef, 0, ["literal", "ab"])[_PARSED], ["ab"],
	_match_parsed_peg("c", undef, 0, ["literal", "a"]), undef
	]
));
echo(_unit_test(
	"character_set_shorthand",
	[
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "s"]), undef,
	_match_parsed_peg("A", undef, 0, ["character_set_shorthand", "s"]), undef,
	_match_parsed_peg("0", undef, 0, ["character_set_shorthand", "s"]), undef,
	_match_parsed_peg(" ", undef, 0, ["character_set_shorthand", "s"])[_PARSED], [" "],
	_match_parsed_peg("\t", undef, 0, ["character_set_shorthand", "s"])[_PARSED], ["\t"],
	_match_parsed_peg("\n", undef, 0, ["character_set_shorthand", "s"])[_PARSED], ["\n"],
	_match_parsed_peg("\r", undef, 0, ["character_set_shorthand", "s"])[_PARSED], ["\r"],
	
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "S"])[_PARSED], ["a"],
	_match_parsed_peg("A", undef, 0, ["character_set_shorthand", "S"])[_PARSED], ["A"],
	_match_parsed_peg("0", undef, 0, ["character_set_shorthand", "S"])[_PARSED], ["0"],
	_match_parsed_peg(" ", undef, 0, ["character_set_shorthand", "S"])[_PARSED], undef,	
	_match_parsed_peg("\t", undef, 0, ["character_set_shorthand", "S"])[_PARSED], undef,
	_match_parsed_peg("\n", undef, 0, ["character_set_shorthand", "S"])[_PARSED], undef,
	_match_parsed_peg("\r", undef, 0, ["character_set_shorthand", "S"])[_PARSED], undef,
	
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "w"])[_PARSED], ["a"],
	_match_parsed_peg("A", undef, 0, ["character_set_shorthand", "w"])[_PARSED], ["A"],
	_match_parsed_peg("0", undef, 0, ["character_set_shorthand", "w"])[_PARSED], ["0"],
	_match_parsed_peg("_", undef, 0, ["character_set_shorthand", "w"])[_PARSED], ["_"],
	_match_parsed_peg(" ", undef, 0, ["character_set_shorthand", "w"])[_PARSED], undef,
	
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "W"])[_PARSED], undef,
	_match_parsed_peg("A", undef, 0, ["character_set_shorthand", "W"])[_PARSED], undef,
	_match_parsed_peg("0", undef, 0, ["character_set_shorthand", "W"])[_PARSED], undef,
	_match_parsed_peg("_", undef, 0, ["character_set_shorthand", "W"])[_PARSED], undef,
	_match_parsed_peg(" ", undef, 0, ["character_set_shorthand", "W"])[_PARSED], [" "],
	
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "d"])[_PARSED], undef,
	_match_parsed_peg("A", undef, 0, ["character_set_shorthand", "d"])[_PARSED], undef,
	_match_parsed_peg("0", undef, 0, ["character_set_shorthand", "d"])[_PARSED], ["0"],
	_match_parsed_peg(" ", undef, 0, ["character_set_shorthand", "d"])[_PARSED], undef,
	
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "D"])[_PARSED], ["a"],
	_match_parsed_peg("A", undef, 0, ["character_set_shorthand", "D"])[_PARSED], ["A"],
	_match_parsed_peg("0", undef, 0, ["character_set_shorthand", "D"])[_PARSED], undef,
	_match_parsed_peg(" ", undef, 0, ["character_set_shorthand", "D"])[_PARSED], [" "],	
	
	_match_parsed_peg("\\", undef, 0, ["character_set_shorthand", "\\"])[_PARSED], ["\\"],
	_match_parsed_peg("a", undef, 0, ["character_set_shorthand", "\\"])[_PARSED], undef,
	]
));
echo(_unit_test("character_range", 
	[
	_match_parsed_peg("a", undef, 0, ["character_range", "az"])[_PARSED], ["a"],
	_match_parsed_peg("A", undef, 0, ["character_range", "az"]), undef,
	_match_parsed_peg("z", undef, 0, ["character_range", "az"])[_PARSED], ["z"],
	_match_parsed_peg("0", undef, 0, ["character_range", "az"]), undef,
	_match_parsed_peg(" ", undef, 0, ["character_range", "az"]), undef,

	_match_parsed_peg("a", undef, 0, ["character_range", "bz"]), undef,
	_match_parsed_peg("z", undef, 0, ["character_range", "ay"]), undef,
	
	_match_parsed_peg("a", undef, 0, ["character_range", "AZ"]), undef,
	_match_parsed_peg("A", undef, 0, ["character_range", "AZ"])[_PARSED], ["A"],
	_match_parsed_peg("z", undef, 0, ["character_range", "AZ"]), undef,
	_match_parsed_peg("Z", undef, 0, ["character_range", "AZ"])[_PARSED], ["Z"],
	_match_parsed_peg("0", undef, 0, ["character_range", "AZ"]), undef,
	_match_parsed_peg(" ", undef, 0, ["character_range", "AZ"]), undef,
	
	_match_parsed_peg("A", undef, 0, ["character_range", "BZ"]), undef,
	_match_parsed_peg("Z", undef, 0, ["character_range", "AY"]), undef,
	
	_match_parsed_peg("a", undef, 0, ["character_range", "09"]), undef,
	_match_parsed_peg("A", undef, 0, ["character_range", "09"]), undef,
	_match_parsed_peg("0", undef, 0, ["character_range", "09"])[_PARSED], ["0"],
	_match_parsed_peg("9", undef, 0, ["character_range", "09"])[_PARSED], ["9"],
	_match_parsed_peg(" ", undef, 0, ["character_range", "09"]), undef,

	_match_parsed_peg("0", undef, 0, ["character_range", "19"]), undef,
	_match_parsed_peg("9", undef, 0, ["character_range", "08"]), undef,
	]
));

echo(_unit_test("positive_character_set",
	[
	_match_parsed_peg("a", undef, 0, ["positive_character_set", "a"])[_PARSED], ["a"],
	_match_parsed_peg("b", undef, 0, ["positive_character_set", "a"]), undef,
	_match_parsed_peg("a", undef, 0, ["positive_character_set", ["character_set_shorthand", "w"]])[_PARSED], ["a"],
	_match_parsed_peg(" ", undef, 0, ["positive_character_set", ["character_set_shorthand", "w"]]), undef,
	_match_parsed_peg("0", undef, 0, ["positive_character_set", ["character_set_shorthand", "w"], "0"])[_PARSED], ["0"],
	_match_parsed_peg("a", undef, 0, ["positive_character_set", ["character_range", "ac"]])[_PARSED], ["a"],
	_match_parsed_peg("z", undef, 0, ["positive_character_set", ["character_range", "ac"]]), undef,
	_match_parsed_peg("z", undef, 0, ["positive_character_set", ["character_range", "ac"], "z"])[_PARSED], ["z"],
	]
));

echo(_unit_test("negative_character_set",
	[
	_match_parsed_peg("a", undef, 0, ["negative_character_set", "a"]), undef,
	_match_parsed_peg("b", undef, 0, ["negative_character_set", "a"])[_PARSED], ["b"],
	_match_parsed_peg("a", undef, 0, ["negative_character_set", ["character_set_shorthand", "w"]]), undef,
	_match_parsed_peg(" ", undef, 0, ["negative_character_set", ["character_set_shorthand", "w"]])[_PARSED], [" "],
	_match_parsed_peg("0", undef, 0, ["negative_character_set", ["character_set_shorthand", "w"], "0"]), undef,
	_match_parsed_peg("a", undef, 0, ["negative_character_set", ["character_range", "ac"]]), undef,
	_match_parsed_peg("z", undef, 0, ["negative_character_set", ["character_range", "ac"]])[_PARSED], ["z"],
	_match_parsed_peg("z", undef, 0, ["negative_character_set", ["character_range", "ac"], "z"]), undef,
	]
));

echo(_unit_test(
	"rule",
	[
	_match_parsed_peg("a", undef, 0, ["rule", "A", ["literal", "a"]])[_PARSED], [["A", "a"]],
	_match_parsed_peg("b", undef, 0, ["rule", "A", ["literal", "a"]]), undef,
	_match_parsed_peg("a", undef, 0, ["private_rule", "A", ["literal", "a"]])[_PARSED], ["a"],
	_match_parsed_peg("b", undef, 0, ["private_rule", "A", ["literal", "a"]]), undef
	]
));
echo(_unit_test(
	"negative_lookahead",
	[
	_match_parsed_peg("b", undef, 0, ["negative_lookahead", ["literal", "a"]])[_PARSED], [],
	_match_parsed_peg("a", undef, 0, ["negative_lookahead", ["literal", "a"]]), undef,
	_match_parsed_peg("ab", undef, 0, ["sequence", ["negative_lookahead", ["literal", "b"]], ["literal", "a"]])[_PARSED], ["a"],
	_match_parsed_peg("ab", undef, 0, 
		["sequence", 
			["negative_lookahead", 
				["sequence", 
					["literal", "a"], 
					["literal", "b"]
				]
			], 
			["literal", "a"],
		]), undef,
	_match_parsed_peg("ab", undef, 0, 
		["sequence", 
			["negative_lookahead", 
				["sequence", 
					["literal", "b"], 
					["literal", "a"]
				]
			], 
			["literal", "a"],
		])[_PARSED], ["a"],
	]
));
echo(_unit_test(
	"positive_lookahead",
	[
	_match_parsed_peg("b", undef, 0, ["positive_lookahead", ["literal", "a"]]), undef,
	_match_parsed_peg("a", undef, 0, ["positive_lookahead", ["literal", "a"]])[_PARSED], []
	]
));

echo(_unit_test(
	"choice",
	[
	_match_parsed_peg("a", undef, 0, ["choice", ["literal", "a"], ["literal", "b"]])[_PARSED], ["a"],
	_match_parsed_peg("b", undef, 0, ["choice", ["literal", "a"], ["literal", "b"]])[_PARSED], ["b"],
	_match_parsed_peg("c", undef, 0, ["choice", ["literal", "a"], ["literal", "b"]]), undef,
	_match_parsed_peg("a", undef, 0, ["choice", ["literal", "a"], ["literal", "b"], ["literal", "c"]])[_PARSED], ["a"],
	_match_parsed_peg("b", undef, 0, ["choice", ["literal", "a"], ["literal", "b"], ["literal", "c"]])[_PARSED], ["b"],
	_match_parsed_peg("c", undef, 0, ["choice", ["literal", "a"], ["literal", "b"], ["literal", "c"]])[_PARSED], ["c"],
	_match_parsed_peg("d", undef, 0, ["choice", ["literal", "a"], ["literal", "b"], ["literal", "c"]]), undef,
	_match_parsed_peg("ab", undef, 0, ["choice", ["literal", "a"], ["literal", "ab"]])[_PARSED], ["a"],
	_match_parsed_peg("ab", undef, 0, ["choice", ["literal", "ab"], ["literal", "a"]])[_PARSED], ["ab"]
	]
));
echo(_unit_test(
	"sequence",
	[
	_match_parsed_peg("ab", undef, 0, ["sequence", ["literal", "a"]])[_PARSED], ["a"],
	_match_parsed_peg("ab", undef, 0, ["sequence", ["literal", "a"], ["literal", "b"]])[_PARSED], ["ab"],
	_match_parsed_peg("abc", undef, 0, ["sequence", ["literal", "a"], ["literal", "b"], ["literal", "c"]])[_PARSED], ["abc"],
	_match_parsed_peg("abc", undef, 0, ["sequence", ["literal", "ab"], ["literal", "c"]])[_PARSED], ["abc"],
	_match_parsed_peg("a", undef, 0, ["sequence", ["literal", "a"], ["literal", "b"]]), undef,
	_match_parsed_peg("b", undef, 0, ["sequence", ["literal", "a"], ["literal", "b"]]), undef,
	_match_parsed_peg("c", undef, 0, ["sequence", ["literal", "a"], ["literal", "b"]]), undef,
	_match_parsed_peg("^abcdcdab$", undef, 0, 
		["sequence", 
			["literal", "^"],
			["zero_to_many",
				["choice", 
					["sequence",
						["literal", "a"],
						["literal", "b"]
					],
					["sequence",
						["literal", "c"],
						["literal", "d"]
					]
				],
			],
			["literal", "$"]
		])[_PARSED], ["^abcdcdab$"]
	]
));



echo(_unit_test(
	"zero_to_many",
	[
	_match_parsed_peg("", undef, 0, ["zero_to_many", ["literal", "a"]])[_PARSED], [],
	_match_parsed_peg("b", undef, 0, ["zero_to_many", ["literal", "a"]])[_PARSED], [],
	_match_parsed_peg("a", undef, 0, ["zero_to_many", ["literal", "a"]])[_PARSED], ["a"],
	_match_parsed_peg("aaa", undef, 0, ["zero_to_many", ["literal", "a"]])[_PARSED], ["aaa"]
	]
));
echo(_unit_test(
	"one_to_many",
	[
	_match_parsed_peg("", undef, 0, ["one_to_many", ["literal", "a"]]), undef,
	_match_parsed_peg("b", undef, 0, ["one_to_many", ["literal", "a"]]), undef,
	_match_parsed_peg("a", undef, 0, ["one_to_many", ["literal", "a"]])[_PARSED], ["a"],
	_match_parsed_peg("aaa", undef, 0, ["one_to_many", ["literal", "a"]])[_PARSED], ["aaa"]
	]
));
echo(_unit_test(
	"zero_to_one",
	[
	_match_parsed_peg("a", undef, 0, ["zero_to_one", ["literal", "a"]])[_PARSED], ["a"],
	_match_parsed_peg("b", undef, 0, ["zero_to_one", ["literal", "a"]])[_PARSED], []
	]
));
echo(_unit_test(
	"many_to_many",
	[
	_match_parsed_peg("", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], undef,
	_match_parsed_peg("a", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], undef,
	_match_parsed_peg("aa", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], ["aa"],
	_match_parsed_peg("aaa", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], ["aaa"],
	_match_parsed_peg("aaaa", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], ["aaaa"],
	_match_parsed_peg("aaaaa", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], ["aaaaa"],
	_match_parsed_peg("aaaaaa", undef, 0, ["many_to_many", ["literal", "a"], "25"])[_PARSED], ["aaaaa"],
	_match_parsed_peg("", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], undef,
	_match_parsed_peg("a", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], undef,
	_match_parsed_peg("aa", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], ["aa"],
	_match_parsed_peg("aaa", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], ["aaa"],
	_match_parsed_peg("aaaa", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], ["aaaa"],
	_match_parsed_peg("aaaaa", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], ["aaaaa"],
	_match_parsed_peg("aaaaaa", undef, 0, ["many_to_many", ["literal", "a"], [2, 5]])[_PARSED], ["aaaaa"],
	_match_parsed_peg("", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], undef,
	_match_parsed_peg("a", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], undef,
	_match_parsed_peg("aa", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], ["aa"],
	_match_parsed_peg("aaa", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], ["aaa"],
	_match_parsed_peg("aaaa", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], ["aaaa"],
	_match_parsed_peg("aaaaa", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], ["aaaaa"],
	_match_parsed_peg("aaaaaa", undef, 0, ["many_to_many", ["literal", "a"], "2"])[_PARSED], ["aaaaaa"],
	]
));

echo(_unit_test(
	"ref",
	[
	_match_parsed_peg("a", [["rule", "A", ["literal", "a"]]], 0, ["ref", 0])[_PARSED], [["A", "a"]],
	_match_parsed_peg("ab", 
		[
			["rule", "A", 
				["sequence",
					["literal", "a"],
					["ref", 1]
				]
			],
			["rule", "B", ["literal", "b"]]
		],
		0, ["ref", 0])[_PARSED], [["A", "a", ["B", "b"]]],
	_match_parsed_peg("a", [["private_rule", "A", ["literal", "a"]]], 0, ["ref", 0])[_PARSED], ["a"],
	_match_parsed_peg("ab", 
		[
			["private_rule", "A", 
				["sequence",
					["literal", "a"],
					["ref", 1]
				]
			],
			["rule", "B", ["literal", "b"]]
		],
		0, ["ref", 0])[_PARSED], ["a", ["B", "b"]],
	_match_parsed_peg("ab", 
		[
			["rule", "A", 
				["sequence",
					["literal", "a"],
					["ref", 1]
				]
			],
			["private_rule", "B", ["literal", "b"]]
		],
		0, ["ref", 0])[_PARSED], [["A", "ab"]],
	_match_parsed_peg("ab",
		[
			["sequence", 
				["ref", 1],
				["ref", 2],
			],
			["rule", "A",
				["literal", "a"]
			],
			["rule", "B", 
				["literal", "b"]
			]
		],
		0, ["ref", 0])[_PARSED], [["A", "a"], ["B", "b"]]
	]
));



echo(_unit_test(
    "grammar",
	[
    _match_parsed_peg("ab", undef, 0, 
		["grammar",
			["rule", "A", 
				["sequence",
					["literal", "a"],
					["ref", 2]
				]
			],
			["rule", "B", ["literal", "b"]]
		]), ["A", "a", ["B", "b"]]
    ]
));
