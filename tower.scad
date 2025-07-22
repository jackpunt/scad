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
high = 125;   // 125 + rad?

hr = rad * .6;
dr = rad * .4;
sep = 0.2;
sod = 4*rad; // standoff distance (l&r: x-dist, f&b: y-dist of standofff)
dw = rad+3.2;  // inset of hole for flap (final flap may be narrower)

dieSize = 12;
module die(trr = [0,0,0], dieSize = dieSize, clr = "red") {
  trr(trr)
  color(clr) roundedCube(dieSize, 1, false, true);
}

// 4 walls: right, front, left, back

// Utility to make a column of hinge segments in z direction
// hh: array of "hinge-pair": [bottom-len, top-len, orient?] or orient*len
// for ex: '5' --> [5,5,1]; '-5' --> [5,5,-1]
// orient: 1: cone on top, -1: socket on top, 0: space, no hinge
// 
module hingez(hh , hr=hr, dr=dr, mnts=1.5, sep=.2) {
  function absi(hh, n = 0) = abs(is_list(hh) ? hh[n] : hh);
  hh = def(hh, [[5,5]]);
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
  top = high - pbz;
  bot = 0;
  dh = high / 2;
  dx = (rad + sep);
  sang = [0, 90, 90, 0, 0, 0, 0][loc];
  mnt0 = [sep, 180, sang];
  hingez(hinga);  // hinge btw awall & swall;
  trr([dx, 0, 0]) cube([wide-sep, 2*rad, high]); // basic wall cube
  trr([wide-rad, 0, bot]) cube([2*rad, sod+rad, pbz]);    // bot block
  trr([wide, 5*rad, bot]) cylinder(h = pbz, r = rad);     // bot cyl
  trr([wide-rad, 0, top]) cube([2*rad, sod+rad, pbz]);    // top block
  trr([wide, 5*rad, top]) cylinder(h = pbz, r = rad);     // top cyl
  trr([wide-rad, 0, bot]) cube([2*rad, sod-rad, high]);   // full block
  trr([wide, sod-rad, bot]) cylinder(h = high, r = rad);  // full cyl
}

// make flap, maybe scaled, rotate, and move to wall
module flapf1(h = wide*.9, a = -90, dw = dw, sf = 1) {
  trr([0, rad, 0, [a, 0, 0]]) scalet([1, sf, 1, [0, 0, 0]]) aflap(h, dw);
}
echo ("sf = ",   (rad+1*sep)/ rad);// 1.05;);

dimple = false;
// make some dimples to remove from 'top' of flap
module dimples(w, h, r = rad, d10=rad, d20=rad) {
  d10 = def(d10, r);
  d20 = def(d20, r);
  d1 = [d10, 3*r, w];
  d2 = [d20, 4*r, h];

