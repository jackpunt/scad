use <mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

// outer dimensions of box:
l = 140; // length of main box
w = 53;  // width of main box
h = 50;  // height of main box
d1 = 52; // div at x = d1; (hold sites)

//
ss = 16;
cr = 3;
r = 2;
db = h / 2 - ss; // raise bottom

/* clang-format off */
hn = 2.3 * t0;// hook notch


// stack of 'sites' cardboard
if (loc == 1) {
    translate([ 1.1 * t0, (w - 45) / 2, t0 ]) //
    cbstack(24, [ 45, 45, 2 ], "lightgrey", .075);
}
/* clang-format on */

// dice_box(s) inside main box; flush with sites
d = 10;                 // dice size
ds = d + 2 * t0 + 1.15; // shaft size
module dbox(x = 0, y = 0, z = 0) {
  de = 3;           // edge to hold dice
  sw = ds - 2 * de; // slot radius: dbox
  dz = d * .5;
  hdz = h - dz;
  sz = d-2;
  r = 2; // tall enough so dice don't fall out top
  translate([ x, y, z ]) rotatet([ 0, 0, 90 ], [ ds / 2, ds / 2, 0 ]) {
    if (loc == 1)                                     // show dice
      translate([ 1.5 * t0, 1.5 * t0, t0 ])           //
          rotatet([ 0, -90, 0 ], [ d / 2, 0, d / 2 ]) //
          astack(4, d + .01, [ 0, 0, 0 ])             // dice
          color("white")                              //
          roundedCube(d, 1);
    difference() {
      slotify([ sz + hdz - sw, sw, t0+pp ], [  ds - t0/2, ds / 2, (hdz-sz) / 2 + sw ], undef, r)
          box([ ds, ds, hdz ]);
    }
  }
}

// make boxes for bonus_tokens (18x20) & resource_chips (20x20)
dd = .9; // increase size for patch
bx = 22 + dd;
by = 22 + dd;
bz = 10 + t0; // bz: base_height;
f = .35;      // fudge: slack in holding base (~ nozzle/2)
bxx = bx + 2 * t0 + f;
byy = by + 2 * t0 + f;

ch = h - 1 * t0 - .01;

// Square box for production markers:
module pbox(xyz, t = t0) {
  rs = by * .25;
  ds = (bz + rs) * .8; // ch*.1; // raise slot

  translate(xyz) // std offset
  atrans(loc, [ [ 0, 0, 0 ], [ -bxx + f / 2, 0, t0 + p ], [] ]) // loc offset
  difference() {
    slotify([ ch - ds, rs, 2 * t ], [ bx - t/2, by / 2, ds + (ch-ds+rs)/2 ], undef, 3)
      box([ bx, by, ch ], t); // top box
    translate([ bx / 2, by / 2, -.5 ]) 
    cylinder(2, r = 5); // hole in bottom
  }
}

// cicular pipe for hunting tokens:
rp = 11;
module hbox() {
  //
  atrans(loc, [ [ 0, 0, 0 ], [ t0 - bxx + f / 2, 0, t0 ], [] ])
      translate([ l + rp + t0 - f / 2, w - t0 - rp - f / 2, p ]) {
    pipe([ rp, rp, ch ]);         // <-- the pipe
    pipe([ rp, rp, t0 ], rp / 2); // base with hole
  }
}

bl = l - (d1 + t0) - bxx;
bw = ds;
bh = 16;
br = 3;
hh = 6;
module bonusTray(loc = 0) {
  // tray for bonus cardboard:
  /* clang-format off */
    module hook()
    {
        hw = 3.25; // 3*t0 + f
        translate([ 0, t0 - hw, dh + (bh - hh) + t0 ]) 
        rc([ bl, 0+t0/2, 0 ], 0, 2, br)
        rc([ 0, 0+t0/2, 0 ], 0, 1, br) 
        difference()
        {
          cube([ bl, hw, hh ]);
          translate([ -p, t0, -t0 ]) 
          cube([ bl + pp, hw - 2 * t0 + pp, hh + pp ]);
        }
    }

