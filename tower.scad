// tower.scad
use <mylib.scad>;

p = .003;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

sample = false;
rad = 2.3;  // z-thickness: hinge radius (2.3mm)
wide = 60-2*rad;  // dist bewteen hinge axis
w60 = wide/60;  // scale factor for flap length
high = 127.4;   // 125 + rad?

hr = rad * .6;
dr = rad * .4;
sep = 0.2;
sod = 4*rad; // standoff distance (l&r: x-dist, f&b: y-dist of standofff)
dw = rad+4;  // inset of hole for flap (final flap may be narrower)

dieSize = 12;
module die(trr = [0,0,0], dieSize = dieSize, clr = "red") {
  trr(trr)
  color(clr) roundedCube(dieSize, 1, false, true);
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

// crr @ [0, 0, 0]
// h: height between cylinders
// dw: inset from wide (each side)
// r: radius of cylinder, thicnkess of flap = 2*rad
module aflap(h, dw = dw, r = rad) {
  d = 2*r;
  hull() dup([0, d, 0]) trr([dw, 0, 0, [0, 90, 0]]) cylinder(wide-2*dw, r, r); // down (y=-d) from hinge axis
  hull() dup([0, 0, h]) trr([dw, d, 0, [0, 90, 0]]) cylinder(wide-2*dw, r, r);
  trr([0, 0, 0, [0, 90, 0]]) color("cyan") cylinder(h = wide+4*rad, r = .1);
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

// make flap rotated, and move to wall
module flapf1(h = wide*.9, a = -90, dw = dw, sf = 1) {
  trr([0, rad, 0, [a, 0, 0]]) scalet([1, sf, 1, [0, 0, 0]]) aflap(h, dw);
}
echo ("sf = ",   (rad+1*sep)/ rad);// 1.05;);
module addFlap(zz, h = 30, a = -125, dw = dw) {
  iw = sep;
  dwf = dw + iw;          // inset from wall
  fw = wide - 2*dwf;      // final width of flap
  dx = dw; // shrink the box to match flapf1 () *(sx+.14)
  sf =  (rad+sep)/ rad;// 1.077;
  zs = rad;
  // trr([-2*rad, 1*rad, 1*rad+zz, [0, 90, 0]]) color("cyan") cylinder(h = wide+4*rad, r = .1);
  difference() {
    children();
    trr([dx, -pp, zz-3*rad+sep]) cube([wide-2*dx, 2*rad+4*pp, 4*rad+pp]);
    trr([0, 0, zz]) flapf1(h, a, dw, sf);
  }
  // [print, upright, folded, open,...]
  ang = [-90, -90, 0, a, a, a][loc]; // display angle
  trr([0, 0, zz]) flapf1(h, ang, dwf ); // sep tilts to: 126
}
module cutFront(h = 30, dw = rad, pp=pp) {
  difference() {
    children();
    trr([dw, -pp, -pp]) cube([wide-2*dw, 2*(rad+pp), h]);
  }
}
fz0 = 35;
fz1 = 70;
fz2 = 95; // high - f2-2*rad

module fwall() {
  fh1 = 40 * w60;
  cutFront()
  addFlap(fz1, fh1, -130)
  awall();
}
module bwall() {
  fh2 = 30 * w60;
  fh0 = 49 * w60;
  addFlap(fz2, fh2, -125)
  addFlap(fz0, fh0 , -125)
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

d = -3;
atrans(loc, [undef, 0, 0, 0, [0,d,-d]] ) die([wide/2, wide/2, fz1-6.2, [70, 45, 0]], 15, "grey");
