_digit = "0123456789";
_lowercase = "abcdefghijklmnopqrstuvwxyz";
_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
_letter = str(_lowercase, _uppercase);
_alphanumeric = str(_letter, _digit);
_whitespace = " \t\r\n";
// string functions

//echo(_has_all_tokens("foo bar baz", "foo baz"));

//echo(_has_all_tokens("foo bar baz", "spam baz"));

function _has_all_tokens(string, tokens, string_seperator=" ", token_seperator=" ", index=0) = 
	split(tokens, token_seperator, index) == undef?		
		true
	: _has_token(string, split(tokens, token_seperator, index), string_seperator) ?	
		_has_all_tokens(string, tokens, string_seperator, token_seperator, index+1)		
	: 
		false
	;



//echo(_has_any_tokens("foo bar baz", "spam baz"));

function _has_any_tokens(string, tokens, seperator=",", index=0) = 
	split(tokens, seperator, index) == undef?		//no more tokens?
		false						//then there's no 
	: _has_token(string, split(tokens, " ", index), " ") ?	//matches
		true						//then 
	: 
		_has_any_tokens(string, tokens, seperator, index+1)//otherwise, try the next token
	;



//echo(_has_token("foo bar baz", "baz"));

function _has_token(string, token, seperator=" ", index=0) = 		
	split(string, seperator, index) == token ? 		//match?
		true						//then I guess we found a token		
	: after(string, seperator, index) == undef ? 		//no more tokens?
		false						//then I guess there aren't any matches
	:							
		_has_token(string, token, seperator, index+1)	//otherwise, try again
	;



test = "foo  (1, bar2)";

echo([
	_match_prefix_regex("foo", "f", 0, 0) == 1,
	_match_prefix_regex("foo", "&fo", 0, 0) == 2,
	_match_prefix_regex("foo", "&fx", 0, 0) == undef,
	_match_prefix_regex("foo", "&xf", 0, 0) == undef,
	_match_prefix_regex("foo", "&xy", 0, 0) == undef,
	_match_prefix_regex("foo", "|fx", 0, 0) == 1,
	_match_prefix_regex("foo", "|xf", 0, 0) == 1,
	_match_prefix_regex("foo", "|xy", 0, 0) == undef,
	_match_prefix_regex("foo", "?x", 0, 0) == 0,
	_match_prefix_regex("foo", "?f", 0, 0) == 1,
	_match_prefix_regex("f", "*o", 0, 0) == 0,
	_match_prefix_regex("of", "*o", 0, 0) == 1,
	_match_prefix_regex("oof", "*o", 0, 0) == 2,
	_match_prefix_regex("oof", "&*of", 0, 0) == 3,
	_match_prefix_regex("f", "+o", 0, 0) == undef,
	_match_prefix_regex("of", "+o", 0, 0) == 1,
	_match_prefix_regex("oof", "+o", 0, 0) == 2,
	_match_prefix_regex("oof", "&+of", 0, 0) == 3,
	_match_prefix_regex("oooofaa", "&*of", 0, 0) == 5,
	_match_prefix_regex("foo", ".", 0, 0) == 1,
	_match_prefix_regex("f", "+.", 0, 0)==1,
	_match_prefix("++1+1++11+111", "", "+", 0) == 13,
	_infix_to_prefix("D+E^5", "^*/+-", index=4),
	_infix_to_prefix("(A+B^C)*D+E^5", "^*/+-", index=12)
]);

//converts infix to prefix using shunting yard algorithm
function _infix_to_prefix(infix, operators, stack="", index=0) = 
	index < 0?
		stack
	: _is_set(infix, operators, index)?
		str(_infix_to_prefix(infix, operators, stack=str(infix[index]), index=index-1), stack)
	: infix[index] == ")"?
		undef
		//_infix_to_prefix(infix, operators, stack=str(stack, infix[index]), index=index-1)
	:
		str(_infix_to_prefix(infix, operators, stack=stack, index=index-1), infix[index])
	;

