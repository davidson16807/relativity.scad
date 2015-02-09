include <relativity.scad>
inch = 25.4;
foot = 12*inch;
height = 5*foot+10*inch;
unit = height/12.5;
eye = 1/5*unit;
point = 10;

//skeleton()
muscle()
upper_body($fn=5);

module skin(){
	skeleton()
	children();

	mirrored(y)
	hulled()
	mirrored(y, class="pubis, ilium")
	show("shoulderblade, ribs, pubis, ilium, lumbar")
	children();

	hulled()
	show("collarbone")
	children();

	hulled()
	show("navicular, calcaneus, talus")
	children();

	mirrored(y)
	hulled()
	show("tibia, fibula")
	children();

	mirrored(y)
	hulled()
	show("thigh")
	children();
}

module muscle(){
	hulled("pectoralis-major")
	hulled("latisimus-dorsi")
	children();
}

module skeleton(){
	hulled("cranium, forehead, jaw, chin")
	hulled("pubis, ilium")
	mirrored(y, class="*")//
	hulled("ribs", $class="ribs")
	hulled("femur", $class="femur") 
	hulled("tibia", $class="tibia")
	hulled("fibula", $class="fibula")
	hulled("shoulderblade", $class="shoulderblade")
	hulled("collarbone", $class="collarbone")
	hulled("humerus", $class="humerus")
	hulled("radius", $class="radius")
	hulled("ulna", $class="ulna")
	hulled("nose", $class="nose")
	hide("muscle")
	children();
}

module body(){
	upper_body()
	lower_body();
}

module upper_body(){
	ball(d=unit, $class="cranium"){
		align(1/2*x)
		ball(d=unit, $class="forehead"){
			align(x-1/3*z)
			ball(d=eye, anchor=x, $class="nose"){
				align(x)
				translate(1/4*unit*down)
				ball(d=eye, anchor=center,, $class="nose");
			
				align(x+y)
				ball(d=eye, anchor=x-y, $class="eye");
			}		
			align(bottom)
			box([1/2*unit, 2/3*unit, 1/4*unit], anchor=z, $class="jaw")
			align(x-z)
			ball(d=1/4*unit, anchor=-x+z, orientation=x, $class="chin");
		}

		align(bottom)
		rod(d=1/3*unit, h=unit, $class="cervical")
		align(-1.5*z){
			align(-x+y)
			translate(1*unit*y)
			box(1/6*unit, anchor=x+y, $class="shoulderblade")
			align(y, $class="humerus"){
				ball(d=1/4*unit)
				align(y)
				box(point, $class="pectoralis-major muscle")
				box(point, $class="latisimus-dorsi muscle");

				translate(2*unit*y)
				ball(d=1/4*unit, anchor=-y){
					ball(d=1/4*unit, anchor=z, $class="condyle");
					ball(d=1/4*unit, anchor=-z, $class="condyle");
					align(y){
						ball(d=1/4*unit, anchor=-y+z, $class="ulna");
						ball(d=1/8*unit, anchor=-y-z, $class="radius");
						translate(1.75*unit*y){
							ball(d=1/8*unit, anchor=y-z, $class="radius")
							hand();

							//hand
							ball(d=1/8*unit, anchor=y+z, $class="ulna");
						}
					}
				}
			}

			assign($class="shoulderblade")
			translate(1/2*unit*-x)
			align(y)
			box(1/6*unit, anchor=-y+z);

			align(-x+y)
			translate(1*unit*y)
			ball(1/6*unit, anchor=-x+y, $class="collarbone");

			assign($class="ribs"){
				//upper center
				ball(d=unit, anchor=center){
					align(x)
					ball(1/6*unit, anchor=-x+z, $class="collarbone");
					
					//lower center
					align(-z)
					ball(d=unit);
				}

				//upper front
				align(-x)
				ball(d=unit, anchor=-x+z);

				//upper back
				align(-x)
				ball(d=unit, anchor=-y+z){
					//lower back
					ball(d=unit, anchor=top)
					align(-x)
					box(1/8*unit, anchor=x, $class="shoulderblade");
					
					//lower front
					align(x)
					ball(d=unit, anchor=top){
						align(y)
						box(point, $class="pectoralis-major muscle");

						ball(d=unit, anchor=top)
						align(-x-y-z){
							box(point, $class="latisimus-dorsi muscle");
							children();
						}
					}
				}
			}

		}
	}
}

