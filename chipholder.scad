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

// radius of chip (mm)
rad = 20;
dia = 2 * rad;
// interior of case; 20 chips + gap:
len = 75; 
// interior of case; 5 tubes + 1mm gap:
wid = 205; 
// wall thickness
t0 = 1.5; // <= (wid - nt * dia)/2;

// thickness of chip
ct = 10/3;
// box > nt * dia
dx = 2; 
// keep bottom of box & tubes:
keep = .748;
// cut = (rad + t0) * 1.258;
cut = (rad+ t0) * (2 - keep); 

echo([rad, len, t0]);


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
    scale([ sx, sy ]) circle(dx); // cut interior
    translate([-dx, dx-cut]) square([2*dx, cut]);
  }
}

// rint = internal radius, 
// t0 = thickness to external
// nt = number of tubes
// ambient: len
module tubes(rint, t0 = t0, nt = nt) {
  rad = rint + t0; // external radius
  dia = rad * 2;  // external diameter
  c = (wid - 2*t0 - (nt * 2 * rint)) / nt;
  trr([0, len, 0, [90, 0, 0]])
  for (i = [0 : nt - 1]) {
    c0 = c/2 + i * (rint * 2 + c);
    // vertical pipes:
    translate([c0, rad, 0])
    halfpipe(rad, cut, t0);

    atrans(loc, [undef, [c0+rad, rad, 2*t0+1]])
    chips(i);
  }
}
module disk(rad = rad, t0 = ct) {
  linear_extrude(height = t0) 
    circle(r = rad);
}
module chips(tn = 0, color = "pink") {
  gap = .05;
  // trr([ rad , ns*ct , rad ])
  // rotate([90, 0,0])
  astack(ns, [0, 0, ct]) {
    color(color)
    disk(rad, ct-.1);
  }
}

tubes(rad, t0, nt);
box([wid, len, rad*keep+2*t0], [t0, 2*t0, t0]); // <=== +8 to see edge
echo("keep=", rad*keep+2*t0);
loc = 0;
