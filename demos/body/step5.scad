include <relativity.scad>
height = 1670;
unit = height/12.5;
eye = 1/5*unit;

head();

module head(){
	ball(unit, $class="cranium bone"){
		align(1/2*x)
		ball(unit, $class="forehead bone"){
			align(x-1/3*z)
			ball(d=eye, anchor=x, $class="nose flesh"){
				align(x)
				translate(1/4*unit*down)
				ball(d=eye, anchor=center,, $class="nose flesh");
			
				align(x+y)
				ball(d=eye, anchor=x-y, $class="eye flesh");
			}		
			align(bottom)
			box([1/2*unit, 2/3*unit, 1/4*unit], anchor=z, $class="jaw bone")
			align(x-z)
			ball(d=1/4*unit, anchor=-x+z, orientation=x, $class="chin bone");
		}
		align(-z)
		assign($class="neck")
		children();
		
		align(y)
		box(point, $class="splenius muscle");
	}
}


module chest(){
	rod(d=1/3*unit, h=unit, $class="cervical bone"){
		align(-x+z)
		box(point, $class="splenius muscle");
		align(x)
		box(point, $class="scalenus muscle");
		align(y)
		box(point, $class="scalenus muscle");
		align(x+y-z)
		box(point, $class="trapezius muscle");
		align(-x-z)
		box(point, $class="trapezius muscle");

		align(-x-1.5*z)
		translate(1.5*unit*y)
		box(1/6*unit, anchor=x+y-z, $class="shoulderblade bone"){
			align(-x)
			box(point, $class="trapezius muscle");

			align(-x)
			box(point, $class="triceps muscle");

			align(x-y+z)
			ball(1/6*unit, anchor=-x+y+z, $class="collarbone bone");

			assign($class="shoulder")
			align(x-z)
			children();
		}

        //upper center
        assign($class="ribs bone"){
            align(-z)
            ball(unit){
                align(x)
                box(point, $class="pectoralis-major muscle");

                align(-x)
                box(point, $class="splenius muscle");

                align(y)
                box(point, $class="scalenus muscle");

                align(x)
                box(point, anchor=x, $class="subclavius muscle");
                
                //lower center
                align(-z)
                ball(unit)
                align(-z)
                align(center, $class="waist")
                children();

                box(1/6*unit, anchor=-y-z, $class="shoulderblade bone");

                align(z)
                box(point, $class="trapezius muscle");
            }
        
            align(-2*z){
                //upper front
                align(-x)
                ball(unit, anchor=-x+z)
                align(x)
                box(point, $class="pectoralis-major muscle");

                //upper back
                align(-x)
                ball(unit, anchor=-y+z){
                    align(x+z)
                    ball(1/6*unit, anchor=-x+y-z, $class="collarbone bone")
                    align(x)
                    box(point, anchor=x, $class="subclavius muscle");

                    align(x+z)
                    box(point, $class="trapezius muscle");
                    align(x)
                    box(point, $class="scalenus muscle");

                    align(-x)
                    box(point, $class="latisimus-dorsi muscle");

                    //lower back
                    ball(unit, anchor=top)
                    align(-x)
                    box(point, $class="latisimus-dorsi muscle")
                    box(1/8*unit, anchor=x, $class="shoulderblade bone");
                    
                    //lower front
                    align(x)
                    ball(unit, anchor=top){
                        align(y)
                        box(point, $class="pectoralis-major muscle");
                        align(x)
                        box(point, $class="pectoralis-major muscle");

                        ball(unit, anchor=top);
                    }
                }
            }
        }
	}
}

module pelvis(){
	rod(d=1/3*unit, h=unit, anchor=z, $class="lumbar bone"){
		align(-z)
		ball(unit, anchor=z, $class="ilium bone")
		assign($class="hip")
		children();

		align(-y-z)
		ball(unit, anchor=-y+z, $class="ilium bone"){
			align(-x)
			box(point, $class="gluteus muscle");

			align(x)
			box(point, $class="vastus muscle");
		}

		align(x-z)
		box(point, $class="psoas muscle");
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
			ball(d=1/4*unit, anchor=z, $class="condyle bone");
			ball(d=1/4*unit, anchor=-z, $class="condyle bone");
			align(y){
				ball(d=1/4*unit, anchor=-y+z, $class="ulna bone");
				ball(d=1/8*unit, anchor=-y-z, $class="radius bone");
				translate(1.75*unit*y){
					ball(d=1/8*unit, anchor=y-z, $class="radius bone")
					assign($class="wrist")
					children();

					//hand
					ball(d=1/8*unit, anchor=y+z, $class="ulna bone");
				}
			}
		}
	}
}

module hand(){
	assign(palm=1/4*unit)
	assign(finger = palm/4){
		align(y-z)
		rod(d=palm, h=2*finger, orientation=x, anchor=-y, $class="carpals bone")
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
	ball(d=width, anchor=y-z, $class="metacarpals bone")
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
	ball(d=1/2*unit, anchor=-x-y+z, $class="pubis bone"){
		align(-x+y)
		ball(d=1/4*unit, anchor=-y, $class="condyle bone")
		ball(d=1/2*unit, anchor=-y+z, $class="condyle bone"){
			ball(d=1/4*unit, 			$class="femur bone");
			align(-x-z)
			box(point, $class="adductor muscle")
			box(point, $class="gluteus muscle");
			align(x-y-z)
			box(point, $class="psoas muscle");
			align(y)
			box(point, $class="abductor muscle");
		}

		align(-x+z)
		box(point, $class="gracilis muscle");
		align(-x-z)
		box(point, $class="adductor muscle");
		align(-x-y)
		box(point, $class="gluteus muscle");
	}

    
	align(-z)
    align(y)
	translate(1.5*unit*down)
	ball(d=1/4*unit, anchor=-x-y, $class="placeholder"){
		align(x)
		box(point, $class="vastus muscle");
		align(-y)
		box(point, $class="vastus muscle");

		align(-x)
		box(point, $class="gluteus muscle");
	}

	align(-z)
	translate(2.5*unit*down)
	translate(25*y)
	ball(d=1/2*unit, anchor=-y+z, $class="condyle bone")
    align(x+y-z)
    ball(1/4*unit, anchor=$outward, $class="femur bone"){
		
		align(x-y-z)
		ball(d=1/2*unit, anchor=$outward, $class="condyle bone")
		align(y)
		box(point, $class="abductor muscle");

		align(-x-y)
		box(point, $class="adductor muscle")
		box(point, $class="gracilis muscle");

		align(x)
		ball(d=1/4*unit, anchor=center, $class="kneecap bone")
		align(x+z)
		box(point, $class="vastus muscle");

		align(x-z)
		ball(d=1/2*unit, anchor=x+z, $class="condyle bone"){
			align(-x+y)
			ball(d=1/6*unit, anchor=-x+y, $class="fibula bone");

			align(x)
			ball(d=1/4*unit, anchor=x, $class="tibia bone")
			align(z)
			translate(2.5*unit*down)
			ball(d=1/4*unit, anchor=-z, $class="tibia bone"){

				align(-x+y)
				ball(d=1/6*unit, anchor=center, $class="fibula bone");
				
				assign($class="ankle")
				children();
			}
		}
	}
}

module foot(){
	assign(heel = 1/4*unit)
	ball(heel, anchor=top, $class="talus bone"){
		align(-x-z)
		ball(heel, anchor=x+z, $class="calcaneus bone");

		align(x)
		ball(heel, anchor=-x+z, $class="navicular bone"){

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