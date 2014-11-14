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

//inhereted properties common to all geometric primitives in relativity.scad
// indicates the class(es) to render
$show = "";
$hide = "";
// indicates the class that is either assigned-to or inherited-by an object
$class = "";

//hammard product (aka "component-wise" product) for vectors
function hammard(v1,v2) = [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];


// form repeating patterns through translation
module translated(offset, n=[1]){
	for(i=n)
		translate(offset*i)
			children();
}

// form radially symmetric objects around the z axis
module rotated(offset, n=[1]){
	for(i=n)
		rotate(offset*i)
			children();
}

// form bilaterally symmetric objects using the mirror() function
module mirrored(axes=[0,0,0]){
	mirror(axes)
		children();
		children();
}

module hulled(class=""){
	if(_has_token($class, $show))
	hull()
	assign($show=class)
	children();

	children();
}

// performs the union on objects marked as positive space (i.e. objects where $class = positive), 
// and performs the difference for objects marked as negative space (i.e objects where $class = $negative)
module differed(positive, negative){
	if(_has_token($class, $show))
	difference(){
		assign($show=positive)
			children();
		assign($show=negative)
			children();
	}
}

// performs the intersection on a list of object classes
module intersected(class=""){
	if(_has_token($class, $show))
	intersection(){
		assign($show=positive)
			children();
		assign($show=negative)
			children();
	}
}

// like translate(), but use positions relative to the size of the parent object
// if tilt==true, child objects will also be oriented away from the parent object's center
module align(anchors){
	assign(anchors = len(anchors.x)==undef && anchors.x!= undef? [anchors] : anchors)
	for(anchor=anchors)
	{
		translate(hammard(anchor, $parent_bounds)/2)
		assign($outward = anchor, $inward = -anchor)
			children();
	}
}

// like rotate(), but works by aligning the zaxis to a given vector
module orient(zaxis, roll=0){
	rotate(_orient_angles(zaxis))
	rotate(roll*z)
		children();
}

