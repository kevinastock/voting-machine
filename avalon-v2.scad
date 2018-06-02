wall = 0.95;

epsilon = 10;
infinity = 1000;

btn_shaft_diameter = 16.2;
btn_x1_offset = 3 + btn_shaft_diameter/2; // From positive x inner wall
btn_x2_offset = btn_x1_offset + 4.5 + btn_shaft_diameter; // From x1
btn_y_offset = 3 + btn_shaft_diameter/2; // From inner edge of wall

screw_minor_diameter = 1.95; // 1.84
screw_post_diameter = 3.5; // 3
screw_post_height = 13.5;
screw_length = 5;

feather_x_offset = 2.7; // From inner edge of wall
feather_y_offset = 15.3 + screw_post_diameter/2; // FIXME
feather_x_screw = 2.54*18;
feather_y_screw = 2.54*7;

pixels_x_offset = 12.7; // From center
pixels_y_offset = feather_y_offset + 7; // From inner edge of wall to closest edge of pixels mount FIXME
pixel_post_height = screw_length;


usb_width = 10;
usb_height = 3.2; // 5
usb_z_offset = -0.5; // From top of posts

switch_x = 5.2; // 5.4
switch_y = 11.8; // 11.6
switch_z = 4;
switch_z_offset = screw_post_height - usb_z_offset;

switch_y_window = 6;
switch_z_short = 0.5;

motor_diameter = 11;
motor_depth = 3.5;

inner_x = 61;
inner_y = feather_y_offset + feather_y_screw +  feather_x_offset;
inner_z = screw_post_height + 11.5;

battery_z = 7.3;
battery_tab_depth = 3;
battery_tab_z = min(1, wall);

screwdriver = 6;

$fn = 60;

module btn_hole(s) {
    translate([wall + inner_x - s, wall + btn_y_offset, -wall])
        cylinder(h=4*wall, d=btn_shaft_diameter, center=true);
}

module frame(h=inner_z) {
    difference() {
        hull() {
            translate([wall/2, wall/2, wall/2])
                sphere(d=wall);
            translate([wall/2 + wall + inner_x, wall/2, wall/2])
                sphere(d=wall);
            translate([wall/2, wall/2 + wall + inner_y, wall/2])
                sphere(d=wall);
            translate([wall/2 + wall + inner_x, wall/2 + wall + inner_y, wall/2])
                sphere(d=wall);
            
            translate([wall/2, wall/2, wall/2 + inner_z*2])
                sphere(d=wall);
            translate([wall/2 + wall + inner_x, wall/2, wall/2 + inner_z*2])
                sphere(d=wall);
            translate([wall/2, wall/2 + wall + inner_y, wall/2 + inner_z*2])
                sphere(d=wall);
            translate([wall/2 + wall + inner_x, wall/2 + wall + inner_y, wall/2 + inner_z*2])
                sphere(d=wall);
        }
        translate([0, 0, wall + h])
            cube([infinity, infinity, infinity]);
        translate([wall, wall, wall])
            cube([inner_x, inner_y, h + epsilon]);
    }  
}

module pixels_mount(s) {
    translate([wall + inner_x/2 + s * pixels_x_offset, wall + pixels_y_offset, wall - epsilon])
    {
        difference() {
            cylinder(h=pixel_post_height+epsilon, d=screw_post_diameter);
            translate([0,0,pixel_post_height + epsilon - screw_length])
            cylinder(h=screw_length+epsilon, d=screw_minor_diameter);
        }
    }
}

module screw_post(x, y) {
    translate([wall + feather_x_offset + x * feather_x_screw, wall + feather_y_offset + y * feather_y_screw, wall-epsilon])
    difference() {
        hull() {
            cylinder(h=screw_post_height-x+epsilon, d=screw_post_diameter);
            
            translate([-screw_post_diameter/2 - epsilon, -screw_post_diameter/2, 0])
                cube([screw_post_diameter/2 + epsilon,(-x+1)*screw_post_diameter,screw_post_height-x+epsilon]);
            
            translate([-screw_post_diameter/2, 0, 0])
                cube([y*screw_post_diameter,screw_post_diameter/2 + epsilon,screw_post_height-x+epsilon]);
        }
        translate([0,0,screw_post_height - x + epsilon - screw_length])
            cylinder(h=screw_length+epsilon, d=screw_minor_diameter);
    }
}

module battery_tab(l) {
    translate([0, 0, wall + inner_z - battery_z])
    rotate([0, 90,0])
    linear_extrude(l)
    polygon(points=[
        [0,0], 
        [0, battery_tab_depth],
        [0.8, battery_tab_depth],
        [battery_tab_z,0]]);
}

module controller() {
    intersection() {
        hull() frame();
        union() {
            difference() {
                frame();
                btn_hole(btn_x1_offset);
                btn_hole(btn_x2_offset);
                
                translate([-epsilon/2, wall + feather_y_offset + feather_y_screw/2 - usb_width/2, wall + screw_post_height - usb_z_offset - usb_height])
                    cube([wall + epsilon, usb_width, usb_height]);
                
                translate([-epsilon/2, wall + switch_y/2 - switch_y_window/2, wall + switch_z_offset - switch_z])
                    cube([wall + epsilon, switch_y_window, switch_z]);
               
            }

            pixels_mount(-1);
            pixels_mount(1);
            
            screw_post(0, 0);
            screw_post(0, 1);
            //screw_post(1, 0);
            screw_post(1, 1);

            translate([-epsilon + wall, -epsilon + wall, -epsilon + wall])
                cube([switch_x + wall + epsilon, switch_y + wall + epsilon, switch_z_offset - switch_z + epsilon]); 
                
            translate([-epsilon + wall, wall + switch_y, wall - epsilon + switch_z_offset - switch_z])
                cube([switch_x + epsilon, wall, switch_z + epsilon]);
            translate([wall + switch_x, wall + switch_y/2 - switch_y_window/2, wall - epsilon + switch_z_offset - switch_z])
                cube([wall, switch_y_window, switch_z_short + epsilon]);
            
            
            translate([wall + switch_x + wall, wall, wall - epsilon])
            difference() {
                cube([motor_depth + wall, motor_diameter + wall, motor_diameter/2 + epsilon]);
                translate([-wall, -wall, wall])
                    cube([motor_depth + wall, motor_diameter + wall, motor_diameter/2 + epsilon]);
            }
               
            difference() {
                union() {
                    translate([wall, wall, 0])
                    battery_tab(inner_x);
                    
                    translate([wall, wall+inner_y, 0])
                    mirror([0,1,0])
                    battery_tab(inner_x);
                    
                    translate([wall, wall, 0])
                    mirror([1, 0, 0])
                    rotate([0,0,90])
                    battery_tab(inner_y);
                    
                    translate([inner_x + wall, wall, 0])
                    rotate([0,0,90])
                    battery_tab(inner_y);
                }
                
                translate([wall + feather_x_offset + 0 * feather_x_screw, wall + feather_y_offset + 0 * feather_y_screw, 0])
                cube([screwdriver, screwdriver, infinity], center = true);

            translate([wall + feather_x_offset + 1 * feather_x_screw, wall + feather_y_offset + 1 * feather_y_screw, 0])
                cube([screwdriver, screwdriver, infinity], center = true);
            
            translate([wall + feather_x_offset + 0 * feather_x_screw, wall + feather_y_offset + 1 * feather_y_screw, 0])
                cube([screwdriver, screwdriver, infinity], center = true);
            
            translate([wall + inner_x, wall + inner_y/2, 0])
                cube([screwdriver, screwdriver, infinity], center = true);
            }
        }
    }
}

controller();