use <mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1; p=.001; pp = 2*p;

// outer dimensions of box:
l = 140; w = 53; h = 50; 
d1 = 55; // div at x = d1;

// 
db = 28; ss = 16; cr = 3;
r = 2;

loc = 0;
// main box:
slotify([h-db, ss/2], [0, w/2, db], undef, cr)
  difference() {
  box([l, w, h]);
  translate([d1, -t0, h-2*t0])  cube([bl+2*t0, 3*t0, 3*t0]);
  }
bonusTray(loc);
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
      box([ds, ds, h-pp]);
      translate([-p, -p, h-dz]) cube([ds+pp, ds+pp, ds-dz]);
  }
  }
}
// interior div for sites:
translate([d1, -p, 0]) 
slotify([h-db, ss/2], [0, w/2, db], undef, cr)
  div([h, w-2*p], .2);

// dbox(d1, p);
dup([ds-t0, 0, 0])
dup([ds-t0, 0, 0])
mirror([0,1,0]) dbox(d1, -w-p, p);


// make boxes for bonus_tokens (18x20) & resource_chips (20x20)
dd = .9; // increase size for patch
bx = 22+dd; by=22+dd; bz = 10+t0; // bz: base_height; 
f = .2; // fudge: slack in holding base
bxx = bx+2*t0+f; byy = by+2*t0+f;

ch = h-1*t0-.01;
// cardboard boxes:
module pbox(xyz, t=t0) {
  rs = by*.125;
  ds = (bz+rs)*.8; //ch*.1; // raise slot
  module atrans() {
    if (loc == 0) {
      translate([-bxx+f/2 , 0, t0+p]) // <--- put in main box
      children(0);
    } else {
      children(0);
    }
  }
  translate(xyz) 
  atrans()
  difference() {
    rh = 5;
    slotify([ch-ds, rs, 2*t], [bx-2*t, by/2, ds], undef, 3)
    // slotify([ch-bz-ds, rs, 2*t], [bx-2*t, by/2, ds], undef, 3)
      box([bx, by, ch], t); // top box
    translate([bx/2 ,by/2, -.5]) cylinder(2, rh, rh);
  }
}

// base_lock inside main box:d box
pbox([l+t0, t0+f/2, 0], t0+p);
translate([l-(bxx)-p, p, 0])  box([bxx, byy, bz]);

// pipe for hunting tokens:
module hbox() {
rp = 11;
module atrans(loc) {
  if (loc == 0) {
    translate([t0-bxx+f/2 , 0, t0]) // <--- in the box
    children(0);
  } else {
    children(0);
  }
}
//
atrans(loc)
translate([l+rp+t0-f/2, w-t0-rp-f/2, p]) {
  pipe([rp, rp, ch]); // <-- the pipe
  pipe([rp, rp, t0], rp/2); // base with hole
 }
// base for pipe:
translate([l-t0-rp-f/2-p, w-t0-rp-f/2-p, -p]) pipe([rp+t0+f/2, rp+t0+f/2, bz]);
}
hbox();

bl = l-(d1+t0)-bxx; bw = ds; bh = 16; br=3; hh=6;
module bonusTray(loc=0) {
// tray for bonus cardboard:
dh = 5; 
module atrans(loc = 0) {
  if (loc == 0) {
    translate([(d1+t0/2-p)+t0, t0, h-dh-bh-t0*1.2]) // <-- hook on box
    children(0);
  } else if (loc == 1) {
    translate([(l+dh+ds+bx-p), -1*t0, 0]) rotate([0,-90,0]) // <-- print location/orientation
    children(0);
  } else if (loc == 2) {
    translate([d1-p, -20, 0]) // <-- edit loc
    children(0);
  }
}
atrans(loc)
union() {
// dup([0, -2.1, 0])
// dup([0, 2.1, 0])
// dup([0, 4.2, 0])
// translate([t0, 4, 0]) cube([20, 2, 18]); // <-- demo cardboard
rc([bl, bw, bh], [90, 0, 0], 2, br)
rc([0, bw, bh], [90, 0, 0], 1, br)
difference() 
{
  cube([bl, bw, bh]);
  translate([-p, t0, t0]) cube([bl+pp, bw-2*t0+pp, bh+pp]);
}
// hook:
hw = 3.25;
translate([0, t0-hw, dh+(bh-hh)+t0]) 
rc([bl, 0, 0], [-90, 0, 0], 2, br)
rc([0, 0, 0], [-90, 0, 0], 1, br)
difference() 
{
  cube([bl, hw, hh]);
  translate([-p, t0, -t0]) cube([bl+pp, hw-2*t0+pp, hh+pp]);
}
}
}
