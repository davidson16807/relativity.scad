include <../../relativity.scad>

height = 1670;
unit = height/11.5;
eye = unit/5;
point = unit/15;

module skeleton(){
    color("white")
    hulled("ilium,pubis")
    mirrored(y)
    hulled("collarbone", $class="collarbone")
    hulled("shoulderblade", $class="shoulderblade")
    hulled("ribs", $class="ribs")
    hulled("ulna", $class="ulna")
    hulled("radius", $class="radius")
    hulled("humerus", $class="humerus")
    hulled("femur", $class="femur")
    hulled("tibia", $class="tibia")
    hulled("fibula", $class="fibula")
    hide("not(bone)")
    children();
}

module muscle() {
    colored([0.5,0,0,1], "muscle")
    hulled("iliacus", $class="muscle")
    mirrored(y)
    hulled("gluteus", $class="muscle")
    //hide("muscle")
    hulled("semimembranosus", $class="muscle")
    hulled("biceps-femoris", $class="muscle")
    hulled("quadriceps", $class="muscle")
    hulled("adductor", $class="muscle")
    hulled("pectoral.sternocostal-portion", $class="muscle")
    hulled("pectoral.clavicular-portion", $class="muscle")
    hulled("trapezius.descending", $class="muscle")
    hulled("trapezius.ascending", $class="muscle")
    hulled("deltoid", $class="muscle")
    hulled("biceps", $class="muscle")
    hulled("triceps", $class="muscle")
    hulled("abs", $class="muscle")
    hulled("oblique,serratus", $class="muscle")
    hulled("semimembranosus", $class="muscle")
    hulled("biceps-femoris", $class="muscle")
    hulled("latissimus-dorsi", $class="muscle")
    hulled("mastoid", $class="muscle")
    // hide("muscle.not(trapezius,latissimus-dorsi)")
    differed("cavity", "serratus", $class="serratus muscle")
    hide("not(muscle)")
    children();
}

module lower_body() {
    pelvis()
    attach("crotch")
    leg()
    attach("ankle")
    foot();
}

