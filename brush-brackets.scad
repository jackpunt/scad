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
z3 = 2;  // depth of material for screw (screw len = z2 + z3)
z4 = br;  // height to brush axis
stub = bw;
sr = 1.5; // rod radius

module brush(l = 20, r = br) {
  trr([-stub/2, 0, 0, [0, -90, 0]]) {
    cylinder(h = l, r = r);
    trr([0, 0, -stub])
    color("blue") cylinder(h = l + 2*stub, r = sr);
  }
}
trr([0, 0, br]) brush();

module bracket1(bt = 2) {
  module caxis(r = sr) {
    trr([bw/2, 0, br-z3, [0, -90, 0]]) cylinder(h = bw+pp, r = r);
  }
  sxy = [1, .5];
  trr([0, 0, z3/2]) cube([bw, bh, z3], center = true); // base cube
  trr([0, 0, z3]) 
  differenceN() 
  {
    linear_extrude(height = z4+1, scale = sxy) 
      difference() {
      square(size = [bw-pp, bh], center = true);
      square(size = [bw-2*bt-pp, bh], center = true);
    }
    #cylinder(h = z3 * 2.1, r = 1, center = true);
    trr([0,0,0, [85, 0, 0, [bw/2, 0, br-z3]]])
     hull() 
    {
      caxis();
      dup([0, 0, 3]) caxis(sr*.6);
    }
  }
}

bracket1();
