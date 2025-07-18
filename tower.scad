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
wide = 60;
hr = 3;
dr = 2;
rad = hr + dr;  // z-thickness: hinge radius

// 4 walls: right, front, left, back
module rwall() {
  cube([wide, high, rad]);
}

module fwall() {

}

module lwall() {

}

module bwall() {

}

rwall(); 
fwall();
lwall();
bwall();
