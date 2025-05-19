use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

h0 = 3.125*25.4;    // "ideal" size of cardboard hex (3 1/8 inch)
h2 = h0 + f ;       // 2H; H = 15.625 + fudge or shrinkage; + .9 mm / 5 gaps
// echo("hs=", 2.5*h2, ">", 2.5*h0, "=", 2.5*(h2-h0), "per 2.5", "5 * (h2-h0)", 8*(h2-h0));
// radius of each hex; h2 is the measured ortho size (+ ~f)
r = h2 * sqrt3_2;

dr = 1; // 1 mm, enlarge hex radius of box
dz = 26/19;  // thickness of tile

// 3.125 = 2H; R, H=sqrt3*R/2; R = H*2/sqrt3

// squeeze-box to hold hextiles

module hexagon(tr=[0,0,0], r = r, t = t0, center = true) {
  tr = def(tr, [0,0,0]);
  trr(tr) cylinder(h = t, r=r, $fn=6, center = center);
}

function edges(i, r = r, h = 10) =
  let(
    x0 = 0,
    x1 = r * .75,
    y1 = r * sqrt3_2,
    y2 = y1/2,
    z0 = h/2
  )
  [
    [+x0, +y1, z0, [0, 0,     0],  "N"],
    [+x1, +y2, z0, [0, 0,   -60], "EN"],
    [+x1, -y2, z0, [0, 0,  -120], "ES"],
    [+x0, -y1, z0, [0, 0,  -180],  "S"],
    [-x1, -y2, z0, [0, 0,  -240], "WS"],
    [-x1, +y2, z0, [0, 0,  -300], "WN"],
  ][i];

module hexwall(dir = 0, h = 10, r = r, t = t0, center = true) {
  trr(edges(dir, r, h)) cube([r+.57*t, t, h], true);
}

module splitwall(dir = 0, h = 10, r = r, t = t0) {
  dx = .57 * t;
  xl = r + dx; dy = 1+f/2;
  trr(edges(dir, r, h)) 
  union() {
    translate ([+xl/4+dx*2, 0, 0]) cube([xl/2, t, h], true);
    translate ([-xl/4+dx, +dy, 0]) cube([xl/2, t, h], true);
  }
}


color("pink") hexagon([0,0, 1], r);

color("cyan") hexagon([0,0, 0], r+2*dr);
for (i = [0 : 3] ) 
  splitwall(i, 20, r+2*dr );

// astack(19, [0,0,dz]) color("pink") hexagon([0,0,0], r);
