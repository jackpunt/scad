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
cut = (rad + t0) * (2 - keep); 
// height of box
bz = rad * keep + 2 * t0;

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
  c1 = is_list(cut) && !is_undef(cut[0]) ? cut[0] : cut;
  c2 = is_list(cut) && !is_undef(cut[1]) ? cut[1] : c1;
  // c2 = def(c2, c1);
  linear_extrude(height = dz) differenceN() {
    circle(dx);
    scale([ sx, sy ]) circle(dx); // cut interior
    translate([0 -dx, dx-c1]) square([dx, c1]);
    translate([dx-dx, dx-c2]) square([dx, c2]);
  }
}

// rint = internal radius, 
// t0 = thickness to external
// nt = number of tubes
// ambient: len, cut
module tubes(rint, t0 = t0, nt = nt) {
  rad = rint + t0; // external radius
  dia = rad * 2;   // external diameter
  dbz = dia - bz;  // high cut on end
  c = (wid - 2*t0 - (nt * 2 * rint)) / nt;
  trr([0, len, 0, [90, 0, 0]])
  for (i = [0 : nt - 1]) {
    x0 = c/2 + i * (rint * 2 + c);
    c1 = (i == 0) ? dbz : cut;
    c2 = (i == nt -1) ? dbz : cut;
    // vertical pipes:
    translate([x0, rad, 0])
    halfpipe(rad, [c1, c2], t0);

    atrans(loc, [undef, [x0+rad, rad, 2*t0+ct/3]])
    chips(i);
  }
}
module disk(rad = rad, t0 = ct) {
  linear_extrude(height = t0) 
    circle(r = rad);
}
module chips(tn = 0, color = "pink") {
  astack(ns, [0, 0, ct]) {
    color(color)
    disk(rad, ct-.1);
  }
}

tubes(rad, t0, nt);
box([wid, len, bz], [t0, 2*t0, t0]); // <=== +8 to see edge
echo("bz=", bz);
loc = 1;
