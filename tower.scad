// tower.scad
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

sample = false;
high = 125;
wide = 60;  // dist bewteen hinge axis
rad = 2.6;  // z-thickness: hinge radius
hr = rad * .6;
dr = rad * .4;
sep = 0.2;
hz0 = 30;
hz1 = 30;
sod = 4*rad; // standoff distance (l&r: x-dist, f&b: y-dist of standofff)
dw = 1*rad+2;

// 4 walls: right, front, left, back

// hinge btw fwall & rwall (also btw bwall & lwall)
module hingez() {
  len = 8;
  mnt0 = [sep, 90, -90];
  trr([0, rad, 0 + hz0]) hinge(len, hr, dr, mnt0);  // bottom hinge
  trr([0, rad, high-hz1]) mirror([0,0,1]) hinge(len, hr, dr, mnt0 ); // top hinge
}

// crr @ [0, 0, rad]
// h: height between cylinders
// dw: inset from wide
// r: radius of cylinder, thicnkess of flap = 2*rad
module aflap(h, dw = dw, r = rad) {
  d = 2*rad;
  hull() dup([0, d, 0]) trr([dw, 0, rad, [0, 90,0]]) cylinder(wide-2*dw, r, r);
  hull() dup([0, 0, h]) trr([dw, d, rad, [0, 90,0]]) cylinder(wide-2*dw, r, r);
}



// front/back wall; (add flaps)
module awall() {
  dx = (rad + sep);
  mnt0 = [sep, 90, -90];
  hingez();
  trr([dx, 0, 0]) cube([wide-sep, 2*rad, high]); // basic wall cube

  c = 10; // cut differential
  differenceN(1) // standoff (with center cut)
  {
    trr([wide-rad,   0,   0]) cube([2*rad,    sod,    high]);     // standoff
    trr([wide-rad-p, 0-p, c]) cube([2*rad+pp, sod+pp, high-2*c]); // center cut
  }
  trr([wide, 5*rad, 0   ])                 hinge(4, hr, dr, mnt0);  // standoff bottom hinge
  trr([wide, 5*rad, high]) mirror([0,0,1]) hinge(4, hr, dr, mnt0); // standoff top hinge

}

module flapf1(h = wide*.6, a = -90) {
  trr([0, rad, 0, [a, 0, 0, [0, 0, rad]]]) aflap(h, dw+1);
}
echo ("sf = ",   (rad+1*sep)/ rad);// 1.05;);
module addFlap(zz, h = 30, a = -125) {
  sx = 1.02;
  sf =  (rad+1*sep)/ rad;// 1.077;
  zs = rad;
  difference() {
    children();
    trr([0, 0, zz]) scalet([sx, sf, sf, [-wide/2, 0, zs]]) flapf1(h, -a);
    trr([0, 0, zz]) scalet([sx, sf, sf, [-wide/2, 0, zs]]) flapf1(h, -90);
    trr([0, 0, zz]) scalet([sx, sf, sf, [-wide/2, 0, zs]]) flapf1(h, -0);
  }
  ang = [-90, -90, 0, a, a][loc];
  trr([0, 0, zz]) flapf1(h, ang); // sep tilts to: 126
}
module cutFront(h = 30) {
  difference() {
    children();
    trr([dw, -p, -p]) cube([wide-2*dw, 2*rad+pp, h]);
  }
}
module fwall() {
  zz = high/2;
  cutFront()
  addFlap(high - 50,  40, -130)
  awall();
}
module bwall() {
  addFlap(high - 35, 30)
  addFlap(high - 80, 50, -130)
  awall();
}

// side wall (no flaps)
module swall(clr="tan") {
  dx = (rad + sep); // reduce width for hinge
  mnt0 = [sep, 90, -90];
  color(clr)
  trr([dx+sod-wide, 0, 0]) cube([wide-2*dx-sod, 2*rad, high]); // basic wall cube
* trr([00-wide, p, -8 ]) cube([wide, 2*rad, high]); // virtual side-wall
}

module rwall() {
  swall("red");
}

module lwall() {
  swall("lavender");
}
// 
function rr(w, s=0, a=-90, r=rad) = [w,s,0, [0,0,a, [0, r, 0]]];

// 0: print
// 1: upright
// 2: folded
// 3: expanded
loc = 4;
swx = wide - sod - rad;
dx0 = wide-sod-rad-sep; // align rwall @ x=0
dxp = 2*wide-sod+sep;   // align lwall to right
print  = [swx-sep, 0, 0, [90, 0, 0]];
print2 = [swx+wide+swx+rad, 0, 0, [90, 0, 0]];

print2a = adif(print, [-dxp, 0, 0]);
up = [0,0,0];
up2    = adif(up,    [-(2*wide+sep    ), 0, 0]);

atrans(loc, [print, up, 1, rr(0, 0, -90), 3])
rwall(); 
atrans(loc, [print, up, 1, rr(0, 0, 0), 3])
fwall();

atrans(loc, [print2, up2, rr(wide, sod, 0), rr(wide, sod, -90), undef])
lwall();
atrans(loc, [print2, up2, rr(sod, sod, 180), rr(wide, wide-sod, 180, 3*rad), 3])
bwall();

