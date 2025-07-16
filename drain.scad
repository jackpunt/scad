use <mylib.scad>;
t0 = 1.8;
len = 150;
high = 82;
back = 15;
rad = 18;
offx1 = 20+15;
offy1 = 25+17;
offx2 = 100;

rotate([0, 180, 0])
differenceN(2) {
  trr([0,0,0]) cube([len, high, t0]);
  trr([0,0,-back]) cube([t0, high, back]);
  trr([offx1, offy1-13, t0/2]) cylinder(h = 2*t0, r = rad, center=true);
  trr([offx2, offy1, t0/2]) cylinder(h = 2*t0, r = rad, center=true);

}
