function relativity_version() =
	[2014, 2, 14];
function relativity_version_num() = 
	relativity_version().x * 10000 + relativity_version().y * 100 + relativity_version().z;
echo(str("relativity.scad ", relativity_version().x, ".", relativity_version().y, ".", relativity_version().z));

if(version_num() < 20140300)
	echo("WARNING: relativity.scad requires OpenSCAD version 2013.03 or higher");


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

//inhereted properties common to all geometric primitives in relativity.scad
// indicates the class(es) to render
$_show = "*";
// indicates the class that is either assigned-to or inherited-by an object
$class = [];

//hadamard product (aka "component-wise" product) for vectors
function hadamard(v1,v2) = [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];


// form repeating patterns through translation
module translated(offset, n=[1], class="*"){
	show(class)
	for(i=n)
		translate(offset*i)
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
	assign($_ancestor_classes = _push($_ancestor_classes, _stack_tokenize($class)))
	assign($_show=["and", $_show, ["descendant", "*", _sizzle_parse(class)]])
	children();
}

module show(class="*"){
	assign($_show=["and", $_show, _sizzle_parse(class)])
	children();
}

module hide(class="*"){
	assign($_show=["and", $_show, ["not", _sizzle_parse(class)]])
	children();
}

module hulled(class="*"){
	if(_matches_sizzle($_ancestor_classes, $_show))
	hull()
	assign($_show=_sizzle_parse(class))
	children();
	
	hide(class)
	children();
}

// performs the union on objects marked as positive space (i.e. objects where $class = positive), 
// and performs the difference for objects marked as negative space (i.e objects where $class = $negative)
module differed(negative, positive="*", unaffected=undef){
	assign(	_positive = _sizzle_parse(positive) )
	assign( _negative = _sizzle_parse(negative) )
	assign( _unaffected = unaffected != undef? 
		_sizzle_parse(unaffected) : ["not", ["or", _positive, _negative]]){
		if(_matches_sizzle($_ancestor_classes, $_show))
		difference(){
			assign($_show = _positive)
				children();
			assign($_show = _negative)
				children();
		}
		assign($_show=["and", $_show, _unaffected])
			children();
	}
}

// performs the intersection on a list of object classes
module intersected(class1, class2, unaffected=undef){
	assign(	class1 = _sizzle_parse(class1),
		class2 = _sizzle_parse(class2))
	assign( unaffected = unaffected != undef? 
		unaffected : ["not", ["or", class1, class2]]){
		if(_matches_sizzle($_ancestor_classes, $_show))
		intersection(){
			assign($_show = class1)
				children();
			assign($_show = class2)
				children();
		}
		assign($_show=["and", $_show, unaffected])
			children();
	}
}

// like translate(), but use positions relative to the size of the parent object
// if tilt==true, child objects will also be oriented away from the parent object's center
module align(anchors){
	assign(anchors = len(anchors.x)==undef && anchors.x!= undef? [anchors] : anchors)
	for(anchor=anchors)
	{
		translate(hadamard(anchor, $parent_bounds)/2)
		assign($outward = anchor, $inward = -anchor)
			children();
	}
}

