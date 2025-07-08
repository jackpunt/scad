// cubitos
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

// box size and placement constraint (3x4 grid in square box)
wmax = 285/4;    // 95 (w0 < wmax)
hmax = 285/3;    // 71 (h0 < hmax)

w00 = 88;  // official card size [long dimension]
h00 = 63;  // official card size [short dimension]

t00 = .4;  // card thickness: sleeves bring thickness to ~.625 per card. (from min .4mm)
t01 = .625; // thickness when stacking sleeved cards 

// euroPoker size (with sleeves):
// width of card
w0 = 90.5;
// height of card
h0 = 66;
bt = 10 * t01 + 2 * t0; //
bw = w0; // total length of box (y-extent @ loc = 2)
bh = h0; // height of box (short dimension of card + bottom(t0) + top(3mm))


// box for setup (Events, VICI, markers, chips) cards:
// vt = box thick (~ t01 * number of cards + 2*t0) x-extent
// vw = box width (long dimension of card + 2*t0)  y-extent
// vh = box height (short dimension of card + bottom(t0) + top(3mm)) z-extent
module vbox(vt0 = bt, vw0 = bw, vh0 = bh, txyz = t0)
{
  ta = is_list(txyz) ? txyz : [txyz, txyz, txyz];
  tx = ta.x; ty = ta.y; tz = ta.z;
  vt = vt0 + 2 * tx; // external x-extent
  vw = vw0 + 2 * ty;
  vh = vh0 + 2 * tz;
  echo("------ vbox: vt= ", vt, "vw=", vw, "vh=", vh);
  // vt: interior x-extent
  module cardGuide(vt = vt0+pp) {
    // w0 size of inset; squeeze
    // h0 height of flat part
    // h1 height of taper part
    w0 = 2; h0 = 4; h1 = 7; a = 7;
    vh2 = vh * .7;
    // TODO: the trig to calc height of green cube (depends on angle a)
    difference() {
    translate([w0/2 + p, 0, vh2]) color("green") cube([w0, vt, h0 + 4 * h1], true);
    trr([w0, 0, vh2+h1+h0, [0, -a, 0]]) color ("pink") cube([w0, vt+pp, h0 + 2 * h1], true);
    trr([w0, 0, vh2-h1-h0, [0, a, 0]]) color ("pink") cube([w0, vt+pp, h0 + 2 * h1], true);
    }
  }
  // slotify the walls:
  vl = vt;
  sw = vw-30;   // width of slot 
  dh = 50;      // depth of slot (below the radius of tray)
  sr = min(5, dh/2, sw/2); // radius of slot
  hwtr0 = [dh, vw -2*ty, 2*tz, .1]; // ]height, width, translate, radius]
  hwtr1 = [dh, sw      , 2*tz, sr]; // ]height, width, translate, radius]
  ss = false;   // show slot

  { 
    // slotted box with card guides:
    slotify(hwtr0, [00+tx/2, vw/2, vh-(dh/2-tz)], 1, 0, ss) // tray bottom
    slotify(hwtr1, [vl-tx/2, vw/2, vh-(dh/2-sr)], 1, 3, ss) // outer slot
    box([vt, vw, vh], ta);
    translate([vt/2,  0+ty, 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vt/2, vw-ty, 0 ]) rotate([0,0,-90]) cardGuide();
  }
}

// tray is a rounded tube (kut) with end caps [from civo_tray]
// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
// txyz: (t0 -> [t0, t0, t0])
module tray(size = 10, rt = 2, rc = 0, k0, txyz = t0) {
 ta = is_list(txyz) ? txyz : [txyz, txyz, txyz];
 s0 = is_list(size) ? size : [size, size, size]; // tube_size
 s = [s0.x, s0.y, s0.z];
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max of tl, bl
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s.z, s.y, s.x], rt, k, ta);

 // endcaps
 hw0 = [s.z, s.y, 0];
 hwx = [s.z, s.y, s.x-ta.x];
 div(hw0, rc, k, ta.x);
 div(hwx, rc, k, ta.x);
}
module die(trr = [0,0,0]) {
  trr(trr)
  color("red") roundedCube(12);
}

