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
module vbox(vt0 = bt, vw0 = bw, vh0 = bh, t00 = t0)
{
  ta = is_list(t00) ? t00 : [t00, t00, t00];
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
  hwtr0 = [dh, vw-2*tx, 2*tz, 1]; // ]height, width, translate, rotate]
  hwtr1 = [dh, vw-30, 2*tz, sr]; // ]height, width, translate, rotate]
  ss = false;   // show slot

  { 
    // slotted box with card guides:
    slotify(hwtr0, [00+tx/2, vw/2, vh-(dh/2-tz)], 1, 0, ss)
    slotify(hwtr1, [vl-tx/2, vw/2, vh-(dh/2-sr)], 1, 3, ss)
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
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s0 = is_list(size) ? size : [size,size,size]; // tube_size
 s = [s0.x + 2*t, s0.y + 2*t, s0.z + 2*t];
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max of tl, bl
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s.z, s.y, s.x], rt, k, t);

 // endcaps
 hw0 = [s.z, s.y, 0];
 hwx = [s.z, s.y, s.x];
 div(hw0, rc, k, t);
 div(hwx, rc, k, t);
}
module die(trr = [0,0,0]) {
  trr(trr)
  color("red") roundedCube(12);
}

module lid(h = h0, w = w0 ) {
  module hinge() {
    bs = 4; // base size
    az = 2; // axle z
    inset = 6; tabl = 4;
    trr([h - bs, 0, 1]) cube([bs, w, bs]); // offset
    color ("green") trr([h+inset , -1-p, bs, [-90, 0,0]]) cylinder(h = w+pp, r = 2);
    // trr([h+inset, -1-p, bs])  cube([tabl, w+2*t0+pp, az]); // axle
    trr([h - bs, 0, bs]) cube([bs+inset, w, az]);
  }
  
    color ("pink") cube([h, w, 1]); // base
    hinge();

}

// allow for 12 cards per color, * .625 = 7.5mm
loc = 2;
tv = 2;
atrans(loc, [[-tv,0,0], [0, 0, 0, [0, 90,0]], 0])
vbox(10 * t01, bw, bh, [t0, tv, t0]);

tl = w0;
ht = 15;   // height of tray
rt = 18;   // radius of scoop
zt = ht+rt;   // z-extent before kut
atrans(loc, [[0 - p, tl + t0, 0, [90, 0, -90]], [0, tl + t0, 0, [0, 0, -90]], 0])
color("blue") 
tray([tl, bh, zt], [0, rt, 1, 1], 1, undef, t0);

atrans(loc, [[-h0-ht-5, t0, 0], 0, 0])
lid(h0, w0);

dup([0, 15, 0])
atrans(loc, [undef, [2, 2* t0, t0], 0])
die();
