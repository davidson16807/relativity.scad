include <relativity.scad>
height = 1670;
unit = height/12.5;



module step0(){
	ball(unit, $class="cranium bone");
}

module step1(){
	ball(unit, $class="cranium bone"){
        align(-z)
        rod(d=1/3*unit, h=unit, $class="cervical bone"){
            align(-z, $class="ribs bone")
            ball(unit){                    
                //lower center
                align(-z)
                ball(unit)                    
                align(-z)
                rod(d=1/3*unit, h=unit, anchor=z, $class="lumbar bone"){
                    align(-z)
                    ball(unit, anchor=z, $class="ilium bone");

                    align(-y-z)
                    ball(unit, anchor=-y+z, $class="ilium bone");
                };
            }
        }
    }
}

module step2(){
	ball(unit, $class="cranium bone"){
        align(-z)
        rod(d=1/3*unit, h=unit, $class="cervical bone"){
            align(-z, $class="ribs bone")
            ball(unit){
                //lower center
                align(-z)
                ball(unit)                    
                align(-z)
                rod(d=1/3*unit, h=unit, anchor=z, $class="lumbar bone"){
                    align(-y-z)
                    ball(unit, anchor=-y+z, $class="ilium bone");
                    align(-z)
                    ball(unit, anchor=z, $class="ilium bone"){

                        align(-z)
                        translate(2.5*unit*down)
                        translate(25*y)
                        ball(1/2*unit, anchor=-y+z, $class="condyle bone"){
                            align(x-z)
                            ball(1/2*unit, anchor=x+z, $class="condyle bone")
                            align(z)
                            translate(2.5*unit*down)
                            ball(1/4*unit, anchor=-z, $class="tibia bone");
                        }
                    }
                }
            }
        }
    }
}

module step3(){
	ball(unit, $class="cranium bone"){
        align(-z)
        rod(d=1/3*unit, h=unit, $class="cervical bone"){
            
            align(-x-1.5*z)
            translate(1.5*unit*y){
                ball(d=1/4*unit, anchor=center, $class="humerus bone");

                translate(2*unit*y)
                ball(d=1/4*unit, anchor=center, $class="humerus bone"){
                    align(y){
                        ball(d=1/4*unit, anchor=-y, $class="ulna bone");
                        translate(1.75*unit*y)
                        ball(d=1/8*unit, anchor=y, $class="ulna bone");
                    }
                }
            }
            
            align(-z, $class="ribs bone")
            ball(unit){
                //lower center
                align(-z)
                ball(unit)                    
                align(-z)
                rod(d=1/3*unit, h=unit, anchor=z, $class="lumbar bone"){
                    align(-y-z)
                    ball(unit, anchor=-y+z, $class="ilium bone");
                    align(-z)
                    ball(unit, anchor=z, $class="ilium bone"){

                        align(-z)
                        translate(2.5*unit*down)
                        translate(25*y)
                        ball(1/2*unit, anchor=-y+z, $class="condyle bone"){
                            align(x-z)
                            ball(1/2*unit, anchor=x+z, $class="condyle bone")
                            align(z)
                            translate(2.5*unit*down)
                            ball(1/4*unit, anchor=-z, $class="tibia bone");
                        }
                    }
                }
            }
        }
    }
}

module body(){
    head()
    attach("neck")
    chest(){
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

module head(){
    ball(unit, $class="cranium bone")
    align(-z, $class="neck")
    children();
}

module chest(){
    rod(d=1/3*unit, h=unit, $class="cervical bone"){
        align(-x-1.5*z, $class="shoulder")
        translate(1.5*unit*y)
        children();
        
        align(-z, $class="ribs bone")
        ball(unit)
        align(-z)
        ball(unit)                    
        align(-z, $class="waist")
        children();
    }
}

module pelvis(){
    rod(d=1/3*unit, h=unit, anchor=z, $class="lumbar bone"){
        align(-y-z)
        ball(unit, anchor=-y+z, $class="ilium bone");
        
        align(-z)
        ball(unit, anchor=z, $class="ilium bone")
        align(-z, $class="hip")
        children();
    }
}

module leg(){
    translate(2.5*unit*down)
    translate(25*y)
    ball(1/2*unit, anchor=-y+z, $class="condyle bone")
    align(x-z)
    ball(1/2*unit, anchor=x+z, $class="condyle bone")
    align(z)
    translate(2.5*unit*down)
    ball(1/4*unit, anchor=-z, $class="tibia bone");
}

module arm(){
    ball(d=1/4*unit, anchor=center, $class="humerus bone");

    translate(2*unit*y)
    ball(d=1/4*unit, anchor=center, $class="humerus bone"){
        align(y){
            ball(d=1/4*unit, anchor=-y, $class="ulna bone");
            translate(1.75*unit*y)
            ball(d=1/8*unit, anchor=y, $class="ulna bone");
        }
    }
}
