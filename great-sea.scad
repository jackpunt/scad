use <mylib.scad>;
// Organizer for GreatSeas box and components
// nine and half ship upgrade market holders
// four player component boxes: 
// --  action(6) & combat(16+8) cards, ships/dudes (29+2), point-markers, trade posts, ship-class & fleet tiles
// temple risers?, coin tray, wood tray, worker/damage/stat tray, "special action" (temple) cards


p = .001;
pp = 2 * p;
t0 = 1;
f = .18;      // fudge for physical clearance
f1 = .1;      // fudge for display
t2 = 2*t0;    // 2 walls
ty = 1.5 * t0;   // neutral box y-wall thickness

sample = false;  // true to print mini-box

cbw = 140;       // combat board
cbh = 100;
cbz = 8;         // 4 * tilez

mapz = 11.5 + 2; // map thickness reduces availablbe box depth + rule book

// box size and placement constraint (3x4 grid in square box)
boxy = 220;    // internal XY-dim of cardboard box (components must fit within)
boxz = 65 - mapz;    // internal height of cardboard box (components must fit within)

// Garphill 54x86 cards
w00 = sample ? 27 : 54;  // official card size [short dimension]
h00 = sample ? 42 : 86;  // official card size [long dimension]

ds = 12;       // dice size

t00 = 8/24;    // = .333mm card thickness: sleeves 60 mics = .06 mm ==> .393 == .4 with sleeves?
t01 = .440;    // = .33 + .6 mm; thickness when stacking sleeved cards (compressed) TBD when sleeve arrive.

// width of card with sleeves (56) 88x56
w0 = w00+2;
// height of card with sleeves (88)
h0 = h00+2;
// stack of Player Cards:
npc = 30;    // number of player cards
z0 = (npc+2) * t01;

pdw = 216;   // playerBoard-x-width: 4 residual
pdh = 133;   // playerBoard-y-height: 87 residual (< 88 sleeve)
pdz = 21;    // playerBoard-z
pdo = (boxy-pdw)/2;     // player board offset (in view)

dw = 2.0;        // fort/ship external wedge size
bz0 = 1.5;       // taperBox base thickness

tilez = 2;       // thickness of cardboard stock (1.78)
tilez9 = tilez * 9.1;  // stack of 9 tiles
tilezb = tilez9 + bz0; // height of fort/ship holders
lidz = 1;        // thickness of neutralLid
lidf = 1.4;      // extend lidz for cutting slot
lidc = 1.4;      // overhang 'clip' above lid

// size of neutral box:
ntx = boxy ;  // x-size of box
nty = pdh;  // y-size of box 
ntz0 = tilezb + t0 + .1;    // to interior/bottom of lid
ntzl = ntz0 + lidf;         // top of 'lid'
ntz  = ntzl + lidc;  // z-size of box (incl: lid & overhang) 
echo("nxt, nty, ntz =", [ntx, nty, ntz0, ntzl, ntz], "tilezb =", tilezb, "boxz =", boxz );

// PlayerBox: cardSection
psz0 = ntz0 - 1.0 - f1;   // z-size of nested box
csh = w0 + t2 + 4 * t0;  // t0 fudge around card (62)
csw = h0 + t2 + 4 * t0;  // cardSection (94)
csz = (boxz - psz0 -f1)/2;  // (pdz + cbz + lidz)/2 >> t0 + (npc+2) * t01;
csz0 = t0 + (npc) * t01; // cards stack to 13.8--14.2
if (csz < csz0 || true ) echo("csz < csz0: csz =", csz, "csz0 =", csz0);


// Note: left & bottom end-cap are embedded in tray wall
cardTrayw = w0 + 6;  // 2 endcaps + 3 gaps; balance with h0 sleeve size
cardTrayh = h0 +ty + 4; // abuts bottom edge: cbh + 2*ty + 4

