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
	_strings_version.x * 10000 + _strings_version.y * 100 + _strings_version.z;






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
	

















function relativity_version() =
	[2015, 11, 26];
function relativity_version_num() = 
	relativity_version().x * 10000 + relativity_version().y * 100 + relativity_version().z;
echo(str("relativity.scad ", relativity_version().x, ".", relativity_version().y, ".", relativity_version().z));

if(version_num() < 20150000)
	echo("WARNING: relativity.scad requires OpenSCAD version 2015.03 or higher");


// an arbitrarily large number
// must be finite to allow use in geometric operations
// interaction between objects of indeterminate size results in undefined behavior
indeterminate = 1e6;

// an arbitrarily small number
// must be nonzero to meet the assumptions of the library

infinitesimal = 0.001;

// helper variables for aligning along the z axis
top = [0,0,1];
center=[0,0,0];
bottom = [0,0,-1];
up = [0,0,1];
down = [0,0,-1];
x = [1,0,0];
y = [0,1,0];
z = [0,0,1];

// properties of the last instance of rod/box/ball in the call stack
$parent_size=[0,0,0];
$parent_bounds=[0,0,0];
$parent_radius=0;
$parent_type="space";
// a stack of classes used by all ancestors
$_ancestor_classes = [];
_token_regex_ignore_dash = _parse_rx("(\\w|-)+|\\S");

//inhereted properties common to all geometric primitives in relativity.scad
// indicates the class(es) to render
$_show = "*";
// indicates the class that is either assigned-to or inherited-by an object
$class = [];
// indicates the absolute position of a primitive
$position = [0,0,0];
// a vector indicating the direction of a parent object		
$inward = [0,0,0];		
$outward = [0,0,0];

//hadamard product (aka "component-wise" product) for vectors
function hadamard(v1,v2) = [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];

// form repeating patterns through translation
module translated(offset, n=[1], class="*"){
	show(class)
	for(i=n)
		_translate(offset*i)
			children();
	hide(class)
		children();
}

// form radially symmetric objects around the z axis
module rotated(offset, n=[1], class="*"){
	show(class)
	for(i=n)
		rotate(offset*i)
			children();
	hide(class)
		children();
}

// form bilaterally symmetric objects using the mirror() function
module mirrored(axes=[0,0,0], class="*"){
	show(class)
	mirror(axes)
		children();
	show(class)
		children();
	hide(class)
		children();
}

module attach(class){
	_assign($_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)))
	_assign($_show=["and", $_show, ["descendant", "*", _sizzle_parse(class)]])
	children();
}

module show(class="*"){
	_assign($_show=["and", $_show, _sizzle_parse(class)])
	children();
}

module hide(class="*"){
	_assign($_show=["and", $_show, ["not", _sizzle_parse(class)]])
	children();
}

module colored(color, class="*"){
	_assign($_show=["and", $_show, _sizzle_parse(class)])
	color(color)
	children();
	
	hide(class)
	children();
}

module scaled(v=[0,0,0], class="*"){
	_assign($_show=["and", $_show, _sizzle_parse(class)])
	scale(v)
	children();
	
	hide(class)
	children();
}

module resized(newsize, class="*"){
	_assign($_show=["and", $_show, _sizzle_parse(class)])
	resize(newsize)
	children();
	
	hide(class)
	children();
}

module hulled(class="*"){
    _assign($_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)))
	if(_sizzle_engine($_ancestor_classes, $_show))
	hull()
	_assign($_show=_sizzle_parse(class))
	children();
	
	hide(class)
	children();
}

// performs the union on objects marked as positive space (i.e. objects where $class = positive), 
// and performs the difference for objects marked as negative space (i.e objects where $class = $negative)
module differed(negative, positive="*", unaffected=undef){
	_positive = _sizzle_parse(positive);
	_negative = _sizzle_parse(negative);
	_unaffected = unaffected != undef? 
        _sizzle_parse(unaffected) : ["not", ["or", _positive, _negative]];
    
