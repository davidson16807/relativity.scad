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

//element-wise multiplication for vectors
function mult(v1,v2) = [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];


// form repeating patterns through translation
module translated(offset, n=[-1:1]){
	for(i=n)
		translate(offset*i)
			children();
}

// form radially symmetric objects around the z axis
module rotated(offset, n=[-1:1]){
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
module mill(through=false, from=top){
	assign(depth = through? -indeterminate : 0)
	difference(){
		children(0);
		if($children > 1)
		for(i=[1:$children-1])
			hull()
			orient(from){
				translate(indeterminate*z)
					children(i);
				translate(depth*z)
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

// forms a holder for an object along the xy plane 
// the holder has a thickness of n
// useful for interfacing with vitamins
module wrap(r, h=infinitesimal){
	difference(){
		hull() buffer(r, h) children();
		translated([0,0,infinitesimal], [-1,1]) children();
	}
}

module smooth(r, h=infinitesimal){
	blackhat(r,h) {
		children(0);
		if($children > 1)
			children(1)
		if($children <= 1)
			cylinder(r=r, h=h, center=true);
	} 
	open(r,h){
		children(0);
		if($children > 1)
			children(1)
		if($children <= 1)
			cylinder(r=r, h=h, center=true);
	} 
}

module whitehat(r, h=infinitesimal){
	difference(){
		children(0);
		translated([0,0,infinitesimal], [-1,1]) 
		open(r,h){
			children(0);
			if($children > 1)
				children(1)
			if($children <= 1)
				cylinder(r=r, h=h, center=true);
		} 
	}
}

module blackhat(r, h=infinitesimal){
	difference(){
		close(r,h) {
			children(0);
			if($children > 1)
				children(1)
			if($children <= 1)
				cylinder(r=r, h=h, center=true);
		} 
		translated([0,0,infinitesimal], [-1,1])
			children(0);
	}
}

// hollows out object 
// the resulting object has a thickness of n
// useful for conserving on plastic
module shell(r, h=infinitesimal, center=false){
	if(center)
		difference(){
			dilate(r/2, h) children();
			translated([0,0,infinitesimal], [-1,1])
				erode(r/2, h) children();
		}
	else if(r<0)
		difference(){
			children();
			translated([0,0,infinitesimal], [-1,1])
				erode(r, h) children();
		}
	else
		difference(){
			dilate(r, h) children();
			translated([0,0,infinitesimal], [-1,1])
				children();
		}
}

module open(r, h=infinitesimal){
	dilate(r, h) erode(r, h){
		children(0);
		if($children > 1)
			children(1)
		if($children <= 1)
			cylinder(r=r, h=h, center=true);
	} 
}
module close(r, h=infinitesimal){
	erode(r, h) dilate(r, h){
		children(0);
		if($children > 1)
			children(1)
		if($children <= 1)
			cylinder(r=r, h=h, center=true);
	} 
}
// opposite of buffer, subtracts from perimeter along the xy plane
// performs minkowski subtraction between children and a cylinder of set radius around the z axis
module erode(r, h=infinitesimal){
	minkowski_difference(){
		children(0);
		if($children > 1)
			children(1)
		if($children <= 1)
			cylinder(r=r, h=h, center=true);
	} 
}
// buffers perimeter along the xy plane
// performs minkowski addition between children and a cylinder of set radius around the z axis
module dilate(r, h=infinitesimal){
	minkowski()
	{
		children(0);
		if($children > 1)
			children(1)
		if($children <= 1)
			cylinder(r=r, h=h, center=true);
	}
}
// performs minkowski subtraction - 
// given two polygons, subtracts the second from the perimeter of the first
// very useful for forming inverse fillets
module minkowski_difference(){
	difference(){
		cube(indeterminate, center=true);
		minkowski() {
			difference(){
				cube(indeterminate, center=true);
				children(0);
			}
			children(1);
		}
	}
}

// like translate(), but use positions relative to the size of the parent object
// if tilt==true, child objects will also be oriented away from the parent object's center
module align(anchor=center, tilt=false){
	translate(mult(anchor, $parent_bounds)/2)
	if(tilt)
		orient(mult(anchor, $parent_bounds))
		children();
	else
		children();
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
module rod(size=[1,1,1], 
			h=undef, d=undef, r=undef, 
			anchor=bottom, orientation=top, visible=true) {
	//diameter is used internally to simplify the maths
	assign(d = r!=undef? 2*r : d)
	assign(size =	len(size)==undef && size!= undef? 
							[size,size,size] : 
						d!=undef && h!=undef? 
							[d,d,h] : size)
	assign(bounds = _rotate_matrix(_orient_angles(orientation)) * [size.x,size.y,size.z,1])
	assign($parent_size = size, 
			$parent_type="rod",
			$parent_bounds=[abs(bounds.x),abs(bounds.y),abs(bounds.z)],
			$parent_radius=sqrt(pow(h/2,2)+pow(d/2,2)))
	translate(-mult(anchor, $parent_bounds)/2)
	{
		echo($parent_bounds);
		if(visible) 
			orient(orientation) 
			resize(size) 
			cylinder(d=size.x, h=size.z, center=true);

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
