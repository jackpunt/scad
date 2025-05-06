use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
l00 = 87; // official card size (+2mm for sleeves)
w00 = 56; // sleeves bring thickness to ~.625 per card. (from min .4mm)
l0 = 92.4;
w0 = 60.4; // w00 + 2mm (sleeves) + 2mm (slack); retain 60.4 for slider compat
h0 = 27;
h1 = h0 + 3; // extend for ramp!
l = l0 + 2 * t0;
w = w0 + 2 * t0;
h = h1 + t0;
tsd = 1.7;      // top_slot depth of topTray

// hypotenuse: given angle * adjacent_base length
function hypa(a, b) = (let(h = b * tan(a)) sqrt(b * b + h * h));
function hypo(a, h) = (let(b = h / tan(a)) sqrt(b * b + h * h));

a = 18;
dz = 6;                 // top of slot
iw = 3.5;               // width of slot_interior
xb = (h - dz) * tan(a); // length of holder after tilt...
lt = l + xb;            // length total
echo("cardbox: xb, lt, lwh=", [ xb, lt, l, w, h ]);
// TODO: snap-on top!

/** angled box on end to hold selected cards at angle (a) */
module holder(a = a)
{
  xb = (h - dz) * tan(a); // length of holder after tilt...
  ha = (h - dz);
  echo();                // top to slot
  fw = iw + 2 * t0;      // full width of slot box
  hb = ha - fw / cos(a); // down from top to rotation point
  hr = ha - hb;
  sz = 8;   // depth to shelf
  echo("xb=", xb, "ha=", ha, "hb=", hb, "hr=", hr);
  wb = w0;
  intersection()
  {
    translate([ p - xb, 0, 0 ]) cube([ xb, w, h ]);
    {
      rotatet([ 0, -a, 0 ], [ 0, 0, dz ])
      {
        translate([ fw, 0, 0 ]) cube([ 7, w, 1.2 * h ]); // fill w/ giant block, then intersect
        {
        bh = t0 + ((a > 1) ? ha / cos(a) : ha);
        // echo("bh=", bh);
        translate([ 0, 0, dz ]) 
        box([ fw, w, bh ], t0); // main box

        translate([ 0, 0, bh - sz ]) 
        rotatet([ 0, -18, 0 ], [ iw, 0, 2 * t0 ])
        cube([ iw + t0, w, t0 ]); // bottom shelf
        }
      }
    }
  }
  // translate([-t0,0,-bl]) rotate([-90,0,0]) cylinder([iw+2*t0, w, bl]);
}

module card(tr = [ (l0 - l00) / 2, (w0 - w00) / 2, 0 ])
{
    translate(tr) astack(32, [ -.03, 0, .625 ]) color("pink") roundedCube([ l00, w00, .4 ], 3, true);
}

// vz: height of ramp @ vx: bump @
vz = 4.;
vx = .4 * l;
fl = 2;
vy = 5.6; // fl: flat length
module ramp(vx = vx, vz = vz, ve = 0)
{
    sa = sin(a2);
    ca = cos(a2);
    vz = (l - vx) * sa;
    vzt = vz + t0; // vz = 3.16
    intersection()
    {
        union()
        {
            rotatet([ 0, -a2-.2, 0 ], [ vx, 0, vz + t0 ]) 
            for (y = [0:(w - vy) / 4:w - vy]) 
            translate([ ve, y, 0 ])
              cube([ vx, vy, vz + t0 ]);
            translate([ vx, 0, 0 ]) cube([ 2.4, w, vz + t0 ]);
        }
        translate([ ve, 0, 0 ]) cube([ vx, w, vz + t0 ]);
    }
    dr = 14;
    intersection()
    {
        translate([ vx + (dr / 2 + .0) * t0, w / 2, vzt / 2 ]) rotate([ -90, 0, 0 ]) cube([ dr, vzt, w ], true);
        color("blue") translate([ vx + (dr / 2 + 0) * t0, w / 2, vzt / 2 ])
            rotatet([ 0, a2, 0 ], [ -dr / 2, 0, vzt / 2 ]) rotate([ -90, 0, 0 ])
                cube([ dr, vzt, w ], true); // no compound rotation!
    }
}
/* clang-format off */

/** try to hold inline cards, also a "lid" to hold cards in box
 @param dx length of tray
 @param dz height of wings
 @ambient w: width of box, t0: thickness
 */
