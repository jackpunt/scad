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
nty = cbh + 2*ty + 4;// 108;  // y-size of box 
ntz0 = tilezb + t0 + .1;    // to interior/bottom of lid
ntzl = ntz0 + lidf;         // top of 'lid'
ntz  = ntzl + lidc;  // z-size of box (incl: lid & overhang) 
echo("nxt, nty, ntz =", [ntx, nty, ntz0, ntzl, ntz], "tilezb =", tilezb, "boxz =", boxz );

// PlayerBox: cardSection
npc = 30;    // number of player cards
csh = (boxy - nty - 1 * f1);// > (h0 + t2);  // cardSection
csw = w0 + t2 + t0;  // t0 fudge around card
csz = t0 + (npc+2) * t01; // 13.2 --> 14: useable underhang height: (boxz - pdz) / 2 = 15.25;
if (csh < h0  + t2 + t2 || true ) echo("csh < h0 + t2: ", csh -t2, h0, "csz=", csz);


// Note: left & bottom end-cap are embedded in tray wall
cardTrayw = w0 + 6;  // 2 endcaps + 3 gaps; balance with h0 sleeve size
cardTrayh = nty; // abuts bottom edge: 

combatt = 5;    // thickness of combat status disks
combatd = 18;   // diameter of combat status disks (10 of them)
damaged = 8;    // x, y, z dimension of orange cube. (12 of them)
templed = 19;   // diameter of Temple disks
workerd = 22;   // height of worker meeple

nTemple = 6;
nTempleCards = 24;        // number of 'special' action cards (4 x nTemples)
cardz = t01 * (nTempleCards + 4);


echo("cardTrayw =", cardTrayw, "cardTrayh =", cardTrayh, "nty=", nty, nty+cardTrayw);

// (w0 x h0) sleeved card size
module card(n = 1, w = w0, h = h0, cz = t01, c = "lightblue") {
  // put cards in sideways orientation:
  astack(n, [0, 0, cz]) color(c) cube([w, h, cz * .9]);
}

// hold 3 * (8 combat) + 6 * (1 Action) = 30 cards
// if (df == 0) stack on z-axis
module cardSection(nx = 2, nz = 2, df = 0) {
  row2 = (df == 0) ? [0, 0, csz + f1] : [0, csh + f1 + df, 0];
  astack(nz, row2)
  astack(nx, [csw + f1+ df, 0, 0]) {
  box([csw, csh, csz], t0);
  trr([(csw-w0)/2, (csh-h0)/2, t0]) card(1, w0, h0);
  }
}

// given cardSection x-extent & boxy: compute 
function psxyzc(csx = 2 * (csw + f1)) = [
  (boxy - csx) / 2 - f1, // psx
  (csh - (pdh - nty))/2, // psy
  boxz,                  // psz
  csx
];

module partsSection() {
  ps = psxyzc(); 
  psx = ps.x;
  psy = ps.y; //(boxy - pdh - f1) / 2 - 2 * f1;
  psz = ps.z;
  csx = ps[3];
  trr([csx + f1, pdh-nty+f1, 0]) roundedBox([psx, psy, psz], 1);
  echo("psx, psy, psz = ", [psx, psy, psz], "vol=", psx * psy * psz / 1000);
}
module neutralSection() {
  dy = pdh - nty;  // 3.5
  nsx = csw;
  nsy = csh - dy;
  nsz = pdz;// boxz - 2 * (csz + f1);
  trr([0, dy+f1, 2 * csz + f1]) color("#ac8a45")
  roundedBox([nsx, nsy, nsz], 1);
  echo("neutral volume: ", [nsx, nsy, nsz], nsx * nsy * nsz / 1000);
}

module playerBox() {
  cardSection();
  ps = psxyzc(); 
  psx = ps.x;
  psy = ps.y;
  psz = ps.z;
  csx = ps[3];
  astack(2, [0, psy+f1, 0]) 
  astack(2, [psx+f1, 0, 0])
  partsSection();
 * astack(2, [csx/2, 0, 0]) neutralSection();
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

fortw = 36.5;     // fort internal size (double fudge)
forth = 18.5;     // fort internal size (double fudge)
fortdx = fortw + 2 * dw + f1;
fortdy = forth + 2 * dw + f1;

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

fortx0 = shipx0 - fortdx;
forty0 = ty + f1;
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
  sfxy = 18.8; sfdx = sfxy + 2 * dw + f1;
  trr([fortx0 + fortdx - sfdx, forty0 + lf * fortdy + df, -p])
  astack(sf, [0, -sfdx, 0])
  aBox(sfxy, sfxy);  // 18.4 + double fudge
}

module cardTray() {
  // div is ty @ cardtrayw
  cx = cardTrayw; cy = cardTrayh; cz = ntz0;
  trr([t0 + 3* t0, ty + 2*t0, t0]) card(nTempleCards, w0, h0);
  color("#5505f585")
  trr([0+p, 0-p, 0-p]) 
  // slotifyX2( [cz, 42, 5 * t0, 1], [cx, cy/2, 0], undef, 4, false )
  div([cz, cy, cx], 0, 0, ty);
  div([cz, cy, t0], 0, 0, .4);

}

coind = 23.2;
coinz = 1.8;  // stack of 30 <= 54mm

