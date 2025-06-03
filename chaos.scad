use <mylib.scad>;
// use <settlers-tray.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

// radius of each hex; h2 is the measured ortho size (+ ~f)
R = 2 * 25.4; // h2 * sqrt3_2;
h0 = R * sqrt3_2;
h2 = 2 * h0;
echo("R, h0, h2", R, h0, h2);

height = 90;
width = 80;
r = 15;

module cbox(r = r, h = height, w = width, k) {
  k = is_undef(k) ? -r : k;
  z = 2 * r;
  intersection() 
  {
  div([z, h, 0], r, k, w);
  divXZ([z, w, 0], r, k, h);
  }
}

module ctray(r = r, h = height, w = width, k) {
  k = is_undef(k) ? -r * 1.2 : k;
  difference() 
  {
  cbox(r, h, w, k);
  trr([t0/2, t0/2, t0])
  cbox(r, h-t0, w-t0, k);
  }
}
// cs: child size; begin grid @ (cs, cs+1)
// nc: columns
// nr: rows
module partsGrid(bw, bh, cs = 5, nc = 10, nr = 20) {
  x0 = cs;
  xi = (bw - cs) / nc;
  xm = bw - cs;
  y0 = cs + 1;
  yi = (bh - cs) / nr;
  ym = bh - cs;
  translate([0, 0, -t0])
  gridify([x0, xi, xm], [y0, yi, ym], 2) cube([cs, cs, cs]);
}

module clip(tr, wx = 2, ly = 3, hz = 2) {
  translate(tr) cube([wx, ly, hz], true);
}
module clips(tr, xa, dy = 30, wx = 2, ly = 3, hz = 2) {
  for (x = xa, iy = [-dy: dy: dy]) 
  {
    clip([tr[0]+x, tr[1]+iy, tr[2]], wx, ly, hz);
    // clip([tr[0]+x1, tr[1]+iy, tr[2]], wx, ly, hz);
  }
}

module partsLid(lw, lh, lz, sd) {
  sd = is_undef(sd) ? 7 : sd;
  union() {
  translate([f, -f, 0])
  difference() {
    box([lw, lh, lz]); // partslid
    partsGrid(width, height, 5, 10, 12);
  }

  // add clips:
  cx = 1+f; d0 = (t0+cx/2);
  tr = [f, (lh-f)/2, t0+sd+f];
  color("red") clips(tr, [00+d0, lw-d0], 30, cx);
  }
}

dzz = [10, 9, 7, 5]; // mtn, Gem, E5, E1
rzz = [1, 1, 1, 1.4];

// sumi computes sum of ary[i: 0..i]
function sumi(ary, i = 0, t0 = t0) = (i > 0 ? t0 + sumi(ary, i-1) + ary[i] : 0);

// four trasy stacked by dzz
module fourTrays(dzz = dzz, rzz = rzz) {
  for (i = [0 : len(dzz)-1])
    let(z = sumi(dzz, i)+1, rz = rzz[i])
    trr([0, 0, z]) ctray(r, height, width, -r*rz);
}

loc = 0;
module lid(h = 27) {
  atrans(loc, [[- width - 4, 0, 0], [t0, -t0, 34, [0, 180, 0, [width/2, height/2, 0]]]]) 
    partsLid(width+2*t0, height+2*t0, h, h-2);
}
difference()
{
  union() {
    fourTrays();
    lid();
  }
  trr([-3, -4, -1]) cube([width+6, 30, 40]);
}
