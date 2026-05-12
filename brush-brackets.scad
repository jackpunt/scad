use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;


// brackets to hold (cylinder) brushes under pool vacuum
br = .2 * inch; // brush radius

bw = 10; // x-width of main block
bh = 8;  // y-height of main block
z0 = 3;  // depth of vac inset
z1 = 2;  // base plate thickness
z2 = 5;  // thick parts of base (screw into here)
z3 = 3.5;  // depth of material for screw (screw len = z2 + z3)
z4 = br;  // height to brush axis
stub = bw;
sr = 1.5; // rod radius
head = 1; // z depth reserved for screw head

module brush(l = 20, r = br) {
  trr([-stub/2, 0, 0, [0, -90, 0]]) {
    cylinder(h = l, r = r);
    trr([0, 0, -stub])
    color("white") cylinder(h = l + 2*stub, r = sr);
  }
}

// space for the screw, subtracted in difference below
module screw(len = z3, head = head ) {
  trr([0, 0, -len]) cylinder(h=len+head, r = 1); // screw part
  trr([0, 0, 0]) cylinder(h = head, r = 2);
}

bt = 2;  // x-thickness of slotted brackets
tz = 1.5;  // top z (& clip top thickness)
bz = br + sr + tz; // bracket z-top
module bracket1(bt = bt) {
  module caxis(r = sr) {
    trr([bw/2, 0, br-z3, [0, -90, 0]]) cylinder(h = bw+pp, r = r);
  }
  sxy = [1, .5]; // scale to shrink
  zh = z4-sr;    // depth of hole for screw head
  difference() {
    trr([0, 0, z3/2]) cube([bw, bh, z3], center = true); // base cube
    trr([0, 0, zh-head]) screw(zh);   // remove hole for screw
     clip((rd+f)/2, .3);

  }
  trr([0, 0, z3]) 
  differenceN() 
  {
    linear_extrude(height = bz-z3, scale = sxy) 
      difference() {
        square(size = [bw-pp, bh], center = true);
        square(size = [bw-2*bt-pp, bh], center = true);
    }
    trr([0,0,0, [1, 0, 0, [bw/2, 0, br-z3]]])
      hull() {
        caxis();
        dup([0, 0, 3]) caxis(sr*.6);
     }
  }
}

rd = 1.8;
rh = 2;
module clip_rod(r = rd/2, h = rh ){
  trr([0, p, 0, [90, 0, 0]]) cylinder(h = h+pp, r = r);
}
module clip(r = rd/2, dh = 0) {
  dx = bw/2 - rd/2 - 1;
  dz = z3/2;
  color("blue") {
    trr([dx, bh/2, dz]) clip_rod(r, rh+dh);
    trr([-dx, bh/2, dz]) clip_rod(r, rh+dh);
  }

  clipx = bw - 2*bt;
  clipy = 2;
  clipz = bz;

  trr([0, (bh+clipy)/2, clipz/2]) cube([bw, clipy, clipz], center = true);
  trr([0, (bh/2-sr)/2, bz-tz/2]) cube([clipx, bh/2+2*sr, tz], center = true);
  }

loc = 1;
atrans(loc, [[0, 0, 0], 0])
bracket1();

atrans(loc, [[0, 0, 0], [0, 0, 0, [-90, 0, 0, [0, bh/2+2, 0]]]])
clip();

atrans(loc, [[0, 0, br]]) 
brush();
