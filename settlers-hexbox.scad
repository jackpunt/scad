use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

h0 = 3.125*25.4;    // "ideal" size of cardboard hex (3 1/8 inch)
h2 = h0 + f ;       // 2H; H = 15.625 + fudge or shrinkage; + .9 mm / 5 gaps
echo("hs=", 2.5*h2, ">", 2.5*h0, "=", 2.5*(h2-h0), "per 2.5", "5 * (h2-h0)", 8*(h2-h0));
// radius of each hex; h2 is the measured ortho size (+ ~f)
r = h2 * sqrt3_2;

dr = 1; // 1 mm 

// 3.125 = 2H; R, H=sqrt3*R/2; R = H*2/sqrt3

// squeeze-box to hold hextiles

module hexagon(tr=[0,0,0], r = r, t = t0, center = true) {
  tr = def(tr, [0,0,0]);
  trr(tr) cylinder(h = t, r=r, $fn=6, center = center);
}
module hexwall(h = 10, tr=[0,0,0], r = r, t = t0, center = true) {
  trr([0,0,0])  cube([r, t, h]);
}


color("pink") hexagon([0,0, 1], r);

hexagon([0,0, 0], r+2*dr);
hexwall();
