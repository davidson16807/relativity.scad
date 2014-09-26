include <relativity.scad>

// forms a holder for an object along the xy plane 
// the holder has a thickness of n
// useful for interfacing with vitamins
module wrap(r, h=infinitesimal){
	difference(){
		hull() dilate(r, h) children();
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
