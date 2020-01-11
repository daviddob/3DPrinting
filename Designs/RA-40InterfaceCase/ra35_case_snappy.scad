
$fn = 60;

part = "all"; // lid, box, or all


str = "RA-35";
font="Arial Black";

/* Board variables */
width=45.84;
length=96.63;
//length=26.63;

usb_height=12;
usb_width=12;
usb_length=16.6;
usb_extend=6.2;

screw_d = 3.3;
screw_r = screw_d / 2;

screw_loffset = 3;
screw_woffset = 3;

db9_width = 31;
db9_height = 12.5;
db9_length = 18.2;
db9_extend = 11.6;

db9_caselip = 2; // 2mm drop behind the db9 connector

board_thickness = 1.5;

hole_extra = 0.5;

/* case variables */

case_thickness = 1.5;
case_standoff = 1.5;
case_spacing = 0;

screw_standoff_d = screw_d + 2;
screw_standoff_r = screw_standoff_d / 2;
screw_nub_r = screw_r * 0.8;

case_width = width + case_thickness*4 + case_spacing;
case_length = length + case_thickness*4 + case_spacing;
case_bottom_height = case_thickness/2 + case_standoff + db9_height;

case_hole_tolerance = 0.25;

case_lip = 2;

snap_percent = 0.9;
snap_offset = 1-snap_percent;


if (part == "all") {
    //translate([0, 0, case_thickness + case_standoff])    board_mockup();
}

if (part == "all" || part == "box") {
    case_bottom();
}
if (part == "all" || part == "lid") {
    color("red") case_top();
}

module ccube(s) {
    translate([0, 0, s[2]/2]) cube(s, center=true);
}

module rounded_bottom_box(size, r = 1, thickness = case_thickness, wall_thickness = -1, snap_side="in") {
    wall_thickness = wall_thickness == -1 ? thickness : wall_thickness;
    w=size[0];
    l=size[1];
    h=size[2];
    difference() {
        minkowski() {
            ccube([size[0] - 1, size[1] - 1, size[2] * 2]);
            sphere(r=r*1.75);
        }
        minkowski() {
            ccube([size[0] - 2 - wall_thickness*2, size[1] - 2 - wall_thickness*2, size[2]*5]);
            sphere(r=r);
        }

        translate([0, 0, size[2]]) ccube([size[0]+5, size[1]+5, size[2]*5]);
        if (snap_side == "in") {
            translate([w/2 - wall_thickness, l/2 - l*snap_offset/2, h-case_lip]) rotate([90,0,0]) cylinder(d=1.2,h=l*snap_percent,$fn=12);
            translate([-w/2 + wall_thickness, l/2 - l*snap_offset/2, h-case_lip]) rotate([90,0,0]) cylinder(d=1.2,h=l*snap_percent,$fn=12);
            translate([-w/2 + w*snap_offset/2, l/2-wall_thickness, h-case_lip]) rotate([0,90,0]) cylinder(d=1.2,h=w*snap_percent,$fn=12);
            translate([-w/2 + w*snap_offset/2, -l/2+wall_thickness, h-case_lip]) rotate([0,90,0]) cylinder(d=1.2,h=w*snap_percent,$fn=12);
        }
    }
    if (snap_side == "out") {
        translate([w/2 - case_thickness,l/2,size[2]-2]) rotate([90,0,0]) cylinder(d=1.2,h=l,$fn=12);
        translate([-w/2 + case_thickness,l/2,size[2]-2])rotate([90,0,0])cylinder(d=1.2,h=l,$fn=12);
        translate([-w/2, l/2-case_thickness, h-2])rotate([0,90,0])cylinder(d=1.2,h=w,$fn=12);
        translate([-w/2, -l/2+case_thickness, h-2])rotate([0,90,0])cylinder(d=1.2,h=w,$fn=12);
    }
}

