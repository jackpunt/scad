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


// chaos box: 
// bz: box z (ambient bz)
// cr: scoop radius (ambient bz)
// h: y_height (height)
// w: x_width (width)
// k: keep/cut (-cr)
module cbox(bz = bz, cr = bz, h = height, w = width, k) {
  k = is_undef(k) ? -cr : k;
  z = 2 * bz;
  intersection() 
  {
    div([z, h, 0], cr, k, w);
    divXZ([z, w, 0], cr, k, h);
  }
}

module ctray(bz = bz, cr = bz, h = height, w = width, k) {
  k = is_undef(k) ? -bz * 1.2 : k;
  difference() 
  {
    cbox(bz, cr, h, w, k);
    trr([t0, t0, t0])
    cbox(bz, cr, h-2*t0, w-2*t0, k);
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

// holes to match with clips
// hole at [tr] + each [xz, dy] location
// cube [wx, ly, hz]
module holes(tr, xa, dy = 30, wx = 2, ly = 3, hz = 2) {
  for (x = xa, iy = [-dy: dy: dy]) 
  {
    translate([tr[0]+x, tr[1]+iy, tr[2]])
    cube([wx, ly+5*f, hz+5*f], true);
    // hole([tr[0]+x, tr[1]+iy, tr[2]], wx, ly, hz);
  }
}
// holes to match with clips
// hole at [tr] + each [xz, dy] location
// cube [wx, ly, hz]
module holesIf(cond = false, tr, xa, dy = 20, wx = 2, ly = 3, hz = 2) {
  if (cond) {
    difference()
    {
      children(0);
      holes(tr, xa, dy, wx, ly, hz);
    }
  } else {
    children(0);
  }
}

// place clips at [tr] + each [xa, dy] location
// xa: [left, right] edges
// dy: [-dy, 0, dy] (3 clips) or supply y_array
// cube([wx, ly, hz], true)
module clips(tr, xa, dy = 30, wx = 2, ly = 4, hz = 2) {
  ya = is_list(dy) ? dy : [-dy, 0, dy];
  for (x = xa, iy = ya) 
  {
    translate([tr[0]+x, tr[1]+iy, tr[2]]) cube([wx, ly, hz], true);
  }
}

// perforated lid (lw, lw, lz) with clips at z=sd;
// sd: depth of clips when lid is inverted
// f = (~.18) fudge to provide friction
module partsLid(lw, lh, lz, sd, f = f) {
  sd = is_undef(sd) ? 8 : sd;
  sw = 16; // apparently, half-width
  sh = 8;
  sr = 2;
  // hwtr, tr, rot, riq, ss
  // slotifyY([sh, sw, 2*t0, sr], [lw/2, 00 + t0/2, lz-sh/2+sr], undef, 1, false)
  // slotifyY([sh, sw, 2*t0, sr], [lw/2, lh - t0/2, lz-sh/2+sr], undef, 1, false)

  union() {
    difference() {
      box([lw, lh, lz]); // partslid
      partsGrid(width, height, 5, 9, 9);
    }

    // add clips:
    wx = 1 + 2 * f; ly = 2.75; hz = 1.75; // holes @ 4.0 overhanging span...
    d0 = t0 + wx / 2 - f;
    
    // color("red") 
    //     [trx, try, trz],   [x_locs...      ]   ,[dy], wx
    clips([0, lh/2, sd+p+.0], [00+d0,    lw-d0]   , 15, wx, ly, hz);
    clips([0, lh/2, sd+p+.5], [00+d0-.5, lw-d0+.5], 15, wx, ly, hz);
  }
}

// set at beginning of radius: bz
module blocks(y = bz) {
  colors = selectNth(0, parts);
  for (i = [0 : len(dzz)-1]) 
  let (z = sumi(dzz, i), cz = dzz[i]) {
   color(colors[i]) translate([width/2, y, (i+1) * t0 + z]) cube([10, 10, cz]);
  }
}

// sumi computes sum of ary[i: 0..i]
// z coord of bottom of i-th tray: size in dzz, plus t0.
function sumi(ary, i = 0, t0 = t0) = (i > 0 ? (t0 + ary[i-1] + sumi(ary, i-1)) : t0) - t0;
// bottom of the i-th layer
function sumt(ary, i = 0, t0 = t0) = sumi(ary, i) + i * t0;

// four trays stacked by dzz
module fourTrays() {
  clr = selectNth(0, parts);
  dzz = selectNth(1, parts); // block size (delta-z in stack)
  crr = selectNth(2, parts);
  rzz = selectNth(3, parts); // k
  bzz = selectNth(4, parts); // box z (wall height)
  aloc = [[1, 1], [0, 0], [1, 0], [0, 1]];
  for (i = [0 : len(dzz)-1])
    let(z = sumt(dzz, i), cr = crr[i], bz = bzz[i], rz = -bz * rzz[i])
    atrans(loc, [[aloc[i][0]*(width+1), aloc[i][1]*(height+1),0], [-xoff, 0, z], 1])
    holesIf(i == 0, [0, height/2, bz-4+p], [0, width], 15, 3, 4, 2.65)
    color(clr[i])
    ctray(bz, cr, height, width, rz);
}

// Lid Overhang (below clips)
loh = 1.5;
module lid(lz = sumt(dzz, 4) - sumt(dzz, 1) + loh * t0) {
  d = t0+.2; lw = width+2*d; lh = height+2*d;
  zt = sumt(dzz, 4) + 1.2 * t0 ; // z_offset to display
  echo("lid: lw, lh, zt = ", lw, lh, zt);

  atrans(loc, [
    undef, // [ 8, height + 2, 0], 
    [-d-xoff, -d, zt+p, [0, 180, 0, [lw/2, 0, 0]]],
    1,
    [-d-xoff, -d, 0, ],
    ]) 
    partsLid(lw, lh, lz, lz - (loh + 2.0)*t0, .2);
}

// 0: printable, 1: assembled with blocks& cutaway, 2: assembled, 3: lid only
loc = 1;

xoff = 0;

height = 92; // 93mm at bottom of cell; - 2mm lid; (no room for dice)
width = 80;  // full size
bz = 13; // height of cbox, default corner radius
parts = [ 
  // color, dz, cr, k, bz
  ["brown", 12,  2, 1, 20], // Mtn
  ["yellow", 5, bz, 1.5, bz+7], // E-1
  [  "red", 10, bz, 1.5, bz+7],   // Gem
  ["yellow", 7, bz, 1.45, bz], // E-5
  ];
// ambient value: dzz
dzz = selectNth(1, parts);
for (i = [0 : len(parts)]) echo(i, "sumi() = ", sumi(dzz, i), "sumt() = ", sumt(dzz,i));

differenceN(1,0)
{
  // intersection() 
  union() 
  {
    fourTrays();
    lid();
  }
  atrans(loc, [undef, [0,0,0]])
  trr([-3-xoff, -4, -1]) cube([width+6, bz+5, 50]); // cutaway view
  atrans(loc, [undef, [0,0,0]])
  trr([-3-xoff, -4, -1]) cube([bz+5, height+6, 50]) // cutaway view
  ;
}

atrans(loc, [undef, [0,0,0]])
blocks();
