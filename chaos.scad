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
    trr([t0, t0, t0])
    cbox(r, h-2*t0, w-2*t0, k);
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

// place clips at each [tr] + [xa, dy] location
module clips(tr, xa, dy = 30, wx = 2, ly = 3, hz = 2) {
  for (x = xa, iy = [-dy: dy: dy]) 
  {
    translate([tr[0]+x, tr[1]+iy, tr[2]]) cube([wx, ly, hz], true);
  }
}

// perforated lid (lw, lw, lz) with clips at z=sd;
// sd: depth of clips when lid is inverted
// f = (~.18) fudge to provide friction
module partsLid(lw, lh, lz, sd, f = f) {
  sd = is_undef(sd) ? 7 : sd;
  union() {
    difference() {
      box([lw, lh, lz]); // partslid
      partsGrid(width, height, 5, 9, 9);
    }

    // add clips:
    wx = 1 + 2 * f; d0 = t0 + wx / 2 - f;
    tr = [0, lh/2, t0+sd+p];
    
    color("red") 
    //   base [x_locs      ],[dy], wx
    clips(tr, [00+d0, lw-d0], r+5, wx);
  }
}

clrs = ["brown", "red", "yellow", "yellow"];
dzz = [10, 9, 5, 7]; // mtn, Gem, E5, E1
rzz = [1.3, 1.3, 1.3, 1.75];
module parts(y = r) {
  for (i = [0 : len(dzz)-1]) 
  let (z = sumi(dzz, i), cz = dzz[i]) {
   color(clrs[i]) translate([width/2, y, (i+1) * t0 + z]) cube([10, 10, cz]);
  }
}

// sumi computes sum of ary[i: 0..i]
// z coord of bottom of i-th tray: size in dzz, plus t0.
function sumi(ary, i = 0, t0 = t0) = (i > 0 ? (t0 + ary[i-1] + sumi(ary, i-1)) : t0) - t0;
function sumt(ary, i = 0, t0 = t0) = sumi(ary, i) + i * t0;

// four trasy stacked by dzz
module fourTrays(dzz = dzz, rzz = rzz) {
  aloc = [[0, 1], [1, 1], [1, -1], [1, 0]];
  for (i = [0 : len(dzz)-1])
    let(z = sumt(dzz, i), rz = rzz[i]) echo("z = ", z)
    atrans(loc, [[aloc[i][0]*(width), aloc[i][1]*(height-4),0], [-xoff, 0, z]])
    ctray(r, height, width, -r*rz*.9);
}

xoff = 0;
loc = 0;

height = 75;
width = 80;
r = 15;

module lid(h = sumt(dzz, 3, t0+f) + 3 * t0) {
  d = t0+.2; lw = width+2*d; lh = height+2*d;
  zt = dzz[0] + sumt(dzz, 3) + t0 ; // z_offset to display
  echo("lid: zt = ", zt);

  atrans(loc, [
    [- 4, -10, 0], 
    [-d-xoff, -d, zt+p, [0, 180, 0, [lw/2, 0, 0]]],
    [-d-xoff, -d, 0, ],
    ]) 
    partsLid(lw, lh, h, h-2, .2);
}
difference()
{
  // intersection() 
  union() 
  {
    fourTrays();
    lid();
  }
  atrans(loc, [undef, [0,0,0]])
  trr([-3-xoff, -4, -1]) cube([width+6, r+5, 50]);
}

atrans(loc, [undef, [0,0,0]])
parts();
