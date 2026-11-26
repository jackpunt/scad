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
t01 = .400;    // = .33 + .6 mm; thickness when stacking sleeved cards (compressed) TBD when sleeve arrive.

// width of card with sleeves
w0 = w00+2.5;
// height of card with sleeves
h0 = h00+1.5;

pdw = 216;   // playerBoard-x-width
pdh = 133;   // playerBoard-y-height
pdz = 21;    // playerBoard-z
pdo = 2;     // player board offset (in view)

dw = 2.0;        // fort/ship external wedge size
bz0 = 1.5;       // taperBox base thickness

tilez = 2;       // thickness of cardboard stock (1.78)
tilez9 = tilez * 9.1;  // stack of 9 tiles
tilezb = tilez9 + bz0; // height of fort/ship holders
lidz = 1;        // thickness of neutralLid
lidf = 1.2;      // extend lidz for cutting slot
lidc = 1.4;      // overhang 'clip' above lid

// size of neutral box:
ntx = boxy ;  // x-size of box
nty = pdh - 3.5;  // y-size of box (boxy - cbh - t2) ?
ntz0 = tilezb + t0 + .1;
ntzl = ntz0 + lidf;         // top of 'lid'
ntz  = ntzl + lidc;  // z-size of box (incl: lid & overhang) 
echo("nxt, nty, ntz =", [ntx, nty, ntz], "tilezb =", tilezb);

// Note: left & bottom end-cap are embedded in tray wall
cardTrayw = h0 + t0 + t0 + 3;  // 2 endcaps + 3 gaps; balance with h0 sleeve size
cardTrayh = w0 + t0 + ty + 2; // abuts bottom edge: 

npc = 30;    // number of player cards
t1c = t0 * 1;//.7;
csz = t0 + (npc+5) * t01; // player box thick?

combatt = 5;    // thickness of combat status disks
combatd = 18;   // diameter of combat status disks (10 of them)
damaged = 8;    // x, y, z dimension of orange cube. (12 of them)
templed = 19;   // diameter of Temple disks

nTemple = 6;
nTempleCards = 24;        // number of 'special' action cards (4 x nTemples)
cardz = t01 * (nTempleCards + 4);

// PlayerBox:
csw = (boxy - nty - 3 * f1);// > (h0 + t2);  // cardSection
csh = w0 + t2;

// (w0 x h0) sleeved card size
module card(n = 1, w = w0, h = h0, cz = t01, c = "lightblue") {
  // put cards in sideways orientation:
  astack(n, [0, 0, cz]) color(c) cube([w, h, cz * .9]);
}

module specialCards(n = nTempleCards) {
  card(n, h0, w0);
}

// hold 3 * (8 combat) + 6 * (1 Action) = 30 cards
// if (df == 0) stack on z-axis
module cardSection(nx = 2, nz = 2, df = 0) {
  row2 = (df == 0) ? [0, 0, csz + f1] : [0, csw + f1 + df, 0];
  astack(nz, row2)
  astack(nx, [csh + f1+ df, 0, 0])
  roundedBox([csh, csw, csz], 1);
}

// given cardSection x-extent & boxy: compute 
function psxyzc(csx = 2 * (csh + f1)) = [
  (boxy - csx) / 2 - f1,
  (csw - 3.5)/2,
  boxz,
  csx
];

