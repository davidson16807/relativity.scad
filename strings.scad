_strings_version = 
	[2022, 11, 5];
function strings_version() =
	_strings_version;
function strings_version_num() =
	_strings_version.x * 10000 + _strings_version.y * 100 + _strings_version.z;






_ASCII_SPACE 	= 32;
_ASCII_0 		= 48;
_ASCII_9 		= _ASCII_0 + 9;
_ASCII_UPPER_A 	= 65;
_ASCII_UPPER_Z 	= _ASCII_UPPER_A + 25;
_ASCII_LOWER_A 	= 97;
_ASCII_LOWER_Z 	= _ASCII_LOWER_A + 25;
_ASCII = "\t\n\r !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
_ASCII_HACK = "\""; // only here to work around syntax highlighter defficiencies in certain text editors
_WHITESPACE = " \t\r\n";
_ASCII_CODE = concat(9,10,13, [for(i=[_ASCII_SPACE : _ASCII_LOWER_Z+4]) i]);

function ascii_code(string) = 
	!is_string(string)?
		undef
    :
        [for (result = search(string, _ASCII, 0)) 
            result == undef?
                undef
            :
                _ASCII_CODE[result[0]]
        ]
	;


// PEG ENGINE
_PARSED = 0;
_POS = 1;
function _match_parsed_peg( string, peg, string_pos=0, peg_op=undef,  ignore_case=false, string_code=undef ) =
	let(
		opcode = peg_op[0],
		operands = _slice(peg_op, 1)
	)

	string == undef?
		undef
    : string_pos > len(string)?
        undef

    : peg != undef && peg_op == undef?
    	_match_parsed_peg(	string, peg, string_pos, peg[1], 
    						 ignore_case=ignore_case, string_code=string_code )
    						 
    : string_code == undef?
    	_match_parsed_peg( string, peg, string_pos, peg_op, ignore_case=ignore_case, string_code=ascii_code(string) )
    
    : opcode == "grammar"?
    	_match_parsed_peg(	string, peg_op, string_pos, peg_op[1],
							 ignore_case=ignore_case, string_code=string_code )[_PARSED][0]
	: opcode == "rule"?
		let(result = _match_parsed_peg(	string, peg, string_pos, operands[1],  
										ignore_case=ignore_case, string_code=string_code ))
		result != undef?
			[[concat( [operands[0]], result[_PARSED] )], result[_POS]]
		: 
			undef
	: opcode == "private_rule"?
		let(result = _match_parsed_peg(	string, peg, string_pos, operands[1],  
										ignore_case=ignore_case, string_code=string_code ))
		result != undef?
			result
		: 
			undef
	: opcode == "ref"?
		len(peg) > operands[0]?
			_match_parsed_peg(string, peg, string_pos, peg[operands[0]], ignore_case=ignore_case, string_code=string_code )
		:
			["ERROR: unrecognized ref id, '"+operands[0]+"'"]

	// BINARY
	: opcode == "choice"?
		let( option = _match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case, string_code=string_code ) )
		option != undef?
			option
		: len(operands) < 2?
			undef
		: 
			_match_parsed_peg(string, peg, string_pos, concat(opcode, _slice(operands, 1)), ignore_case=ignore_case, string_code=string_code )
	: opcode == "sequence"?
		let( first = _match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case, string_code=string_code ) )
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
		_match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case, string_code=string_code ) != undef?
			[[], string_pos]
		: 
			undef
	: opcode == "negative_lookahead"?
		_match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case, string_code=string_code ) == undef?
			[[], string_pos]
		: 
			undef

	// POSTFIX
	: opcode == "one_to_many"?
		_match_parsed_peg(string, peg, string_pos, 
			["sequence", operands[0], ["zero_to_many", operands[0]]	], 
			ignore_case=ignore_case, string_code=string_code 
			)
	: opcode == "zero_to_many"?
		_match_parsed_peg(string, peg, string_pos, 
			["choice", 
				["sequence", operands[0], ["zero_to_many", operands[0]] ], 
				["empty_string"]
			], 
			ignore_case=ignore_case, string_code=string_code 
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
				ignore_case=ignore_case, string_code=string_code
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
				ignore_case=ignore_case, string_code=string_code
				)
	: opcode == "zero_to_one"?
		_match_parsed_peg(string, peg, string_pos, 
			["choice",
				operands[0],
				["empty_string"]
			], 
			ignore_case=ignore_case, string_code=string_code 
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
					_match_parsed_peg(string, peg, string_pos, arg, ignore_case=ignore_case, string_code=string_code ) != undef
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
					_match_parsed_peg(string, peg, string_pos, arg, ignore_case=ignore_case, string_code=string_code ) != undef
			])
		
		any(matches)?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "character_range"?
		!_is_in_range(string_code[string_pos], ascii_code(operands[0][0])[0], ascii_code(operands[0][1])[0])?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "character_literal"?
		!equals(string[string_pos], operands[0], ignore_case=ignore_case)?
			undef
		:
			[ [string[string_pos]], string_pos+1 ]
	: opcode == "character_set_shorthand"?
		operands[0] == "s" && !_is_in_range(string_code[string_pos], 0, _ASCII_SPACE)? //whitespace
			undef
		: operands[0] == "S" && _is_in_range(string_code[string_pos], 0, _ASCII_SPACE)? //nonwhitespace
			undef
		
		: operands[0] == "d" && !_is_in_range(string_code[string_pos], _ASCII_0, _ASCII_9)? //digit
			undef
		: operands[0] == "D" && _is_in_range(string_code[string_pos], _ASCII_0, _ASCII_9)? //nondigit
			undef
		
		: operands[0] == "w" && !_is_variable_safe(string_code[string_pos])? // word character
			undef
		: operands[0] == "W" && _is_variable_safe(string_code[string_pos])? //non word character
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
	: opcode == "start"?
		string_pos == 0?
			[[], string_pos]
		: 
			undef
	: opcode == "end"?
		string_pos == len(string)?
			[[], string_pos]
		:
			undef
	: opcode == "private"?
		let( result = _match_parsed_peg(string, peg, string_pos, operands[0], ignore_case=ignore_case, string_code=string_code))
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

