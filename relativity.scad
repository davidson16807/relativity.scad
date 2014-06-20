
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
x = [1,0,0];
y = [0,1,0];
z = [0,0,1];

// size of the last instance of rod/box/ball in the call stack
$parent_size=[0,0,0];
// name of the last instance of rod/box/ball in the call stack
$parent_type="space";

//element-wise multiplication for vectors
function mult(v1,v2) = [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];


// form repeating patterns through translation
module translated(offset, n=[0:1]){
	for(i=n)
		translate(offset*i)
			children();
}

// form radially symmetric objects around the z axis
module rotated(offset, n=[0:1]){
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


// like bridged(), but includes child modules in the render
module bridged(){
	difference(){
		hull() children();
		for (i = [0 : $children-1])
			hull(){
				translate([0,0,infinitesimal])  children(i);
				translate([0,0,-infinitesimal]) children(i);
			}
	}
	children();
}
// like hull(), but excludes the space around component parts to allow for combining detailed geometries
module bridge(){
	difference(){
		hull() children();
		for (i = [0 : $children-1])
			hull(){
				translate([0,0,infinitesimal])  children(i);
				translate([0,0,-infinitesimal]) children(i);
			}
	}
}

module embed(){
	difference(){
		children(0);
		if ($children > 1)
		for (i = [1 : $children-1])
			hull(){
				translate([0,0,infinitesimal])  children(i);
				translate([0,0,-infinitesimal]) children(i);
			}
	}
	for (i = [1 : $children-1])
		children(i);
}

//like difference(), but removes any overhang that may obstruct attempts to mill or print the resulting object
module mill(depth=-indeterminate){
	difference(){
		children(0);
		if($children > 1)
		for(i=[1:$children-1])
			hull(){
				translate([0,0,depth+2*indeterminate])
					children(i);
				translate([0,0,depth])
					children(i);
			}
	}
}
// like project(), but returns a 3d object of given height
// useful for forming reliable beds for printed objects
module bed(cut, height, center=false){
	linear_extrude(height=height, center=center) 
	projection(cut=cut)
		children();
}
// slices the object around its bed
// also useful for forming beds
module slice(height){
	intersection(){
		box([indeterminate, indeterminate, height]);
		children();
	}
}

// hollows out object 
// the resulting object has a thickness of n
// useful for conserving on plastic
module hollow(n){
	difference(){
		children();
		translate([0,0,infinitesimal])  erode(n)children();
		translate([0,0,-infinitesimal]) erode(n) children();
	}
}
// forms a holder for an object along the xy plane 
// the holder has a thickness of n
// useful for interfacing with vitamins
module wrap(n){
	difference(){
		hull() buffer(n) children();
		translate([0,0,infinitesimal])  children();
		translate([0,0,-infinitesimal]) children();
	}
}

// opposite of buffer, subtracts from perimeter along the xy plane
// performs minkowski subtraction between children and a cylinder of set radius around the z axis
module erode(n){
	minkowski_difference(){
		children();
		cylinder(r=n, h=infinitesimal, center=true);
	} 
}
// buffers perimeter along the xy plane
// performs minkowski addition between children and a cylinder of set radius around the z axis
module buffer(n){
	minkowski()
	{
		children();
		cylinder(r=n, h=infinitesimal, center=true);
	}
}
// performs minkowski subtraction - 
// given two polygons, subtracts the second from the perimeter of the first
// very useful for forming inverse fillets
module minkowski_difference(){
	difference(){
		children(0);
		minkowski() {
			difference(){
				minkowski() {
					children(0);
					children(1);
				}
				children(0);
			}
			children(1);
		}
	}
}

// like translate(), but use positions relative to the size of the parent object
// if tilt==true, child objects will also be oriented away from the parent object's center
module align(anchor=center, tilt=false){
	translate(mult(anchor, $parent_size)/2)
	if(tilt)
		orient(mult(anchor, $parent_size))
		children();
	else
		children();
}

// like rotate(), but works by aligning the zaxis to a given vector
module orient(zaxis, roll=0){
	rotate(	[-asin(zaxis.y / norm(zaxis)),
		  		atan2(zaxis.x, zaxis.z),
		  		0] )
	rotate([0,0,roll])
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
module box(size, anchor=bottom, visible=true) {
	assign(size = len(size)==undef && size!= undef? [size,size,size] : size)
	translate(-mult(anchor, size)/2)
	{
		if(visible) cube(size, center=true);
		assign($parent_size = size, $parent_type="box")
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module rod(size=[1,1,1], h=undef, d=undef, r=undef, anchor=bottom, visible=true) {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d!=undef && h!=undef? 
							[d,d,h] : size)
	translate(-mult(anchor, size)/2)
	{
		if(visible) resize(size) cylinder(d=size.x, h=size.z, center=true);
		assign($parent_size = size, $parent_type="rod")
			children();
	}
}
// wrapper for cylinder with enhanced centering functionality and cascading children
module ball(size=[1,1,1], d=undef, r=undef, anchor=bottom, visible=true) {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d!=undef? 
							[d,d,d] : size)
	translate(-mult(anchor, size)/2)
	{
		if(visible) resize(size) sphere(d=size.x, center=true);
		assign($parent_size = size, $parent_type="ball")
			children();
	}
}