
_digit = "0123456789";
_lowercase = "abcdefghijklmnopqrstuvwxyz";
_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
_letter = str(_lowercase, _uppercase);
_alphanumeric = str(_letter, _digit);
_variable_safe = str(_alphanumeric, "_");
_whitespace = " \t\r\n";
_nonsymbol = str(_alphanumeric, _whitespace);

_regex_ops = "?*+&|";

_strings_version = 
	[2014, 3, 17];
function strings_version() =
	_strings_version;
function strings_version_num() =
	_strings_version.x * 1000 + _strings_version.y * 100 + _strings_version.z;







function grep(string, pattern, ignore_case=false) = 		//string
    [for (index = _index_of(string, _parse_rx(pattern), regex=true, ignore_case=ignore_case))
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
    i >= len(indices)?
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
		undef
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
        _match_parsed_rx(string, pattern, pos, ignore_case=ignore_case)
    : starts_with(string, pattern, pos, ignore_case=ignore_case)? 
        pos+len(pattern) 
    : 
        undef
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
function ends_with(string, end, ignore_case=false) =
	equals(	after(string, len(string)-len(end)-1), 
		end,
		ignore_case=ignore_case)
	;







function _match_regex(string, pattern, pos=0, ignore_case=false) = 		//end pos
	_match_parsed_rx(string,
		_parse_rx(pattern), 
		pos, 
		ignore_case=ignore_case);
	
//converts an infix notated regex string to a parse tree using the shunting yard algorithm
function _parse_rx(	rx, 		ops=[], 	args=[], 				i=0) = 
	rx == undef?
		undef
	: i >= len(rx)?
		len(ops) <= 0?
			args[0]
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
			
			
	: ops[0] == "{"?
		rx[i] == "}"?
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		 i+1)
		: rx[i] == ","?
			_parse_rx(rx, ops, 		_swap(args, _push(args[0], "")), 	 i+1)
		: 
			_parse_rx(rx, ops, 		_swap(args, _swap(args[0], str(args[0][0], rx[i]))), i+1)
			
			
	: ops[0] == "[" || ops[0] == "[^"?
		rx[i] == "]"?
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i+1)
		: rx[i] == "\\"?
			_parse_rx(rx, ops, 		_swap(args, _push(args[0],rx[i+1])), 	i+2)
		: rx[i] == "-"?
			_parse_rx(rx, ops, 		_swap(args, _push(_pop(args[0]), ["-", args[0][0], rx[i+1]])), i+2)
		:
			_parse_rx(rx, ops, 		_swap(args, _push(args[0], rx[i])), 	i+1)
	: rx[i] == "[" && rx[i+1] == "^"?
		!_can_concat(rx, i)?
			_parse_rx(rx, _push(ops, "[^"),	_push(args, []),	 		i+2)
		: _can_shunt(ops, "&")?
			_parse_rx(rx, _push(_push(ops,"&"),"[^"), _push(args, []), i+2)
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
	: rx[i] == "["?
		!_can_concat(rx, i)?
			_parse_rx(rx, _push(ops, "["), 	_push(args, []),	 		i+1)
		: _can_shunt(ops, "&")?
			_parse_rx(rx, _push(_push(ops,"&"),"["), _push(args, []), i+1)
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
			
	: rx[i] == "{"?
			_parse_rx(rx, _push(ops, "{"),	_push(args, ["", []]), 			i+1)
			
			
	: is_in(rx[i], _regex_ops)?
		_can_shunt(ops, rx[i])?
			_parse_rx(rx, _push(ops, rx[i]), args, 		 		i+1)
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
	: rx[i] == ")"?
		ops[0] == "(" ?
			_parse_rx(rx, _pop(ops), 	args,			 		i+1)
		: len(ops) <= 0 ?
			_parse_rx(rx, ops, 		args,			 		i+1)
		: 
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
	: rx[i] == "("?
		!_can_concat(rx, i)?
			_parse_rx(rx, _push(ops, "("), 	args, 		 			i+1)
		: _can_shunt(ops, "&")?
			_parse_rx(rx, _push(_push(ops, "&"), "("), args, 	 		i+1)
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
	: rx[i] == "\\"?
		!_can_concat(rx, i)?
			_parse_rx(rx, ops, 			_push(args,str(rx[i],rx[i+1])),	i+2)
		: _can_shunt(ops, "&")?
			_parse_rx(rx, _push(ops, "&"),	_push(args,str(rx[i],rx[i+1])),	i+2)
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
	:
		!_can_concat(rx, i)?
			_parse_rx(rx, ops, 		_push(args, rx[i]),	 		i+1)
		: _can_shunt(ops, "&")?
			_parse_rx(rx, _push(ops, "&"),	_push(args, rx[i]),	 		i+1)
		:
			_parse_rx(rx, _pop(ops), 	_push_rx_op(args, ops[0]), 		i)
	;

	
