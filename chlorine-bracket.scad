use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;
rr = 8.25 * inch;
ri = rr - .25 * inch;

bh = 3; // bracket height

module ring(r1=20, r2 = 18, $fa=$fa, $fn=$fn) {
  difference() {
  circle(r=r1, $fa=$fa, $fn=$fn);
  circle(r2, $fa=$fa, $fn=$fn);
  }
}
module basket() {
  color ("white") 
  trr([0, 0, -p]) linear_extrude(height = t0) 
  trr([0, ri, 0]) ring(rr, ri, $fn=60);
  trr([0, 0, 0, [-90, 0, 0]])
  cylinder(h = ri*2, r = 1.5);
}

bw = 8;
bs = 50;
bm = sqrt(3)/2; // translate to close angle at corners
module bracket() {
  difference() {
    // approx      vv    but wrong for other bs
    trr([0, bw/(2*sqrt(3)), 0, [0, 0, -30]])
    linear_extrude(height = bh) 
      astack(3, [0, 0, 0, [0, 0, -60]]) {
        trr([-(bs-bw/sqrt(3))*bm, 0, 0])
        square(size = [bw, bs], center = true);
      }
    basket();
  }
}

pr = 1.5 * inch;  // puck radius
module puck(h = 1 * inch, r = 1.5 * inch) {
  color("#dbe8ff")
  cylinder(h = h, r = r);
}

// TODO atrans(...)
// trr([0, pr-(rr-ri), bh]) puck();
// basket();
bracket();