// PUBLIC FACING PEG
function peg(string, grammar) = _match_parsed_peg(string, _index_peg_refs(grammar));

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
				["ref", "start"],
				["ref", "end"],
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

		["rule", "start",
			["private", ["literal", "^"]],
		],
		["rule", "end",
			["private", ["literal", "$"]],
		],
		["rule", "wildcard",
			["private", ["literal", "."]],
		],
		["rule", "literal", 
			["negative_character_set", 
				"{","}","[","]","(",")", 
				"|","*","+","?",".","\\",".",
				"^","$",
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


function split(string, separator=" ", ignore_case = false, regex=false) = 
	_split(string, index_of(string, separator, ignore_case=ignore_case, regex=regex));
    
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





















function is_string(x) = 
	x == str(x);

function is_empty(string) = 
	string == "";

function is_whitespace(string) = 
	len([for (char=ascii_code(string)) if(char>0) char]) < 1;

function is_null_or_empty(string) = 
	is_undef(string) || string == "";
	
function is_null_or_whitespace(string) = 
	is_undef(string) || len([for (char=ascii_code(string)) if(char>0) char]) < 1;

function trim(string) = 
	string == undef?
		undef
	: string == ""?
		""
	:
		_null_coalesce(
			between(string, _match_set(string, _WHITESPACE, 0), 
					_match_set_reverse(string, _WHITESPACE, len(string))),
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


	

function _is_in_range(code, min_char, max_char) = 
	code >= min_char &&
	code <= max_char;

function _is_variable_safe(code) = 
	_is_in_range(code, _ASCII_0, _ASCII_9) ||
	_is_in_range(code, _ASCII_UPPER_A, _ASCII_UPPER_Z) ||
	_is_in_range(code, _ASCII_LOWER_A, _ASCII_LOWER_Z) ||
	chr(code) == "_";

function equals(this, that, ignore_case=false) = 
	ignore_case?
		lower(this) == lower(that)
	:
		this==that
	;



// set all letters to "UPPER CASE"
function upper(string) = 
	let(code = ascii_code(string))
	join([for (i = [0:len(string)-1])
			code[i] >= 97 && code[i] <= 122?
                chr(code[i]-97+65)
            :
                string[i]
		]);
// set all letters to "lower case"
function lower(string) = 
	let(code = ascii_code(string))
	join([for (i = [0:len(string)-1])
			code[i] >= 65 && code[i] <= 90?
                chr(code[i]+97-65)
            :
                string[i]
		]);
// set all letters to "Title Case"
function title(string) =
    let(lower_case_string = lower(string))
    join([for (word = split(lower_case_string))
        join ([upper(word[0]), lower(after(word, 0))], "")
    ], " ");
   

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
	

	

function parse_int(string, base=10) = 
	string[0] == "-" ? 
		-1*_parse_int(string, base, 1) 
	: 
		_parse_int(string, base);

function _parse_int(string, base, i=0, sum=0) = 
	i == len(string) ? 
		sum
	: 
		sum + _parse_int(string, base, i+1, 
				search(string[i],"0123456789ABCDEF")[0]*pow(base,len(string)-i-1));

function parse_float(string) = 
	string[0] == "-" ? 
		-1*parse_float(after(string,0))
	: 
		_parse_float(split(string, "."));

function _parse_float(sections)=
    len(sections) == 2?
        _parse_int(sections[0], 10) + _parse_int(sections[1], 10)/pow(10,len(sections[1]))
    :
        _parse_int(sections[0], 10) 
    ;


function join(strings, delimiter="") = 
	strings == undef?
		undef
	: strings == []?
		""
	: _join(strings, len(strings)-1, delimiter);
function _join(strings, index, delimiter) = 
	index==0 ? 
		strings[index] 
	: str(_join(strings, index-1, delimiter), delimiter, strings[index]) ;
	
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