module case_top() {
    difference() {
        union() {
            translate([0, 0, case_bottom_height+0.75]) rotate([180,0,0]) translate([0,0,-1]) difference() {
                rounded_bottom_box([case_width, case_length, 1+case_lip], r=1, lip_height=0, wall_thickness=case_lip*2, snap_side="none");
                translate([0, 0, 5]) rotate([180,0,0]) rounded_bottom_box([case_width+0.5, case_length+0.5, 5], r=1, wall_thickness=case_thickness*1.35);
                
                translate([0, 0, -3.5]) linear_extrude(2) rotate([180, 0, -90])
                    text(str, font = font, size=18, halign="center", valign="center");
            }
            translate([-usb_width/2 - case_hole_tolerance, length/2, case_bottom_height - usb_height + 1.7])
                cube([usb_width + case_hole_tolerance*2, case_lip*1.6, usb_height + case_hole_tolerance*2 ]);
            translate([-db9_width/2 - case_hole_tolerance, -length/2 - case_lip * 1.6, case_bottom_height - db9_height + case_thickness + 0.7])
                cube([db9_width + case_hole_tolerance*2, case_lip*1.6, usb_height + case_hole_tolerance*2 ]);
        }

        translate([-usb_width/2 - case_hole_tolerance, length/2 - usb_length + usb_extend, case_thickness + case_standoff + board_thickness - case_hole_tolerance])
            cube([usb_width + case_hole_tolerance*2, usb_length, usb_height + case_hole_tolerance*2]);
        translate([-db9_width/2 - case_hole_tolerance,-length/2 - db9_extend, case_thickness + case_standoff + board_thickness - case_hole_tolerance])
            cube([db9_width + case_hole_tolerance*2, db9_length, db9_height + case_hole_tolerance*2 - db9_caselip]);
        
        translate([0, case_length/2 - 8, 0]) {
            translate([case_width/2 - 7, -20, 0]) cylinder(100, screw_r, screw_r);
            translate([usb_width/2 + 8, 0, 0]) cylinder(100, screw_r, screw_r);
            translate([(usb_width/2 + 8)*-1, 0, 0]) cylinder(100, screw_r, screw_r);
        }
    }
}

module case_bottom() {
    difference() {
        translate([0, 0, 1.75]) rounded_bottom_box([case_width, case_length, case_bottom_height], r=1);
        
        // Hole for the USB jack
        translate([-usb_width/2 - case_hole_tolerance, length/2 - usb_length + usb_extend, case_thickness + case_standoff + board_thickness - case_hole_tolerance])
            cube([usb_width + case_hole_tolerance*2, usb_length, usb_height*2 + case_hole_tolerance*2]);
        
        // Hole for the DB9 connector
        translate([-db9_width/2 - case_hole_tolerance,-length/2 - db9_extend, case_thickness + case_standoff + board_thickness - case_hole_tolerance])
            cube([db9_width + case_hole_tolerance*2, db9_length, db9_height + case_hole_tolerance*2]);
    }
    
    // Add screw standoffs and nubs for holding it in place
    for (w = [1, -1]) {
        for (h = [1, -1]) {
            translate([width/2 * w, length/2 * h, case_thickness/2]) // to the edge
                translate([-screw_loffset * w, -screw_woffset * h, 0]) { // screwhole offset
                    cylinder(case_standoff + case_thickness/2, screw_standoff_r, screw_standoff_r);
                    color("blue") cylinder(case_standoff + board_thickness*2 + case_thickness/2, screw_nub_r, screw_nub_r);
                }
        }
    }
}

module board_mockup() {
    
    // Draw the board with the screw holes
    difference() {
        ccube([width, length, board_thickness]);
        
        // Screw holes
        for (w = [1, -1]) {
            for (h = [1, -1]) {
                translate([width/2 * w, length/2 * h, -hole_extra/2]) // to the edge
                    translate([-screw_loffset * w, -screw_woffset * h, 0]) { // screwhole offset
                        cylinder(board_thickness + hole_extra*2, screw_r, screw_r);
                    }
            }
        }
    }
    
    // Draw the USB jack
    translate([-usb_width/2, length/2 - usb_length + usb_extend, board_thickness])
        cube([usb_width, usb_length, usb_height]);
    
    // Draw a block for the DB9 connector
    translate([-db9_width/2,-length/2 - db9_extend,board_thickness])
        cube([db9_width, db9_length, db9_height]);
}

