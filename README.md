relativity.scad
===============

##The OpenSCAD General Library of Relativity##

This OpenSCAD library adds functionality to size, position, and orient objects relative to other geometric primitives.   

To do so, the library introduces a new set of modules to replace the default geometric primitives in OpenSCAD. These new primitives have the ability to align themselves, and any child object, relative to their own size.  

So this:  

	cube_h=10;
	cylinder_d=7;
	*translate([0,0,cube_h/2]){  
		cube(cube_h, center=true);  
	  
		translate([cube_h/2 + cylinder_d/2,0,0])
		cylinder(d=cylinder_d, h=cube_h, center=true);  
	}  

becomes this:  

	box(10, anchor=[0,0,-1])
	align([1,0,0])
	rod(d=7, h=$parent_size.z);

The library also includes a number of optional replacement modules that help to perform CSG operations while using this new approach 

Module | Description
--------- | --------------
mirrored | form bilaterally symmetric objects using the `mirror()` function 
rotated | form radially symmetric objects by repeated calls to `rotate()` 
translated | form repeating patterns by repeated calls to `translate() `
[hulled](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#hulled) | performs `hull` between objects of a given class
[intersected](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#intersected) | performs `difference` between objects of a given class
[differed](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#differed) | performs `difference` between one class of objects and another

For more information, check out the [wiki](https://github.com/davidson16807/relativity.scad/wiki)!