combatt = 5;    // thickness of combat status disks
combatd = 18;   // diameter of combat status disks (10 of them)
damaged = 8;    // x, y, z dimension of orange cube. (12 of them)
templed = 19;   // diameter of Temple disks
workerd = 22;   // height of worker meeple

nTemple = 6;
nTempleCards = 24;        // number of 'special' action cards (4 x nTemples)
cardz = t01 * (nTempleCards + 4);

module vol(dxyz, label = "vol: ") {
  echo(str(label, "psx, psy, psz = ", dxyz, " vol=", prod(dxyz) / 1000));
}

// (w0 x h0) sleeved card size
module card(n = 1, w = w0, h = h0, cz = t01, c = "lightblue") {
  // put cards in sideways orientation:
  astack(n, [0, 0, cz]) color(c) cube([w, h, cz * .9]);
}

module astackxyz(n, d, rot, colors, i0 = 0) {
  function scolor(ii) = is_list(colors) ? colors[(ii % len(colors))] : colors;
  dxyz = is_list(d) ? d : [ 0, 0, d ];
  rxyz = is_list(rot) ? rot : is_undef(rot) ? [ 0, 0, 0 ] : rotOfId(rot);
  n = is_list(n) ? n : (dxyz.x != 0) ? [ n, 0, 0 ] : (dxyz.y != 0) ? [ 0, n, 0 ] : [0, 0, n];
  imax = i0 + prod(n) - 1;
  echo("dxyz=", dxyz, "n=", n, "i0=", i0, "imax=", imax);
  if (i0 <= imax)
  for (ii = [i0 : imax]) {
    // ix = floor(ii/1.0) % n.x;
    ix = ii % n.x;
    iy = (floor(ii/n.x)) % n.y;
    iz = floor(ii/(n.y*n.x)) % n.z;
    echo(ii, "ix, iy, iz = ", ix, iy, iz);
    color(scolor(ii))
    rotate(rxyz) trr(amul(dxyz, [ix, iy, iz])) children();
  }
}

// Player Colors
pcolors = ["red", "orange", "purple", "grey"];

// box for Parts & Player Cards
module partsSection(nx = 2, ny = 1, nz = 2, df = 0) {
  tl = 1.1;
  dlz = 1.1;   //
  dlxy = 2.5;  // for lid
  psx = (boxy / 2) - 1 * f1 - dlxy;
  psy = boxy - pdh - f1 - dlxy;
  psz = (boxz - f1) / 2 - dlz;  // 
  dxyz = [psx + f1 + df + dlxy, psy + f1 + df + 2, psz + f1 + df + dlz];
  echo("psx, psy, psz = ", [psx, psy, psz], "vol=", psx * psy * psz / 1000, "net =", psx * psy * psz / 1000 - w0 * h0 * z0 / 1000);
  trr([tl, tl + pdh - nty, 0])
  astackxyz([nx, ny, nz], dxyz, undef, pcolors) {
    roundedBox([psx, psy, psz], 1);
  }
  trr([tl, tl + pdh - nty, 0])
  astackxyz([nx, ny, nz], dxyz) {
    if (loc == 0)
      trr([(csw-h0)/2, (csh-w0)/2, t0]) card(npc, h0, w0);
  }
}

module combatBoard() {
  cbws = 68.0;     // central "tab" height (wide part < cbh = 100)
  cbhi = 87.8;     // width of narrow part (less than cbw = 140)
  c = "#ffec5ec1";// '#7fccf610'
  trr([0, cbh/2, cbz/2]) 
  {
    color(c) 
    roundedCube([cbw, cbhi, cbz], 3, true, true);
    color(c) 
    roundedCube([cbws, cbh, cbz-p], 3, true, true);
  }
}

