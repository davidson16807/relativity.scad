_digit = "0123456789";
_lowercase = "abcdefghijklmnopqrstuvwxyz";
_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
_letter = str(_lowercase, _uppercase);
_alphanumeric = str(_letter, _digit);
_variable_safe = str(_alphanumeric, "_");
_whitespace = " \t\r\n";
_nonsymbol = str(_alphanumeric, _whitespace);

_strings_version = 
	[2014, 3, 17];
function strings_version() =
	_strings_version;
function strings_version_num() =
	_strings_version.x * 10000 + _strings_version.y * 100 + _strings_version.z;






_ascii = "         \t\n  \r                   !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
_hack = "\""; // used to work around syntax highlighter defficiencies in certain text editors

function ascii_code(string) = 
	!is_string(string)?
		undef
    :
        [for (result = search(string, _ascii, 0)) 
            result[0]
        ]
	;


// PEG ENGINE
_PARSED = 0;
_POS = 1;
function _match_parsed_peg( string, peg=undef, string_pos=0, peg_op=undef,  ignore_case=false ) =
	let(
		opcode = peg_op[0],
		operands = _slice(peg_op, 1)
	)

	string == undef?
		undef
    : len(string) < string_pos?
        undef

    : peg != undef && peg_op == undef?
    	_match_parsed_peg(	string, peg, string_pos, peg[1], 
    						 ignore_case=ignore_case )
    
    : opcode == "grammar"?
    	_match_parsed_peg(	string, peg_op, string_pos, peg_op[1],
							 ignore_case=ignore_case )[_PARSED][0]
	: opcode == "rule"?
		let(result = _match_parsed_peg(	string, peg, string_pos, operands[1],  
										ignore_case=ignore_case ))
		result != undef?
			[[concat( [operands[0]], result[_PARSED] )], result[_POS]]
		: 
			undef
	: opcode == "private_rule"?
		let(result = _match_parsed_peg(	string, peg, string_pos, operands[1],  
										ignore_case=ignore_case ))
		result != undef?
			result
		: 
			undef
	: opcode == "ref"?
		len(peg) > operands[0]?
			_match_parsed_peg(string, peg, string_pos, peg[operands[0]], ignore_case=ignore_case )
		:
			["ERROR: unrecognized ref id, '"+operands[0]+"'"]

	// BINARY
	: opcode == "choice"?
		let( option = _match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case ) )
		option != undef?
			option
		: len(operands) < 2?
			undef
		: 
			_match_parsed_peg(string, peg, string_pos, concat(opcode, _slice(operands, 1)), ignore_case=ignore_case )
	: opcode == "sequence"?
		let( first = _match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case ) )
		first == undef?
			undef
		: len(operands) == 1?
			first
		: 
			let( rest = _match_parsed_peg(string, peg, first[_POS], concat(opcode, _slice(operands, 1)), ignore_case = ignore_case) )
			rest == undef?
				undef
			: is_string(first[_PARSED][0]) && is_string(rest[_PARSED][0])?
				[[str(first[_PARSED][0], rest[_PARSED][0])], rest[_POS]]
			: 
				[concat(first[_PARSED], rest[_PARSED]), rest[_POS]]

	// PREFIX
	: opcode == "positive_lookahead"?
		_match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case ) != undef?
			[[], string_pos]
		: 
			undef
	: opcode == "negative_lookahead"?
		_match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case ) == undef?
			[[], string_pos]
		: 
			undef

	// POSTFIX
	: opcode == "one_to_many"?
		_match_parsed_peg(string, peg, string_pos, 
			["sequence", operands[0], ["zero_to_many", operands[0]]	], 
			ignore_case=ignore_case 
			)
	: opcode == "zero_to_many"?
		_match_parsed_peg(string, peg, string_pos, 
			["choice", 
				["sequence", operands[0], ["zero_to_many", operands[0]] ], 
				["empty_string"]
			], 
			ignore_case=ignore_case 
			)
	: opcode == "many_to_many"?
		let(min = operands[1][0],
			max = operands[1][1])
		let(min = is_string(min)? parse_int(min) : min,
			max = 
				max == undef? 
					undef 
				: is_string(max)? 
					parse_int(max)
				:
					max
			)
		min == undef?
			undef
		: max == undef?
			_match_parsed_peg(string, peg, string_pos,
				concat(["sequence"], 
						[for (i = [0:min-1])
							operands[0]
						],
						[["zero_to_many", operands[0]]]
					),
				ignore_case=ignore_case
				)	
		: max < 0 || min > max?
			undef
		:
			_match_parsed_peg(string, peg, string_pos,
				concat(["sequence"], 
						[for (i = [0:min-1])
							operands[0]
						],
						[for (i = [min:max-1])
							["zero_to_one", operands[0]]
						]
					),
				ignore_case=ignore_case
				)
	: opcode == "zero_to_one"?
		_match_parsed_peg(string, peg, string_pos, 
			["choice",
				operands[0],
				["empty_string"]
			], 
			ignore_case=ignore_case 
			)
			
			
	// PRIMITIVES
	: opcode == "literal"?
		!starts_with(string, operands[0], string_pos, ignore_case=ignore_case) ?
			undef
		:
			[ 
				[between(string, string_pos, string_pos+len(operands[0]))], 
				string_pos+len(operands[0]) 
			]
	: opcode == "positive_character_set"?
		let(matches		= 
			[ for (arg = operands)
				arg == str(arg)?
					equals(string[string_pos], arg, ignore_case=ignore_case)
				:
					_match_parsed_peg(string, peg, string_pos, arg, ignore_case=ignore_case ) != undef
			])
		
		!any(matches)?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "negative_character_set"?
		let(matches	= 
			[ for (arg = operands)
				arg == str(arg)?
					equals(string[string_pos], arg, ignore_case=ignore_case)
				:
					_match_parsed_peg(string, peg, string_pos, arg, ignore_case=ignore_case ) != undef
			])
		
		any(matches)?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "character_range"?
		!_is_in_range(string[string_pos], operands[0][0], operands[0][1])?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "character_literal"?
		!equals(string[string_pos], operands[0], ignore_case=ignore_case)?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "character_set_shorthand"?
		operands[0] == "s" && !is_in(string[string_pos], _whitespace)? //whitespace
			undef
		: operands[0] == "S" && is_in(string[string_pos], _whitespace)? //nonwhitespace
			undef
					
		: operands[0] == "d" && !is_in(string[string_pos], _digit)? //digit
			undef
		: operands[0] == "D" && is_in(string[string_pos], _digit)? //nondigit
			undef
					
		: operands[0] == "w" && !is_in(string[string_pos], _variable_safe)? // word character
			undef
		: operands[0] == "W" && is_in(string[string_pos], _variable_safe)? //non word character
			undef
		: !is_in(operands[0], "sSdDwW") && !equals(string[string_pos], operands[0], ignore_case=ignore_case)? // literal
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "wildcard"?
		string[string_pos] == undef?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "private"?
		let( result = _match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case))
		result == undef?
			undef
		: 
			[[], result[_POS]]
	: opcode == "empty_string"?
		[[], string_pos]
    : 
        ["ERROR: unrecognized opcode, '"+opcode+"'"]
	;
	
