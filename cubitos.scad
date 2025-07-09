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
  sw = vw*.7;      // width of slot 
  dh = vh*.8;      // depth of slot (below the radius of tray)
  sr = min(5, dh/2, sw/2); // radius of slot
  hwtr0 = [dh, vw -2*ty, 2*tz, .1]; // ]height, width, translate, radius]
  hwtr1 = [dh, sw      , 2*tz, sr]; // ]height, width, translate, radius]
  ss = false;   // show slot

  { 
    // slotted box with card guides:
    slotify(hwtr0, [00+tx/2, vw/2, vh-(dh/2-tz)], 1, 0, ss) // tray bottom
    slotify(hwtr1, [vl-tx/2, vw/2, vh-(dh/2-sr)], 1, 3, ss) // outer slot
    box([vt, vw, vh], ta);
    if (w0 > 50) {
    translate([vt/2,  0+ty, 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vt/2, vw-ty, 0 ]) rotate([0,0,-90]) cardGuide();
    }
  }
}

// tray is a rounded tube (kut) with end caps [from civo_tray]
// size: [x: length, y: width_curved, z: height_curved]
// rs: radii of scoop for tray
// rc: radii of caps  [bl, tl, tr, br] (2)
// k0: cut_end default: cut max(top radii) -> k
// txyz: (t0 -> [t0, t0, t0])
module tray(size = 10, rs = 2, rc = 0, k0, txyz = t0) {
  rs = def(rs, 2);
  rc = def(rc, 0);

  echo("tray: rs =", rs);
 ta = is_list(txyz) ? txyz : [txyz, txyz, txyz];
 s0 = is_list(size) ? size : [size, size, size]; // tube_size
 s = [s0.x, s0.y, s0.z];
 rm = is_list(rs) ? max(rs[1], rs[2]) : rs;   // round_max of tl, bl
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s.z, s.y, s.x], rs, k, ta);

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
// trr: final placement
// ht: height of each block (3)
// hr: radius (& height) of hinge/cone (hr = 1.5) 
// dr: incremental thickness around cone (2)
// mnt: extend a mounting block [dist, angle-socket, angle-cone]
module hinge(trr=[0,0,0], ht = 3, hr = 1.5, dr = 2, mnts = 1.5, sep = .2) {
  trr = def(trr, [0,0,0]);
  ht = def(ht, 3); 
  hr = def(hr, 1.5);
  dr = def(dr, 2.0);
  rt = hr + dr;               // total radius of hinge
  mnts = is_list(mnts) ? mnts : [mnts];
  mnt0 = def(mnts[0], hr);    // mount length (block)
  mnta = def(mnts[1], 0);     // rotation around z-axis (block)
  mntb = def(mnts[2], mnta);  // rotation around z-axis (cone)
  mntc = def(mnts[3], mnt0);  // mount length (cone)
  sep = def(sep, .2);
  echo("hinge: [zh, ht, hr, dr, mnts, sep] =", [zh, ht, hr, dr, mnts, sep]);
  fn = 30;

  module mountblock(h = ht, z = 0, mntd = mnt0, mnta = mnta) {
    if (mntd > 0) {
      rt = hr + dr; 
      my = (rt + mntd);
      color("red")
      trr([0, my/2, z+h/2, [0, 0, mnta, [0, -my/2, 0]]]) cube([2 * rt, my, h], true);
    }
  }
  module coneblock(hr = hr) {
    rr = hr * .68;
    trr([0, 0, ht/2, [180, 0,0]])
    union() {
      cylinder(h = ht, r = hr + dr, center = true, $fn = fn);
      trr([0, 0, ht/2-p]) 
      union() {
        cylinder(hr*.7, hr, hr*.56, $fn = fn); // frustrum of cone QQQ: hr*.7 vs rr=hr*.68
        trr([0, 0, hr-rr]) sphere(rr, $fn = fn); // sphere on top
      }
    }
  }
  module section() {
    color("cyan") intersection() { 
      cube([rt + dr, rt + dr, 2*ht]); 
      difference() { 
        cylinder(h = 2*ht, r = rt);
        children();
      }
    }
  }
  trr(trr)
  union() {
    // section() {
    difference() // bottom socket
    {
      union() {
        mountblock(ht, 0, mnt0, mnta); // bottom socket block
        trr([0, 0, ht/2]) cylinder(h = ht, r = rt, center = true, $fn = fn);
      }
      trr([0,0,ht+p]) scale([(hr+sep)/hr, (hr+sep)/hr, 1]) coneblock(hr); // or +cos(30)*sep
    }
    mountblock(ht, ht+sep, mntc, mntb); // top ball block
    trr([0,0,ht+sep]) coneblock(hr); // top ball
    }
// }
}

// cs: child size; begin grid @ (cs, cs+1)
// nc: columns
// nr: rows
module partsGrid(bw, bh, cs = 5, nc = 10, nr = 20) {
  xi = (bw - cs) / nc;
  x0 = (bw - cs - xi * (nc - 1) + cs)/2;
  xm = bw - cs;
  yi = (bh - cs) / nr;
  y0 = (bh - cs - yi * (nr - 1) + cs)/2;
  ym = bh - cs;
  translate([0, 0, t0])
  gridify([x0, xi, xm], [y0, yi, ym], 2) cube([cs, cs, cs], true);
}

// h: height of a card (h0)
// w: width of a card (w0)
// t: thickness of lid (2)
// rt: radius [total] of hinge (hr + dr = 3)
// zh: ambient z-coord of hinge
module lid(h = h0, w = w0, t = 2, rt = hr + dr ) {
  et = tt * .6;
  ym = ht - zh + rt + sep;   // push out to clear (7.3)
  lh = h - ym + et;          // lid height - pink part [+ et to clear top edge when closed]
  ba = .3;
  lhh = lh - 3 + ba;            // TODO: correct formula for '2.9' axis of hinge; zh = 11.9
  echo("[ht, zh, rt, sep, ym, lh, lhh] =", [ht, zh, rt, sep, ym, lh, lhh]);