function _match_prefix_regex(string, regex, string_pos, regex_pos)=
	//INVALID INPUT
	string == undef?
		undef
	: regex == undef?
		undef
	: string_pos == undef?
		undef
	: regex_pos == undef?
		undef
	: string_pos >= len(string)?
		undef
	: regex_pos >= len(regex)?
		undef

	//UNION
	: regex[regex_pos] == "|" ?
		_ensure_defined(_match_prefix_regex(string, regex, string_pos, regex_pos+1),
				_match_prefix_regex(string, regex, string_pos, 
					_match_prefix(regex, "*+?", "|&", regex_pos+1)))

	//KLEENE STAR
	: regex[regex_pos] == "*" ?
		_ensure_defined(
			_match_prefix_regex(string, regex,
				_match_prefix_regex(string, regex, string_pos, regex_pos+1),
				regex_pos),
			string_pos)

	//KLEENE PLUS
	: regex[regex_pos] == "+" ?
		_ensure_defined(
			_match_prefix_regex(string, regex,
				_match_prefix_regex(string, regex, string_pos, regex_pos+1),
				regex_pos),
			_match_prefix_regex(string, regex, string_pos, regex_pos+1))

	//OPTION
	: regex[regex_pos] == "?" ?
		_ensure_defined(_match_prefix_regex(string, regex, string_pos, regex_pos+1),
				string_pos)

	//CONCATENATION
	: regex[regex_pos] == "&" ?	
		_match_prefix_regex(string, regex, 
			_match_prefix_regex(string, regex, string_pos, regex_pos+1), 
			_match_prefix(regex, "*+?", "|&", regex_pos+1))

	//LITERAL
	: string[string_pos] == regex[regex_pos] ?
		string_pos+1

	//WILDCARD
	: regex[regex_pos] == "."?
		string_pos+1

	//NO MATCH
	: 
		undef
	;
	
function _match_prefix(regex, unary, binary, index=0) = 
	index >= len(regex)?
		len(regex)
	: _is_set(regex, unary, index)?
		_match_prefix(regex, unary, binary, index+1)
	: _is_set(regex, binary, index)?
		_match_prefix(regex, unary, binary,  _match_prefix(regex, unary, binary, index+1))
	: 
		index+1
	;

function token(string, index, pos=0) = 
	index == 0?
		_ensure_nonempty(between(string, _token_start(string, pos), _token_end(string, pos)),
				 undef)
	:
		token(string, index-1, _token_end(string, pos))
	;





function _token_start(string, index=0, ignore_space=true) = 
	index >= len(string)?
		undef
	: index == len(string)?
		len(string)
	: _is_set(string, _whitespace, index) && ignore_space?
		_match_set(string, _whitespace, index)
	: //symbol
		index
	;
	

function _token_end(string, index=0, ignore_space=true, tokenize_quotes=true) = 
	index >= len(string)?
		len(string)
	: _is_set(string, _alphanumeric, index) ?
		_match_set(string, _alphanumeric, index)
	: _is_set(string, _whitespace, index) ? (
		ignore_space?
			_token_end(string, _match_set(string, _whitespace, index))
		:
			_match_set(string, _whitespace, index)
	)
	
	: string[index] == "\"" && tokenize_quotes ?
		_match_quote(string, "\"", index+1)
	: string[index] == "'" && tokenize_quotes?
		_match_quote(string, "'", index+1)
	: 
		index+1
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
		_ensure_defined(
			between(string, _match_set(string, _whitespace, 0), 
					_match_set_reverse(string, _whitespace, len(string))),
			""
		)
	;

//echo(_match_set(test, _symbol, 13));

function _match_set(string, set, index) = 
	index >= len(string)?
		len(string)
	: _is_set(string, set, index)?
		_match_set(string, set, index+1)
	: 
		index
	;

function _match_set_reverse(string, set, index) = 
	index <= 0?
		0
	: _is_set(string, set, index-1)?
		_match_set_reverse(string, set, index-1)
	: 
		index
	;

