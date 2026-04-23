use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1.2;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

h0 = 3.125*25.4;    // "ideal" size of cardboard hex (3 1/8 inch)
h2 = h0 + f ;       // 2H; H = 15.625 + fudge or shrinkage; + .9 mm / 5 gaps
// radius of each hex; h2 is the measured ortho size (+ ~f)
r = (h2/2) / sqrt3_2;
echo("h2 =", h2, "r = ", r);

dr = t0/2; // ~1 mm, enlarge hex radius of box
dz = 25/19;  // thickness of tile

// 3.125 = 2H; R, H=sqrt3*R/2; R = H*2/sqrt3

// squeeze-box to hold hextiles

// a hex shaped card
module hexagon(tr=[0,0,0], r = r, t = dz, center = true) {
  tr = def(tr, [0,0,0]);
  trr(tr) trr([0,0,t/2]) cylinder(h = t, r=r, $fn=6, center = center);
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


// two shells to join together... fails
module splitwall(dir = 0, h = 10, r = r, t = t0, f = f) {
  ff = f/3;
  dx = -1.5 * t; xl = r + dx; 
  dy = t + ff;
  trr(edges(dir, r, h)) 
  union() {
    translate ([+xl/4+ff,  0, 0]) cube([xl/2, t, h], true);
    translate ([-xl/4-ff, dy, 0]) cube([xl/2, t, h], true);
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

// hexbox with splitwall
module hexbox(r = r) {
  ff = f/3;  // try make tight
  rr = r + 2 * (2*dr + ff);
  difference() {
    union() {
      color("cyan") hexagon([0, 0, 0], rr);
      trr([0, 0, t0-p]) hexring(r-.5, r + 2*dr+t0);
    }
    // cut off two sides of hexbox:
    translate([-rr*.75, 0, 0]) cube([rr/2, 2*h2, 1.2*t0], true);
  }
  for (i = [0 : 3] ) 
    splitwall(i, 20, r + dr/2, t0, ff );
}

// solid cylinder with fn sides:
module polycylinder(h, fn = 6, r=10, trr) {
  trr = def(trr, [0, 0, 0]); // or [0, 0, -h/2]; to center-z

  $fn = fn;
  trr(trr)
  linear_extrude(h )
  circle(r);
}

function da(a, r, r0 = 60) = (sin(r0+a)-sin(r0))*r;

hr0 = r;
hr = hr0+min(hr0,da(30, hr0)); // extend to hold rotated hexes +da(hr0, 30)

/**
4 sided hex box; truncated on x
@param h: interior height
@param r: interior radius
@param t: wall/end thickness
@param trr: tr & rot & ctr
*/
module hexBox(h=10, r=5, t=t0, trr) {
  trr = def(trr, [0, 0, 0]); // or [0, 0, -h/2]; to center-z
  rr = r + 1.5*t0; 
  hh = h + 2*t0; 
  h2 = rr * sqrt3;
  k1 = .7;
  k2 = rr/3; // inset from end of box
  trr(trr)
  differenceN(1) 
  {
  // %  trr([-rr + k2/2, 0, 15])  cube([k2, .1 + k2*sqrt3*2, 32],true);
    translate([0, 0, -p])  
    polycylinder(hh, 6, rr); // outer shell: h+2*t0 X r+2*t0
    translate([1.2*t0+p, 0, t0])
    polycylinder(h, 6, r);  // interior space: h X r

    // cut off two sides of hexbox:
    // cut large base end:
    translate([rr*(1-k1/2), 0, hh/2]) cube([rr*k1, h2+pp, hh+2*pp], true);
    // cut hole on pointy end
    trr([-rr + k2/2, 0, 15])  cube([k2, .1 + k2*sqrt3*2, 32],true);
    // drill cube to square off the edge
    trr([2-rr + k2, 0, h/2+t0]) cube([6, .1 + k2*sqrt3*2-2*t0, h],true);
  }
}

// loc = 0: with cards, 1: print, 2: design, 3: wtf?
loc = 1; nt = 19; hz = nt * dz - f;  // -f to make it sticky/stretch

atrans(loc, [[0, 0, 1*t0], undef, undef, 0])
  astack(nt, [0, 0, dz]) color("pink") hexagon(undef, r, dz-f);

atrans(loc, [[1.5*t0, 0, 0], [0, 0, 0, [0, 90, 0, [r/2, 0, 0]]], [0,0,0], [0, 0, -.5]])
  // color("skyblue")
  {astack(2, [0, 0, -30]) hexBox(hz, r+2, 1);}


// splitwall hexbox does not work, the wings just break off
// *atrans(loc, [[0,0,0], [0,0,0], [h2+4*t0, 0, 0]])
//   dup([[0, 0, 10, [ 180, 0, 0, [0, 0, 9]]], [+26-h2, 0, 0, [ 0, 0, 180, [0, 0, 00]]]][loc])
//     hexbox(r + 3);