// w: interior width (long side; finger cut on this edge)
// h: interior height
// z: interior z-size
// rz: rotation around z-axis (while still centered around [0,0] )
// ambient: 
// - dw: wedge size
// - bz0: base thickness
module taperBox(w = 30, h = 24, z = tilez9, rz = 0) {
  z = def(z, tilez9);
  // linearExtrude(taper) roundedRect(), cut finger slots on side and base
  dww = w + 2 * dw;  // full width
  dwh = h + 2 * dw;  // full height
  shz = z + bz0;
  cr = max(w/4, 7);   // cylinder radius
  dy = dwh/2-dw/2;
  wh = (w + h)/2;
  module cut(r = cr, dir = 1) {
    trr([0, dir * dy, -p]) {
    scale([1,.5]) 
    trr([0, 0, (bz0+tilez9+2*pp)/2]) cylinder(h = bz0+tilez9+2*pp, r = r, center = true);
    trr([0, 0, bz0+(bz0+tilez9+pp)/2]) cube([2*r, dw + .1 +8*p, tilez9+bz0+pp], true);
    trr([0, dir*dw/2, (bz0+tilez9+pp)/2]) cube([2*r, dw + .1 +8*p, tilez9+bz0+pp], true);
    }
  }
  // extrude & rotate while centered; then offset from [0, 0]
  trr([dww/2, dwh/2, 0, [0, 0, rz]])
  difference() {
    linear_extrude(height = shz, scale = (wh + 2 * t0) / (wh + 2 * dw))
    trr([-dww/2, -dwh/2, 0]) roundedRect([dww, dwh], 1);
    trr([-w/2,   -h/2, bz0]) cube([w, h, shz] ); // tile
    cut(cr, -1);      // base slot & finger cut
    cut(cr, +1);      // base slot & finger cut
  }
}

shipw = 30.5;     // double fudge
shiph = 24.5;     // double fudge
shipdx = shiph + 2 * dw + f1;
shipdy = shipw + 2 * dw + f1;
shipdx3 = 3 * shipdx;
shipdy3 = 3 * shipdy;
shipx0 = ntx - dw - shipdx3;
shipy0 = ty + f1;

module shipBox(nx = 3, ny = 3, df = 0) {
  module aBox() {
    dwh = shiph + 2 * dw;
    color("blue") 
    trr([0, 0, 0, [0, 0, 90, [dwh/2, dwh/2, 0]]])
    taperBox(shipw, shiph, tilez9);
  }
  astack(ny, [0, shipdy + df, 0])
  astack(nx, [shipdx + df, 0, 0]) 
  trr([shipx0, shipy0, pp]) 
  aBox();
}

fortw = 36.5;     // fort internal size (double fudge)
forth = 18.5;     // fort internal size (double fudge)
fortdx = fortw + 2 * dw + f1;
fortdy = forth + 2 * dw + f1;

fortx0 = shipx0 - fortdx;
forty0 = ty + f1;
fortdy3 = fortdy * 3;
sfxy = 18.8; 
sfxyw = sfxy + 2 * dw + f1;

echo("fortdy * 4 =", fortdy*4, "shipdx3=", shipdx3, "shipdy3 =", shipdy3);
module fortBox(lf = 3, sf = 1, df = 0) {
  module aBox(fortw = fortw, forth = forth) {
    dwh = forth + 2 * dw;
    // trr([0, 0, 0, [0, 0, 90, [dwh/2, dwh/2, 0]]]) // rotate around lower-right corner
    color("red") taperBox(fortw, forth);
  }
  // col of 3 large forts:
  astack(lf, [0, fortdy + df, 0])
  trr([fortx0, forty0, pp])
  aBox();

  // trr([fortx0-fortdx, forty0, -p])
  // aBox();
  // one half-size fort: (forty0 -forth-2*dw - 2*t0 - 2 * f1)
  trr([fortx0 + fortdx - sfxyw, forty0 + lf * fortdy + df, -p])
  astack(sf, [0, -sfxyw, 0])
  aBox(sfxy, sfxy);  // 18.4 + double fudge
}