  // offset from tray: (hy & zd are both 4.1; zh = (15-4.1) = 11.9)
  trr([ty, -zh -lhh, 0]) {   // et is clipping the front edge (proly some goof of ty vs tt...)
    trr([0, -ym, 0])
    color ("pink") 
     difference()
    {
      trr([w/2, lh/2, t/2]) {
        cube([w, lh, t], true); // base lid
        trr([0, (10-lh)/2, tt/2 ]) cube([tl, 2.2*tt, tt], true); // clips
      }
      if (w0 > 80) {
        partsGrid(w, lh, 8, 6, 5);     // perforate
      } else {
        partsGrid(w, lh, 3, 4, 4);     // perforate
      }
    }
    // hinge connection & "tray"
    difference() 
    {
      union() {
        trr([w/2, lh-ym/2-.2, t/2])             cube([w-5, ym, t], true); // tang
        trr([w/2, lh-rt+ba, rt/2+1])            cube([w-5, 2*rt, rt], true); // block
        // trr([w/2, lh-ym, ym-p, [-30, 0, 0]]) cube([w-5, ym*.5, 1.8+pp], true); // feet
      }
      trr([w/2, lh-ym/2+p, 6]) cube([w*.63, 16, 14], true); // cut center of block & tang
    }
    trr([w/2, lhh, hy, [0, 90, 0]]) cylinder(w-5, rt, rt, $fn=30, center = true); // space filler
    trr([w/2, lhh, rt/2, [0, 00, 0]]) cube([w-5, rt, rt], center = true); // support for cylinder
  }
}

module trayAndLid() {
  cx = tl - dz * 2;
  cz = zd+hr+dr+sep; 
  cc = zd - (hr + dr); // cut notch (above hinge) to hold card bottom
  lt = 2;   // lid thickness
  by = 3;   // lid blocker
  bz = 7;   // lid blocker

  mnts = [.1, 180, 0, 0];
  sep = .2;
  rotate([90, 0, 0])
  union() {
  difference() 
  {
  color("blue")
    tray([tl, bh+2*tt, zt], [0, rs, 1, 1], 0, undef, [ty, tt, tt]);
    // back side slot for lid:
    trr([dz, -pp, zh - cz + zd ]) cube([cx, tt+2*pp, cz + p]);
    // front edge
    trr([tl/2, bh + tt, ht-tt+pp ]) cube([tl-2*ty, 2*tt, 2.4*tt], true);
    // hole for clip:
    trr([tl/2, bh - 3, ht-1.57+pp ]) cube([tl+2*ty, 3, 1.2], true);
    trr([tl/2, bh -.8, ht -.57+pp ]) cube([tl+2*ty, 6, 1.2], true);
    // top side cut to hold card bottom
    trr([-p, -p, ht-cc+p]) cube([tl+pp, zd, cc+pp]);
  }
    hinge([ 0, hy, zh, [0, 90, 0]], dz, undef, dr, mnts, sep );
    hinge([tl, hy, zh, [0, -90, 0]], dz, undef, dr, mnts, sep );
    difference() {
      trr([tl/2, by/2 + ty -p, bz/2 + tz]) cube([tl-8, by, bz], true); // angle stop block
      trr([tl/2+p, by/2+p + ty -p +p, bz/2 + tz]) cube([tl-38+pp, by+pp, bz+pp], true); // cut
    }
  }

  ar = [-3, -zh, hy];
  echo ("ar = ", ar);
  trr(ar) color("cyan") cube([5, .1, .1]);
  atrans(loc, [
    [0, 0, 0], 
    0, 
    [0, 0, 0, [23, 0, 0, ar]], 
    [0, 0, 0, [-89.99999999, 0, 0, ar]], 
    undef, 
    0,
    2,
    ])
  lid(h0, w0, lt );
}

// allow for 12 cards per color, * .625 = 7.5mm
loc = 0;
tw = 1;   // thickness of tray walls (in print x-coord); tray-x
ty = 1.2; // thickness of walls, tray endcap (in print y-coord);
tz = 1;   // thickness of tray bottom (todo)

tt = 1;
tl = w0 + 2 * ty; // total y-length (width of card)

atrans(loc, [[-t0, 0, 0], [0, 0, 0, [0, 90, 0]], 1, 1])
vbox(10 * t01, bw, bh, [t0, ty, t0]);

ht = 16;   // height of tray
rs = 18;   // radius of scoop
zt = ht+rs;// z-extent before kut

hr = 1.5;  // hinge radius
hy = 4.1;  // hinge z (pre rotation, the y-coord of axle)
sep = .2;

dr = 1.5;
th = 2;           // 'thickness' for hinge
zd = 4.1;         // down from top of tray (coincidentally? == hy)
zh = ht - zd;     // z for hinge
dz = 3;           // block size of hinge
// hinge([ 0, hy, zh, [0, 0, 0]], 3, undef, undef, [1, 180, 90], .2 );

atrans(loc, [
  [0, tl, 0, [0, 0, -90]], 
  [0, tl, 0, [-90, 0, -90]], 
  [0, tl, 0, [-90, 0, -90]], 
  [0, tl, 0, [-90, 0, -90]], 
  0, 
  0,
  [0, tl, 0, [-90, 0, -90]], // 6
  ])
trayAndLid();

dup([0, 13, 0])
atrans(loc, [undef, [9, 5, tt], 1, 1])
die();