// PEG SYMBOL LINKER
function _get_rule_indexer(peg) = 
	[for (rule = _slice(peg, 1))
		rule[1]
	];
function _get_rule_index(rule, indexer) = 
	[for (i = [0:len(indexer)-1]) if(indexer[i] == rule) i+1 ] [0];
function _index_peg_op_refs(peg_op, indexer) = 
	let(
			opcode = peg_op[0],
			operands = _slice(peg_op, 1)
		)
	peg_op == str(peg_op)?
		peg_op
	: opcode == "ref"?
		["ref", _get_rule_index(operands[0], indexer)]
	:
		concat(opcode, [for (operand = operands) _index_peg_op_refs(operand, indexer)])
    ;
function _index_peg_refs(peg) = 
	_index_peg_op_refs(peg, _get_rule_indexer(peg));
function _get_rule(peg, ref) = 
	[for (rule = peg) if(rule[1] == ref) rule ] [0];

_rx_peg = 
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
function _parse_rx(rx) = 
	_match_parsed_peg(rx, _rx_peg)[_PARSED][0];

function _match_parsed_rx(string, regex, string_pos=0, ignore_case=false) = 
	_match_parsed_peg(string, 
		undef, 
		string_pos=string_pos, 
		peg_op=regex, 
		ignore_case=ignore_case)[_POS];
function _match_regex(string, pattern, pos=0, ignore_case=false) = 		//end pos
	_match_parsed_rx(string,
		regex=_parse_rx(pattern),
		string_pos=pos,
		ignore_case=ignore_case);





//returns a list representing the tokenization of an input string
//echo(tokenize("not(foo)"));
//echo(tokenize("foo bar baz  "));
_token_regex_ignore_space = _parse_rx("\\w+|\\S");
_token_regex = _parse_rx("\\w+|\\S|\\s+");
function tokenize(string, ignore_space=true) = 
    _tokenize(string, ignore_space? _token_regex_ignore_space : _token_regex);
function _tokenize(string, pattern) = 
    _grep(string, _index_of(string, pattern, regex=true));