module coin () { cylinder(h = coinz, r = coind/2); }
module coinTray(n = 40) {
  cx = 4 * coind + 1.5 * t0 ; cy = coind+2*t0; cz = tilezb + .9;
  coinv = round(coind * coind * coinz * n); 
  roundedBox([cx+t2, cy+t0, cz], 1);
  // show the coins:
  astack(10, [0, 0, coinz])
  astack(4, [coind, 0, 0])
  trr([f1 + t0+coind/2, f1 + t0+coind/2, t0]) color("silver") cylinder(h = coinz, d = coind);
  echo("coinTray: cx, cy, cz", [cx, cy, cz], cx * cy * cz/1000, coinv/1000);
}
module woodTray(n = 40) {
  // wood: 6.6 x 14.6 x 7.4
  woodv = round( 6.6 * 14.6 * 7.4 * n);
  wx = cardTrayw-4*t0-2*f; wy = w0; wz = tilezb - cardz;
  color("#611951f5")
  trr([t0+f1, t0+t2, 0 + cardz])
  box([wx+t2, wy+t2, wz+t0]);
  echo("woodTray: wx, wy, wz", [wx, wy, wz], wx * wy * wz/1000, woodv/1000);
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
  divw = 25; // wide for workerd, combatd, templed
  fdx = (cardTrayw + ty) + divw/2 + f1;
  fdy = ty + f;
  divx = fdx + divw/2;
  div([ntz0, nty -30, divx], 0, 0);
  trr([18, nty-30, 0]) div([ntz0, 30, divx], 0, 0);
  trr([divx, 0, 0]) divXZ([ntz0, 18 + t0, nty-30], 0, 0);

  fy0 = fdy + f1;
  if (fill) trr([fdx, fy0, t0]) temples();
  fy1 = fy0 + nTemple * tilez;
  if (fill) trr([fdx, fy1, t0]) statDisks();
  wdy = 10.2; 
  wdz = 9.6;
  fy2 = fy1 + 10 * combatt + f1;
  if (fill) astack(2, [0, wdy + f1, 0])
    trr([fdx - workerd/2, fy2, t0])
    color("orange") cube([workerd, wdy, wdz]);
  ccc = 8;
  fy3 = fy2 + 2 * wdy;
  if (fill) astack(2, [0, 0, ccc + f1])
  astack(2, [0, ccc + f1, 0])
  astack(3, [ccc + f1, 0, 0]) trr([fdx-1.5*ccc, fy3, t0]) cube([ccc, ccc, ccc]);
}

// temple risers?, coin tray, wood tray, 
// worker/damage/stat tray, "special action" (temple) cards
// 9 & 1/2 ship-upgrade tile holders
module neutralTray() {
  difference() {
    roundedBox([ntx, nty, ntz], 1, [t0, ty, t0]);
    neutralLid(lidf);
  }
  shipcc = [shipx0 + shipdx3/2, shipy0 + shipdy3/2, 0]; // horiz
  // trr(shipcc) cylinder(20, 1);
  trr([t0, 0, t0, [0, 0, 0, shipcc]]) shipBox();
  trr([t0, 0, t0]) fortBox(3, 1);

  miscBox(loc == 0 || loc == 3);

  cardTray();
  
  atrans(loc, [-1, [0,0,0], -1, -1, -1, 1]) neutralLid();

}
module playerBoards() {
  color("#af49006a") cube([pdw, pdh, pdz]); // '#af4900'
}

atrans(loc, [[0, nty+f1, 0], [0, 0, 0]]) playerBox();

// neutral tray:
atrans(loc, [[0, 0, 0], -1, -1, 0]) neutralTray();
// atrans(loc, [[0, 0, 0], -1, -1, 0]) neutralLid();

// combat boards:
atrans(loc, [[boxy/2, (nty-cbh)/2, ntzl], -1, -1, -1, -1, [boxy/2, (nty-cbh)/2, ntzl]]) combatBoard();

// playerBoards:
atrans(loc, [[0, 0, 0]]) trr([ pdo, 0, boxz-pdz]) playerBoards();

// outer box:
module outerBox(tb = .2) {
   trr([-tb-p, -tb-p, -tb-p]) color("#5756564a")
   box([boxy + 2*tb, boxy + 2*tb, boxz + tb], tb);
}
atrans(loc, [[0, 0, 0]]) outerBox(.02);

// 2: partsSection
atrans(loc, [-1, -1, [0, 0, 0]]) astack(3, [0, 45, 0]) partsSection();

// 4: test print the fort/ship boxes:
atrans(loc, [-1, -1, -1, -1, [0,0,0]]) {
  trr([-1, -87, 0]) fortBox(1, 0);
  trr([23, -61, 0]) fortBox(0, 1);
  trr([-66, 1, 0]) shipBox(1);
}
// 5: print 8 fort & ship
atrans(loc, [-1, -1, -1, -1, -1, [0,0,0]]) {
  trr([0, -25, 0]) fortBox(8, 0, .4);
  trr([-shipx0, 0, 0]) shipBox(4, 2, .4);
}

// 6: 4 cardSection
atrans(loc, [-1, -1, -1, -1, -1, -1, [0,0,0]]) cardSection(2, 2, .5);
// a meeple
// trr([5, 5, 1.1* t0 +  nTempleCards * t01]) cube([8, 22, 10, ]);

// 0: all - assembled
// 1: playerBox
// 2: single partsSection
// 3: neutralTray
// 4: test print fort/ship boxes
// 5: print 8 ship/fort boxes

loc = 3; 
