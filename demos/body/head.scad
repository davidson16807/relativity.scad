include <relativity.scad>

unit=84;
eye=unit/5;

color("black")
translate(eye/2*y)
translated(eye*y, n=[-5:5])
box(d=.3);

color("black")
translated(eye*z, n=[-5:5])
rotated(90*x)
box(d=.3);


module skin(){
    
    hull()
    show("jaw,zygomatic")
    mirrored(y)
    children();
    
    show("eye")
    mirrored(y)
    children();
    
    differed("socket")
    {
        hull()
        show("nose")
        mirrored(y)
        children();
        
        hull()
        show("cranium,forehead,occiput,arch,zygomatic")
        mirrored(y)
        children();
        
        mirrored(y)
        hulled("socket", $class="socket")
        children();
    }
}

//skin()
ball(unit, anchor=-z, $class="cranium"){
        color("blue")
        align(x)
        ball(unit/8, anchor=-x-y);
        color("blue")
        align(x)
        ball(1/2*eye, anchor=-x+z, $class="nose");
    
        color("lightblue")
        align(-x-z)
        translate(5*y)
        ball(3/4*unit, anchor=-x-z, $class="occiput");
        
        color("lightblue")
        align(z)
        translate(unit/8*x)
        ball([1,6/8,1]*unit, anchor=z, $class="forehead");
    
        color("lightgreen")
        align(x)
        translate(1/2*eye*x+7*y+1/2*eye*z)
        ball(2/3*unit, anchor=x, $class="forehead");
    
        color("blue")
        align(x)
        translate(eye*y)
        ball(1.5*eye, anchor=z, $class="orbit"){
            
            
                ball(7/4*eye, $class="arch");
                
                ball(3/2*eye, anchor=-x, $class="socket")
                ball(3/2*eye, anchor=-y);
            
            
            ball(eye, $class="eye");
        }
        
        
        
        color("green")
        align(bottom)
        box([eye, 3*eye, infinitesimal], anchor=-x+z, $class="jaw")
        align(x)
        box([1/2*eye, 3*eye, eye], anchor=-x+z){
            
            //todo: simplify this
            align(y+z, $class="zygomatic")
            ball(1.5*eye, anchor=-z)
            align(x)
            ball(1*eye, anchor=center)
            align(x)
            ball(1/2*eye, anchor=center)
            align(z)
            ball(1/2*eye, anchor=center);
            
            align(-x)
            translate(1/2*unit*x)
            ball(d=1/3*unit, anchor=x){
                align(x+z)
                ball(eye, anchor=x-z, $class="nose"){
                    align(y)
                    ball(1/2*eye, anchor=x);
                    align(y)
                    ball(1/2*eye, anchor=x, $class="zygomatic");
                    
                    align(x)
                    translate(2*x)
                    ball(1/2*eye, anchor=center);
                }
                
                translate(-eye*z)
                ball(1/2*eye,anchor=-x-y+z);
            }
        }
        

        align(-z)
        assign($class="neck")
        children();
    }

color([1,0,0,.6])
translate(-10*x +1.8*y -5*z)
rotate(27*y)
rotate((40.+90)*z)
import("/home/carl/Downloads/skull_Fill_Build_Space.stl");
