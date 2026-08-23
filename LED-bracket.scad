use <mylib.scad>;


t0 = 2;

is2D = true;
p = is2D ? .001 : .001;
pp = 2 * p;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
inch = 25.4;        // mm per inch
tr0 = [0, 0, 0];    // CONST

// bracket hold outdoor LED lamp

h = 15 + t0; // NOTE: this requires a longer screw! (or fill inside an cut nut lock)
r1 = 15; // outside radius of piece1
r2 = 17; //
cr = 2.5; // center hole radius 


// a pipe with a hole in the end cap:
module piece1 (r = r1, cr = cr) {
  pipe([r, r, h], t0);       // pipe with t0 wall
  pipe([r, r, t0], r-cr);    // end cap with cr hole in center
}

// r: radius of ring
// n: number of teeth in full circle (360-degree)
// z: depth of notch (90-degre notch)
// t: thickness of ring
module tooth_ring(n = 30, r = 20, z = 2, t = t0) {
  module tooth(r = 20, z = 5, t = t) {
    trr([r, 0, 0, [0, -90, 0]])
    linear_extrude(height = t, scale = (r-t)/ r)  polygon([[0, z], [0, -z], [z, 0]]);
  }
  deg = 360 / n; dt = t/2;
  for (d = [0 : deg : 360-deg]) 
  rotate([0, 0, d])
  {
    tooth(r-dt+p, z, t);
    tooth(r+dt, z*(r+dt)/(r-dt), t);
  }
}
module piece1_tooth(d = .5) {
  piece1();
  trr([0, 0, h-3])
  intersection() {
    piece1();
    trr([0, 0, 3])
    tooth_ring(30, 16, d);
  }
}
piece1_tooth();


dx = 1; // separation of piece1 & piece2

module piece2(r = r2) {
  // trr([0, 0, -0, [0, 90, 0, [r-0, 0, 0]]])
  trr([r1+dx, 0, r, [0, 90, 0, [r*0, 0, 0]]])
  difference() {
    piece1(r, 9);
    trr([-1.6*r, -r-p, -p])
    cube([r, 2*r+pp, h+pp]); // cut the top
  }
}
cy = 16;  // cube y-size
cz = 6;   // cube z-size (fillet)
piece2();
trr([cr, -cy/2, 0]) cube([r1 + h + dx - cr, cy, t0]);
trr([r1-t0, -cy/2, 0]) cube([2*t0+dx, cy, cz]);
