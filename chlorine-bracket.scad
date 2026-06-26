use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;
basket_rad = 8.25/2 * inch;
rw = .5 * inch;

bh = 3; // bracket height

module ring(r1=20, dr = 2, $fa=$fa, $fn=$fn) {
  difference() {
  circle(r=r1, $fa=$fa, $fn=$fn);
  circle(r1+dr, $fa=$fa, $fn=$fn);
  }
}

plat_rad = 2.75 * inch; 
module platform() {
  module cross(y = 6.5 * inch, w = .5 * inch) {
    square([w, y], true);
    square([y, w], true);
  }
  module cross2(r1 = 10, r2 = 30, w = 3/8 * inch) {
    astack(4, [0, 0, 0, [0, 0, 90]])
    trr([0, 0, 0, [0, 0, 45]]) trr([-w/2, r1, 0]) square([w, r2 - r1]);
  }

  w = .25 * inch; tz = 3;
  h = 2 * inch;
  pipe_rad = .25*inch; tp = 1.5;
  legs = [plat_rad - 3 * w, 0, -p];

  difference() {
    linear_extrude(height = tz) {
      ring(plat_rad, -w);
      ring(plat_rad*.5, -w);
      cross(plat_rad * 2 - 2*w);
      cross2(plat_rad*.5-w/2, plat_rad-w/2, w);      
    }
    astack(4, [0, 0, 0, [0, 0, 90]])
    trr(legs) cylinder(h = tz + pp, r = pipe_rad - tp);
  }

  astack(4, [0, 0, 0, [0, 0, 90]], undef, ["red", "blue", "green"])
  trr(legs) pipe([pipe_rad, pipe_rad, h], tp);

  // astack(2, [1.42 *pr, 1.42 * pr, 0]) trr([-r*.38, -r*.38, 3]) puck(.5*inch, .8*inch);
}

// platform() ;

// rim of the basket with steel bar handle
module basket() {
  rh = 5;     // ring height
  bz = rh;
  rod = 1.28;  // rod radius
  color ("white") 
  trr([0, 0, -rh-p]) linear_extrude(height = rh) 
  trr([0, basket_rad, -rh]) ring(basket_rad, -rw, $fn=60);
  trr([0, 0, -rod-1, [-90, 0, 0]])
  cylinder(h = 2*basket_rad-rw, r = rod); // support rod
}

bw = 8;         // bracket segment width
bs = 50;        // bracket segment length
bm = sqrt(3)/2; // translate to close angle at corners
module bracket() {
  lx = 1.5*bs;
  ly = bw * 3;
  lz = -1.6;
  differenceN(2) {
    trr([-lx/2, ly, lz]) cube([lx, bw, bh]);
    // approx      vv    but wrong for other bs
    trr([0, bw/(2*sqrt(3))+14, lz, [0, 0, -30]])
    linear_extrude(height = bh) 
      astack(3, [0, 0, 0, [0, 0, -60]]) {
        trr([-(bs-bw/sqrt(3))*bm, 0, 0])
        square(size = [bw, bs], center = true);
      }
    basket();
  }
}

puck_rad = 1.5 * inch;  // puck radius
module puck(h = 1 * inch, r = puck_rad) {
  color("#dbe8ff")
  cylinder(h = h, r = r);
}

// TODO atrans(...)
// 0: design w/basket, 1 bracket, 2: w/ puck
// 3: platform, 4: w/basket
loc = 3;
atrans(loc, [[0, 0, 0], [0, 0, 0, [180, 0, 0]], 0]) bracket();
atrans(loc, [undef, undef, [0, 0, 0]])
 trr([0, puck_rad, bh]) puck();
atrans(loc, [[0, 0, 0], undef, 0, 1, [0, -basket_rad, 0]])
 basket();
atrans(loc, [undef, 0, 0, [0, 0, 0], [3, 0, -0-3, [0, 90+45, 0]]]) 
trr([0,0,0, [0,0,45]]) platform();
