// tower.scad
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

sample = false;
high = 120;
wide = 60;  // dist bewteen hinge axis
rad = 2;  // z-thickness: hinge radius
hr = rad * .6;
dr = rad * .4;
sep = 0.2;
hz0 = 30;
hz1 = 30;
sod = 4*rad; // standoff distance (l&r: x-dist, f&b: y-dist of standofff)

// 4 walls: right, front, left, back

// hinge btw fwall & rwall (also btw bwall & lwall)
module hingez() {
  len = 8;
  mnt0 = [sep, 90, -90];
  trr([0, rad, 0 + hz0]) hinge(len, hr, dr, mnt0);  // bottom hinge
  trr([0, rad, high-hz1]) mirror([0,0,1]) hinge(len, hr, dr, mnt0 ); // top hinge
}

module awall() {
  dx = (rad + sep);
  mnt0 = [sep, 90, -90];
  hingez();
  trr([dx, 0, 0]) cube([wide-sep, 2*rad, high]); // basic wall cube

  differenceN(1) {
#    trr([wide-rad,   0,    0]) cube([2*rad,   sod,    high]);
    trr([wide-rad-p, 0-p, 10]) cube([2*rad+pp, sod+pp, high-20]); // standoff
  }
  trr([wide, 5*rad, 0 + 0]) hinge(4, hr, dr, mnt0);  // standoff bottom
  trr([wide, 5*rad, high]) mirror([0,0,1]) hinge(4, hr, dr, mnt0 ); // standoff top

}
module fwall() {
  awall();
}
module bwall() {
  awall();
}

module swall(clr="tan") {
  dx = (rad + sep); // reduce width for hinge
  mnt0 = [sep, 90, -90];
  color(clr)
  trr([dx+sod-wide, 0, 0]) cube([wide-2*dx-sod, 2*rad, high]); // basic wall cube
* trr([-0*rad, 0, 0 ]) cube([wide+1*rad, 2*rad, high]);
}

module rwall() {
  swall("red");
}
module lwall() {
  swall("lavender");
}

// 0: print
// 1: upright
// 2: folded
// 3: expanded
loc = 3;
print=[wide-sod-rad-sep, 0, 0, [90,0,0]];
up = [0,0,0];
print2 = adif(print, [-(2*wide-sod+sep), 0, 0]);
up2 = adif(up, [-(2*wide+sep), 0, 0]);

atrans(loc, [print, up, 1, [0,0,0, [0, 0, -90, [0, rad, rad]]]])
rwall(); 
atrans(loc, [print, up, 1, [0,0,0, [0, 0,  -0, [0, rad, rad]]]])
fwall();

atrans(loc, [print2, up2, [wide,sod,0, [0,0,-0, [0, rad, rad]]], [wide,sod,0, [0,0,-90, [0, rad, rad]]]])
lwall();
atrans(loc, [print2, up2, [sod,0,0, [0,0,180, [0, 3*rad, 0]]], [wide,wide-sod,0, [0,0,180, [0, 3*rad, 0]]]])
bwall();

