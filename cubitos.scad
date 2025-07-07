// cubitos
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

l00 = 87; // official card size (+2mm for sleeves)
w00 = 56; // sleeves bring thickness to ~.625 per card. (from min .4mm)
l0 = 92.4;
w0 = 60.4; // w00 + 2mm (sleeves) + 2mm (slack); retain 60.4 for slider compat
h0 = 27;
h1 = h0 + 3; // extend for ramp!
l = l0 + 2 * t0; // total length of box (y-extent @ loc = 2)
w = w0 + 2 * t0; // width of civo_cardbox
h = h1 + t0;
tsd = 1.7;      // top_slot depth of topTray

// box for setup (Events, VICI, markers, chips) cards:
module vbox()
{
  sh = 3.4; // center slot reduction & lid size
  vw = l + 2; // more slack for lid...
  vl = 20+2*t0; // x-extent (width to stack cards)
  vh = w0 + sh + t0 +t0; // about as high as main box is wide (+2 for lid?)
  sw = 55;// width of slot
  dh = 39+sh; // depth of slot
  sr = min(5, dh/2, sw/2); // radius of slot
  hwtr = [dh, sw, 2*t0, sr]; // ]height, width, translate, rotate]
  h2 = w0;  // center slot height
  sz = 11/32 * vl; // 11 +/- 1
  ss = false;

  l1y = w + 2 * (vl + 3*t0); // l1y = w+vh
  l0y = l1y; // 0 -3*t0; 
  echo("------h2=", h2, "vh=", vh);

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
    slotify(hwtr, [vl-t0/2, vw/2, vh-(dh/2-sr)], 1, 3, ss)
    box([vl, vw, vh], t0);
    dh2 = dh-(vh-h2); hwtr2 = [dh2, sw, 2*t0, sr];
    // slotify(hwtr2, [sz+t0/2, vw/2, h2-(dh2/2-sr)], 1, 3, false)
    // div([h2, vw, sz], 2, 0, t0);
    translate([vl/2,     (t0+.6), 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vl/2, vw- (t0+.6), 0 ]) rotate([0,0,-90]) cardGuide();
  }
  // vboxTop();
 }
}
loc = 0;
// atrans(loc, [[0,0,0], undef, undef, undef, undef, 0])
vbox();