module topTray(dx = l/4, dz = 6)
{
    f = .43;
    tw = w +.75;
    sw = 2 * t0;
    atrans(loc, [ [ l+2, 0, dx, [0, 90, 0] ], 
                [ (l-dx)/2+20, 0, h-dz-tsd+t0 ], 
                [ (l-dx)/2+20, 0, h-dz-tsd+t0+p ],
          ])
    /* clang-format on */
    {
        rz = 5;
        in = f;
        dw = 3;
        dup([ 0, w, 0], [0,0,180, [dx/2, 0, 0]])
          color("blue") translate([0, 2-(dw+f/2), rz]) cube([dx, dw, t0]);
      translate([0, t0-f/2, 0]) box([ dx, w-2*t0+f, rz+1 ], [-t0,t0,t0], [2,2,0]);
    }
}


// box for setup (Events, VICI, markers, chips) cards:
module vbox()
{
  sh = 3.4; // center slot reduction & lid size
  vw = l + 2; // more slack for lid...
  vl = 20+2*t0;
  vh = w0 + sh + t0 +t0; // about as high as main box is wide (+2 for )
  sw = 55;// total width of box
  dh = 19+sh; // depth of slot
  sr = min(5, dh/2, sw/2);
  hwtr = [dh, sw, 2*t0, sr];
  h2 = w0;  // center slot height
  sz = 11/32 * vl; // 11 +/- 1
  ss = false;

  l1y = w + 2 * (vl + 3*t0); // l1y = w+vh
  l0y = l1y; // 0 -3*t0; 
  echo("------h2=", h2, "vh=", vh);
  module vboxTop() {
    // bt = (vh-h2); // mm == 2*sh
    tt = t0*1.2; bt = sh+tt; fx = .25; fy = .25;
    atrans(loc, [
        [-vw/2-2*t0, l0y-vl/2,       0, [0, 0, 90]], 
        [-vw/2-2*t0, l1y-vl/2,       0, [0, 0, 90]],
        [ vw/2     , l1y-vl/2, vh+tt+p, [180,0,90]],
        ])
    {
    // color("cyan")
    // union(){
     translate([0, 0, tt/2]) cube([vl, vw, tt], center=true);
     box(lwh = [vl-2*t0-fx, vw-2*t0-fy, tt+bt], cxy=true);
    // }
    }
  }
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
  atrans(loc, [
               [0, l0y, 0, [0,0,-90]], 
               [0, l1y, 0, [0,0,-90]], 
               [0, l1y, 0, [0,0,-90]]
               ]) 
  { 
//   echo("vbox2:", hwtr)
    slotify(hwtr, [00+t0/2, vw/2, vh-(dh/2-sr)], 1, 3, ss)
    slotify(hwtr, [vl-t0/2, vw/2, vh-(dh/2-sr)], 1, 3, ss)
    box([vl, vw, vh], t0);
  dh2 = dh-(vh-h2); hwtr2 = [dh2, sw, 2*t0, sr];
  slotify(hwtr2, [sz+t0/2, vw/2, h2-(dh2/2-sr)], 1, 3, false)
    div([h2, vw, sz], 2, 0, t0);
    translate([vl/2,     (t0+.6), 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vl/2, vw- (t0+.6), 0 ]) rotate([0,0,-90]) cardGuide();
  }
  vboxTop();
 }
}

// add horizontal slot to children(0)
module hslot(dz = dz, dx = 0)
{
    sw = 2;
    sh = 4;
    difference()
    {
        union()
        children();
        translate([dx - (sw - pp) / 2, t0, dz - sh ]) 
        cube([ sw, w0, sh ]);
    }
    // support posts:
    ni = 6;
    posts(sh+pp, [0, w/ni + t0/2, dz - sh - p], [0, w/ni, 0], ni-1);
}

// cut child(0) in XY plane @ depth: y0..y1
module cutaway0(loc = loc, cxyz = [ 10, 10, 10 ], txyz = [ -5, -5, -5 ])
{
    if (loc == 1)
    {
        difference()
        {
            children(0);
            translate(txyz) cube(cxyz);
        }
    }
    else
    {
        children(0);
    }
}
module cutaway(loc = loc)
{
    cutaway0(loc, [ lt + 10, 10, h + 10 ], [ -5 - xb, -5, -5 ]) children();
}
module pat(s = 5, l = 30)
{
    rotatet([ 0, 45, 0 ], [ s / 2, 0, s / 2 ]) translate([ 0, -p, 0 ]) cube([ s, l + pp, s ]);
}

