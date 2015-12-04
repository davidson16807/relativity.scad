include <relativity.scad>

unit=84;
eye=unit/5;

echo(eye/2);
echo(unit/8);



module skin(){
    
    hull()
    show("jaw,cheek")
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
        show("cranium,forehead,occiput,arch,cheek")
        mirrored(y)
        children();
        
        mirrored(y)
        hulled("socket", $class="socket")
        children();
    }
}

module debug(){
    mirrored(y)
    hide("socket")
    colored("blue", "brow")
    colored("black", "grid")
    colored("green", "nose")
    colored("orange", "cheek")
    colored("red", "jaw")
    colored([1,1,1,0.7])
    children(); 
}

//skin()
debug()
ball(unit, anchor=-z, $class="cranium"){
    translate(1/2*eye*y)
    translated(eye*y, n=[-5:5], $class="grid")
    box(d=.3);

    translate(1/2*eye*z)
    translated(eye*z, n=[-5:5], $class="grid")
    rotated(90*x)
    box(d=.3);

    align(x)
    ball(1/8*unit, anchor=-x-y-z, $class="brow");
    
    align(x)
    ball(1/8*unit, anchor=-x+z, $class="nose");

    align(-x-z)
    translate(-1/32*unit*x + 1/16*unit*z)
    ball(1/2*unit, anchor=-x-z, $class="occiput");

    align(-x-z)
    translate(1/16*unit*y)
    ball(3/4*unit, anchor=-x-z, $class="occiput");
    
    align(z)
    translate(1/8*unit*x)
    ball([1, 3/4, 1]*unit, anchor=z, $class="forehead");

    align(x)
    translate(1/2*eye*x+1/12*unit*y+1/2*eye*z)
    ball(2/3*unit, anchor=x, $class="forehead");

    align(x)
    ball(3/2*eye, anchor=-y+z, $class="orbit"){
        
        ball(7/4*eye, $class="arch"); 
        
        ball(3/2*eye, anchor=-x, $class="socket")
        ball(3/2*eye, anchor=-y);
        
        ball(eye, $class="eye");
    }
    
    
    
    align(bottom)
    box([1/5*unit, 3*eye, infinitesimal], anchor=-x+z, $class="jaw")
    align(x)
    box([infinitesimal, 3*eye, eye], anchor=-x+z){
        
        //todo: simplify this
        align(y+z, $class="cheek")
        ball(3/2*eye, anchor=-z)
        align(x)
        ball(1*eye, anchor=center)
        align(x)
        ball(1/2*eye, anchor=center)
        align(z)
        ball(1/2*eye, anchor=center);
        
        align(-x)
        translate(1/2*unit*x)
        ball(d=1/3*unit, anchor=x){
            align(-x-z)
            rotate(30*y)
            rod(d=1/2*unit, h=infinitesimal, anchor=center);
            
            align(x+z)
            ball(eye, anchor=x-z, $class="nose"){
                align(y)
                ball(1/2*eye, anchor=z);
                align(y)
                ball(1/2*eye, anchor=x-z, $class="cheek");
                
                align(x)
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



    module head(){
        ball(d=unit, anchor=-z, $class="cranium"){
            
            color("blue")
            align(-x-z)
            translate(-1/32*unit*x + 1/16*unit*z)
            ball(1/2*unit, anchor=-x-z, $class="occiput");

            align(-x-z)
            translate(1/16*unit*y)
            ball(3/4*unit, anchor=-x-z, $class="occiput");    
            
            align(z)
            translate(1/8*unit*x)
            ball([1, 3/4, 1]*unit, anchor=z, $class="forehead");

            align(x)
            translate(1/2*eye*x+1/12*unit*y+1/2*eye*z)
            ball(2/3*unit, anchor=x, $class="forehead");
            
            align(x)
            ball(1.5*eye, anchor=z, $class="orbit"){
                ball(7/4*eye, $class="arch");
                
                ball(3/2*eye, anchor=-x, $class="socket")
                ball(3/2*eye, anchor=-y);
                
                ball(eye, $class="eye");
            }

            align(-z)
            translated(1/5*unit*x)
            box([infinitesimal, 3*eye, eye], anchor=-x+z, $class="jaw"){
                
                align(y+z, $class="cheek")
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
                            ball(1/2*eye, anchor=x-z, $class="cheek");
                            
                            align(x)
                            ball(1/2*eye, anchor=center);
                        }
                        
                        translate(-eye*z)
                        ball(1/2*eye,anchor=-x-y+z);
                    }
                    
                }
            }

            align(-z)
            assign($class="neck")
            children();
        }
    }


color([.2,.2,.2,0.5])
translate(-10*x +1.8*y -5*z)
rotate(27*y)
rotate((40.+90)*z)
import("/home/carl/Downloads/skull_Fill_Build_Space.stl");