function _can_concat(regex, i) = 
	regex[i-1] != undef &&
	(!is_in(regex[i-1], "|(") || regex[i-2] == "\\");
	
function _can_shunt(stack, op) = 
	stack[0] == "(" || 
	len(stack) <= 0 || 
	_precedence(op, _regex_ops) < _precedence(stack[0], _regex_ops);
	
function _push_rx_op(stack, op) = 
	is_in(op[0], "[?*+")? // is unary?
		_push(_pop(stack), 	[op, stack[0]])
	: 		 	// is binary?
		_push(_pop(stack,2), 	[op, stack[1][0], stack[0], ])
	;

function _swap(stack, replacement) = 
	_push(_pop(stack), replacement);
function _pop(stack, n=1) = 
	n <= 1?
		len(stack) <=0? [] : stack[1]
	:
		_pop(_pop(stack), n-1)
	;
function _push(stack, char) = 
	[char, stack];

function _precedence(op, ops) = 
	search(op, ops)[0];
	
function _match_parsed_rx(string, regex, string_pos=0, ignore_case=false) = 
	//INVALID INPUT
	string == undef?
		undef
	
	//string length and anchors
	: regex == "^"?
		string_pos == 0?
			string_pos
		:
			undef
	: regex == "$"?
		string_pos >= len(string)?
			string_pos
		:
			undef
	: string_pos == undef?
		undef
	: string_pos >= len(string)?
		undef
		
	//ALTERNATION
	: regex[0] == "|" ?
		_null_coalesce(
			_match_parsed_rx(string, regex[1], string_pos, ignore_case=ignore_case),
			_match_parsed_rx(string, regex[2], string_pos, ignore_case=ignore_case)
		)

	//KLEENE STAR
	: regex[0] == "*" ?
		_match_repetition(string, regex[1],
			0, undef,
			string_pos,
			ignore_case=ignore_case)

	//KLEENE BRACKETS
	: regex[0] == "{" ?
		regex[2][1][0] == undef?
			_match_repetition(string, regex[1],
				_parse_int(regex[2][0], 10), undef,
				string_pos,
				ignore_case=ignore_case)
		:
			_match_repetition(string, regex[1],
				_parse_int(regex[2][1][0], 10), _parse_int(regex[2][0], 10),
				string_pos,
				ignore_case=ignore_case)
		
	//KLEENE PLUS
	: regex[0] == "+" ?
		_match_repetition(string, regex[1],
			1, undef,
			string_pos,
			ignore_case=ignore_case)

	//OPTION
	: regex[0] == "?" ?
		_match_repetition(string, regex[1],
			0, 1,
			string_pos,
			ignore_case=ignore_case)

	//CONCATENATION
	: regex[0] == "&" ?	
		_match_parsed_rx(string, regex[2], 
			_match_parsed_rx(string, regex[1], string_pos, ignore_case=ignore_case), 
			ignore_case=ignore_case)
			
	//ESCAPE CHARACTER
	: regex == "\\d"?
		is_in(string[string_pos], _digit)?
			string_pos+1
		: 
			undef
	: regex == "\\s"?
		is_in(string[string_pos], _whitespace)?
			string_pos+1
		: 
			undef
	: regex == "\\w"?
		is_in(string[string_pos], _alphanumeric)?
			string_pos+1
		: 
			undef
	: regex == "\\D"?
		!is_in(string[string_pos], _digit)?
			string_pos+1
		: 
			undef
				
	: regex == "\\S"?
		!is_in(string[string_pos], _whitespace)?
			string_pos+1
		: 
			undef
	: regex == "\\W"?
		!is_in(string[string_pos], _alphanumeric)?
			string_pos+1
		: 
			undef
	: regex[0] == "\\"?
		string[string_pos] == regex[0][1]?
			string_pos+1
		:
			undef
	
	//CHARACTER SET
	: regex[0] == "[" ?
		_is_in_stack(string[string_pos], regex[1], ignore_case=ignore_case)?
			string_pos+1
		:
			undef
	//NEGATIVE CHARACTER SET
	: regex[0] == "[^" ?
		!_is_in_stack(string[string_pos], regex[1], ignore_case=ignore_case)?
			string_pos+1
		:
			undef
		
	//LITERAL
	: equals(string[string_pos], regex, ignore_case=ignore_case) ?
		string_pos+1
	
	//WILDCARD
	: regex == "."?
		string_pos+1
	
	//NO MATCH
	: 
		undef
	;

