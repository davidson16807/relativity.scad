include <relativity.scad>

inch = 25.4;
foot = 12*inch;
height = 5*foot+10*inch;
unit = height/11;

assign($fn=15)
//hulled("cranium, jaw")
hulled("pubis, ilium")
//mirrored(y, class="*")//
hulled("ribs", $class="ribs")
hulled("thigh", $class="thigh") 
hulled("fibula", $class="fibula")
hulled("tibia", $class="tibia")
hulled("foot", $class="foot")
hulled("shoulderblade", $class="shoulderblade")
hulled("collarbone", $class="collarbone")
hulled("humerus", $class="humerus")
hulled("forearm", $class="forearm")
ball(d=unit, $class="cranium"){
	align(x-z)
	*rod(d=1/2*unit, h=1/4*unit, anchor=-x+z, orientation=x, $class="chin")
	align(-x-z)
	rod(d=2/3*unit, h=1/3*unit, anchor=x-z, orientation=x, $class="chin")
	;
	*align(x)
	box([1/4*unit, 3/4*unit, unit], anchor=-x+z, $class="jaw");
	
	*align(bottom)
	rod(d=1/3*unit, h=unit, $class="cervical")
	align(-z){
		align(-x+y)
		translate(1*unit*y)
		ball(d=1/6*unit, anchor=x+y, $class="shoulderblade")
		align(y, $class="humerus"){
			ball(d=1/4*unit);
			translate(2*unit*y)
			ball(d=1/4*unit)
			align(y, $class="forearm"){
				ball(d=1/4*unit);
				translate(1.5*unit*y)
				ball(d=1/4*unit);
			}
		}
		
		align(-x+y)
		translate(1*unit*y)
		ball(d=1/6*unit, anchor=-x+y, $class="collarbone");
		
		assign($class="ribs"){
			//upper center
			ball(d=unit, anchor=center){
				align(x)
				ball(d=1/6*unit, anchor=-x+z, $class="collarbone");
				
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
				ball(d=1/8*unit, anchor=x, $class="shoulderblade");
				
				//lower front
				align(x)
				ball(d=unit, anchor=top)
				ball(d=unit, anchor=top)
				align(-x-y-z)
				rod(1/3*unit, h=unit, anchor=-x+z, $class="lumbar"){
					align(-z)
					ball(d=unit, anchor=z, $class="ilium")
					align(-z){
						ball(d=1/2*unit, anchor=-x-y+z, $class="pubis")
						align(-x+y)
						ball(d=1/4*unit, anchor=-y, $class="thighball")
						align(y)
						ball(d=1/4*unit, $class="thigh");
						
						translate(2.5*unit*down)
						translate(1*inch*y)
						ball(d=1/2*unit, anchor=-y-z, $class="condyle"){
							align(x)
							ball(d=1/4*unit, anchor=x, $class="thigh");
							
							align(-z)
							ball(d=1/2*unit, anchor=z, $class="condyle"){
								align(-x+y)
								ball(d=1/6*unit, anchor=-x+y, $class="fibula");
								
								align(x-y)
								ball(d=1/4*unit, anchor=x-y, $class="tibia")
								translate(2.5*unit*down)
								ball(d=1/4*unit, anchor=-z, $class="tibia"){
									align(-x-y)
									box([infinitesimal, 1/2*unit, 1/2*unit], anchor=-y+z, $class="foot")
									align(bottom)
									box([1.5*unit, 1/2*unit, infinitesimal], anchor=-x);
									
									align(-x+y)
									ball(d=1/6*unit, $class="fibula");
								}
							}
						}
					}
					
					align(-y-z)
					ball(d=unit, anchor=-y+z, $class="ilium");
				}
			}
		}
		
		assign($class="shoulderblade")
		translate(1/2*unit*-x)
		align(y)
		ball(d=1/6*unit, anchor=-y+z);
		
	}
}