module upper_body(){
    head()
    attach("neck")
    chest(){
        attach("shoulder")
        arm()
        attach("wrist")
        hand();
        
        attach("waist"){
            pelvis();

            children();
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
        attach("crotch")
        leg()
        attach("ankle")
        foot();
    }
}

module head(){
    ball(d=unit, anchor=-z, $class="cranium bone"){

        align(-x-z)
        translate(-1/32*unit*x + 1/16*unit*z)
        ball(1/2*unit, anchor=-x-z, $class="occiput bone");

        align(-x-z)
        translate(1/16*unit*y)
        ball(3/4*unit, anchor=-x-z, $class="occiput bone");    

        align(z)
        translate(1/8*unit*x)
        ball([1, 3/4, 1]*unit, anchor=z, $class="forehead bone");

        align(x)
        translate(1/2*eye*x+1/12*unit*y+1/2*eye*z)
        ball(2/3*unit, anchor=x, $class="forehead bone");

        align(x)
        ball(1.5*eye, anchor=z, $class="orbit"){
            ball(7/4*eye, $class="arch bone");

            ball(3/2*eye, anchor=-x, $class="socket")
            ball(3/2*eye, anchor=-y);

            ball(eye, $class="eye");
        }

        align(-z)
        ball(1/3*unit, anchor=x-y, $class="descending trapezius muscle");

        align(-z)
        box([eye, 3*eye, infinitesimal], anchor=-x, $class="jaw bone"){
            align(-x+y)
            ball([eye, infinitesimal, infinitesimal], anchor=-x+y, $class="mastoid muscle");
            
            align(x)
            box([infinitesimal, 3*eye, eye], anchor=-x+z){

                align(y+z, $class="cheek bone")
                ball(3/2*eye, anchor=-z)
                align(x)
                ball(1*eye, anchor=center)
                align(x)
                ball(1/2*eye, anchor=center)
                align(z)
                ball(1/2*eye, anchor=center);

                translate(1/2*unit*x){
                    ball(d=1/3*unit, anchor=x){

                        align(x+z)
                        ball(eye, anchor=x-z, $class="nose"){
                            align(y)
                            ball(1/2*eye, anchor=z);
                            align(y)
                            ball(1/2*eye, anchor=x-z, $class="cheek bone");

                            align(x)
                            ball(1/2*eye, anchor=center);
                        }

                        translate(-eye*z)
                        ball(1/2*eye,anchor=-x-y+z);
                    }

                }
            }
        }

        align(-z)
        assign($class="neck")
        children();
    }
}

module chest(){
    rod(d=1/3*unit, h=1/2*unit, $class="cervical bone"){
        align(-x-z)
        translate(-unit/2*z){
            //back
            ball(unit, anchor=-y+z, $class="ribs bone"){
                ball(1.1*unit, $class="ascending trapezius muscle");
            }
            
            translate(3/2*unit*y)
            ball(1/6*unit, anchor=x+y-z, $class="shoulderblade bone"){
                ball(1.1*$parent_size, $class="ascending trapezius muscle");

                ball(1.1*1/6*unit, $class="ascending trapezius muscle");

                align(-z)
                box(point, $class="triceps muscle");
                
                align(y)
                ball(3/5*unit, anchor=center, $class="deltoid muscle head");

                align(x-y+z)
                ball(1/6*unit, anchor=-x+y, $class="collarbone bone")
                align(-z)
                box(point, $class="biceps muscle");

                align(x-z, $class="shoulder")
                children();
            }
        }

        //center
        align(-z, $class="ribs bone")
        ball(unit){
            ball(1.1*unit, $class="descending trapezius muscle");
            ball(1.1*unit, $class="ascending trapezius muscle");

            align(x)
            ball(point, anchor=x-y, $class="mastoid muscle")
            box(point, $class="pectoral sternocostal-portion muscle")
            box(point, $class="pectoral clavicular-portion muscle");
            
            //front
            align(x-z)
            ball(unit, anchor=z){
                align(x)
                box(point, anchor=x, $class="pectoral sternocostal-portion muscle");

                ball(1.1*unit, $class="abs muscle");
                ball(1.1*unit, $class="pectoral sternocostal-portion muscle");

                align(x-z)
                ball(2*unit, anchor=z, $class="cavity");
                
                ball(unit, anchor=-y){
                    ball(unit, anchor=z){
                        ball(1.01*unit, $class="serratus muscle");
                    }
                    ball(1.01*unit, $class="oblique muscle");
                    ball(1.2*unit, $class="pectoral sternocostal-portion muscle head");
                }
            }

            //bottom center
            align(-z)
            ball(unit){
                align(-x+y)
                ball(1/4*unit, anchor=-x-y, $class="lower shoulderblade bone")
                ball(1.1*$parent_size, $class="latissimus-dorsi muscle")
                // ball(1.1*$parent_size, $class="ascending trapezius muscle")
                ;

                ball(1.1*unit, $class="ascending trapezius muscle");

                align(-x)
                ball(1/10*unit, anchor=-y, $class="latissimus-dorsi muscle");
                
                align(-z, $class="waist")
                children();
            }

            align(x)
            translate(1/6*unit*y)
            ball(1/6*unit, anchor=-y, $class="collarbone bone"){
                ball(1.1*$parent_size, $class="pectoral clavicular-portion muscle")
                ball(1.1*$parent_size, $class="pectoral sternocostal-portion muscle");
                
                align(y)
                ball(point, anchor=x-y, $class="mastoid muscle");
            }
            
            align(y)
            ball(1/6*unit, anchor=-x-y-z, $class="collarbone bone")
            ball(1/6*unit, $class="deltoid muscle")
            ball(1/6*unit, $class="pectoral clavicular-portion muscle")
            ball(1/6*unit, $class="pectoral sternocostal-portion muscle");

            align(-x+y)
            ball(1/6*unit, anchor=-y+z, $class="shoulderblade bone")
            ball(1.1*1/6*unit, $class="ascending trapezius muscle")
            ball(1.1*1/6*unit, $class="deltoid muscle");
        }
    }
}

module pelvis(){
    box(d=1/3*unit, h=unit, anchor=-x+z, $class="lumbar bone"){
        align(-y-z)
        ball(unit, anchor=-y+z, $class="ilium bone"){
            ball(1.01*$parent_size, $class="iliacus muscle");
            ball(1.01*unit, $class="gluteus muscle")
            ball(1.01*unit, $class="oblique muscle");
            
            align(y-z)
            ball(1/4*unit, anchor=y-z, $class="quadriceps muscle");
        }
        
        align(-z)
        ball(unit, anchor=z, $class="ilium bone"){
            ball(1.01*$parent_size, $class="iliacus muscle");
            ball(1.01*unit, $class="latissimus-dorsi muscle");
            ball(1.01*unit, $class="abs muscle");
            
            
            translate(1/4*unit*(-x-z))
            ball(unit, anchor=center, $class="coccyx bone"){
                ball(1.01*$parent_size, $class="iliacus muscle");

                align(y-z)
                ball(1.15*unit, anchor=center, $class="gluteus muscle head");
            }

            align(-z, $class="crotch")
            children();
        }
    }
}


module leg(){
    ball(d=1/2*unit, anchor=-x-y+z, $class="pubis bone"){
        ball(1.01*$parent_size, $class="iliacus muscle");

        align(-z)
        ball(1.01*$parent_size, anchor=-z, $class="adductor muscle");

        align(-x+y)
        ball(1/4*unit, anchor=-y, $class="condyle bone")
        ball(1/2*unit, anchor=-y+z, $class="condyle bone"){
            ball(1.01*$parent_size, $class="quadriceps muscle");
            ball(1/4*unit,            $class="adductor muscle");
            
            ball(1/4*unit,            $class="femur bone")
            
            ball(1.01*1/2*unit, $class="gluteus muscle");
            
            translate(-1*unit*z -1/2*unit*y)
            ball(1/4*unit, $class="gluteus muscle");
        }

        align(-z)
        ball(1/4*unit, anchor=-z, $class="semimembranosus biceps-femoris hamstrings muscle");
    }

