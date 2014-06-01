relativity.scad
===============

##The OpenSCAD General Library of Relativity##

This OpenSCAD library adds functionality to size, position, and orient objects relative to other geometric primitives.   

To do so, the library introduces a new set of modules to replace the default geometric primitives in OpenSCAD. These new primitives have the ability to align themselves, and any child object, relative to their own size.  

So this:  

	translate([0,0,cube_height/2]){  
		cube(cube_height, center=true);  
	  
		translate([cube_height/2,0,0])  
		rotate([0,90,0])  
		cylinder(d=cube_height/4, h=cube_height);  
	}  

becomes this:  

	box(50, anchor=[0,0,-1])  
	align([1,0,0], tilt=true)  
	rod(d=$parent_size.x/4, h=$parent_size.z);  

The library also provides a number of helper functions relevant to generating printable models

Module | Description
--------- | --------------
minkowski subtraction | subtracts one child object from the perimeter of nother 
buffer | adds to an object's perimeter along the xy plane 
erode | subtracts from an object's perimeter along the xy plane 
wrap | returns  an object that wraps around a given child along the xy lane 
hollow | hollows out an object along the xy plane |
slice | returns a 3d slice of the object with a given height 
bed | projects an object and extrudes a 3d object from it; good for aking printable beds 
mill | like difference(), but removes any overhang that may obstruct ttempts to mill or print an object 
bridge | like hull(), but excludes the hulls for individual child bjects to allow combining detailed geometries 
bridged | variant of bridge() that includes child objects in the result 

as well as functions relevant to generating repeated patterns:

Module | Description
--------- | --------------
mirrored | form bilaterally symmetric objects using the mirror() function 
rotated | form radially symmetric objects by repeated calls to rotate() 
translated | form repeating patterns by repeated calls to translate() 

For more information, check out the upcoming [wiki](https://github.com/davidson16807/relativity.scad/wiki)!