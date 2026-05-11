use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;
rr = 8.25 * inch;
rw = .5 * inch;

bh = 3; // bracket height

module ring(r1=20, r2 = 18, $fa=$fa, $fn=$fn) {
  difference() {
  circle(r=r1, $fa=$fa, $fn=$fn);
  circle(r2, $fa=$fa, $fn=$fn);
  }
}
module basket() {
  ri = rr - rw;
  color ("white") 
  trr([0, 0, -p]) linear_extrude(height = t0) 
  trr([0, rr, 0]) ring(rr, ri, $fn=60);
  trr([0, 0, 0, [-90, 0, 0]])
  cylinder(h = ri*2, r = 1.5);
}

bw = 8;         // bracket segment width
bs = 50;        // bracket segment length
bm = sqrt(3)/2; // translate to close angle at corners
module bracket() {
  lx = 1.5*bs;
  ly = bw * 3;
  differenceN(2) {
    trr([-lx/2, ly, 0]) cube([lx, bw, bh]);
    // approx      vv    but wrong for other bs
    trr([0, bw/(2*sqrt(3))+9, 0, [0, 0, -30]])
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
// 0: design, 1 bracket, 2: w/ puck
loc = 1;
atrans(loc, [[0, 0, 0], [0, 0, 0, [180, 0, 0]], 0]) bracket();
atrans(loc, [undef, undef, [0, 0, 0]])
 trr([0, pr, bh]) puck();
atrans(loc, [[0, 0, 0], undef, 0])
 basket();