    translate(1/4*unit*y)
    translate(1.5*unit*down){
        // ball(1/3*unit, anchor=-x-y, $class="adductor muscle head")
        align(y)
        ball(1/2*unit, anchor=center, $class="quadriceps muscle head");

        ball(1/3*unit, anchor=x-y+z, $class="semimembranosus biceps-femoris hamstrings muscle")
        align(y)
        ball(1/3*unit);
    }

    translate(1/4*unit*y)
    translate(2.5*unit*down)
    ball(d=1/4*unit, anchor=-y+z, $class="condyle bone"){
        ball(1.01*$parent_size, $class="adductor muscle");
        ball(1.01*$parent_size, $class="semimembranosus biceps-femoris hamstrings muscle");

        align(x-y+z)
        ball(1/3*unit, anchor=-y, $class="quadriceps muscle");

        align(x+y)
        ball($parent_size, anchor=center, $class="quadriceps muscle");

        align(y)
        ball(d=1/4*unit, anchor=-y, $class="condyle bone")
        ball(1.01*$parent_size, $class="semimembranosus biceps-femoris hamstrings muscle");

        align(x+y)
        ball(d=1/4*unit, anchor=x, $class="femur bone"){
            ball($parent_size, $class="quadriceps muscle");

            align(x)
            ball(1/4*unit, anchor=z, $class="kneecap bone")
            ball(1/4*unit, $class="quadriceps muscle");
        }
        
        align(y-z)
        ball(d=1/2*unit, anchor=z, $class="condyle bone"){
            align(-x+y)
            ball(d=1/6*unit, anchor=-x+y, $class="fibula bone")
            ball(1.01*$parent_size, $class="biceps-femoris hamstrings muscle");

            align(x)
            ball(d=1/4*unit, anchor=x, $class="tibia bone"){
                align(-x)
                ball(point, $class="quadriceps muscle");

                align(-y)
                ball(point, $class="semimembranosus hamstrings muscle");

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

module arm(){
    ball(d=1/4*unit, anchor=center, $class="humerus bone")
    ball(d=1/4*unit, $class="pectoral sternocostal-portion muscle")
    ball(d=1/4*unit, anchor=-y, $class="pectoral clavicular-portion muscle")
    ball(d=1/4*unit, $class="latissimus-dorsi muscle");
    ball(d=1/4*unit, $class="triceps muscle");
    
    translate(unit*y){
        ball(d=1/4*unit, anchor=y, $class="deltoid muscle");
        ball(d=1/4*unit, anchor=-x-z, $class="biceps muscle head");
        ball(d=1/4*unit, anchor=-x+z, $class="biceps muscle head");
        ball(d=1/4*unit, anchor=x-z, $class="triceps muscle head");
        ball(d=1/4*unit, anchor=x+z, $class="triceps muscle head");
    }
    
    translate(2*unit*y)
    ball(d=1/4*unit, anchor=center, $class="humerus bone"){
        align(z)
        box(point, $class="biceps muscle");
        
        ball(d=1/4*unit, anchor=z, $class="condyle bone");
        
        ball(d=1/4*unit, anchor=-z, $class="condyle bone");
        
        align(y){
            ball(d=1/4*unit, anchor=-y+z, $class="ulna bone")
            align(-x)
            ball(d=point, anchor=-x, $class="triceps muscle");
            
            ball(d=1/8*unit, anchor=-y-z, $class="radius bone")
            ball(d=1.1*1/8*unit, $class="biceps muscle");
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

module hand(){
    assign(palm=1/4*unit)
    assign(finger = palm/4){
        align(y-z)
        rod(d=palm, h=2*finger, orientation=x, anchor=-y, $class="carpals bone")
        align(y){
            finger(0, finger, 1);       // middle
            finger(1, finger, 0.9);     // index
            finger(-1, finger, 0.9);    // ring
            finger(-2, finger, 0.8);    // pinky

            translate(2*finger*z)       // thumb
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