use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;


// brackets to hold (cylinder) brushes under pool vacuum
br = .2 * inch; // brush radius

bw = 10;
bh = 8;
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
    color("blue") cylinder(h = l + 2*stub, r = sr);
  }
}
trr([0, 0, br]) brush();

// space for the screw, subtracted in difference below
module screw(len = z3, head = head ) {
  trr([0, 0, -len]) cylinder(h=len+head, r = 1); // screw part
  trr([0, 0, 0]) cylinder(h = head, r = 2);
}

module bracket1(bt = 2) {
  module caxis(r = sr) {
    trr([bw/2, 0, br-z3, [0, -90, 0]]) cylinder(h = bw+pp, r = r);
  }
  sxy = [1, .5]; // scale to shrink
  zh = z4-sr;    // depth of hole for screw head
  difference() {
    trr([0, 0, z3/2]) cube([bw, bh, z3], center = true); // base cube
   # trr([0, 0, zh-head]) screw(zh);
  }
  trr([0, 0, z3]) 
  differenceN() 
  {
    linear_extrude(height = br + sr + 1-z3, scale = sxy) 
      difference() {
      square(size = [bw-pp, bh], center = true);
      square(size = [bw-2*bt-pp, bh], center = true);
    }
    trr([0,0,0, [1, 0, 0, [bw/2, 0, br-z3]]])
     hull() 
    {
      caxis();
      dup([0, 0, 3]) caxis(sr*.6);
    }
  }
}

module clip() {

}

bracket1();