module partsSection() {
  ps = psxyzc(); 
  psx = ps.x;
  psy = ps.y; //(boxy - pdh - f1) / 2 - 2 * f1;
  psz = ps.z;
  csx = ps[3];
  echo("psx, psy, psz = ", [ps.x, ps.y, ps.z]);
  trr([csx + f1, pdh-nty+f1, 0]) roundedBox([psx, psy, psz], 1);
  echo("parts volume: ", [psx, psy, psz], psx * psy * psz / 1000);
}
module neutralSection() {
  dy = pdh - nty;  // 3.5
  nsx = csh;
  nsy = csw - dy;
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
  astack(2, [csx/2, 0, 0]) neutralSection();
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
module taperBox(w = 30, h = 24, z = tilez9, rz = 0) {
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
shipdx = shipw + 2 * dw + f1/2;
shipdy = shiph + 2 * dw + f1/2;
shipx0 = ntx - dw - 3 * shipdx; 

module shipBox(nx = 3, ny = 3, df = 0) {
  module aBox() {
    dwh = shiph + 2 * dw;
    color("blue") 
    // trr([0, 0, 0, [0, 0, 0, [dwh/2, dwh/2, 0]]])
    taperBox(shipw, shiph, tilez9);
  }
  astack(ny, [0, shipdy + df, 0])
  astack(nx, [shipdx + df, 0, 0]) 
  trr([shipx0, 0, pp]) 
  aBox();
}

fortw = 36.5;     // fort internal size (double fudge)
forth = 18.5;     // fort internal size (double fudge)
fortdx = fortw + 2 * dw + .1;
fortdy = forth + 2 * dw + .1;
fortx0 = t0 + f1;
forty0 = nty - ty - fortw - 2 * dw - f1;

module fortBox(lf = 9, sf = 1, df = 0) {
  module aBox(fortw = fortw, forth = forth) {
    dwh = forth + 2 * dw;
    trr([0, 0, 0, [0, 0, 90, [dwh/2, dwh/2, 0]]]) // rotate around lower-right corner
    color("red") taperBox(fortw, forth);
  }
  // row of 9 large forts:
  astack(lf, [fortdy + df, 0, 0])
  trr([fortx0, forty0, pp])
  aBox();
  // one half-size fort: (forty0 -forth-2*dw - 2*t0 - 2 * f1)
  trr([fortx0, cardTrayh + t0, -p])
  astack(sf, [0, 0, 0])
  aBox(18.8, 18.8);  // 18.4 + double fudge
}

module cardTray() {
  cx = cardTrayw; cy = cardTrayh; cz = ntz0;
  color("#5505f585")
  trr([0+p, 0-p, 0-p]) 
  slotifyY2( [cz, 38, 3 * t0, 2], [cx/2, cy, 0], undef, 2, false )
  box([cx, cy, cz]);
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
 * color("#611951f5")
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

module temples() {
  h = tilez * 1; d = templed;  // templez could go up to 3.11!
  astack(nTemple, [0, h, 0], undef, "#fefcbc9a")
    trr([0, 0, d/2, [-90, 0, 0]]) cylinder(h = h*.9, d = d);
}

// cs: child size; begin grid @ (cs, cs+1)
// nc: columns
// nr: rows
module lidGrid(bw, bh, cs = 5, nc = undef, nr = undef) {
  nc = def(nc, bw/(2 * cs));
  nr = def(nr, bh/(2 * cs));
  x0 = cs;
  xi = (bw - cs) / nc;
  xm = bw - cs;
  y0 = cs + 1;
  yi = (bh - cs) / nr;
  ym = bh - cs;
  translate([0, 0, -t0])
  gridify([x0, xi, xm], [y0, yi, ym], 2) cube([cs, cs, cs]);
}

// f: enlarge for clearance when using as cut template
module neutralLid(lf = 0) {
  f = lf - lidz;
  color("#3e9eff3e") 
  trr([0-p, ty/2, ntz - lidc - lidz]) 
  difference() {
    cube([ntx-t0+f, nty-t2+f, lidz + f]);
    if (f <= 0) lidGrid(ntx-t0, nty-t2, 5);
  }
  if (f > 0) {
    trr([0-p,        -p, ntz - 2* t0 ]) cube([3*t0+pp, nty+pp, t2+f]);
    trr([ntx-3*t0-p, -p, ntz - 2* t0 ]) cube([3*t0+pp, nty+pp, t2+f]);
  }
}

// temple risers?, coin tray, wood tray, 
// worker/damage/stat tray, "special action" (temple) cards
// 9 & 1/2 ship-upgrade tile holders
module neutralTray() {
  difference() {
    roundedBox([ntx, nty, ntz], 1, [t0, ty, t0]);
    neutralLid(lidf);
  }

  trr([t0, ty+f1, t0]) shipBox();
  trr([t0, 0, t0]) fortBox();

  divz = ntzl - t0;
  divy = forty0 - t0 -f1;
  divXZ([divz, shipx0, divy - t0], 0, 0, t0);
    div([divz, divy, shipx0 - t0], 0, 0, t0);
    div([divz, divy, cardTrayw - t0 +pp], 0, 0, t0);
    // stop block on small Fort:
    trr([0, cardTrayh, 0])
    div([  6 , divy - cardTrayh - t0, 26.3], 0, 0, t0);

  trr([t0 + 2* t0, ty + t0, t0]) specialCards();  // align with cardTray()

  // between two divs:
  fdx = (cardTrayw + shipx0 - t0) / 2;
  fdy = ty + f1;
  trr([fdx, fdy + f1 + 12, t0])
    statDisks();

  trr([fdx, fdy + f1, t0])
    temples();

  *atrans(loc, [[t0+f, cardTrayh + f1, t0]])
    coinTray(40);

  atrans(loc, [[0, 0, t0]])
    woodTray();

  cardTray();
  
  atrans(loc, [-1, [0,0,0], -1, -1, -1, 5]) neutralLid();

}
module playerBoards() {
  color("#af49006a") cube([pdw, pdh, pdz]); // '#af4900'
}

// if (loc == 0) astack(2, [csw+.2, 0, 0])
// if (loc == 0) astack(2, [0, csh+.2, 0])
atrans(loc, [[0, nty+f1, 0], [0, 0, 0]]) playerBox();

// neutral tray:
atrans(loc, [[0, 0, 0], -1, -1, 0]) trr([0, 0, 0]) neutralTray();
*atrans(loc, [[0, 0, 0]]) trr([0, 0, 0]) neutralLid();

// combat boards:
atrans(loc, [[0, 0, 0]]) trr([boxy/2, t0, ntzl]) combatBoard();

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

loc = 6; 
