// cubitos
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

l00 = 87;  // official card size (+2mm for sleeves)
w00 = 56;  // sleeves bring thickness to ~.625 per card. (from min .4mm)
l0 = 92.4; // l00 + 5.4mm, sleeves & some slack
w0 = 60.4; // w00 + 2mm (sleeves) + 2mm (slack); retain 60.4 for box top compat
l = l0 + 2 * t0; // total length of box (y-extent @ loc = 2)
w = w0 + 2 * t0; // width of civo_cardbox

lmax = 285/4;    // 95 (l0=92.4)
hmax = 285/3;    // 71 (w =62.4)

// box for setup (Events, VICI, markers, chips) cards:
module vbox(v0 = 20, vw = l)
{
  // vw = l + 2;   // more y-slack for card guides
  vl = v0+2*t0; // x-extent (width to stack cards)
  vh = w;       // height of vcard holder
  sw = vw-2;    // width of slot (the whole width for this one)
  dh = 10;      // depth of slot (below the radius of tray)
  sr = 1;//min(5, dh/2, sw/2); // radius of slot
  hwtr = [dh, sw, 2*t0, sr]; // ]height, width, translate, rotate]
  ss = false;   // show slot

  echo("------vh=", vh);

  module cardGuide() {
    up = 10; h1 = 10; h2 = 10; cy=0; a = 6; df = 4;
    union() {
    translate([0, 0, vh/2+up+df/2 ])
    rotate([0, 90-a, 0]) color("green") cube([h1, vl, t0+1], true);
    translate([0, 0, vh/2+up-df/2-(h2+h1)/2, ])
    rotate([0, 90+a, 0]) color("green") cube([h2, vl, t0+1], true);
    translate([.0, 0, vh/2+up/2, ])
    cube([t0+2, vl, df+t0, ], true);
    }
  }
 // temp union for 'intersection' test
 //   intersection() 
 {
  // vbox:
  atrans(loc, [
               [0, 0, 0, [0,0,0]], 
               [0, 0, 0, [0,90,0]], 
               [0, 0, 0, [0,0,-90]],
               
               ]) 
  { 
    //   echo("vbox2:", hwtr)
    // slotted box with card guides:
    slotify(hwtr, [00+t0/2, vw/2, vh-(dh/2-sr)], 1, 0, ss)
    box([vl, vw, vh], t0);
    translate([vl/2,     (t0+.6), 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vl/2, vw- (t0+.6), 0 ]) rotate([0,0,-90]) cardGuide();
  }
 }
}

// tray is a rounded tube (kut) with end caps [from civo_tray]
// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s = is_list(size) ? size : [size,size,size]; // tube_size
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s.z, s.y, s.x], rt, k, t);

 // endcaps
 hw0 = [s.z, s.y, 0];
 hwx = [s.z, s.y, s.x];
 div(hw0, rc, k);
 div(hwx, rc, k);
}
module die(trr = [0,0,0]) {
  trr(trr)
  color("red") roundedCube(12);
}

loc = 0;
atrans(loc, [[0,0,0], undef, undef, undef, undef, 0])
vbox();
tl = l0+t0;
atrans(loc, [[t0+p,tl+t0,0,[90, 0, -90]], [0,0,0,[0,0,90]]])
tray([tl, w, 26], 9, 0);

dup([0, 15, 0])
atrans(loc, [[-50, t0, t0]])
die();