module cardTray(fill = loc == 0 || loc == 3) {
  // div is ty @ cardtrayw
  cx = cardTrayw; cy = cardTrayh; cz = ntz0;
  if (fill)
    trr([t0 + 3* t0, ty + 2*t0, t0]) card(nTempleCards, w0, h0);
  color("#5505f585")
  trr([0+p, 0-p, 0-p]) 
  // slotifyX2( [cz, 42, 5 * t0, 1], [cx, cy/2, 0], undef, 4, false )
  div([cz, cy, cx], 0, 0, ty);
  div([cz, cy, t0], 0, 0, .4);
  divXZ([cz, cx + ty, cy], 0);
}

coind = 23.2;
coinz = 1.8;  // stack of 30 <= 54mm

module coin () { cylinder(h = coinz, r = coind/2); }

module coinTray(fill = loc == 0 || loc == 3) {
  psx = (boxy - t2 -f1) / 2 - f1;
  psy = nty - cardTrayh -3;
  psz = psz0;
  vol([psx-3, psy, psz], "Coins: ");
  trr([t0 + f1, cardTrayh + t0 + f1 , t0]) {
    roundedBox([psx-3, nty - cardTrayh -3, psz]);
    // show the coins:
    if (fill) {
    astack(10, [0, 0, coinz])
    astack(4, [coind, 0, 0])
    trr([f1 + t0+coind/2, f1 + t2+coind/2, t0]) color("silver") cylinder(h = coinz, d = coind);
    }
  }
}
module woodTray(n = 40) {
  // wood: 6.6 x 14.6 x 7.4
  wood = [6.6, 7.4, 14.6, n, .001];
  psx = (boxy) / 2;
  psy = 23;
  psz = psz0;
  trr([ntx -psx-t0-f1, nty - ty - f1 - psy, t0])
    color("#d6bd00f5")
    roundedBox([psx, psy, psz], 1);
  if (n > 0) {
    fw = .3;
    astackxyz([13, 3, 1], [wood.x * 1.3, wood.y + fw, wood.z + fw])
    trr([ntx -psx-t0-f1, nty - ty - f1 - psy, t2])
    color("#7a4402f5")
    cube([wood.x, wood.y, wood.z]);

  }
  vol([psx, psy, psz], "wood: ");
  woodv = round(prod(wood));
  echo("wood: vol =", woodv);
}

module statDisks() {
  h = combatt; r = combatd/2;
  module statd() {
    cylinder(h = h, r = r);
  }
  astack(10, [0, h, 0], undef, ["red", "blue","green","orange","violet"])
  trr([0, 0, r, [-90, 0, 0]]) statd();
  // trr([-15.6, 3, 10, [0, 90, 0]]) color("violet") statd();
}

// aligned: x0 is center of stack, y0 is bottom of stack
module temples() {
  h = tilez * 1; d = templed;  // templez could go up to 3.11!
  astack(nTemple, [0, h, 0], undef, "#fefcbc9a")
    trr([0, 0, d/2, [-90, 0, 0]]) cylinder(h = h*.9, d = d);
}

// from cubitos
// bw: allocated width (cols)
// bh: allocated height (rows)
// snr: [cs, nc, nr]
// - cs: child size; begin grid @ (cs, cs+1)
// - nc: columns
// - nr: rows
module lidGrid(bw, bh, snr=[5, 10, 20]) {
  snr = def(snr, [5, 10, 20]);
  cs = snr[0]; nc = snr[1]; nr = snr[2];
  xi = (bw - cs) / nc;
  x0 = (bw - cs - xi * (nc - 1) + cs)/2;
  xm = bw - cs;
  yi = (bh - cs) / nr;
  y0 = (bh - cs - yi * (nr - 1) + cs)/2;
  yl = bh - cs;
  translate([0, 0, t0])
  gridify([x0, xi, xm], [y0, yi, yl], 2) cube([cs, cs, cs], true);
}

