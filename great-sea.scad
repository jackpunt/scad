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
cbz = 8;

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
npc = 30;    // number of player cards
t1c = t0 * 1;//.7;
pbt = npc * t01 + 1 * t0; // player box thick?

combatt = 5;    // thickness of combat status disks
combatd = 18;   // diameter of combat status disks (10 of them)
damaged = 8;    // x, y, z dimension of orange cube. (12 of them)
templed = 19;   // diameter of Temple disks

nTemple = 6;
nTempleCards = 24;        // number of 'special' action cards (4 x nTemples)
cardz = t01 * (nTempleCards + 4);

pdw = 216;   // playerBoard-x-width
pdh = 133;   // playerBoard-y-height
pdz = 21;    // playerBoard-z
pdo = 2;     // player board offset (in view)

// PlayerBox:
csw = h0 + 13 + t2;  // cardSection
csh = w0 + t2;
psz = 30;       // 3 cm depth

// (w0 x h0) sleeved card size
module card(n = 1, w = w0, h = h0, cz = t01, c = "lightblue") {
  // put cards in sideways orientation:
  astack(n, [0, 0, cz]) color(c) cube([w, h, cz*.9]);
}

module specialCards(n = nTempleCards) {
  card(n, h0, w0);
}

module playerBox() {
  // hold 3 * (8 combat) + 6 * (1 Action) = 30 cards
  module cardSection(npc = npc) {
    csd2 = 2 * pbt + t1c; ss = false;
    trr([0, 0, csd2, [-90, 0, 0]]) {
      slotifyY2([csh, 60, 3 * t0, 8], [csw/2, csd2/2, 40], undef, 3, ss)
      divXZ([csh, csw, csd2/2], 0, 0, t1c);
      slotifyY2([csh, 60, 3 * t0, 8], [csw/2, 0, 40], undef, 3, ss)
      slotifyY2([csh, 60, 3 * t0, 8], [csw/2, csd2, 40], undef, 3, ss)
      box([csw, csd2, csh]);
    }
  }
  module partsSection() {
    box([csw, csh, psz], [t0, t0, -1], [2, 2, 1.1]);
  }
  module pboxLid() {
    inz = 3 + t0;
    cube([csw, csh, t0]);
    trr([t0, t0, t0-inz])
    box([csw-t2, csh-t2, inz], [t0, t0, -1], [2, 2, 1.1]);
  }
  // astack(2, [0, 0, pbt-t0])
  cardSection();
 * partsSection();
}

module combatBoard() {
  cbws = 68.0;     // central "tab" height (wide part < cbh = 100)
  cbhi = 87.8;     // width of narrow part (less than cbw = 140)
  c = "#d4ebfe1c";// '#7fccf610'
  trr([0, cbh/2, cbz/2]) 
  {
    color(c) 
    roundedCube([cbw, cbhi, cbz], 3, true, true);
    color(c) 
    roundedCube([cbws, cbh, cbz-p], 3, true, true);
  }
}

tilez = 1.8;  // thickness of cardboard stock (1.78)
tilez9 = 9.5 * tilez;  // stack of 9 tiles

dw = 2.1;
bz0 = 2;         // taperBox base thickness

// size of neutral box:
ntx = boxy ;  // x-size of box
nty = pdh;  // y-size of box (boxy - cbh - t2) ?
ntz = tilez9 + bz0 + 3 + 1;  // z-size of box (incl: lid & overhang) 
echo("nxt, nty, ntz =", [ntx, nty, ntz], "tilez9 + bz0 =", tilez9+bz0);

// rz: rotation around z-axis (while still centered around [0,0] )
module taperBox(w = 30, h = 24, z = tilez9, rz = 0) {
  // linearExtrude(taper) roundedRect(), cut finger slots on side and base
  dww = w + 2 * dw;
  dwh = h + 2 * dw;
  shz = z + bz0;
  cr = w/4;   // cylinder radius
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
    trr([-w/2,   -h/2, bz0]) roundedCube([w, h, shz], .2, true); // tile
    cut(cr, -1);      // base slot & finger cut
    cut(cr, +1);      // base slot & finger cut
  }
}

shipw = 30.1;
shiph = 24.1;
shipdx = shipw + 2 * dw + .05;
shipdy = shiph + 2 * dw + .05;
shipx0 = ntx - dw - 3 * shipdx; 

module shipBox() {
  module aBox() {
    dwh = shiph + 2 * dw;
    color("blue") 
    trr([0, 0, 0, [0, 0, 0, [dwh/2, dwh/2, 0]]])
    taperBox(shipw, shiph, tilez9);
  }
  astack(3, [0, shipdy, 0])
  astack(3, [shipdx, 0, 0]) 
  trr([shipx0, 0, pp]) 
  aBox();
}