    dh = 2.9;
    atrans(loc, [
        [ (l + dh + bh + bx - p), -1 * t0, 0, [ 0, -90, 0 ] ], // <-- print loc
        [ (d1 + t0 / 2 - p) + t0, t0, h - dh - bh - hn + .2], // <-- on box
        [ d1 - p, -20, 0 ]  // <-- edit loc
    ]) 
    {
        hook();
        rc([ bl, bw-t0/2, bh ], 0, 3, br) 
        rc([ 0, bw-t0/2, bh ], 0, 0, br)
        difference()
        {
            cube([ bl, bw, bh ]);
            translate([ -p, t0, t0 ]) cube([ bl + pp, bw - 2 * t0 + pp, bh + pp ]);
        }
        div([bh, bw, 0], .1, -br);
        div([bh, bw, bl-t0], .1, -br);
        if (loc == 1)
        {
            translate([ 2, bw - 1.2 * t0, t0 ])
                cbstack(5, [ 20, 18, 2, [ 0, 0, -90 ] ], "brown", .1); // <-- demo cardboard
            translate([ 24, bw - 1.2 * t0, t0 ])
                cbstack(5, [ 18, 20, 2, [ 0, 0, -90 ] ], "brown", .1); // <-- demo cardboard
        }
    }
}/* clang-format on */

// n: repetitions
// hwt: [h, w, t] or [h, w, t, rot]
// d: space between (.01)
// c: color ("tan")
module cbstack(n = 1, hwt = [ 18, 20, 2 ], c = "tan", d = .01) {
  h = hwt[0];
  w = hwt[1];
  t = hwt[2];
  rot = is_undef(hwt[3]) ? [ 0, 0, 0 ] : hwt[3];
  astack(n, t + d, rot) color(c) cube([ t, h, w ]);
}

// main box:
module mainBox() {

  slotify([ h - db , ss, 3*t0 ], [ 0, w / 2, (ss+h+db)/2 ], undef, cr) 
  difference() { 
      box([ l, w, h ]); // <-- MAIN BOX
      translate([ d1, -t0, h - hn ]) cube([ bl + 2 * t0, 3 * t0, 3 * t0 ]);
  }
  // interior divs:
  translate([ d1, -p, 0 ])   // 
  slotify([ h - db , ss, 3*t0 ], [ 0, w / 2, (ss+h+db)/2 ], undef, cr) //
  div([ h, w - 2 * p ], .2); // div for sites

  cw = 28;  // size of VP_100
  sy = [ t0, w - cw - t0 * 2.2, t0 * 1.5 ];
  if (loc == 1)
    translate([ d1 + 3 * (ds - t0) + 1.1 * t0, sy[loc], t0 ])
        cbstack(12, [ 28, 28, 2 ], "tan", .1); // score-100 tiles

  color("green") div([ bz, w, d1 + 3 * (ds - t0) ], 0);  // div VP_100 & dbox
  color("green") div([ bz, w, l - bxx ], 0);  // div for VP_100 & pbox

  // dbox(d1, p);
  dup([ ds - t0, 0, 0 ]) dup([ ds - t0, 0, 0 ]) mirror([ 0, 1, 0 ])
    dbox(d1, -w - p, p);

  // base for pbox:
  translate([ l - (bxx)-p, p, 0 ]) box([ bxx, byy, bz ]);

  // base for hbox:
  translate([ l - t0 - rp - f / 2 - p, w - t0 - rp - f / 2 - p, -p ])
      pipe([ rp + t0 + f / 2, rp + t0 + f / 2, bz ]);

}
loc = 0;

*mainBox();
bonusTray(loc);
*pbox([ l + t0, t0 + f / 2, 0 ], t0 + p);
*hbox();
