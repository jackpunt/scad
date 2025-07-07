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
w0 = 90.5;   // 
h0 = 66;     // 
bt = 10 * t01 + 2 * t0; //
bw = w0 + 2 * t0; // total length of box (y-extent @ loc = 2)
bh = h0 + 2 * t0; // height of box (short dimension of card + bottom(t0) + top(3mm))


// box for setup (Events, VICI, markers, chips) cards:
// vt = box thick (~ t01 * number of cards + 2*t0) x-extent
// vw = box width (long dimension of card + 2*t0)  y-extent
// vh = box height (short dimension of card + bottom(t0) + top(3mm)) z-extent
module vbox(vt = bt, vw = bw, vh = bh)
{
  echo("------ vbox: vt= ", vt, "vw=", vw, "vh=", vh);
  module cardGuide() {
    up = 10; h1 = 10; h2 = 10; cy=0; a = 7; df = 4;
    vh2 = vh * .59;
    union() {
    translate([0, 0, vh2+up+df/2 ])
    rotate([0, 90-a, 0]) color("green") cube([h1, vt, t0+1], true);
    translate([0, 0, vh2+up-df/2-(h2+h1)/2, ])
    rotate([0, 90+a, 0]) color("green") cube([h2, vt, t0+1], true);
    translate([0, 0, vh2+up/2, ])       cube([t0+2, vt, df+t0, ], true);
    }
  }

  // slotify the walls:
  vl = vt;
  sw = vw-30;   // width of slot 
  dh = 50;      // depth of slot (below the radius of tray)
  sr = min(5, dh/2, sw/2); // radius of slot
  hwtr0 = [dh, vw- 2, 2*t0, 1]; // ]height, width, translate, rotate]
  hwtr1 = [dh, vw-30, 2*t0, sr]; // ]height, width, translate, rotate]
  ss = false;   // show slot
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
    slotify(hwtr0, [00+t0/2, vw/2, vh-(dh/2-1)], 1, 0, ss)
    slotify(hwtr1, [vl-t0/2, vw/2, vh-(dh/2-sr)], 1, 3, ss)
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
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max of tl, bl
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

module lid( ) {
  union() {
    cube([]);
  }
}

// allow for 12 cards per color, * .625 = 7.5mm
loc = 0;
atrans(loc, [[0,0,0], 0])
vbox(10*t01);

tl = w0+t0;
rt = 18;
zt = 18+rt;
atrans(loc, [[t0 - p, tl + t0, 0, [90, 0, -90]], [0, tl + t0, 0, [0, 0, -90]]])
tray([tl, bh, zt], [0, rt, 1, 1], 0);

dup([0, 15, 0])
atrans(loc, [undef, [2, 2* t0, t0]])
die();