// two pieces: ball & socket
// socket on bottom, ball on top
// square blocks 2*r + dxy
// height = dz, cone height = ~2 * r
// trr: final placement
// dxyz: size of block
// r: size of cone
module hinge(trr=[0,0,0], dxyz = [2, 2, 3], r = 1.5, t = 2, mnt = .01, sep = .2) {
  trr = def(trr, [0,0,0]);
  dxyz = def(dxyz, [2, 2, 3]);
  r = def(r, 1.5);
  t = def(t, 2.0);
  mnt = def(mnt, 0.1);
  sep = def(sep, .2);

  dz = dxyz.z;
  ht = dz+r-sep/2;
  zs = dz+r/2+sep;
  fn = 30;

  module mountblock(h = dz, z = 0) {
    if (mnt > 0) {
      rt = r + t;
      trr([0, -(rt+mnt)/2, z]) cube([2 * rt, rt + mnt, h], true);
    }
  }
  module coneblock(r = r) {
    r1 = r * 1.5;
    r2 = r + t;
    cylinder(h = dz, r = r2, center = true, $fn = fn);
    trr([0, 0, dz/2]) {
      cylinder(r, r1, r, $fn = fn); // frustrum of cone
      trr([0, 0, r*.9]) sphere(r, $fn = fn); // sphere on top
    }
  }
  trr(trr)
  trr([0, 0, zs+ht/2, [180, 0, 0]])
  union() {
    mountblock(dz, 0); // bottom block
    difference() // top socket
    {
      union() {
      mountblock(ht, zs); // top block
      trr([0, 0, zs]) cylinder(h = ht, r = r+t, center = true, $fn = fn);
      }
      coneblock(r + sep);
    }
    coneblock(r); // bottom ball
  }
}

// make hole for axle 
// TODO: use conical axle & hole; so no overhang!
// trr: location of hinge point [x, y, z]
// ar: radius of hole (1.5)
// f: extra radius (.1)
// child(0) 
module hole(trr, h = t0, ar = 1.5, f=.1) {
  difference() 
  {
    children(0);
   # trr(trr) cylinder(h, ar+f/2, ar+f/2, true);
  }
}

// h: (height of a card)
// w: (width of a card)
// dxz: location of hinge point [x, ty, z]
// hw: hinge width (with ty increment to axle)
module lid(h = h0, w = w0, dxyz = [], hw = 5 ) {
  r = 1.5; t = 2; rt = r + t;
  dx = dxyz.x;
  dy = dxyz.y;
  dz = dxyz.z;

  // offset from tray:
  trr([-.1, 0, 0]) union() {
    color ("pink") cube([h, w, 1]); // base
  }
}

// allow for 12 cards per color, * .625 = 7.5mm
loc = 0;
ty = 1;
tt = 1;
tl = w0 + 2 * tt; // total y-length

*atrans(loc, [[-t0, 0, 0], [0, 0, 0, [0, 90, 0]], 0])
vbox(10 * t01, bw, bh, [t0, ty, t0]);

ht = 15;   // height of tray
rt = 18;   // radius of scoop
zt = ht+rt;// z-extent before kut

hr = 1.5;  // hinge radius
hy = 5;    // hinge z
sep = .2;

dz = 3; 
th = 2;           // 'thickness' for hinge
zh = ht - 5;      // z for hinge
hx = dz+hr-sep/2; // 3 = hinge.dz
// atrans(loc, [[0 - p, tl, 0, [90, 0, -90]], [0, tl, 0, [0, 0, -90]], 0])
union() {
  // difference() 
  {
  color("blue")
    tray([tl, bh+2*ty, zt], [0, rt, 1, 1], 0, undef, [ty, tt, tt]);
    // trr([hx, -p, zh -(hr+th+sep)]) cube([(hr+sep) * 2, 1+pp, (hr+th+sep)*2]);
    #trr([hx, -p, zh -(hr+th+sep)]) cube([tl-(hr+th) * 2, 1+pp, (hr+th+sep)*2]);
  }
  hinge([ 0, hy, zh, [180, -90, 0]], [2,2,3], undef, undef, 1.5, .2 );
  hinge([tl, hy, zh, [180, 90, 0]], [2,2,3], undef, undef, 1.5, .2 );
}
*atrans(loc, [[-h0-ht, t0, 0], 0, 0])
lid(h0, w0, [-(ht-5), ty, 5], 5);

dup([0, 15, 0])
atrans(loc, [undef, [2, 25, tt], 0])
die();
