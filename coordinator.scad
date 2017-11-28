len_button_box = 34;
len_jacks = 63;
len_control = 57;

width = 30;
width_usb = 12;
button_radius = 15;
button_offset = 5;

offset_usb = 10;

height = 33;
height_jacks = 9.8;
height_usb = 8;


wall=2;

difference() {
    cube([len_button_box + len_jacks + len_control + 2*wall, width + 2*wall, height + wall]);
    translate([wall, wall,-wall]) {
        cube([len_button_box + len_jacks + len_control, width, height + wall]);
    }
    translate([wall + len_button_box, -wall, -wall]) {
        cube([len_jacks, width + 4*wall, height_jacks + wall]);
    }
    translate([wall + button_offset + button_radius, wall+width/2, 0]) {
        cylinder(h=height + 2*wall, r = button_radius);
    }
    translate([wall+len_button_box + len_jacks + len_control, offset_usb, -wall]) {
        cube([3*wall, width_usb, height_usb + wall]);
    }
}