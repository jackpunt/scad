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
// round top_inner corners:
slotify([h-db, ss/2], [0, w/2, db], undef, cr)
 box(l, w, h, 1);


// dice_box(s) inside main box; flush with sites
module dbox(x=0, y= 0, z=0) {
  d = 10;           // dice size
  ds = d +2*t0+1.2; // shaft size
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
bx = 22; by=22; bz = 10; f = .2; // fudge: slack in holding base
bxx = bx+2*t0+f; byy = by+2*t0+f;

// main parts box:
module pbox(lwh=[l+t0, t0+f/2, 0]) {
  ds = h*.5; // raise slot
    translate(lwh) 
    translate([-bxx+f/2 , 0, t0])
    slotify([h-ds-t0, by*.125], [bx-t0, by/2, ds], undef, 2)
    box(bx, by, h-1*t0-.1);
}
dup([0, w-p-by-2*t0]) pbox();
// base_lock inside main box
translate([l-bxx-p, p, p])         box(bxx, byy, bz);
translate([l-bxx-p, w-by-2*t0, p]) box(bxx, byy, bz);