//returns a list representing the tokenization of an input string
//echo(tokenize("not(foo)"));
//echo(tokenize("foo bar baz  "));
function tokenize(string, pos=0, ignore_space=true) = 
	pos >= len(string)?
		[]
	:
		concat(
			between(string, 
				_token_start(string, pos, ignore_space=ignore_space), 
				_token_end(string, pos, token_characters=str(_alphanumeric, "_-"), ignore_space=ignore_space)
			),
			tokenize(string, 
				_token_end(string, pos, token_characters=str(_alphanumeric, "_-"), ignore_space=ignore_space), 
				ignore_space=ignore_space)
		)
	;

function _token_start(string, pos=0, ignore_space=true) = 
	pos >= len(string)?
		undef
	: pos == len(string)?
		len(string)
	: is_in(string[pos], _whitespace) && ignore_space?
		_match_set(string, _whitespace, pos)
	: //symbol
		pos
	;
	

function _token_end(string, pos=0, token_characters=_variable_safe, ignore_space=true, tokenize_quotes=true) = 
	pos >= len(string)?
		len(string)
	: is_in(string[pos], token_characters) ?
		_match_set(string, token_characters, pos)
	: is_in(string[pos], _whitespace) ? (
		ignore_space?
			_token_end(string, _match_set(string, _whitespace, pos))
		:
			_match_set(string, _whitespace, pos)
	)
	
	: string[pos] == "\"" && tokenize_quotes ?
		_match_quote(string, "\"", pos+1)
	: string[pos] == "'" && tokenize_quotes?
		_match_quote(string, "'", pos+1)
	: 
		pos+1
	;

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

function _match_repetition(string, regex, min_reps, max_reps, pos, ignore_case=false) = 
    pos == undef?
        undef
    : pos > len(string)?
        undef
	: _null_coalesce(
		_match_repetition(string, regex, min_reps-1, max_reps-1, 
			_match_parsed_rx(string, regex, pos, ignore_case=ignore_case), 
            ignore_case=ignore_case),
		(min_reps== undef || min_reps <= 0) && (max_reps == undef || max_reps >= 0)?
			pos
		: 
			undef
	);
	
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

function _match_quote(string, quote_char, pos) = 
	pos >= len(string)?
		len(string)
	: string[pos] == quote_char?
		pos
	: string[pos] == "\\"? 
		_match_quote(string, quote_char, pos+2)
	: 
		_match_quote(string, quote_char, pos+1)
	;

	
function _is_in_range(char, min_char, max_char) = 
	search(char, _alphanumeric,0)[0][0] >= search(min_char, _alphanumeric,0)[0][0] &&
	search(char, _alphanumeric,0)[0][0] <= search(max_char, _alphanumeric,0)[0][0];
function _is_in_stack(string, stack, ignore_case=false) = 
	stack == undef?
		false
	: len(stack) <= 0?
		false
	: stack[0][0] == "-"?
		_is_in_range(string, stack[0][1], stack[0][2])
	: string == stack[0]?
		true
	: ignore_case && lower(string) == lower(stack[0])?
		true
	:
		_is_in_stack(string, _pop(stack), ignore_case=ignore_case)
	;

function equals(this, that, ignore_case=false) = 
	ignore_case?
		lower(this) == lower(that)
	:
		this==that
	;

function lower(string) = 
	_transform_case(string, search(string, "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0), 97);

function upper(string) = 
	_transform_case(string, search(string, "abcdefghijklmnopqrstuvwxyz",0), 65);

//TODO: convert to list comprehensions
function _transform_case(string, encodings, offset) = 
    join([for (i = [0:len(encodings)-1])
            len(encodings[i]) > 0?
                chr(encodings[i][0] + offset)
            :
                string[i]
    ])
	;


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
	