    _assign($_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)))
    if(_sizzle_engine($_ancestor_classes, $_show))
    difference(){
        _assign($_show = _positive)
            children();
        _assign($_show = _negative)
            children();
    }
    _assign($_show=["and", $_show, _unaffected])
        children();
}

// performs the intersection on a list of object classes
module intersected(class1, class2, unaffected=undef){
	class1 = _sizzle_parse(class1);
	class2 = _sizzle_parse(class2);
	unaffected = unaffected != undef? 
		unaffected : ["not", ["or", class1, class2]];
    
    _assign($_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)))
    if(_sizzle_engine($_ancestor_classes, $_show))
    intersection(){
        _assign($_show = class1)
            children();
        _assign($_show = class2)
            children();
    }
    _assign($_show=["and", $_show, unaffected])
        children();
}

// like translate(), but use positions relative to the size of the parent object
// if tilt==true, child objects will also be oriented away from the parent object's center
module align(anchors, bounds="box"){
	anchors = len(anchors.x)==undef && anchors.x!= undef? [anchors] : anchors;
	for(anchor=anchors)
	{
		if(bounds == "box")
		_translate(hadamard(anchor, $parent_bounds)/2)
		_assign($outward = anchor, $inward = -anchor)
			children();
		
		if(bounds == "ball"){
			_anchor = _rotate_matrix(_orient_angles(anchor)) * [0,0,1,1];
			_translate(hadamard(_anchor, $parent_bounds)/2)
			_assign($outward = anchor, $inward = -anchor)
				children();
		}
	}
}

// like rotate(), but works by aligning the zaxis to a given vector
module orient(zaxes, roll=0){
	zaxes = len(zaxes.x) == undef && zaxes.x != undef? [zaxes] : zaxes;
	for(zaxis=zaxes)
	{
		rotate(_orient_angles(zaxis))
		rotate(roll*z)
			children();
	}
}

// duplicates last instance of box/rod/ball in the call stack
// useful for performing hull() or difference() between parent and child 
module parent(size=undef, anchor=center){
	echo("WARNING: parent() module is depreciated. Please use CSG operators such as differed() and hulled().");
	size = size==undef? $parent_size : size;
	if($parent_type=="box") 
		box(size, anchor=anchor)
			children();
	else if($parent_type=="rod")
		rod(size, anchor=anchor)
			children();
	else if($parent_type=="ball")
		ball(size, anchor=anchor)
			children();
}