function grep(string, pattern, ignore_case=false) = 		//string
    _grep(string, _index_of(string, _parse_rx(pattern), regex=true, ignore_case=ignore_case));
function _grep(string, indices) = 
    [for (index = indices)
        between(string, index.x, index.y)
    ];


function replace(string, replaced, replacement, ignore_case=false, regex=false) = 
	_replace(string, replacement, index_of(string, replaced, ignore_case=ignore_case, regex=regex));
    
function _replace(string, replacement, indices, i=0) = 
    i >= len(indices)?
        after(string, indices[len(indices)-1].y-1)
    : i == 0?
        str( before(string, indices[0].x), replacement, _replace(string, replacement, indices, i+1) )
    :
        str( between(string, indices[i-1].y, indices[i].x), replacement, _replace(string, replacement, indices, i+1) )
    ;


function split(string, seperator=" ", ignore_case = false, regex=false) = 
	_split(string, index_of(string, seperator, ignore_case=ignore_case, regex=regex));
    
function _split(string, indices, i=0) = 
    len(indices) == 0?
        [string]
    : i >= len(indices)?
        _coalesce_on(after(string, indices[len(indices)-1].y-1), "", [])
    : i == 0?
        concat( _coalesce_on(before(string, indices[0].x), "", []), _split(string, indices, i+1) )
    :
        concat( between(string, indices[i-1].y, indices[i].x), _split(string, indices, i+1) )
    ;

function contains(string, substring, ignore_case=false, regex=false) = 
	regex?
        _index_of_first(string, _parse_rx(substring), regex=regex, ignore_case=ignore_case) != undef
	:
		_index_of_first(string, substring, regex=regex, ignore_case=ignore_case) != undef
	; 
	


function index_of(string, pattern, ignore_case=false, regex=false) = 
	_index_of(string, 
        regex? _parse_rx(pattern) : pattern, 
        regex=regex, 
        ignore_case=ignore_case);
function _index_of(string, pattern, pos=0, regex=false, ignore_case=false) = 		//[start,end]
	pos == undef?
        undef
	: pos >= len(string)?
		[]
	:
        _index_of_recurse(string, pattern, 
            _index_of_first(string, pattern, pos=pos, regex=regex, ignore_case=ignore_case),
            pos, regex, ignore_case)
	;
function _index_of_recurse(string, pattern, index_of_first, pos, regex, ignore_case) = 
    index_of_first == undef?
        []
    : concat(
        [index_of_first],
        _coalesce_on(
            _index_of(string, pattern, 
                    pos = index_of_first.y,
                    regex=regex,
                    ignore_case=ignore_case),
            undef,
            [])
    );
function _index_of_first(string, pattern, pos=0, ignore_case=false, regex=false) =
	pos == undef?
        undef
    : pos >= len(string)?
		undef
	: _coalesce_on([pos, _match(string, pattern, pos, regex=regex, ignore_case=ignore_case)], 
		[pos, undef],
		_index_of_first(string, pattern, pos+1, regex=regex, ignore_case=ignore_case))
    ;
function _match(string, pattern, pos, regex=false, ignore_case=false) = 
    regex?
    	_match_parsed_peg(string, undef, pos, peg_op=pattern, ignore_case=ignore_case)[_POS]
    : starts_with(string, pattern, pos, ignore_case=ignore_case)? 
        pos+len(pattern) 
    : 
        undef
    ;
    
    
function starts_with(string, start, pos=0, ignore_case=false, regex=false) = 
	regex?
		_match_parsed_peg(string,
			undef,
			pos, 
			_parse_rx(start), 
			ignore_case=ignore_case) != undef
	:
		equals(	substring(string, pos, len(start)), 
			start, 
			ignore_case=ignore_case)
	;
function ends_with(string, end, ignore_case=false) =
	equals(	after(string, len(string)-len(end)-1), 
		end,
		ignore_case=ignore_case)
	;





function _pop(stack, n=1) = 
	n <= 1?
		len(stack) <=0? [] : stack[1]
	:
		_pop(_pop(stack), n-1)
	;
function _push(stack, char) = 
	[char, stack];























function is_empty(string) = 
	string == "";

function is_null_or_empty(string) = 
	string == undef || string == "";
	
function is_null_or_whitespace(string) = 
	string == undef || trim(string) == "";

function trim(string) = 
	string == undef?
		undef
	: string == ""?
		""
	:
		_null_coalesce(
			between(string, _match_set(string, _whitespace, 0), 
					_match_set_reverse(string, _whitespace, len(string))),
			""
		)
	;

function _match_set(string, set, pos) = 
	pos >= len(string)?
		len(string)
	: is_in(string[pos], set )?
		_match_set(string, set, pos+1)
	: 
		pos
	;