// like rotate(), but works by aligning the zaxis to a given vector
module orient(zaxes, roll=0){
	assign(zaxes = len(zaxes.x) == undef && anchors.x != undef? [zaxes] : zaxes)
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
	assign(size = size==undef? $parent_size : size)
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
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d != undef && h == undef? 
							[d,d,indeterminate] : 
						d == undef && h != undef? 
							[indeterminate, indeterminate, h] : 
						d != undef && h != undef?
							[d,d,h] :
						size)
	assign( $parent_size = size, 
			$parent_type="box", 
			$parent_bounds=[size.x < indeterminate/2? size.x : 0,
							size.y < indeterminate/2? size.y : 0,
							size.z < indeterminate/2? size.z : 0],
			$parent_radius=sqrt(pow(size.x/2,2) + pow(size.y/2,2) + pow(size.z/2,2)),
			$_ancestor_classes = _push($_ancestor_classes, _stack_tokenize($class)),
			$inward=center, 
			$outward=center){
		translate(-hadamard(anchor, size)/2)
			if(_matches_sizzle($_ancestor_classes, $_show)) cube(size, center=true);
		translate(-hadamard(anchor, $parent_bounds)/2)
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module rod(	size=[1,1,1], 
			h=undef, d=undef, r=undef, 
			anchor=$inward, orientation=top, bounds="rod") {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d != undef && h == undef? 
							[d,d,indeterminate] : 
						d == undef && h != undef? 
							[indeterminate, indeterminate, h] : 
						d != undef && h != undef?
							[d,d,h] :
						size)
	assign(_bounds = _rotate_matrix(_orient_angles(orientation)) * [size.x,size.y,size.z,1])
	assign($parent_size = size, 
			$parent_type="rod",
			$parent_bounds=[abs(_bounds.x) < indeterminate/2? abs(_bounds.x) : 0,
							abs(_bounds.y) < indeterminate/2? abs(_bounds.y) : 0,
							abs(_bounds.z) < indeterminate/2? abs(_bounds.z) : 0],
			$parent_radius=sqrt(pow(h/2,2)+pow(d/2,2)),
			$_ancestor_classes = _push($_ancestor_classes, _stack_tokenize($class)),
			$inward=center, 
			$outward=center){
		translate(-hadamard(anchor, [abs(_bounds.x),abs(_bounds.y),abs(_bounds.z)])/2){
			if(_matches_sizzle($_ancestor_classes, $_show))
				orient(orientation) 
				resize(size) 
				cylinder(d=size.x, h=size.z, center=true);
		}
		translate(-hadamard(anchor, $parent_bounds)/2)
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module ball(size=[1,1,1], 
			h=undef, d=undef, r=undef, 
			anchor=$inward, bounds="ball") {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d != undef && h == undef? 
							[d,d,d] : 
						d == undef && h != undef? 
							[h,h,h] : 
						d != undef && h != undef?
							[d,d,h] :
						size)
	assign($parent_size = size, 
			$parent_type="ball", 
			$parent_bounds=[size.x < indeterminate/2? size.x : 0,
							size.y < indeterminate/2? size.y : 0,
							size.z < indeterminate/2? size.z : 0],
			$parent_radius=sqrt(pow(size.x/2,2) + pow(size.y/2,2) + pow(size.z/2,2)),
			$_ancestor_classes = _push($_ancestor_classes, _stack_tokenize($class)),
			$inward=center, 
			$outward=center ){
		translate(-hadamard(anchor, size)/2)
			if(_matches_sizzle($_ancestor_classes, $_show)) resize(size) sphere(d=size.x, center=true);
		translate(-hadamard(anchor, $parent_bounds)/2)
			children();
	}
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

function _matches_sizzle(classes, sizzle) = 
	_sizzle_engine(classes, sizzle);
	
        
//echo(_stack_tokenize("baz"));
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
	//is sizzle empty?
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

function _sizzle_parse(sizzle) = 
	sizzle == ""?
		""
	: 
		_sizzle_DFA(
			_stack_tokenize(sizzle, ignore_space=false)
		);

//echo(_sizzle_DFA(_stack_tokenize("not(foo,bar)")));
//echo(_sizzle_DFA(_stack_tokenize("foo,bar baz")));
//echo(_sizzle_DFA(_stack_tokenize("foo bar,baz")));
//echo(_sizzle_DFA(_stack_tokenize("foo.bar,baz")));
//simulates a deterministic finite automaton that parses tokenized sizzle strings
function _sizzle_DFA(in, ops=[], args=[]) = 
	len(in) <= 0?
		len(ops) <= 0?
			args[0]
		:
			_sizzle_DFA(in,		_pop(ops),		_push_sizzle_op(args, ops[0]))
	:in[0] == "not"?
			_sizzle_DFA(_pop(in),	_push(ops, "not"),	args)
	:in[0] == ","?
			_sizzle_DFA(_pop(in),	_push(ops, "or"),	args)
	:in[0] == "."?
			_sizzle_DFA(_pop(in),	_push(ops, "and"),	args)
   :trim(in[0]) == ""?
			_sizzle_DFA(_pop(in),	_push(ops, "descendant"),args)
	:in[0] == "("?
			_sizzle_DFA(_pop(in),	_push(ops, "("),		args)
	:in[0] == ")"?
		ops[0] == "("?
			_sizzle_DFA(_pop(in),	_pop(ops),			args)
		:
			_sizzle_DFA(in,		_pop(ops),				_push_sizzle_op(args, ops[0]))
	:
			_sizzle_DFA(_pop(in),	ops,                _push(args, in[0]))
	;
        
function _push_sizzle_op(args, op) = 
	op == "or" || op == "and" || op == "descendant"?
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
//echo(_has_token(_stack_tokenize("foo bar baz"), "baz"));
function _has_token(tokens, token) = 
	len(tokens) <= 0?
		false
	: tokens[0] == token?
		true
	: 
		_has_token(_pop(tokens), token)
	;	

//returns a stack representing the tokenization of an input string
//stacks are used due to limitations in OpenSCAD when processing lists
//stacks are represented through nested right associative lists
//echo(_stack_tokenize("not(foo)"));
//echo(_stack_tokenize("foo bar baz  "));
function _stack_tokenize(string, pos=0, ignore_space=true) = 
	pos >= len(string)?
		[]
	:
		_push(	
			_stack_tokenize(string, 
				_token_end(string, pos, token_characters=str(_alphanumeric, "_-"), ignore_space=ignore_space), 
				ignore_space=ignore_space),
			between(string, 
				_token_start(string, pos, ignore_space=ignore_space), 
				_token_end(string, pos, token_characters=str(_alphanumeric, "_-"), ignore_space=ignore_space)
			)
		)
	;



_digit = "0123456789";
_lowercase = "abcdefghijklmnopqrstuvwxyz";
_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
_letter = str(_lowercase, _uppercase);
_alphanumeric = str(_letter, _digit);
_variable_safe = str(_alphanumeric, "_");
_whitespace = " \t\r\n";
_nonsymbol = str(_alphanumeric, _whitespace);

_regex_ops = "?*+&|";





function grep(string, pattern, index=0, ignore_case=false) = 		//string
	_between_range(string, _index_of_regex(string, _parse_rx(pattern), index, ignore_case=ignore_case));





function replace(string, replaced, replacement, ignore_case=false, regex=false) = 	//string
	regex?
		_replace_regex(string, _parse_rx(replaced), replacement, ignore_case=ignore_case)
	: string == undef?
		undef
	: pos >= len(string)?
		""
	: contains(string, replaced, ignore_case=ignore_case)?
		str(	before(string, index_of(string, replaced, ignore_case=ignore_case)),
			replacement,
			replace(after(string, index_of(string, replaced, ignore_case=ignore_case)+len(replaced)-1), 
				replaced, replacement, ignore_case=ignore_case)
		)
	: 
		string
	;
function _replace_regex(string, pattern, replacement, ignore_case=false) = 	//string
	string == undef?
		undef
	: pos >= len(string)?
		""
	: 
		_replace_between_range(string, pattern, replacement, 
			_index_of_regex(string, pattern, ignore_case=ignore_case),
			ignore_case = ignore_case
		)
	;
function _replace_between_range(string, pattern, replacement, range, ignore_case=false) = 
	range != undef?
		str(	before(string, range.x),
			replacement,
			_replace_regex(after(string, range.y-1), 
				pattern, replacement,
				ignore_case=ignore_case)
		)
	: 
		string
	;




function split(string, seperator=" ", index=0, pos=0, ignore_case = false, regex=false) = 
	regex?
		_split_regex(string, _parse_rx(seperator), index, ignore_case=ignore_case)
	: index < 0?
		undef
	: index == 0?
		between(string, pos, 
			_null_coalesce(	_index_of_first(string, seperator, pos=pos, ignore_case=ignore_case), 
					len(string)+1))
	:
		split(string, seperator, 
			index-1,
			_null_coalesce(	_index_of_first(string, seperator, pos=pos, ignore_case=ignore_case)+len(seperator), 
					len(string)+1),
			ignore_case=ignore_case)
	;
function _split_regex(string, pattern, index, pos=0, ignore_case=false) =
	index < 0?
		undef
	: index == 0?
		between(string, pos, 
			_null_coalesce(	_index_of_first_regex(string, pattern, pos=pos, ignore_case=ignore_case).x, 
					len(string)+1))
	:
		_split_regex(string, pattern, 
			index-1, 
			_null_coalesce(	_index_of_first_regex(string, pattern, pos=pos, ignore_case=ignore_case).y, 
					len(string)+1), 
			ignore_case=ignore_case)
	;




function contains(string, substring, ignore_case=false, regex=false) = 
	regex?
		_contains_regex(string, _parse_rx(substring), ignore_case=ignore_case)
	:
		index_of(string, substring, ignore_case=ignore_case) != undef
	; 
function _contains_regex(string, pattern, ignore_case=false) = 			//bool		
	_index_of_regex(string, pattern, ignore_case=ignore_case) != undef;
	


function index_of(string, pattern, index=0, pos=0, ignore_case=false, regex=false) = 
	regex?
		_index_of_regex(string, _parse_rx(pattern), index, ignore_case=ignore_case)
	: len(pattern) == 1 && !ignore_case?
		search(pattern, after(string, pos), 0)[0][index] + pos + 1
	: index <= 0?
		_index_of_first(string, pattern, pos, ignore_case=ignore_case)
	: 
		index_of(string, pattern, index-1, 
			pos = _index_of_first(string, pattern, ignore_case=ignore_case) + len(pattern),
			ignore_case=ignore_case)
	;

function _index_of_first(string, pattern, pos=0, ignore_case=false, regex=false) = 
	string == undef?
		undef
	: pattern == undef?
		undef
	: pos < 0 || pos == undef?
		undef
	: pos >= len(string)?
		undef
	: starts_with(string, pattern, pos, ignore_case=ignore_case)?
		pos
	:
		_index_of_first(string, pattern, pos+1, ignore_case=ignore_case)
	;
function _index_of_regex(string, pattern, index=0, pos=0, ignore_case=false) = 		//[start,end]
	index == 0?
		_index_of_first_regex(string, pattern, pos, ignore_case=ignore_case)
	:
		_index_of_regex(string, pattern, 
			index = index-1,
			pos = _index_of_first_regex(string, pattern, index=0, pos=pos, ignore_case=ignore_case).y,
			ignore_case=ignore_case)
	;
function _index_of_first_regex(string, pattern, pos=0, ignore_case=false) =
	pos >= len(string)?
		undef
	: _coalesce_on([pos, _match_parsed_rx(string, pattern, pos, ignore_case=ignore_case)], 
		[pos, undef],
		_index_of_first_regex(string, pattern, pos+1, ignore_case=ignore_case));





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
			
			
	: _is_in(rx[i], _regex_ops)?
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
	(!_is_in(regex[i-1], "|(") || regex[i-2] == "\\");
	
function _can_shunt(stack, op) = 
	stack[0] == "(" || 
	len(stack) <= 0 || 
	_precedence(op, _regex_ops) < _precedence(stack[0], _regex_ops);
	
function _push_rx_op(stack, op) = 
	_is_in(op[0], "[?*+")? // is unary?
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
		_is_in(string[string_pos], _digit)?
			string_pos+1
		: 
			undef
	: regex == "\\s"?
		_is_in(string[string_pos], _whitespace)?
			string_pos+1
		: 
			undef
	: regex == "\\w"?
		_is_in(string[string_pos], _alphanumeric)?
			string_pos+1
		: 
			undef
	: regex == "\\D"?
		!_is_in(string[string_pos], _digit)?
			string_pos+1
		: 
			undef
				
	: regex == "\\S"?
		!_is_in(string[string_pos], _whitespace)?
			string_pos+1
		: 
			undef
	: regex == "\\W"?
		!_is_in(string[string_pos], _alphanumeric)?
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

function token(string, index, pos=0) = 
	index == 0?
		_coalesce_on(between(string, _token_start(string, pos), _token_end(string, pos)),
				"",
				undef)
	:
		token(string, index-1, _token_end(string, pos))
	;

function _token_start(string, pos=0, ignore_space=true) = 
	pos >= len(string)?
		undef
	: pos == len(string)?
		len(string)
	: _is_in(string[pos], _whitespace) && ignore_space?
		_match_set(string, _whitespace, pos)
	: //symbol
		pos
	;
	

function _token_end(string, pos=0, token_characters=_variable_safe, ignore_space=true, tokenize_quotes=true) = 
	pos >= len(string)?
		len(string)
	: _is_in(string[pos], token_characters) ?
		_match_set(string, token_characters, pos)
	: _is_in(string[pos], _whitespace) ? (
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
	_null_coalesce(
		_match_repetition(string, regex, min_reps-1, max_reps-1, 
			_match_parsed_rx(string, regex, pos, ignore_case=ignore_case)
			, ignore_case=ignore_case),
		(min_reps== undef || min_reps <= 0) && (max_reps == undef || max_reps >= 0)?
			pos
		: 
			undef
	);
	
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
	
function _is_in_range(char, min_char, max_char) = 
	search(char, _alphanumeric,0)[0][0] >= search(min_char, _alphanumeric,0)[0][0] &&
	search(char, _alphanumeric,0)[0][0] <= search(max_char, _alphanumeric,0)[0][0];

function _match_set(string, set, pos) = 
	pos >= len(string)?
		len(string)
	: _is_in(string[pos], set )?
		_match_set(string, set, pos+1)
	: 
		pos
	;

function _match_set_reverse(string, set, pos) = 
	pos <= 0?
		0
	: _is_in(string[pos-1], set)?
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


// quicker in theory, but slow in practice due to generated warnings
//function _is_in(string, set, index=0) = 
//	len(search(string[index],set)) > 0;
function _is_in(char, string, index=0, ignore_case=false) = 
	char == undef?
		false
	: ignore_case?
		_is_in(lower(char), lower(string))
	: index >= len(string)?
		false
	: char == string[index]?
		true
	:
		_is_in(char, string, index+1)
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
	
function reverse(string, i=0) = 
	string == undef?
		undef
	: len(string) <= 0?
		""
	: i <= len(string)-1?
		str(reverse(string, i+1), string[i])
	:
		"";

function substring(string, start, length=undef) = 
	length == undef? 
		between(string, start, len(string)) 
	: 
		between(string, start, length+start)
	;

function _between_range(string, vector) = 
	vector == undef?
		undef
	: 
		between(string, vector.x, vector.y)
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
	
