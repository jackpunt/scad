use <mylib.scad>;

p = .001;
pp = 2 * p;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

// 5-tubes, adjacent, in box, cut top
// number of tubes
nt = 5;
// number in each stack
ns = 20; 

// wall thickness
t0 = 1.5;
// radius of chip (mm)
rad = 20;
dia = 2 * rad;
// interior of case; 20 chips + gap:
len = 70; 
// interior of case; 5 tubes + 1mm gap:
wid = 201; 

// thickness of chip
ct = 10/3;
// box > nt * dia
dx = 2; 
// 
keep = .742;
cut = (rad + t0) * 1.258;
// cut = rad * (2 - keep); 

module halfpipe(rad = rad, cut = rad, t0 = t0) {
  trr([rad, 0, 0-p])
  pipe2([rad, rad, len], cut, t0);
}
// pipe with top [y] cut off:
module pipe2(rrh = 10, cut = 0, t = t0) {
  dx = is_list(rrh) && !is_undef(rrh[0]) ? rrh[0] : rrh;
  dy = is_list(rrh) && !is_undef(rrh[1]) ? rrh[1] : rrh;
  dz = is_list(rrh) && !is_undef(rrh[2]) ? rrh[2] : rrh;
  sx = dx > 0 ? (dx - t) / dx : 0;
  sy = dy > 0 ? (dy - t) / dy : 0;
  linear_extrude(height = dz) differenceN() {
    circle(dx);
    scale([ sx, sx ]) circle(dx); // cut interior
    translate([-dx, dx-cut]) square([2*dx, cut]);
  }
}

echo([rad, len, t0]);

// rint = internal radius, 
// t0 = thickness to external
// nt = number of tubes
// ambient: len
module tubes(rint, t0 = t0, nt = nt) {
  rad = rint + t0; // external radius
  dia = rad * 2;  // external diameter
  trr([0, len, 0, [90, 0, 0]])
  for (i = [0 : nt - 1]) {
    // vertical pipes:
    c0 = i * (rint * 2 );
    translate([c0, rad, 0])
    halfpipe(rad, cut, t0);
  }
}
module disk(rad = rad, t0 = ct) {
  color("pink")
  linear_extrude(height = t0) 
    circle(r = rad);
}
module chips(tn = 0) {
  gap = .05;
  trr([tn * (rad*2) + rad + t0 + gap, ns*ct + t0 + gap, rad + t0 + gap])
  rotate([90, 0,0])
  astack(ns, [0, 0, ct]) {
    disk(rad, ct-.1);
  }
}

tubes(rad, t0, nt);
box([wid, len, rad*keep+t0+8]);

chips(0);
chips(4);