// lz: enlarge for clearance when using as cut template
module neutralLid(lz = lidz) {
  fm = lz - lidz;
  lx = ntx - 2*f;
  ly = nty - ty;
  if (fm <= .01) color("#3e9eff78")  {
    trr([0-p, ty/2+f , ntz0 + f])
    difference() {
      cube([lx, ly-2*f, lz]);
      // lidGrid(lx, ly, [6, 11, 7]);
    }
    // stiffener that holds combatBoard
    tt = 3; tz = 3;
    trr([0-p, ty/2+f , ntz0 + f])
    trr([lx/2, ly/2, t0])
    difference() {
      cube([cbw+2*tt, cbh+2*tt, tz], true);
      cube([cbw+3*f, cbh+ 3*f, tz+1], true);
    }
    // box([cbw, cbh, lidz], [1, 1, 1], [2, 2, -2], true);
  }
  if (fm > .01) {
    trr([0-p, ty/2, ntz0])
    cube([lx, ly, lz]);
    bz = (lidz+lidc+fm+pp);  // end-cap when cutting
    trr([0-p,       -p, ntz0+p]) cube([3*t0+pp, nty+pp, bz]);
    trr([ntx-3*t0-p, -p, ntz0+p]) cube([3*t0+pp, nty+pp, bz]);
  }
}
module miscBox(fill = false) {
  // templeCards & forts
  divw = 27; // wide for workerd, combatd, templed
  mx0 = cardTrayw;
  mx1 = ntx - (t0 + shipdx3 + fortdx + t0);
  mx2 = ntx - (t0 + shipdx3 + sfxyw + t0); // near center of board
  my1 = ty + f1 + shipdy3 + t0; // cbh + 2*ty + 4;
  fdx = (mx0+ mx1) / 2;
  fdy = ty + f;
  divx0 = fdx - divw/2 - f1 - ty;
  divx1 = fdx + divw/2 - f1;
  // zig to left, above 3 forts:
  zigy = ty + f1 + fortdy3 +t0;
  zigx = mx2 - mx1;
                       div([ntz0,     zigy, divx1], 0); // vertical long
  trr([zigx, zigy, 0]) div([ntz0, my1-zigy, divx1], 0); // vertical short
  trr([divx1, 0, 0]) divXZ([ntz0, zigx, zigy], 0); // horizontal

  trr([divx1 + zigx, 0, 0]) divXZ([ntz0, ntx-mx2+t0, my1], 0);
 * trr([divx0, 0, 0]) divXZ([ntz0, ntx-cardTrayw, my1], 0);

  if (fill) {
    fy0 = fdy + f1;
    trr([fdx, fy0, t0]) temples();
    fy1 = fy0 + nTemple * tilez;
    trr([fdx, fy1, t0]) statDisks();
    wdy = 10.2; 
    wdz = 9.6;
    fy2 = fy1 + 12 * combatt + f1;
    astack(2, [0, wdy + f1, 0])
      trr([mx2 - workerd - t2, fy2, t0])
      color("orange") cube([workerd, wdy, wdz]);
    ccc = 8; cc1 = ccc * 1.2;
    fy3 = fy1 + 10 * combatt + t0;
    astackxyz([2, 3, 2], [cc1, cc1, cc1]) trr([mx0 + 3*t0, fy3, t0]) cube([ccc, ccc, ccc]);
  }
}

module sampleLid(lz = lidz) {
  ntx = 30;
  nty = 30;
  ntz0 = 10;
  ntzl = ntz0 + lidf;         // top of 'lid'
  ntz  = ntzl + lidc;  // z-size of box (incl: lid & overhang) 

  fm = lz - lidz;
  lx = ntx - 2*f;
  ly = nty - ty;
  if (fm <= .01) color("#3e9eff78")  {
    trr([0-p, ty/2+f , 0])
    difference() {
      cube([lx, ly-2*f, lz]);
      // lidGrid(lx, ly, [6, 11, 7]);
    }
  }
  if (fm > .01) {
    trr([0-p, ty/2, ntz0])
    cube([lx, ly, lz]);
    bz = (lidz+lidc+fm+pp);  // end-cap when cutting
    trr([0-p,       -p, ntz0+p]) cube([3*t0+pp, nty+pp, bz]);
    trr([ntx-3*t0-p, -p, ntz0+p]) cube([3*t0+pp, nty+pp, bz]);
  }
}

