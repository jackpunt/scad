use <mylib.scad>;
use <MCAD/boxes.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1; p=.001; pp = 2*p;

// outer dimensions of box:
l = 138; w = 53; h = 50; 
d1 = 55; // div at x = d1;


db = 22; ss = 16;      // remove slot from sites end:
r = 2;
// round top_inner corners:
rc([0, (w-ss)/2, h], [0, 90, 0], 1, r)
rc([0, (w+ss)/2-.005, h], [0, 90, 0], 0, r)
slotify([h-db, ss/2], [0, w/2, db])
 box(l, w, h, 1);


// dice_box(s) inside main box; flush with sites
module dbox(x=0, y= 0, z=0) {
  d = 10;           // dice size
  ds = d +2*t0+1.2; // shaft size
  de = 3;           // edge to hold dice
  sw = ds - 2 * de; // slot radius: dbox
  dz = d/2;
  translate([x, y, z]) {
  *translate([1.5*t0, 1.5*t0, 37]) color("white") roundedCube(d,1); // die
  difference() 
  {
      r = 2;
      rc([0, ds, h], [0, 90, 0], 1, r)         // site_slot
      slotify([h-sw-dz, sw/2], [ds-t0, ds/2, sw], [0, -90, 0], [r, 1]) 
      box(ds, ds, h-pp);
      translate([t0, t0, h-dz]) cube([ds, ds-t0+p, ds-dz]);
  }
  }
}
dbox(d1, p);
mirror([0,1,0]) dbox(d1, -w-p, p);

// interior div for sites:
translate([d1, -p, 0]) div([15, w-2*p], .2);

// make boxes for bonus_tokens (18x20) & resource_chips (20x20)
bx = 22; by=22; bz = 5; f = .2; // fudge: slack in holding base
bxx = bx+2*t0+f; byy = by+2*t0+f;

module pbox(p=[l+t0, t0+f/2, 0]) {
  ds = h*.2;
    translate(p) 
    translate([-bxx+f/2 , 0, t0])
    slotify([h-ds-t0, by*.125], [bx-t0, by/2, ds], undef, [2, 1])
    box(bx, by, h-1*t0-.1);
}
dup([0, w-p-by-2*t0]) pbox();
// base_lock inside main box
translate([l-bxx-p, p, p])         box(bxx, byy, bz);
translate([l-bxx-p, w-by-2*t0, p]) box(bxx, byy, bz);
