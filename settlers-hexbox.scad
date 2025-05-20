use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1.2;
f = .06;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

h0 = 3.125*25.4;    // "ideal" size of cardboard hex (3 1/8 inch)
h2 = h0 + f ;       // 2H; H = 15.625 + fudge or shrinkage; + .9 mm / 5 gaps
// radius of each hex; h2 is the measured ortho size (+ ~f)
r = (h2/2) / sqrt3_2;
echo("h2 =", h2, "r = ", r);

dr = t0/2; // ~1 mm, enlarge hex radius of box
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
    z0 = h/2-p
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

module splitwall(dir = 0, h = 10, r = r, t = t0, f = f) {
  dx = -1.5 * t; xl = r + dx; 
  dy = t + f;
  trr(edges(dir, r, h)) 
  union() {
    translate ([+xl/4+f,  0, 0]) cube([xl/2, t, h], true);
    translate ([-xl/4-f, dy, 0]) cube([xl/2, t, h], true);
  }
}

module hexring(r0 = r, r2 = r + dr) {
  z = 1.2*t0;
 color("red") difference()
  {
    hexagon([0,0,0], r2, t0);
    hexagon([0,0,0], r0, 2*t0);
    translate([-r2, -r2, -z/2]) cube([r2-r0/2, 2*r2, z]);
  }
}

module hexbox(r = r) {
  rr = r + 2 * (2*dr + f);
  difference() {
    union() {
      color("cyan") hexagon([0, 0, 0], rr);
      trr([0, 0, t0-p]) hexring(r-.5, r + 2*dr+t0);
    }
    // cut off two sides of hexbox:
    translate([-rr*.75, 0, 0]) cube([rr/2, 2*h2, 1.2*t0], true);
  }
  for (i = [0 : 3] ) 
    splitwall(i, 20, r + dr/2, t0, f );
}


loc = 1;

atrans(loc, [[0,0,0], [0,0,0], [h2+4*t0, 0, 0]])
dup([[0, 0, 10, [ 180, 0, 0, [0, 0, 9]]], [+26-h2, 0, 0, [ 0, 0, 180, [0, 0, 00]]]][loc])
  hexbox(r + 3);
atrans(loc, [[0,0, 1.5]])
  astack(19, [0,0,dz]) color("pink") hexagon([0,0,0], r);
