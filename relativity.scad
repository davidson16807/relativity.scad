include <relativity.scad>

box([5,5,indeterminate])
align(x)
box(50);

*difference(){
	arm_base(negative=false, positive=true);
	arm_base(negative=true, positive=false);
}

module arm_base(positive=true, negative=false){
	rod(d=14, h=8, $show=positive)
		align(y)
			box([70, $parent_size.x/2, $parent_size.z], anchor=-x+y, $fn=10) {
				align(x)
					rod(d=$parent_size.y, h=$parent_size.z, anchor=center);

				align(-x)
				translate(65*x)
				rotate(11*z)
					rod(d=3, orientation=y, anchor=center, $show=negative);

				align(y)
					rod(d=5, orientation=y, anchor=center, $show=negative);

				align(y)
				hotend_screw_pos(){
					rod();
					rod(d=3, orientation=y, anchor=center, $show=negative);
				}

			}

	rod(d=3, $show=negative, anchor=center, $fn=10);

}

module hotend_screw_pos(){
	rod(d=4, anchor=center, $show=false){
		align(x)
		translate(1*x){
			rod(d=7, orientation=y, anchor=-x)
				assign($show=true)
				children();
		}
		align(-x)
		translate(-2*x){
			rod(d=3, anchor=x)
				assign($show=true)
				mirror(x)
				children();
		}
	}
}