cardTrayw = h0 + 5 * t0;  // 2 endcaps + gaps? balance with h0 sleeve size
cardTrayh = w0 + 4 * t0;

fortw = 36.1;
forth = 18.1;
fortdx = fortw + 2 * dw + .1;
fortdy = forth + 2 * dw + .1;
fortx0 = t0;// + 3 * (shipw + 2 * dw);
forty0 = nty - ty - fortw - 2 * dw;
module fortBox() {
  module aBox(fortw = fortw) {
    dwh = forth + 2 * dw;
    trr([0, 0, 0, [0, 0, 90, [dwh/2, dwh/2, 0]]])
    color("red") taperBox(fortw, forth);
  }
  astack(9, [fortdy, 0, 0])
  // astack(2, [0, dy, 0])
  trr([fortx0 + f1, forty0 - f1, pp])
  aBox();
  // one half-size fort:
  trr([shipx0 - forth - 2 * dw - f1, 0, t0+pp])
  aBox(fortw/2);
}

module cardTray() {
  cx = cardTrayw; cy = cardTrayh; cz = tilez9;
  color("#5505f585")
  trr([0-p, ty-t0, 0-p]) 
  slotifyY2( [cz, 60, 3 * t0, 2], [cx/2, cy, 0], undef, 2, false )
  box([cx, cy, cz]);
}

coind = 23.2;
coinz = 1.8;  // stack of 30 <= 54mm

module coin () { cylinder(h = coinz, r = coind/2); }
module coinTray(n = 40) {
  cx = 4 * coind + 1.5 * t0 ; cy = coind+2*t0; cz = tilez9 + bz0 + .9;
  coinv = round(coind * coind * coinz * n); 
  box([cx+t2, cy+t0, cz]);
  // show the coins:
  astack(10, [0, 0, coinz])
  astack(4, [coind, 0, 0])
  trr([f1 + t0+coind/2, f1 + t0+coind/2, t0]) color("silver") cylinder(h = coinz, d = coind);
  echo("coinTray: cx, cy, cz", [cx, cy, cz], cx * cy * cz/1000, coinv/1000);
}
module woodTray(n = 40) {
  // wood: 6.6 x 14.6 x 7.4
  woodv = round( 6.6 * 14.6 * 7.4 * n);
  wx = cardTrayw-4*t0-2*f; wy = w0; wz = tilez9 + bz0 - cardz;
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
module neutralLid(f = 0) {
  color("#3e9eff3e") 
  trr([0-p, t0, ntz - 2* t0]) 
  difference() {
  cube([ntx-t0+f, nty-t2+f, t0+f]);
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
    neutralLid(.2);
  }

  trr([t0 + t0, ty + t0, t0]) specialCards();  // align with cardTray()

  trr([shipx0 - combatd/2 + 1.2, 10 + fortw/2 + 2*dw + 2*t0, t0])
    statDisks();

  trr([shipx0 - templed/2 + 1.2, fortw/2 + 4.4, t0])
    temples();

  atrans(loc, [[t0+f, cardTrayh +ty -t0 + f1, t0]])
    coinTray(40);

  atrans(loc, [[0, 0, t0]])
    woodTray();

  cardTray();

  trr([t0, ty+f1, t0]) shipBox();
  trr([t0, 0, t0]) fortBox();
  
  atrans(loc, [-1, [0,0,0]]) neutralLid();

}
module playerBoards() {
 * color("#af4900") cube([pdw, pdh, pdz]); // '#af4900'
}

// 0: all - assembled
// 1: single box
loc = 0; 

// if (loc == 0) astack(2, [csw+.2, 0, 0])
// if (loc == 0) astack(2, [0, csh+.2, 0])
atrans(loc, [[0, nty+t0, 0], [0, 0, 0]]) playerBox();
echo("boxy-nty=", boxy-nty, "h0=", h0);

// playerBoards:
atrans(loc, [[0, 0, 0]]) trr([ pdo, 0, ntz]) playerBoards();

// neutral tray:
atrans(loc, [[0, 0, 0]]) trr([0, 0, 0]) neutralTray();
*atrans(loc, [[0, 0, 0]]) trr([0, 0, 0]) neutralLid();

// combat boards:
*atrans(loc, [[0, 0, 0]]) trr([boxy/2, t0, boxz-cbz-p]) combatBoard();
// outer box:
module outerBox(tb = .2) {
   trr([-tb-p, -tb-p, -tb-p]) color("#5756564a")
   box([boxy + 2*tb, boxy + 2*tb, boxz + tb], tb);
}
atrans(loc, [[0, 0, 0]]) outerBox(.02);
