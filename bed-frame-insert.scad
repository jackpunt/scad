use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 2;
inch = 25.4;

n=1;  // how many in stack
r1 = .55 * inch; // flat base radius
h0 = .5 * inch - t0;  // height of center peg
r0 = 9/32 * inch; // radius of center peg
w0 = 2 * (r0+f);  // width of wings
echo("n, h0, r1, r0 2*r0, w0", [n, h0, r1, r0, 2*r0, w0]);
pr = 1.6/2;  // pinhole radius

// NOTE: print with Strength: bottom shell layers = 6;
// 
astack(n, [2*r1+.4, 0, 0])
differenceN(2) {
  trr([0, 0, p])
  linear_extrude(height = t0) circle(r = r1);

  trr([0, 0, t0-p]) {
    trr([0, 0, t0]) 
    // taper
    linear_extrude(height = h0-t0, scale = .9) circle(r = r0);
    // base:
    linear_extrude(height = t0) circle(r = r0);
    // wings:
    linear_extrude(height = h0-t0/2, scale = .95) {
      square(size = [1.5, w0], center = true);
      square(size = [w0, 1.5], center = true);
    }
  }
  cylinder(r1=2.0, r2=pr, h=t0+t0, $fn=24); // guide hole
  cylinder(r1=pr, r2=pr*.94, h=h0+t0+pp, $fn=24); // pinhole
  astack(6, [0, 0, 0, [0, 0, 60]]) cube([pr+f, .5, h0+t0]);
}
