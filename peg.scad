_digit = "0123456789";
_lowercase = "abcdefghijklmnopqrstuvwxyz";
_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
_letter = str(_lowercase, _uppercase);
_alphanumeric = str(_letter, _digit);
_variable_safe = str(_alphanumeric, "_");
_whitespace = " \t\r\n";
_nonsymbol = str(_alphanumeric, _whitespace);
_ascii = "         \t\n  \r                   !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
_hack = "\""; // used to work around syntax highlighter defficiencies in certain text editors

_PARSED = 0;
_POS = 1;

function _match_parsed_peg( string, peg, string_pos=0, peg_op=undef,  ignore_case=false ) =
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
			: _is_string(first[_PARSED][0]) && _is_string(rest[_PARSED][0])?
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
		let(min = _is_string(min)? parse_int(min) : min,
			max = 
				max == undef? 
					undef 
				: _is_string(max)? 
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
			[ [operands[0]], string_pos+len(operands[0]) ]
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
		string[string_pos] != operands[0]?
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
		: !is_in(operands[0], "sSdDwW") && string[string_pos] != operands[0]? // literal
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
	

function equals(this, that, ignore_case=false) = 
	ignore_case?
		lower(this) == lower(that)
	:
		this==that
	;

function _null_coalesce(string, replacement) = 
	string == undef?
		replacement
	:
		string
	;

function starts_with(string, start, pos=0, ignore_case=false, regex=false) = 
	regex?
		_match_parsed_rx(string,
			_parse_rx(start), 
			pos, 
			ignore_case=ignore_case) != undef
	:
		equals(	substring(string, pos, len(start)), 
			start, 
			ignore_case=ignore_case)
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
function any(booleans, index=0) = 
    index > len(booleans)?
        false
    : booleans[index]?
        true
    :
        any(booleans, index+1)
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


function all(booleans, index=0) = 
	index >= len(booleans)?
		true
	: !booleans[index]?
		false
	: 
		all(booleans, index+1)
	;







function _is_in_range(char, min_char, max_char) = 
	_ascii_code(char) >= _ascii_code(min_char) &&
	_ascii_code(char) <= _ascii_code(max_char);
	
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
function _is_string(x) = 
	x == str(x);

function _ascii_code(char) = 
	len(char) != 1 || !_is_string(char)?
		undef
	:
		search(char, _ascii, 0)[0][0]
	;









// SYMBOL LINKER

function _get_rule_indexer(peg) = 
	[for (rule = _slice(peg, 1))
		rule[1]
	];
	
function _get_rule_index(rule, indexer) = 
	[for (i = [0:len(indexer)-1]) if(indexer[i] == rule) i+1 ] [0];

function _index_op_refs(peg_op, indexer) = 
	let(
			opcode = peg_op[0],
			operands = _slice(peg_op, 1)
		)
	peg_op == str(peg_op)?
		peg_op
	: opcode == "ref"?
		["ref", _get_rule_index(operands[0], indexer)]
	:
		concat(opcode, [for (operand = operands) _index_op_refs(operand, indexer)])
    ;

function _index_peg_refs(peg) = 
	_index_op_refs(peg, _get_rule_indexer(peg));

function _get_rule(peg, ref) = 
	[for (rule = peg) if(rule[1] == ref) rule ] [0];






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