module paty(s = 5, l = w)
{
    scale([ 1, 1, .7 ]) translate([ -s / 4, 0, -s / 2.8 ]) pat(s / 2, l);
}
module patx(s = 5, l = w)
{
    scale([ 1, 1, .7 ]) translate([ 0, -s / 4, -s / 2.8 ]) rotatet([ 45, 0, 0 ], [ 0, s / 2, s / 2 ])
        translate([ -p, 0, 0 ]) cube([ l + pp, s, s ]);
}

module gridaway(x0 = 40, l = l * .65, h = 25)
{
    s = 10;
    difference()
    {
        children(0);
        translate([ x0, 0, t0 + s * .8 ]) grid(l - s - x0, h - s - 5, 5) paty(s, w);
    }
}
module gridawayy(x0 = 20, l = l)
{
    s = 10;
    difference()
    {
        children(0);
        translate([ x0, 0, t0 + s ]) grid(l - s - x0, h - s - 5, 5) paty(s, w);
    }
}
module gridawayx(x0 = 20, w = w)
{
    s = 10;
    difference()
    {
        children(0);
        translate([ -10, x0, t0 + s ])
            // rotatet([0, 0, -90], [-20, 0, 20])
            grid(w - s - x0, h - s - 5, 5, [ 0, 1, 1 ]) patx(s / 2, 20);
    }
}

module mainBox()
{
  sw = 20; // half width
  sr = 10;  // slot radius
  rq = 3; // rq if different from sr

  sh = 1; sl = (l-20); r = 2; ds = .1;
  hds = 7.0;      // bottom of slot
  slh = h+sr-hds; // slot height: sr at top of box
  ss = false;

  module topSlots() {
    // corner should be: [l, h, w/2 +- sr] => [100.9, 26, 43.2--53.2 (47.2  +- 4)]
    // 2 top-side slots: (fat slow for test)
    slotify2([sl, 5, 2*t0, .1], [l/2, t0/2, 1], 0, undef, true)
    // slotify2([sh, sl, 2*t0, r], [l/2, w-t0/2, h-3], [0,90,90], [2, 0], ss)
      children(0);
  }
  module topSlots0() {
    hds = 1.5;
    difference() {
      children(0);
      show(false) translate([(l-sl)/2, -p, h-tsd]) cube([sl, w+2*t0+pp, tsd+pp]);
    }
  }

  // add slot to end-cap to insert cards on bottom
  // cuts through holder, topslots0(), braces at end
  hslot() 
  {
    holder();
    // end slot:
    slotify([slh, sw, 2*t0, sr], [l-t0/2, w/2, hds+slh/2], 1, [3, 1], ss )
    topSlots0()
        box([ l, w, h ], t0);
    // Brace end of box:
    xx = 3*t0; zz = 7;
    translate([l-xx,0,0]) cube([xx,w,zz/2]);
    translate([l-(xx-t0),0,0]) cube([xx-t0,w,zz]);
    ramp();
  }
}
module slottest() {
  sw = 20; // half width
  sr = 10;  // slot radius
  rq = 3; // rq if different from sr

  sh = 1; sl = (l-20); r = 2; ds = .1;
  hds = 3.5;      // bottom of slot
  slh = h+sr-hds; // slot height: sr at top of box
  rot = [0,0,0]; riq = [2, 0];
  echo("-----SLOTIFY TEST:--------", rot, riq);
  // test: botton slot
    slotify([slh, sw, 2*t0, sr], [l-t0/2+8, w/2, t0/2], [0,0,0, 0], [3, 2], true )
  slotify([sh, sl, 2*t0, r], [l/2, w-t0/2, h], rot, riq, true)
    box([100, w, 25], t0);

}

use<testRC.scad>;
// translate([-50, -40, 0])  testRC();

loc = 0;
///
/// MAIN BUILD HERE:
///
cutaway() gridaway() mainBox();
// slottest();
// topTray();
//  dup([ 0, -25, 0 ])
//  vbox();

dy = 10;
dr = 5; // rCube test
// translate([ 0, 0, 0 ]) roundedCube([ dy, dy / 2, 3 ], dr, true);
// roundedRect([ dy, dy ], 1);

// atan(6/88) = 4;
// atan(7/88) = 4.5;
a2 = 3.2; // angle of the card on ramp
if (loc != 0)
    translate([ 0, 0, .1 ]) rotatet([ 0, a2, 0 ], [ 90, 0, 1 ]) card([ 4, (w0 - w00) / 2, 1 ]);
