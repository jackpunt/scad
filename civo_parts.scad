use <mylib.scad>;
use <MCAD/boxes.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1; p=.001; pp = 2*p;

// outer dimensions of box:
l = 138; w = 53; h = 50; 
d1 = 55; // div at x = d1;


db = 28; ss = 16; cr = 3;      // remove slot from sites end:
r = 2;
// main box:
slotify([h-db, ss/2], [0, w/2, db], undef, cr)
 box(l, w, h, 1);


// dice_box(s) inside main box; flush with sites
d = 10;           // dice size
ds = d +2*t0+1.2; // shaft size
module dbox(x=0, y= 0, z=0) {
  de = 3;           // edge to hold dice
  sw = ds - 2 * de; // slot radius: dbox
  dz = d/2; r = 2;  //
  translate([x, y, z]) 
  rotatet([0, 0, 90], [ds/2, ds/2, 0])
  {
  *translate([1.5*t0, 1.5*t0, 37]) color("white") roundedCube(d,1); // die
  difference() 
  {
      slotify([h-sw-dz, sw/2], [ds-t0, ds/2, sw], undef, r) 
      box(ds, ds, h-pp);
      translate([-p, -p, h-dz]) cube([ds+pp, ds+pp, ds-dz]);
  }
  }
}
// interior div for sites:
translate([d1, -p, 0]) 
slotify([h-db, ss/2], [0, w/2, db], undef, [cr])
  div([h, w-2*p], .2);

dbox(d1, p);
mirror([0,1,0]) dbox(d1, -w-p, p);

// make boxes for bonus_tokens (18x20) & resource_chips (20x20)
bx = 22; by=22; bz = 10+t0; f = .2; // fudge: slack in holding base
bxx = bx+2*t0+f; byy = by+2*t0+f;

// cardboard boxes:
ch = h-1*t0-.1;
module pbox(lwh=[l+t0, t0+f/2, 0]) {
  ds = h*.5; // raise slot
    translate(lwh) 
    // translate([-bxx+f/2 , 0, t0]) // <--- put in main box
    slotify([h-ds-t0, by*.125], [bx-t0, by/2, ds], undef, 2)
    box(bx, by, ch);
}
// dup([0, w-p-by-2*t0]) // <-- a second pbox
// base_lock inside main box:d box
 pbox();
  translate([l-bxx-p, p, 0])         box(bxx, byy, bz);
// translate([l-bxx-p, w-by-2*t0, p]) box(bxx, byy, bz);

// pipe for hunting tokens:
rp = 11;
//  translate([-bxx+f , 0, t0]) // <--- in the box
 translate([l+rp+t0-f/2, w-t0-rp-f/2, p]) {
  pipe([rp, rp, ch]); // <-- the pipe
  pipe([rp, rp, t0], rp/2); // base with hole
 }
// base for pipe:
translate([l-t0-rp-f/2-p, w-t0-rp-f/2-p, -p]) pipe([rp+t0+f/2, rp+t0+f/2, bz]);

// tray for bonus cardboard:
dh = 5; bl = l-(d1+ds+t0)-bxx; bw = ds; bh = 16; br=3;
*translate([(d1+ds-p), 0, h-dh-bh]) 
union() {
// dup([0, -2.1, 0])
// dup([0, 2.1, 0])
// dup([0, 4.2, 0])
// translate([t0, 4, 0]) cube([20, 2, 18]); // <-- demo cardboard
rc([bl, bw, bh], [90, 0, 0], 2, br)
difference() 
{
  cube([bl, bw, bh]);
  translate([-p, -t0, t0]) cube([bl+pp, bw+pp, bh+pp]);
}
}
// rotate([0, 90, 0]) translate([0, -20, 0]) roundedTube([bh+5, bw, bl], [.1, .1, 15, .1], 5 );