  if (dimple)
  gridify(d1, d2, 2) // XY plane
   scale([1.3, 1.15, .45]) sphere(r);
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
  rr = rad*1.3;
  trr([0, 0, zz, [ang+90, 0, 0, [0, rad, 0]]])  // rotate *after* dimples (@-90)
  differenceN(1) {
    flapf1(h, -90, dwf ); // sep tilts to: 126
    trr([5*rad, 3*rad, z0]) dimples(fw-2*rr, h, rr, -rr/2);
    trr([5*rad, 4.65*rad, z0]) dimples(fw-4*rr, h-3*rr, rr, 1*rr, 1.5*rr);
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
// gt: thickness of edge outside of hole (same as for cutFront: rad)
// dg: thickness of gate (rad)
// ys: y-extent (2*rad)
module gate(h = gateH, gt = rad, dg = rad, ys = 2*rad) {
  dws = gt+sep;              // offset to outer edge of gate
  gw = wide - 2 * dws;       // total width of gate
  hh = max(dg, gt);    // hinge height (along axis)
  bm = 4 * rad - sep;  // bar height (almost 4 * rad; 2.3->9.2)
  f0 = 6.51 - dw;      // inset to clear folded flap (unrelated to bm!)
  gap = sqrt(h*h + bm*bm)-h;// sep * 4;       // gap for bar rotation clearance sqrt(h*h+bm*bm)
  differenceN(2) {
    color("cyan")
    trr([gt+sep+f0, 0, h-dg-gap]) roundedCube([gw-2*f0, bm, dg], bm/2, true);
    color("cyan")
    trr([dws,       0, 2*rad]) cube([gw,      ys,      h-2*rad-gap]);
    trr([dws+dg, -pp, -pp]) cube([gw-2*dg, ys+2*pp, h-dg-gap]);
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
fz1 = 72;
fz2 = 95; // high - f2-2*rad

pr = rad-1;// 1.3;    // pin hole radius
pz = 10;   // pin hole depth
pbz = 10;  // pin bracket size (top notch)
lz = 5;    // latch depth
module pinSlot() {
  top = high - pbz;
  bot = 0;

  differenceN(1) {
    children(); // awall & gate-hinge
    // remove:
    trr([wide, 5*rad, -1])  cylinder(h = high+2, r = pr);    // long axle hole

    trr([wide-pr, 2*rad, top-p])      cube([2*pr, sod-rad, pbz+pp]); // top block
    trr([wide-pr, 1*rad, top-(lz+p)]) cube([2*pr, 2*rad, pbz + (lz+pp)]); // top slot
    trr([wide, sod-rad, top-lz]) cylinder(h = lz, r = pr);  // key arch

    trr([wide-pr, 2*rad, bot-p])      cube([2*pr, sod-rad, pbz+pp]); // bot block
    trr([wide-pr, rad, bot-p])        cube([2*pr, 2*rad, pbz + (lz+pp)]); // bot slot
    trr([wide, sod-rad, bot+pbz]) cylinder(h = lz, r = pr);  // 

    trr([wide, -p, -1])  cube([2*rad, sod+2*rad,high+2]);    // cutaway
  }
  #trr([wide-pr, 1*rad, top -1, [8, 0, 0]]) cube([2*pr, pr, pbz]); // bevel catch
  #trr([wide-pr, 1*rad, bot +1, [-8, 0, 0, [0,0,pbz]]]) cube([2*pr, pr, pbz]); // bevel catch

}
module fwall() {
  fh1 = 40 * w60;
  gh = gateH; 
  mh = (110 - gh - 20)/5 ;
  pinSlot() {
  cutFront(gh)
  addFlap(fz1, fh1, -130)
  awall([[gh+10, 10, -1], mh, -mh, [mh, high-110-sep]]);

  // [up-flat: a=0,..., extended: a=90]
  atrans(loc, [rrx(0, 0, 0, rad, rad), 0, 0, rrx(0, 0, 90, rad, rad), 3, 0, 0]) 
  gateStop()
  gate(gh, rad);
  }
}
module bwall() {
  fh2 = 30 * w60;
  fh0 = 54 * w60;
  addFlap(fz2, fh2, -125)
  addFlap(fz0, fh0 , -125)
  awall([[20, 20, -1], 15, -15, [10, high-110-sep]]);
}

// side wall (no flaps)
module swall(clr="tan", dir=1) {
  dx = (rad + sep); // reduce width for hinge
  ws = wide - sod;
  mnt0 = [sep, 90, -90];
  color(clr)
  differenceN(4) {
    trr([2*rad-ws, 0, 0]) cube([ws-dx-2*rad, 2*rad, high]);       // basic wall cube (rm for hingez)
    trr([sod-wide+2*rad, rad, 0]) cylinder(h = high, r = rad);    // cylinder for binding pin
    trr([-ws, 0, pbz]) cube([ws-dx, 2*rad, high-2*pbz]);          // basic wall cube (rm for hingez)
    trr([sod-wide, rad, pbz]) cylinder(h = high-2*pbz, r = rad);  // cylinder for binding pin
    // hole could be much deeper:
  #  trr([-ws, rad, -1  -pz+pbz]) cylinder(h = pz+pz+1, r = pr);  // bottom hole
  #  trr([-ws, rad, high-pz-pbz]) cylinder(h = pz+pz+1, r = pr);  // top hole
  }
}

module rwall() {
  swall("red", 1);
}

module lwall() {
  swall("lavender", -1);
}

// Common trr around point for atrans:
// w: x-offset
// s: y-offset
// a: rotate on axis
// cy, cy: center of rotation
function rrx(w=0, s=0, a=-90, cy=rad, cz=0) = [w, s, 0, [a, 0, 0, [0, cy, cz]]];
function rry(w=0, s=0, a=-90, cx=rad, cz=0) = [w, s, 0, [0, a, 0, [cx, 0, cz]]];
// rotate wall into postion for loc
// w: wide; s: y-offset; a: angle; cy: rad
function rrz(w=0, s=0, a=-90, cy=rad, cx=0) = [w, s, 0, [0, 0, a, [cx, cy, 0]]];

// 0: print
// 1: upright (no rotations)
// 2: folded
// 3: expanded
// 4: open wall
// 5: bwall only (print orientation)
// 6: fwall only (print orientation)
loc = 6;

swx = wide - sod - rad;
dx0 = wide-sod-rad-sep; // align rwall @ x=0
dxp = 2*wide-sod+sep;   // align lwall to right
print  = [swx-sep, 0, 0, [90, 0, 0]];
print2 = [swx+wide+swx+rad, 0, 0, [90, 0, 0]];

print2a = adif(print, [-dxp, 0, 0]);
up = [0,0,0];
up2    = adif(up,    [-(2*wide+sep    ), 0, 0]);

atrans(loc, [print, up, 1, rrz(0, 0, -90), 3])
rwall(); 
atrans(loc, [print, up, 1, rrz(0, 0, 0), 3, undef, 1])
fwall();

atrans(loc, [print2, up2, rrz(wide, sod, 0), rrz(wide, wide, 90), undef])
lwall();
atrans(loc, [print2, up2, rrz(sod, sod, 180), rrz(wide, wide-sod, 180, 3*rad), 3, 0])
bwall();

d = -1;
atrans(loc, [undef, 0, 0, 0, [0, d, -d-2]] )
  die([wide/2, wide/2, fz1-6.2, [70, 45, 0]], 15, "grey");

// TODO: clip-axles