function _match_quote(string, quote_char, index) = 
	index >= len(string)?
		len(string)
	: string[index] == quote_char?
		index
	: string[index] == "\\"? 
		_match_quote(string, quote_char, index+2)
	: 
		_match_quote(string, quote_char, index+1)
	;

//function _match_range(string, minimum, maximum, index) = 



//echo(search(" \t\r\n", "foo "));

//echo(_is_set(test, _symbol, 6));

function _is_set(string, set, index=0) = 
	len(search(string[index],set)) > 0;



//echo(after(test, _split_end(test, " ", 1)));

//echo( _split_end(test, " ", -1));

//echo( _split_end(test, " ", 0));

//echo( between(test, undef, 3) );

function split(string, seperator=" ", index=0, ignore_case = false) = 
	!contains(string, seperator, ignore_case=ignore_case) ?
		string
	: index < 0?
		undef
	: index == 0?
		between(string, 0, find(string, seperator, index))
	:
		between(string, _ensure_defined(find(string, seperator, index-1)+len(seperator), len(string)+1), 
				_ensure_defined(find(string, seperator, index), 		 len(string)+1)) 
	;
	

function contains(string, substring, index=0, ignore_case=false) = 
	find(string, substring, ignore_case=ignore_case) != undef; 



function find(string, goal, index=0, pos=0, ignore_case=false) = 
	len(goal) == 1 && !ignore_case?
		search(goal, after(string, pos), 0)[0][index] + pos + 1
	: index <= 0?
		_find(string, goal, pos, ignore_case=ignore_case)
	: 
		find(string, goal, index-1, 
			pos = _find(string, goal, ignore_case=ignore_case) + len(goal),
			ignore_case=ignore_case)
	;

function _find(string, goal, index=0, ignore_case=false) = 
	string == undef?
		undef
	: goal == undef?
		undef
	: index < 0 || index == undef?
		undef
	: index >= len(string)?
		undef
	: starts_with(string, goal, index, ignore_case)?
		index
	:
		_find(string, goal, index+1, ignore_case)
	;



//echo(starts_with("", ""));

function starts_with(string, start, index=0, ignore_case=false) = 
	equals(	substring(string, index, len(start)), 
		start, 
		ignore_case=ignore_case);



function ends_with(string, end, ignore_case=false) =
	equals(	after(string, len(string)-len(end)-1), 
		end,
		ignore_case=ignore_case)
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

function _transform_case(string, encoded, offset, index=0) = 
	index >= len(string)?
		""
	: len(encoded[index]) <= 0?
		str(substring(string, index, 1),	_transform_case(string, encoded, offset, index+1))
	: 
		str(chr(encoded[index][0]+offset),	_transform_case(string, encoded, offset, index+1))
	;



function join(strings, delimeter) = 
	strings == undef?
		undef
	: strings == []?
		""
	: _join(strings, len(strings)-1, delimeter, 0);

function _join(strings, index, delimeter) = 
	index==0 ? 
		strings[index] 
	: str(_join(strings, index-1, delimeter), delimeter, strings[index]) ;
	



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
	: end <= 0?
		undef
	: end > len(string)?
		after(string, start-1)
	: start > end?
		undef
	: start == end ? 
		"" 
	: 
		str(string[start], between(string, start+1, end))
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
		str(before(string, index-1), string[index-1])
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
		str(string[index+1], after(string, index+1))
	;
	



function _ensure_nonempty(string, replacement) = 
	string == ""?
		replacement
	:
		string
	;

function _ensure_defined(string, replacement) = 
	string == undef?
		replacement
	:
		string
	;
	



function parse_int(string, base=10, i=0, nb=0) = 
	string[0] == "-" ? 
		-1*_parse_int(string, base, 1) 
	: 
		_strToInt(str, base);

function _parse_int(string, base, i=0, nb=0) = 
	i == len(string) ? 
		nb 
	: 
		nb + _parse_int(string, base, i+1, 
				search(string[i],"0123456789ABCDEF")[0]*pow(base,len(string)-i-1));
