include <relativity.scad>
inch = 25.4;
foot = 12*inch;
height = 5*foot+10*inch;
unit = height/12.5;
eye = 1/5*unit;
point = 5;

$fn=7;

skeleton()
body();
muscle()
body();

module skin2(){
	hulled("radius,ulna")
	hulled("humerus>condyle,humerus")
	hulled("collarbone")
	hulled("ribs,ilium")
	hulled("pectoralis-major,latisimus-dorsi,trapezius,shoulderblade")
	chest()
	attach("shoulder")
	children();
}
module skin(){
	skeleton()
	children();

	mirrored(y)
	hulled()
	mirrored(y, class="pubis,ilium")
	show("shoulderblade,ribs,pubis,ilium,lumbar")
	children();

	hulled()
	show("collarbone")
	children();

	hulled()
	show("navicular,calcaneus,talus")
	children();

	mirrored(y)
	hulled()
	show("tibia,fibula")
	children();

	mirrored(y)
	hulled()
	show("thigh")
	children();
}

module muscle(){
	mirrored(y)
	//chest
	hulled("pectoralis-major")
	hulled("latisimus-dorsi")
	hulled("trapezius")
	hulled("splenius")
	hulled("scalenus")
	hulled("subclavius")
	//leg
	hulled("gluteus")
	hulled("psoas")
	hulled("adductor,gracilis")
	hulled("abductor")
	hulled("tensor-fasciae-latae")
	hulled("vastus")
	hide("placeholder")
	children();
}

module skeleton(){
	hulled("cranium,forehead,jaw,chin")
	hulled("pubis,ilium")
	mirrored(y)//
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
	head()
	attach("neck")
	chest($fn=5){
		attach("shoulder")
		arm()
		attach("wrist")
		hand();

		attach("waist")
		pelvis()
		attach("hip")
		leg()
		attach("ankle")
		foot();
	}
}

module upper_body(){
	head()
	attach("neck")
	chest()
	attach("shoulder")
	arm()
	attach("wrist")
	hand();
}

module lower_body(){
	pelvis()
	attach("hip")
	leg()
	attach("ankle")
	foot();
}

module head(){
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
		align(-z)
		assign($class="neck")
		children();
		
		align(y)
		box(point, $class="splenius");
	}
}

module chest(){
	rod(d=1/3*unit, h=unit, $class="cervical"){
		align(-x+z)
		box(point, $class="splenius");
		align(x)
		box(point, $class="scalenus muscle");
		align(y)
		box(point, $class="scalenus muscle");
		align(x+y-z)
		box(point, $class="trapezius");
		align(-x-z)
		box(point, $class="trapezius");

		align(-x-1.5*z)
		translate(1.5*unit*y)
		box(1/6*unit, anchor=x+y-z, $class="shoulderblade"){
			align(-x)
			box(point, $class="trapezius");

			align(-x)
			box(point, $class="triceps muscle");

			align(x-y+z)
			ball(1/6*unit, anchor=-x+y+z, $class="collarbone");

			assign($class="shoulder")
			align(x-z)
			children();
		}


		align(-2*z)
		assign($class="ribs"){
			//upper center
			ball(d=unit, anchor=center){
				align(x)
				box(point, $class="pectoralis-major muscle");

				align(-x)
				box(point, $class="splenius");

				align(y)
				box(point, $class="scalenus");

				align(x)
				box(point, anchor=x, $class="subclavius muscle");
				
				//lower center
				align(-z)
				ball(d=unit);

				box(1/6*unit, anchor=-y-z, $class="shoulderblade");

				align(z)
				box(point, $class="trapezius");
			}

			//upper front
			align(-x)
			ball(d=unit, anchor=-x+z)
			align(x)
			box(point, $class="pectoralis-major muscle");

			//upper back
			align(-x)
			ball(d=unit, anchor=-y+z){
				align(x+z)
				ball(1/6*unit, anchor=-x+y-z, $class="collarbone")
				align(x)
				box(point, anchor=x, $class="subclavius muscle");

				align(x+z)
				box(point, $class="trapezius");
				align(x)
				box(point, $class="scalenus muscle");

				align(-x)
				box(point, $class="latisimus-dorsi muscle");

				//lower back
				ball(d=unit, anchor=top)
				align(-x)
				box(point, $class="latisimus-dorsi muscle")
				box(1/8*unit, anchor=x, $class="shoulderblade");
				
				//lower front
				align(x)
				ball(d=unit, anchor=top){
					align(y)
					box(point, $class="pectoralis-major muscle");
					align(x)
					box(point, $class="pectoralis-major muscle");

					ball(d=unit, anchor=top)
					align(-x-y-z, $class="waist")
					children();
				}
			}
		}
	}
}