function _match_set_reverse(string, set, pos) = 
	pos <= 0?
		0
	: is_in(string[pos-1], set)?
		_match_set_reverse(string, set, pos-1)
	: 
		pos
	;


	

function _is_in_range(char, min_char, max_char) = 
	ascii_code(char)[0] >= ascii_code(min_char)[0] &&
	ascii_code(char)[0] <= ascii_code(max_char)[0];

function equals(this, that, ignore_case=false) = 
	ignore_case?
		lower(this) == lower(that)
	:
		this==that
	;



function upper(string) = 
	let(code = ascii_code(string))
	join([for (i = [0:len(string)-1])
			code[i] >= 97 && code[i] <= 122?
                chr(code[i]-97+65)
            :
                string[i]
		]);
function lower(string) = 
	let(code = ascii_code(string))
	join([for (i = [0:len(string)-1])
			code[i] >= 65 && code[i] <= 90?
                chr(code[i]+97-65)
            :
                string[i]
		]);

function reverse(string) = 
	string == undef?
		undef
	: len(string) <= 0?
		""
	: 
        join([for (i = [0:len(string)-1]) string[len(string)-1-i]])
    ;

function substring(string, start, length=undef) = 
	length == undef? 
		between(string, start, len(string)) 
	: 
		between(string, start, length+start)
	;

//note: start is inclusive, end is exclusive
function between(string, start, end) = 
	string == undef?
		undef
	: start == undef?
		undef
	: start > len(string)?
		undef
	: start < 0?
		before(string, end)
	: end == undef?
		undef
	: end < 0?
		undef
	: end > len(string)?
		after(string, start-1)
	: start > end?
		undef
	: start == end ? 
		"" 
	: 
        join([for (i=[start:end-1]) string[i]])
	;

function before(string, index=0) = 
	string == undef?
		undef
	: index == undef?
		undef
	: index > len(string)?
		string
	: index <= 0?
		""
	: 
        join([for (i=[0:index-1]) string[i]])
	;

function after(string, index=0) =
	string == undef?
		undef
	: index == undef?
		undef
	: index < 0?
		string
	: index >= len(string)-1?
		""
	:
        join([for (i=[index+1:len(string)-1]) string[i]])
	;
	

	

function parse_int(string, base=10, i=0, nb=0) = 
	string[0] == "-" ? 
		-1*_parse_int(string, base, 1) 
	: 
		_parse_int(string, base);

function _parse_int(string, base, i=0, nb=0) = 
	i == len(string) ? 
		nb 
	: 
		nb + _parse_int(string, base, i+1, 
				search(string[i],"0123456789ABCDEF")[0]*pow(base,len(string)-i-1));
                
function join(strings, delimeter="") = 
	strings == undef?
		undef
	: strings == []?
		""
	: _join(strings, len(strings)-1, delimeter, 0);
function _join(strings, index, delimeter) = 
	index==0 ? 
		strings[index] 
	: str(_join(strings, index-1, delimeter), delimeter, strings[index]) ;
	
function is_in(string, list, ignore_case=false) = 
	string == undef?
		false
    : 
        any([ for (i = [0:len(list)-1]) equals(string, list[i], ignore_case=ignore_case) ])
	;


function _slice(array, start=0, end=-1) = 
	array == undef?
		undef
	: start == undef?
		undef
	: start >= len(array)?
		[]
	: start < 0?
		_slice(array, len(array)+start, end)
	: end == undef?
		undef
	: end < 0?
		_slice(array, start, len(array)+end)
	: end >= len(array)?
        undef
    : start > end && start >= 0 && end >= 0?
        _slice(array, end, start)
	: 
        [for (i=[start:end]) array[i]]
	;
function is_string(x) = 
	x == str(x);





function any(booleans, index=0) = 
    index > len(booleans)?
        false
    : booleans[index]?
        true
    :
        any(booleans, index+1)
    ;
function all(booleans, index=0) = 
	index >= len(booleans)?
		true
	: !booleans[index]?
		false
	: 
		all(booleans, index+1)
	;

function _null_coalesce(string, replacement) = 
	string == undef?
		replacement
	:
		string
	;
function _coalesce_on(value, error, fallback) = 
	value == error?
		fallback
	: 
		value
	;
	



function _unit_test(name, tests) = 
	let(results = 
		[for(i=[0:len(tests)/2]) 
			let(test = tests[i*2], 
				result=tests[i*2+1])
			test==result
		])
	!all(results)?
		concat([name],
			[for(i=[0:len(tests)/2]) 
				let(test = tests[i*2], 
					result=tests[i*2+1])
				[test, result]
			]
		)
	:
		str(name, ":\tpassed")
    ;