module sampleTray(lz = lidz) {
  ntx = 30;
  nty = 30;
  ntz0 = 10;
  ntzl = ntz0 + lidf;         // top of 'lid'
  ntz  = ntzl + lidc;  // z-size of box (incl: lid & overhang) 

  difference() {
    roundedBox([ntx, nty, ntz], 1, [t0, ty, t0]);
    sampleLid(lidf);
  }
}
if (loc == 14) {
  trr([-50, 0, 0]) sampleTray();
  trr([-50, 40, 0]) sampleLid();
}

// temple risers?, coin tray, wood tray, 
// worker/damage/stat tray, "special action" (temple) cards
// 9 & 1/2 ship-upgrade tile holders
module neutralTray(fill = loc == 0 || loc == 3) {
  difference() {
    roundedBox([ntx, nty, ntz], 1, [t0, ty, t0]);
    neutralLid(lidf);
    // cut holes below cardTray:
    astack(2, [0, (h0+6)/3, 0])
    trr([(w0+6)/2, (h0+6)/3, 0]) cylinder(h = 3, d = 20, center = true);
  }
  if (fill) {
    shipcc = [shipx0 + shipdx3/2, shipy0 + shipdy3/2, 0]; // horiz
    // trr(shipcc) cylinder(20, 1);
    trr([t0, 0, t0, [0, 0, 0, shipcc]]) shipBox();
    trr([t0, 0, t0]) fortBox(3, 1);
  }

  miscBox(fill);

  *trr(loc == 4 ? [0, -nty, -t0] : [0,0,0]) {
    woodTray(fill ? 40 : 0);
    coinTray(fill);
  }
  cardTray(fill);
  
  atrans(loc, [-1, [0,0,0], -1, -1, -1, 1]) neutralLid();

}
module playerBoards() {
  color("#af49006a") cube([pdw, pdh, pdz]); // '#af4900'
}

// 0: everything
// 1: show with lid
// 3: just neutral tray:
// 4: neutralBox for print, with coins & wood (print)
atrans(loc, [[0, 0, 0], 0, -1, 0, [0,0,0]]) neutralTray(loc != 4);
// atrans(loc, [[0, 0, 0], -1, -1, 0]) neutralLid();

// combat boards:
atrans(loc, [[boxy/2, (nty-cbh)/2, ntzl], -1, -1, -1, -1, [boxy/2, (nty-cbh)/2, ntzl]]) combatBoard();

// playerBoards:
atrans(loc, [[0, 0, 0]]) trr([ pdo, 0, boxz-pdz]) playerBoards();

// 2: partsSection
atrans(loc, [[0, nty, 0]]) partsSection();
atrans(loc, [-1, -1, [0, 0, 0]]) partsSection(2, 2, 1);


// outer box:
module outerBox(tb = .2) {
   trr([-tb-p, -tb-p, -tb-p]) color("#5756564a")
   box([boxy + 2*tb, boxy + 2*tb, boxz + tb], tb);
}
atrans(loc, [[0, 0, 0]]) outerBox(.02);

// 5: print 8 fort & 2 ship
atrans(loc, [-1, -1, -1, -1, -1, [0,0,0]]) {
  trr([0, -25, 0]) fortBox(8, 0, .4);
  trr([-shipx0, 0, 0]) shipBox(2, 1, .4);
}

// a meeple
// trr([5, 5, 1.1* t0 +  nTempleCards * t01]) cube([8, 22, 10, ]);

// 0: everything
// 1: show with lid
// 3: just neutral tray:
// 4: neutralTray for print, with coins & wood (print)

// 0: all - assembled
// 1: playerBox: partsSection, cardSection
// 2: partsSection to print
// 3: neutralTray
// 4: test print fort/ship boxes
// 5: print 8 ship/fort boxes
loc = 4; 
