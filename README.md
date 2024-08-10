relativity.scad
===============

##The OpenSCAD General Library of Relativity##

This library adds functionality to size, position, and orient objects relative to other geometric primitives.   
The library introduces a new set of modules to replace the default geometric primitives in OpenSCAD. These new primitives have the ability to align themselves, and any child object, relative to their own size.  

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

But the library does more. Way more. The library does to OpenSCAD what css does for html:

*It separates presentation from content.*

You can build a single model that defines all the parts of a project and how they interact, then create a presentation layer to isolate a printable part using [show](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#show) or [hide](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#hide). You can also go the opposite way - you can define a series of components, then define attachment points for each and use [attach](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#attach) to pop them into place like lego blocks.

Here's a full listing of CSG operations

Module | Description
--------- | --------------
mirrored | form bilaterally symmetric objects using the `mirror()` function 
rotated | form radially symmetric objects by repeated calls to `rotate()` 
translated | form repeating patterns by repeated calls to `translate() `
[hulled](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#hulled) | performs `hull` between objects of a given class
[intersected](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#intersected) | performs `difference` between objects of a given class
[differed](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#differed) | performs `difference` between one class of objects and another
[show](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#show) | renders only the specified class 
[hide](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#hide) | renders everything but the specified class 
[attach](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#attach) | attaches child to the parent at an attachment point of a given class

For more information, check out the [wiki](https://github.com/davidson16807/relativity.scad/wiki)!