// wrapper for cube with enhanced centering functionality and cascading children
module box(	size=[1,1,1], 
			h=undef, d=undef, r=undef, 
			anchor=$inward, bounds="box") {
    
	d = r!=undef? 2*r : d;
	size =	len(size)==undef && size!= undef? 
                [size,size,size] 
            : d != undef && h == undef? 
                [d,d,indeterminate] 
            : d == undef && h != undef? 
                [indeterminate, indeterminate, h] 
            : d != undef && h != undef?
                [d,d,h] 
            : 
                size
            ;
                
	_assign($parent_size = size, 
			$parent_type="box", 
			$parent_bounds=[size.x < indeterminate/2? size.x : 0,
							size.y < indeterminate/2? size.y : 0,
							size.z < indeterminate/2? size.z : 0],
			$parent_radius=sqrt(pow(size.x/2,2) + pow(size.y/2,2) + pow(size.z/2,2)),
			$_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)),
			$inward=center, 
			$outward=center){
		_translate(-hadamard(anchor, $parent_size)/2)
			if(_sizzle_engine($_ancestor_classes, $_show)) cube($parent_size, center=true);
		_translate(-hadamard(anchor, $parent_bounds)/2)
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module rod(	size=[1,1,1], 
			h=undef, d=undef, r=undef, 
			anchor=$inward, orientation=top, bounds="rod") {
                
	d = r!=undef? 2*r : d;
	size =	len(size)==undef && size!= undef? 
                [size,size,size] 
            : d != undef && h == undef? 
                [d,d,indeterminate] 
            : d == undef && h != undef? 
                [indeterminate, indeterminate, h] 
            : d != undef && h != undef?
                [d,d,h] 
            : 
                size
            ;
    _bounds = _rotate_matrix(_orient_angles(orientation)) * [size.x,size.y,size.z,1];
                
	_assign($parent_size = size, 
			$parent_type="rod",
			$parent_bounds=[abs(_bounds.x) < indeterminate/2? abs(_bounds.x) : 0,
							abs(_bounds.y) < indeterminate/2? abs(_bounds.y) : 0,
							abs(_bounds.z) < indeterminate/2? abs(_bounds.z) : 0],
			$parent_radius=sqrt(pow(h/2,2)+pow(d/2,2)),
			$_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)),
			$inward=center, 
			$outward=center){
		_translate(-hadamard(anchor, [abs(_bounds.x),abs(_bounds.y),abs(_bounds.z)])/2){
			if(_sizzle_engine($_ancestor_classes, $_show))
				orient(orientation) 
				resize($parent_size) 
				cylinder(d=$parent_size.x, h=$parent_size.z, center=true);
		}
		_translate(-hadamard(anchor, $parent_bounds)/2)
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module ball(size=[1,1,1], 
			h=undef, d=undef, r=undef, 
			anchor=$inward, bounds="ball") {
	//diameter is used internally to simplify the maths
	d = r!=undef? 2*r : d;
	size =	len(size)==undef && size!= undef? 
                [size,size,size] 
            : d != undef && h == undef? 
                [d,d,d] 
            : d == undef && h != undef? 
                [h, h, h] 
            : d != undef && h != undef?
                [d,d,h] 
            : 
                size
            ;
                
	_assign($parent_size = size, 
			$parent_type="ball", 
			$parent_bounds=[size.x < indeterminate/2? size.x : 0,
							size.y < indeterminate/2? size.y : 0,
							size.z < indeterminate/2? size.z : 0],
			$parent_radius=sqrt(pow(size.x/2,2) + pow(size.y/2,2) + pow(size.z/2,2)),
			$_ancestor_classes = _push($_ancestor_classes, _tokenize($class, _token_regex_ignore_dash)),
			$inward=center, 
			$outward=center ){
		_translate(-hadamard(anchor, $parent_size)/2)
			if(_sizzle_engine($_ancestor_classes, $_show)) 
                resize($parent_size) 
                sphere(d=$parent_size.x, center=true);
		_translate(-hadamard(anchor, $parent_bounds)/2)
			children();
	}
}




module _assign(){
    children();
}

//matrix rotation functions
function _rotate_x_matrix(a)=
							[[1,0,0,0], 
                      [0,cos(a),-sin(a),0], 
                      [0,sin(a),cos(a),0], 
                      [0,0,0,1]]; 

function _rotate_y_matrix(a)=
							[[cos(a),0,sin(a),0], 
                      [0,1,0,0], 
                      [-sin(a),0,cos(a),0], 
                      [0,0,0,1]]; 

function _rotate_z_matrix(a)=
							[[cos(a),-sin(a),0,0], 
                      [sin(a),cos(a),0,0], 
                      [0,0,1,0], 
                      [0,0,0,1]]; 

function _rotate_matrix(a)=_rotate_z_matrix(a.z)*_rotate_y_matrix(a.y)*_rotate_x_matrix(a.x);

function _orient_angles(zaxis)=
				[-asin(zaxis.y / norm(zaxis)),
		  		 atan2(zaxis.x, zaxis.z),
		  		 0];

//private wrapper for translate(), tracks the position of children using a special variable, $position
module _translate(offset){
	_assign($position = $position + offset)
	translate(offset)
	children();
}
	
        
//echo(_sizzle_parse("not(foo,bar)"));
//echo(_sizzle_parse("baz"));
//echo(_sizzle_parse("bar baz"));
//echo(_sizzle_engine([["baz", []],[]], _sizzle_parse("baz")));
//echo(_sizzle_engine([["baz", []],[]], _sizzle_parse("foo,bar")));
//echo(_sizzle_engine([["baz", []],[]], _sizzle_parse("not(foo,bar)")));
//echo(_sizzle_engine([["bar", []],[]], _sizzle_parse("not(foo,bar)")));
//echo(_sizzle_engine([["baz", []], [["bar", []],[]]], _sizzle_parse("bar baz")));
function _sizzle_engine_ancestor(ancestors, sizzle) = 
        //return true if any ancestor matches the sizzle
        len(ancestors) <= 0?
            false
        : _sizzle_engine(_push([], ancestors[0]), sizzle)?
            true
        : 
            _sizzle_engine_ancestor(_pop(ancestors), sizzle)
        ;
function _sizzle_engine(classes, sizzle) = 
	//is sizzle a string?
	sizzle == str(sizzle)?
		sizzle != "" && (sizzle == "*" || _has_token(classes[0], sizzle))
	//is sizzle a known operator?
	: sizzle[0] == "or"?
		_sizzle_engine(classes, sizzle[1]) || _sizzle_engine(classes, sizzle[2])
	: sizzle[0] == "not"?
		!_sizzle_engine(classes, sizzle[1])
	: sizzle[0] == "and"?
		_sizzle_engine(classes, sizzle[1]) && _sizzle_engine(classes, sizzle[2])
	: sizzle[0] == "descendant"? // parameters: descendant, ancestor
		_sizzle_engine(_push([], classes[0]), sizzle[1]) && _sizzle_engine_ancestor(_pop(classes), sizzle[2])
	: sizzle[0] == "child"? // parameters: child, parent
		_sizzle_engine(_push([], classes[0]), sizzle[1]) && _sizzle_engine_ancestor(_push([], _pop(classes)[0]), sizzle[2])
	: //invalid syntax
		false
	;

_sizzle_token_regex = _parse_rx("(\\w|_|-)+|\\S|\\s+");
function _sizzle_parse(sizzle) = 
	sizzle == ""?
		""
	: 
		_sizzle_DFA(
			_tokenize(sizzle, _sizzle_token_regex)
		)
    ;

//echo(_sizzle_DFA(_tokenize("not(foo,bar)")));
//echo(_sizzle_DFA(_tokenize("foo,bar baz")));
//echo(_sizzle_DFA(_tokenize("foo bar,baz")));
//echo(_sizzle_DFA(_tokenize("foo.bar,baz")));
//simulates a deterministic finite automaton that parses tokenized sizzle strings
function _sizzle_DFA(in, ops=[], args=[], pos=0) = 
	pos >= len(in)?
		len(ops) <= 0?
			args[0]
		:
			_sizzle_DFA(in,	_pop(ops),			_push_sizzle_op(args, ops[0]), pos)
	:in[pos] == "not"?
			_sizzle_DFA(in,	_push(ops, "not"),	args, 					pos+1)
	:in[pos] == ","?
			_sizzle_DFA(in,	_push(ops, "or"),	args, 					pos+1)
	:in[pos] == "."?
			_sizzle_DFA(in,	_push(ops, "and"),	args, 					pos+1)
	:in[pos] == ">"?
			_sizzle_DFA(in,	_push(ops, "child"),args, 					pos+1)
    :trim(in[pos]) == ""?
			_sizzle_DFA(in,	_push(ops, "descendant"),args, 				pos+1)
	:in[pos] == "("?
			_sizzle_DFA(in,	_push(ops, "("),	args, 					pos+1)
	:in[pos] == ")"?
		ops[0] == "("?
			_sizzle_DFA(in,	_pop(ops),			args, 					pos+1)
		:
			_sizzle_DFA(in,	_pop(ops),			_push_sizzle_op(args, ops[0]), pos)
	:
			_sizzle_DFA(in,	ops,                _push(args, in[pos]), 	pos+1)
	;
        
function _push_sizzle_op(args, op) = 
	op == "or" || op == "and" || op == "descendant" || op == "child"?
		_push(
			_pop(args, 2),
			[op, args[0], args[1][0]]
		)
	:			//unary
		_push(
			_pop(args),
			[op, args[0]]
		)
	;
	
//echo(_has_token(["baz",[]], "baz"));
//echo(_has_token(tokenize("foo bar baz"), "baz"));
function _has_token(tokens, token) = 
	tokens == undef || len(tokens) <= 0?
		false
	: 
        any([for (i = [0:len(tokens)-1]) tokens[i] == token])
	;	



















