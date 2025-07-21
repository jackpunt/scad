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

// h-h, h, h-m
module hinge2m(hh = 3, hr=1.5, dr=2, mnts=1.5, sep=.2) {
  hh = def(hh, [3, 6, 3]); 
  h0 = is_list(hh) ? hh[0] : hh;
  h1 = is_list(hh) ? hh[1] : hh;
  h2 = is_list(hh) ? hh[2] : hh;
  rad = hr + dr;
  trr([0, rad, h0+h1/2]) mirror([0,0,1])   
  hinge([h1/2, h0], hr, dr, mnts, sep); // mirror at bottom
  trr([0, rad, h0+h1/2])
  hinge([h1/2, h2], hr, dr, mnts, sep); // bottom hinge
}

// 4 walls: right, front, left, back

function hangle() = -90;

// hinge btw awall & swall; socket attached to swall (so needs to rotate with swall)
module hingez0() {
  sang = [90, 90, 90, 0, 0, 90, 90][loc];
  mntb = [sep, sang, -90];
  mnt0 = [sep, sang, -90];
  // hinge2m([40, 20, 10], hr, dr, mntb);
  trr([0, rad, 50]) mirror([0,0,1])   hinge([10, 40], hr, dr, mntb); // botton-m
  trr([0, rad, 50])                   hinge([10, 10], hr, dr, mntb); // bottom hinge

  trr([0, rad, 90]) mirror([0,0,1])   hinge([10, 10], hr, dr, mnt0); // botton-m
  trr([0, rad, 90])                   hinge([10, high-100], hr, dr, mnt0); // top hinge
}
function flatten(l) = [ for (a = l) for (b = a) b ] ;

// h, h-m, h
// make column of hinge segments in z direction
// hh: height of each segment of hinge (hh[i]<0 --> mirror(0,0,1))
module hingez(hh , hr=hr, dr=dr, mnts=1.5, sep=.2) {
  function absi(hh, n = 0) = abs(is_list(hh) ? hh[n] : hh);
  hh = def(hh, [[5,5]]);
  // hf = flatten(hh);
  sang = [90, 90, 90, 0, 0, 90, 90][loc];
  mntb = [sep, sang, -90];
  rad = hr + dr;
  hp0 = [ for (h = hh) absi(h ,0) ];
  hp1 = [ for (h = hh) absi(h, 1) ]; 
  // echo("hh=", hh);
  for (i = [0 : len(hh)-1]) {
    let(z0 = sumi(hp0, i), z1 = sumi(hp1, i), hii = hh[i], hi = is_list(hii) ? hii : [abs(hii), abs(hii), sign(hii)], ht = def(hi[2], 1))
    // echo("hi=", hi, "ht=", ht, "z0=", z0, "z1=", z1)
    if (ht != 0) {
    if (ht > 0) {
      trr([0, rad, z0+z1-hi[0]-hi[1]])
      hinge(hi, hr, dr, mntb, sep);
    } else {
      trr([0, rad, z0+z1+sep])
      mirror([0,0,1]) 
      hinge([hi[1], hi[0]], hr, dr, mntb, sep);
    }
    }
  }
}

// crr @ [0, 0, 0]
// h: height between cylinders
// dw: inset from wide (each side)
// r: radius of cylinder, thicnkess of flap = 2*rad
module aflap(h, dw = dw, r = rad) {
  d = 2*r;
  hull() dup([0, d, 0]) trr([dw, 0, 0, [0, 90, 0]]) cylinder(wide-2*dw, r, r); // down (y=-d) from hinge axis
  hull() dup([0, 0, h]) trr([dw, d, 0, [0, 90, 0]]) cylinder(wide-2*dw, r, r);
  if (loc != 0 && loc != 6) trr([0, 0, 0, [0, 90, 0]]) color("cyan") cylinder(h = wide+4*rad, r = .1);  // axis line
}

// front/back wall; (add flaps)
module awall(hinga = [10, 10, 10]) {
  dh = high / 2;
  dx = (rad + sep);
  sang = [0, 90, 90, 0, 0, 0, 0][loc];
  mnt0 = [sep, 180, sang];
  hingez(hinga);
  trr([dx, 0, 0]) cube([wide-sep, 2*rad, high]); // basic wall cube

  differenceN(1) // standoff
  {
    trr([wide-rad,   0,   0]) cube([2*rad,    sod,    high]);     // standoff
  }
  trr([wide, 5*rad, 0   ]) hinge([dh, dh], hr, dr, mnt0); // standoff bottom hinge
}

// make flap, maybe scaled, rotate, and move to wall
module flapf1(h = wide*.9, a = -90, dw = dw, sf = 1) {
  trr([0, rad, 0, [a, 0, 0]]) scalet([1, sf, 1, [0, 0, 0]]) aflap(h, dw);
}
echo ("sf = ",   (rad+1*sep)/ rad);// 1.05;);

// make some dimples to remove from 'top' of flap
module dimples(w, h, r = rad, d10=rad, d20=rad) {
  d10 = def(d10, r);
  d20 = def(d20, r);
  d1 = [d10, 3*r, w];
  d2 = [d20, 4*r, h];
  echo("dimples: d1, d2=", d1, d2);

  gridify(d1, d2, 2) // XY plane
   scale([1.4, 1.2, .35]) sphere(r);
}
    
module addFlap(zz, h = 30, a = -125, dw = dw) {
  iw = sep;
  dwf = dw + iw;          // inset from wall
  fw = wide - 2*dwf;      // final width of flap
  dx = dw; // shrink the box to match flapf1 () *(sx+.14)
  sf =  (rad+sep)/ rad;// 1.077;
  zs = rad;
  h0 = dw-rad-sep; //1.5*rad; // dw = rad+4;