module hand(){
	assign(palm=1/4*unit)
	assign(finger = palm/4){
		align(y-z)
		rod(d=palm, h=2*finger, orientation=x, anchor=-y, $class="carpals")
		align(y){
			finger(0, finger, 1); 		// middle
			finger(1, finger, 0.9);		// index
			finger(-1, finger, 0.9);	// ring
			finger(-2, finger, 0.8);	// pinky

			translate(2*finger*z)		// thumb
			translate(1*finger*-y)
			rotate(45*x)
			finger(2, finger, 0.6);
		}
	}
}

module finger(index, width, length){
	translate(index*width*z)	
	ball(d=width, anchor=y-z, $class="metacarpals")
	align(-y)
	translate(index*0.5*width*z)
	translate(length*5*width*y)
	ball(d=width)
	translate(length*3*width*y)
	ball(d=width)
	translate(length*2.5*width*y)
	ball(d=width)
	translate(length*1*width*y)
	ball(d=1/2*width);
}

module lower_body(){
	rod(1/3*unit, h=unit, anchor=-x+z, $class="lumbar"){
		align(-z)
		ball(d=unit, anchor=z, $class="ilium"){
			align(-z)
			ball(d=1/2*unit, anchor=-x-y+z, $class="pubis")
			align(-x+y)
			ball(d=1/4*unit, anchor=-y, $class="condyle")
			ball(d=1/2*unit, anchor=-y+z, $class="condyle")
			ball(d=1/4*unit, 			$class="femur");

			align(-z)
			translate(2.5*unit*down)
			translate(1*inch*y)
			ball(d=1/2*unit, anchor=-y+z, $class="condyle"){
				align(x)
				ball(d=1/4*unit, anchor=x, $class="femur")

				align(x)
				ball(d=1/8*unit, $class="kneecap");

				align(-z)
				ball(d=1/2*unit, anchor=z, $class="condyle"){
					align(-x+y)
					ball(d=1/6*unit, anchor=-x+y, $class="fibula");

					align(x)
					ball(d=1/4*unit, anchor=x, $class="tibia")
					align(z)
					translate(2.5*unit*down)
					ball(d=1/4*unit, anchor=-z, $class="tibia"){

						align(-x+y)
						ball(d=1/6*unit, anchor=center, $class="fibula");

						assign(heel = 1/4*unit)
						ball(heel, anchor=top, $class="talus"){
							align(-x-z)
							ball(heel, anchor=x+z, $class="calcaneus");

							align(x)
							ball(heel, anchor=-x+z, $class="navicular"){

								align(-y)
								translate(1*1/2*heel*x)
								for(i=[0:4])
								rotate(i*z*50/5)
								translate(3*1/2*heel*x)
								translate(-1*heel/5*i*z)
								ball(d=1/4*heel, anchor=center);

								align(-y-z)
								translate(3*1/2*heel*x)
								for(i=[0:4])
								rotate(i*z*50/5)
								translate(4*1/2*heel*x)
								translate(-1/2*heel/5*i*z)
								ball(d=1/4*heel, anchor=x+y);

								align(-y-z)
								translate(4*1/2*heel*x)
								for(i=[0:4])
								rotate(i*z*50/5)
								translate(4*1/2*heel*x)
								translate(-1/2*heel*z)
								ball(d=1/4*heel, anchor=y);
	
								align(-y-z)
								translate(6*1/2*heel*x)
								for(i=[0:4])
								rotate(i*z*80/5)
								translate(3*1/2*heel*x)
								translate(-1/2*heel*z)
								ball(d=1/4*heel, anchor=x+y);
							}
						}
					}
				}
			}
			
		}

		align(-y-z)
		ball(d=unit, anchor=-y+z, $class="ilium");
	}
}