module pelvis(){
	rod(1/3*unit, h=unit, anchor=-x+z, $class="lumbar"){
		align(-z)
		ball(d=unit, anchor=z, $class="ilium")
		assign($class="hip")
		children();

		align(-y-z)
		ball(d=unit, anchor=-y+z, $class="ilium"){
			align(-x)
			box(point, $class="gluteus");

			align(x)
			box(point, $class="vastus");
		}

		align(x-z)
		box(point, $class="psoas");
	}
}

module arm(){
	assign($class="humerus"){
		ball(d=1/4*unit, anchor=center)
		align(y)
		box(point, $class="pectoralis-major muscle")
		box(point, $class="latisimus-dorsi muscle");

		translate(2*unit*y)
		ball(d=1/4*unit, anchor=center){
			ball(d=1/4*unit, anchor=z, $class="condyle");
			ball(d=1/4*unit, anchor=-z, $class="condyle");
			align(y){
				ball(d=1/4*unit, anchor=-y+z, $class="ulna");
				ball(d=1/8*unit, anchor=-y-z, $class="radius");
				translate(1.75*unit*y){
					ball(d=1/8*unit, anchor=y-z, $class="radius")
					assign($class="wrist")
					children();

					//hand
					ball(d=1/8*unit, anchor=y+z, $class="ulna");
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

module leg(){
	align(-z)
	ball(d=1/2*unit, anchor=-x-y+z, $class="pubis"){
		align(-x+y)
		ball(d=1/4*unit, anchor=-y, $class="condyle")
		ball(d=1/2*unit, anchor=-y+z, $class="condyle"){
			ball(d=1/4*unit, 			$class="femur");
			align(-x-z)
			box(point, $class="adductor")
			box(point, $class="gluteus");
			align(x-y-z)
			box(point, $class="psoas");
			align(y)
			box(point, $class="abductor");
		}

		align(-x+z)
		box(point, $class="gracilis");
		align(-x-z)
		box(point, $class="adductor");
		align(-x-y)
		box(point, $class="gluteus");
	}

	align(-z)
	translate(1.5*unit*down)
	translate(1*inch*y)
	ball(d=1/4*unit, anchor=x-y, $class="placeholder"){
		align(x)
		box(point, $class="vastus");
		align(-y)
		box(point, $class="vastus");

		align(-x)
		box(point, $class="gluteus");
	}

	align(-z)
	translate(2.5*unit*down)
	translate(1*inch*y)
	ball(d=1/4*unit, anchor=-y+z, $class="condyle"){
		
		align(y)
		ball(d=1/4*unit, anchor=-y, $class="condyle")
		align(y)
		box(point, $class="abductor");

		align(-x-y)
		box(point, $class="adductor")
		box(point, $class="gracilis");

		align(x+y)
		ball(d=1/8*unit, anchor=-x, $class="kneecap")
		align(x+z)
		box(point, $class="vastus");

		align(x+y)
		ball(d=1/4*unit, anchor=x, $class="femur");

		align(y-z)
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
				
				assign($class="ankle")
				children();
			}
		}
	}
}

module foot(){
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