// duplicates last instance of box/rod/ball in the call stack
// useful for performing hull() or difference() between parent and child 
module parent(size=undef, anchor=center){
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
module box(size, anchor=$inward) {
	assign(size = len(size)==undef && size!= undef? [size,size,size] : size)
	assign( $parent_size = size, 
			$parent_type="box", 
			$parent_bounds=[size.x < indeterminate/2? size.x : 0,
							size.y < indeterminate/2? size.y : 0,
							size.z < indeterminate/2? size.z : 0],
			$inward=center, 
			$outward=center){
		translate(-hammard(anchor, size)/2)
			if(_has_token($class, $show)) cube(size, center=true);
		translate(-hammard(anchor, $parent_bounds)/2)
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module rod(size=[1,1,1], 
			h=indeterminate, d=indeterminate, r=undef, 
			anchor=$inward, orientation=top) {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d<indeterminate-1 || h<indeterminate-1? 
							[d,d,h] : 
						size)
	assign(bounds = _rotate_matrix(_orient_angles(orientation)) * [size.x,size.y,size.z,1])
	assign($parent_size = size, 
			$parent_type="rod",
			$parent_bounds=[abs(bounds.x) < indeterminate/2? abs(bounds.x) : 0,
							abs(bounds.y) < indeterminate/2? abs(bounds.y) : 0,
							abs(bounds.z) < indeterminate/2? abs(bounds.z) : 0],
			$parent_radius=sqrt(pow(h/2,2)+pow(d/2,2)),
			$inward=center, 
			$outward=center){
		translate(-hammard(anchor, [abs(bounds.x),abs(bounds.y),abs(bounds.z)])/2){
			if(_has_token($class, $show))
				orient(orientation) 
				resize(size) 
				cylinder(d=size.x, h=size.z, center=true);
		}
		translate(-hammard(anchor, $parent_bounds)/2)
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module ball(size=[1,1,1], d=undef, r=undef, anchor=$inward) {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d!=undef? 
							[d,d,d] : 
						size)
	assign($parent_size = size, 
			$parent_type="ball", 
			$parent_bounds=[size.x < indeterminate/2? size.x : 0,
							size.y < indeterminate/2? size.y : 0,
							size.z < indeterminate/2? size.z : 0],
			$inward=center, 
			$outward=center ){
		translate(-hammard(anchor, size)/2)
			if(_has_token($class, $show)) resize(size) sphere(d=size.x, center=true);
		translate(-hammard(anchor, $parent_bounds)/2)
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

// string functions


// string functions
function _css_select_all(tag, class, id, selectors, index=0) = 
	token(selectors, " ", index) == undef?		
		true
	: _css_select(string, token(tokens, token_seperator, index)) ?	
		_css_select_all(tag, class, id, selectors, index+1)
	: 
		false
	;
	
function _css_select(tag, class, id, selector, index=0) = 
	selector == "*"?
		true
	: starts_with(selector, "#") ?
		id == after(selector, "#")
	: starts_with(selector, ".") ?
		_has_token(class, after(selector, ".")) ?
	: starts_with(selector, "*")
		id == after(selector, "#") || _has_token(class, after(selector, ".")) || tag == selector
	: 
		tag == selector
	;
//echo(_has_all_tokens("foo bar baz", "foo baz"));
//echo(_has_all_tokens("foo bar baz", "spam baz"));
function _has_all_tokens(string, tokens, string_seperator=" ", token_seperator=" ", index=0) = 
	token(tokens, token_seperator, index) == undef?		
		true						
	: _has_token(string, token(tokens, token_seperator, index), string_seperator) ?	
		_has_all_tokens(string, tokens, string_seperator, token_seperator, index+1)		
	: 
		false
	;

//echo(_has_any_tokens("foo bar baz", "spam baz"));
function _has_any_tokens(string, tokens, seperator=",", index=0) = 
	token(tokens, seperator, index) == undef?		//no more tokens?
		false						//then there's no 
	: _has_token(string, token(tokens, " ", index), " ") ?	//matches
		true						//then 
	: 
		_has_any_tokens(string, tokens, seperator, index+1)//otherwise, try the next token
	;

//echo(_has_token("foo bar baz", "baz"));
function _has_token(string, token, seperator=" ", index=0) = 		
	token(string, seperator, index) == token ? 		//match?
		true						//then I guess we found a token		
	: after(string, seperator, index) == undef ? 		//no more tokens?
		false						//then I guess there aren't any matches
	:							
		_has_token(string, token, seperator, index+1)	//otherwise, try again
	;

//echo(token("foo bar baz  ", " ", 0) == "foo");
//echo(token("foo","", 2));
function token(string, seperator=" ", index=0, ignore_case = false) = 
	index < 0?
		undef
	:
		before(after(string, 	seperator, index-1, ignore_case), 
					seperator, 0, ignore_case);

//echo(replace("foobar spam nOOb", "OO", "u", ignore_case=true));
function replace(string, replaced, replacement, ignore_case=false) = 
	find(string, replaced, ignore_case=ignore_case) != undef?
		replace(_replace(string, replaced, replacement, ignore_case),
					 replaced, replacement, ignore_case)
	:
		string
	;
function _replace(string, replaced, replacement, ignore_case=false) = 
	str(	before(string, replaced, ignore_case=ignore_case), 
		replacement, 
		after(string, replaced, ignore_case=ignore_case));

//echo(before("foo bar baz", index=0));
//echo(before("foo", "", 3));
function before(string, seperator=" ", index=0, ignore_case=false) = 
	string == undef?
		undef
	: index < 0?
		undef
	: find(string, seperator, index, ignore_case) != undef?
		substring(string, 0, find(string, seperator, index, ignore_case))
	:
		string
	;
//echo(after("foo bar baz", index=0));
//echo(after("bar", "",3));
function after(string, seperator=" ", index=0, ignore_case=false) =
	string == undef?
		undef
	: index < 0?
		string
	: find(string, seperator, index, ignore_case) != undef ?
		substring(string, find(string, seperator, index, ignore_case) + len(seperator))
	:
		undef
	;

function contains(this, that, ignore_case=false) = 
	find(this, that, ignore_case=ignore_case) != undef;

//function sed(string, regex, replacement) = 
//function grep(string, regex, index=0)=

//echo(find("foo", "", 2));
function find(string, goal, index=0, ignore_case=false) = 
	string == ""?
		undef
	: len(goal) == 0 && index >= len(string)?
		undef
	: len(goal) == 1 && !ignore_case?
		search(goal, string, 0)[0][index]
	: starts_with(string, goal, ignore_case)?
		index
	: 
		find(substring(string, 1), goal, index+1, ignore_case)
	;

//echo(starts_with("", ""));
function starts_with(string, start, ignore_case=false) = 
	equals(	substring(string, 0, len(start)), 
		start, 
		ignore_case=ignore_case);

function ends_with(string, end, ignore_case=false) =
	equals(	substring(string, len(string)-len(end)), 
		end, 
		ignore_case=ignore_case);

function equals(this, that, ignore_case=false) =
	ignore_case?
		lower(this) == lower(that)
	:
		this==that
	;

//echo(lower("!@#$1234FOOBAR!@#$1234"));
//echo(upper("!@#$1234foobar!@#$1234"));
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
	
function substring(string, start, length=undef) = 
	length == undef? 
		_substring(string, start, len(string)) 
	: 
		_substring(string, start, length+start)
	;
function _substring(string, start, end) = 
	start==end ? 
		"" 
	: 
		str(string[start], _substring(string, start+1, end))
	;
