in_h = 6;
in_w = 27;
wall = 3;
thickness = 1.5;

button_width = 8;
button_height = button_width / 2;
button_off_center = 7.5;
button_base_depth = 3;

align_r = 2.3;

cable_thickness = 3.5;

$fn = 90;


module exterior() {
   translate([0,0,in_h/2]) {
        minkowski() {
          cube([in_w,in_w,in_h],center=true);
          sphere(wall);
        }
    }
}

module interior() {
    translate([0,0,in_h/2]) {
    resize(newsize=[in_w+wall*2 - thickness*2, in_w+wall*2 - thickness*2, in_h+wall*2 - thickness*2]) {
        minkowski() {
          cube([in_w,in_w,in_h],center=true);
          sphere(wall);
        }
    }
}
}

module button_plate(offset) {
    intersection() {
        translate([in_w/2 + wall, offset, 0]) {
            translate([-thickness/2 - button_base_depth, 0, 0]) {
                cube([thickness, button_width*0.6, 1000], center = true);
            }
        }
        
        exterior();
        
        translate([0,0,5000]) {
            cube(10000, center=true);
        }
    }
}

module top_shell(flat) {   
    difference() {
        if (flat) {
            translate([0,0,in_h/2])
            linear_extrude(height=in_h+wall*2, center=true)
            projection() {
                exterior();
            }
        } else {
            exterior();
        }
        
        translate([0,0,-5000]) {
            cube(10000, center=true);
        }
        
        interior();
        
        
        translate([5000, button_off_center, button_height/2]) {
            cube([10000, button_width, button_width/2], center = true);
        }

        translate([5000, -button_off_center, button_height/2]) {
            cube([10000, button_width, button_width/2], center = true);
        }
    
        rotate([0,-90,0])
        cylinder(1000, cable_thickness/2);
            
    }

    button_plate(button_off_center);
    button_plate(-button_off_center);
    
    intersection() {
        interior();
        translate([(in_w + wall - thickness)/2, (in_w + wall - thickness)/2, 0])
        cylinder(h=in_w, r=align_r, center=true);
    }
    intersection() {
        interior();
        translate([-(in_w + wall - thickness)/2, -(in_w + wall - thickness)/2, 0])
        cylinder(h=in_w, r=align_r, center=true);
    }
}



translate([20, 0, in_h+wall]) rotate([180,0,0]) top_shell(false);
translate([-20, 0, in_h+wall]) rotate([180,0,0]) top_shell(true);



