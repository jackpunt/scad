use <mylib.scad>;

p = .001;
pp = 2 * p;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

// 5-tubes, adjacent, in box, cut top
// number of tubes
nt = 4;
// number in each stack
ns = 15; 

// wall thickness
t0 = 1.5; // <= (wid - nt * dia)/2;

fr = .2;  // fudge radius so chips fit easily in tubes
// radius of chip (mm) => 
crad = 27/2;
rint = crad;
rext = crad + t0;
dia = 2 * crad;
// thickness of chip
ct = 4.15; // 10/3;
bty = 2*t0;  // box thickness in y-direction; 
btyy = (76 - ct * (ns + .7))/2; // space for almost ns+1 chips
// force tray to fill 76 mm for cardboard lid!

// box > nt * dia
dx = 2; 

// empirical: crossover point of adjacent tubes
tweak = 1.301;
// keep bottom of box & tubes:
keep = 2 - tweak;
cut = (crad + t0) * tweak;

// box length, external; 20 chips + gap:
blen = ns * ct + .7 * ct + 2 * bty; 
// box width, external; 5 tubes + 1mm gap:
bwid = (crad + fr) * 2 * nt + 2 + t0 + .5;
// box height; 
bz = crad * keep + 2 * t0;

echo("[crad, blen, bwid, t0]", [crad, blen, bwid, t0]);


// rad: external radius of pipe
// cut: number or [c0, c1]
// t: thickness to interior of pipe
// ambient: blen (height: dz for pipe2)
module halfpipe(rad = crad, cut = crad, t = t0) {
  trr([rad, 0, 0-p])
  pipe2([rad, rad, blen], cut, t);
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

// rint = internal radius [crad = chip radius]
// t0 = thickness to external
// nt = number of tubes
// ambient: blen, cut, loc (1 to see chips)
module tubes(rint, t0 = t0, nt = nt) {
  rad = rint + t0; // external radius
  radx = rad + fr; // slightly oversize radius
  dia = radx * 2;  // external diameter
  dbz = dia - bz;  // high cut on ends of box
  // divey up space between tubes:
  xs = (bwid - 2 * t0 - (2 * nt * rint)) / nt;
  trr([0, blen, 0, [90, 0, 0]])
  for (i = [0 : nt - 1]) {
    x0 = xs/2 + i * (rint * 2 + xs);
    c1 = (i == 0) ? dbz : cut;
    c2 = (i == nt -1) ? dbz : cut;
    // vertical pipes:
    translate([x0, radx, 0])
    halfpipe(radx, [c1, c2], t0);

    // draw chips in the tube:
    ys = blen - 2 * bty - ns * ct; // extra space in y dir
    atrans(loc, [undef, [x0+rad, rad, bty + ys/2]])
      chips(i);
  }
}
module disk(rad = crad, t0 = ct, c = "pink") {
  color(c)
  linear_extrude(height = t0) 
    circle(r = rad);
}
// stack of disks, centered at [0,0]
// ambient: ns, crad
module chips(c = "pink") {
  astack(ns, [0, 0, ct]) {
    disk(crad, ct-.1);
  }
}

// ambient: bwid, blen, t0
module chipbox() {
    box([bwid, blen, bz], [t0, bty, t0]); // <=== +8 to see edge
}

sl = 8;
differenceN(2) {
  tubes(crad, t0, nt);
  chipbox();
  // slots for clips on lid:
  trr([(bwid-sl)/2, 0-p, 0-p]) cube([sl, 1+pp, 3]);
  trr([(bwid-sl)/2, blen-1+p, 0-p]) cube([sl, 1+pp, 3]);
}
echo("bz=", bz);
loc = 0;