  differenceN(1) {
    children();
    trr([rad+iw, rad, zz, [0,90,0]]) cylinder(h = wide - 2*(rad+iw), r = rad); // hinge hole
    trr([dx, -pp, zz-3*rad+iw]) cube([wide-2*dx, 2*rad+4*pp, 4*rad+pp]); // main box
    trr([0, 0, zz]) flapf1(h, a, dw, sf);  // tilted flap
  }
  trr([0    + (dw-h0), 1*rad, zz, [0,  90, 0]]) hinge([h0, h0], hr, dr, 0, sep);
  trr([wide - (dw-h0), 1*rad, zz, [0, -90, 0]]) hinge([h0, h0], hr, dr, 0, sep);
  // [print, upright, folded, open,...]
  ang = [-90, -90, 0, a, a, -90, -90][loc]; // display angle
  z0 = -rad;
  trr([0, 0, zz, [ang+90, 0, 0, [0, rad, 0]]])  // rotate *after* dimples (@-90)
  differenceN(1) {
    flapf1(h, -90, dwf ); // sep tilts to: 126
    trr([5*rad+iw, 3*rad, z0]) dimples(fw-2*rad, h, rad, -rad/2);
    trr([5*rad+iw, 4.5*rad, z0]) dimples(fw-4*rad, h-3*rad, rad, 1*rad, 1.5*rad);
  }
}
module cutFront(h = 30, dw = rad) {
  difference() {
    children();
    trr([dw, -pp, -pp]) cube([wide-2*dw, 2*(rad+pp), h]);
  }
}

gateH = 50;
// h: height of hole (same as for cutFront)
// dw: thickness of edge outside of hole (same as for cutFront: rad)
// dg: thickness of gate (rad)
// ys: y-extent (2*rad)
module gate(h = gateH, dw = rad, dg = rad, ys = 2*rad) {
  dws = dw+sep;              // offset to outer edge of gate
  gw = wide - 2 * dws;       // total width of gate
  hh = max(dg, dw);    // hinge height (along axis)
  gap = sep * 4;       // gap for bar rotation clearance
  bm = 3.8 * rad;      // bar height
  differenceN(2) {
    color("cyan")
    trr([dw+sep, 0, h-dg-gap]) roundedCube([gw, bm, dg], bm/2, true);
    color("cyan")
    trr([dw+sep,       0, 2*rad]) cube([gw,      ys,      h-2*rad-gap]);
    trr([dw+sep+dg, -pp, -pp]) cube([gw-2*dg, ys+2*pp, h-dg-gap]);
  }
  trr([dg+sep   , rad, 0, [0, -90, 0, [0, 0, hh]]]) 
  hinge(hh, hr, dr, [.1, -90, 0]  );

  trr([dg+sep+gw, rad, 0, [0, 90, 0, [0, 0, hh]]]) 
  hinge(hh, hr, dr, [.1,  90, 0]  );
}

// a beveled block to stop gate at vertical
// child is gate
module gateStop(dw=rad, z = gateH-10) {
  a = 30;
  dws = dw + sep;
  gw = wide - 2 * dws + dw;
  intersection() {
    trr([gw+.2, 2 * rad, z, [0, 0, +a]]) cube([rad, 2*rad, rad], center = true);
    trr([sep+p, 0, 0]) children(0);
  }
  intersection() {
    trr([0+dw , 2 * rad, z, [0, 0, -a]]) cube([rad, 2*rad, rad], center = true);
    trr([-sep-p, 0, 0]) children(0);
  }

  difference() {
    children();
    trr([gw+.1, 1.99 * rad, z, [0, 0, +a]]) cube([rad, 2.2*rad, 1.4*rad], true);
    trr([dw+.1 , 1.99 * rad, z, [0, 0, -a]]) cube([rad, 2.2*rad, 1.4*rad], true);
  }
}

// flap heights: 
fz0 = 35;
fz1 = 70;
fz2 = 95; // high - f2-2*rad

module fwall() {
  fh1 = 40 * w60;
  gh = gateH; 
  mh = (110 - gh - 20)/5 ;
  cutFront(gh)
  addFlap(fz1, fh1, -130)
  awall([[gh+10, 10, -1], mh, -mh, [mh, high-110-sep]]);

  atrans(loc, [[0, 0, 0], 0, 0, 0, [0,0,0, [90,0,0, [0, rad, rad]]], 0, 0]) 
  gateStop()
  gate(gh, rad);
}
module bwall() {
  fh2 = 30 * w60;
  fh0 = 49 * w60;
  addFlap(fz2, fh2, -125)
  addFlap(fz0, fh0 , -125)
  awall([[20, 20, -1], 15, -15, [10, high-110-sep]]);
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
// rotate wall into postion for loc
// w: wide; s: y-offset; a: angle; r: rad
function rr(w, s=0, a=-90, r=rad) = [w, s, 0, [0, 0, a, [0, r, 0]]];

// 0: print
// 1: upright (no rotations)
// 2: folded
// 3: expanded
// 4: open wall
// 5: bwall only (print orientation)
// 6: fwall only (print orientation)
loc = 5;

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
atrans(loc, [print, up, 1, rr(0, 0, 0), 3, undef, 0])
fwall();

atrans(loc, [print2, up2, rr(wide, sod, 0), rr(wide, sod, -90), undef])
lwall();
atrans(loc, [print2, up2, rr(sod, sod, 180), rr(wide, wide-sod, 180, 3*rad), 3, 0])
bwall();

d = -3;
atrans(loc, [undef, 0, 0, 0, [0,d,-d]] ) die([wide/2, wide/2, fz1-6.2, [70, 45, 0]], 15, "grey");

// TODO: clip-axles, texture flaps
