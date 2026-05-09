use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 2;
inch = 25.4;

h0 = .5 * inch - t0;  // center peg
r0 = .25 * inch; // center peg
r1 = .50 * inch; // flat base radius

// NOTE: print with Strength: bottom shell layers = 6;
// 
astack(3, [inch+.4, 0, 0])
difference() {
  union() {
    trr([0, 0, p])
    linear_extrude(height = t0) circle(r = r1);

    trr([0, 0, t0-p])
    linear_extrude(height = h0, scale = .9) {
      circle(r = r0-f);
      square(size = [1.8, r0*2], center = true);
      square(size = [r0*2, 1.8], center = true);
    }
  }
  cylinder(r1=.8, r2=.6, h=h0+2*t0-pp, $fn=12);
}
