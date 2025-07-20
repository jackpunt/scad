// tower.scad
use <mylib.scad>;

p = .003;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

sample = false;
rad = 2.4;  // z-thickness: hinge radius
high = 130;
wide = 60-rad;  // dist bewteen hinge axis
hr = rad * .6;
dr = rad * .4;
sep = 0.2;
sod = 4*rad; // standoff distance (l&r: x-dist, f&b: y-dist of standofff)
dw = 1*rad;

dieSize = 12;
module die(trr = [0,0,0], dieSize = dieSize, clr = "red") {
  trr(trr)
  color(clr) roundedCube(dieSize);
}

// 4 walls: right, front, left, back

function hangle() = -90;

// hinge btw awall & swall; socket attached to swall (so needs to rotate with swall)
module hingez() {
  sang = [90, 90, 90, 0, 0, 90][loc];
  mnt0 = [sep, sang, -90];
  trr([0, rad, 0+0])                  hinge([30, 10], hr, dr, mnt0); // bottom hinge
  trr([0, rad, 70]) mirror([0,0,1])   hinge([20, 10], hr, dr, mnt0); // botton-m

  trr([0, rad, high-60])              hinge([20, 20], hr, dr, mnt0); // top hinge
  trr([0, rad, high]) mirror([0,0,1]) hinge([10, 10], hr, dr, mnt0); // top-m
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
  dh = high / 2;
  dx = (rad + sep);
  sang = [0, 90, 90, 0, 0, 0][loc];
  mnt0 = [sep, 180, sang];
  hingez();
  trr([dx, 0, 0]) cube([wide-sep, 2*rad, high]); // basic wall cube

  differenceN(1) // standoff
  {
    trr([wide-rad,   0,   0]) cube([2*rad,    sod,    high]);     // standoff
  }
  trr([wide, 5*rad, 0   ])                 hinge([dh, dh], hr, dr, mnt0); // standoff bottom hinge
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
    trr([dw+.5,-1,zz-2*rad+sep]) cube([wide-2*dw-1,3*rad, 2*rad+2*rad+pp]);
    trr([0, 0, zz]) scalet([sx, sf, 1, [-wide/2, 0, zs]]) flapf1(h, a);
  }
  ang = [-90, -90, 0, a, a, a][loc]; // display angle
  trr([0, 0, zz]) flapf1(h, ang); // sep tilts to: 126
}
module cutFront(h = 30, pp=pp) {
  difference() {
    children();
    trr([dw, -pp, -pp]) cube([wide-2*dw, 2*(rad+pp), h]);
  }
}
module fwall() {
  zz = high/2;
  cutFront()
  addFlap(75,  40, -130)
  awall();
}
module bwall() {
  addFlap(high - 35, 30, -125)
  addFlap(40, 49, -125)
  awall();
}

// side wall (no flaps)
module swall(clr="tan") {
  dx = (rad + sep); // reduce width for hinge
  mnt0 = [sep, 90, -90];
  color(clr)
  trr([dx+sod-wide, 0, 0]) cube([wide-2*dx-sod, 2*rad, high]); // basic wall cube
// % trr([00-wide, p, -8 ]) cube([wide, 2*rad, high]); // virtual side-wall
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
// 4: open wall
// 5: bwall only?
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
atrans(loc, [print2, up2, rr(sod, sod, 180), rr(wide, wide-sod, 180, 3*rad), 3, 0])
bwall();

d = 3;
atrans(loc, [undef, 0, 0, 0, [0,0,0]] ) die([30, 20+d, 60-d], 15, "grey");
