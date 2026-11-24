use <mylib.scad>;
// Organizer for GreatSeas box and components
// nine and half ship upgrade market holders
// four player component boxes: 
// --  action(6) & combat(16+8) cards, ships/dudes (29+2), point-markers, trade posts, ship-class & fleet tiles
// temple risers?, coin tray, wood tray, worker/damage/stat tray, "special action" (temple) cards


p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
t2 = 2*t0;    // 2 walls

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
h0 = h00+3.0;
npc = 30;    // number of player cards
pbt = npc * t01 + 2 * t0; // player box thick?

pdw = 216;   // playerBoard-x-width
pdh = 133;   // playerBoard-y-height
pdz = 21;    // playerBoard-z
pdo = 2;     // player board offset (in view)

// PlayerBox:
csw = h0 + 13 + t2;  // cardSection
csh = w0 + t2;
psz = 30;       // 3 cm depth

// (w0 x h0) sleeved card size
module card(n = 1, w = w0, h = h0, cz = t00, c = "lightblue") {
  // put cards in sideways orientation:
  astack(n, [0, 0, cz]) color(c) cube([h, w, cz]);
}
module playerBox() {
  // hold 3 * (8 combat) + 6 * (1 Action)
  module cardSection(npc = npc) {
    box([csw, csh, pbt]);
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
  cardSection();
  partsSection();
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

module temple() {

}
module coinTray() {

}
module woodTray() {

}
module specialCards(n = 24) {
  card(n);
}

tilez = 1.8;  // thickness of cardboard stock (1.78)
tilez9 = 9.5 * tilez;  // stack of 9 tiles

dw = 2.1;
bz0 = 2;         // taperBox base thickness

// size of neutral box:
ntx = boxy - 2*pdo;  // x-size of box
nty = pdh;  // y-size of box (boxy - cbh - t2) ?
ntz = tilez9 + bz0 + 3 + 1;  // z-size of box
echo("nxt, nty, ntz =", [ntx, nty, ntz]);

shipw = 30.1;
shiph = 24.1;
shipz = tilez;  // cardboard stock thickness (1.78)

// rz: rotation around z-axis (while still centered around [0,0] )
module taperBox(w = shipw, h = shiph, z = tilez9, rz = 0) {
  // linearExtrude(taper) roundedRect(), cut finger slots on side and base
  dww = w + 2 * dw;
  dwh = h + 2 * dw;
  shz = z + bz0;
  cr = w/4;   // cylinder radius
  dy = dwh/2-dw/2;
  wh = (w + h)/2;
  module cut(r = cr) {
    scale([1,.5]) 
    trr([0, 0, (bz0+tilez9+pp)/2]) cylinder(h = bz0+tilez9+pp, r = r, center = true);
    trr([0, 0, bz0+(bz0+tilez9+pp)/2]) cube([2*r, dw + .1 +8*p, tilez9+bz0+pp], true);
    trr([0, dw/2, (bz0+tilez9+pp)/2]) cube([2*r, dw + .1 +8*p, tilez9+bz0+pp], true);
  }
  // extrude & rotate while centered; then offset from [0, 0]
  trr([dww/2, dwh/2, 0, [0, 0, rz]])
  difference() {
    linear_extrude(height = shz, scale = (wh + 2 * t0) / (wh + 2 * dw))
    trr([-dww/2, -dwh/2, 0]) roundedRect([dww, dwh], 1);
    trr([-w/2,   -h/2, bz0]) roundedCube([w, h, shz], .2, true); // tile
    trr([0, -dy, -p]) cut(cr);      // base slot & finger cut
    trr([0, +dy, -p]) cut(cr);      // base slot & finger cut
  }
}
module shipBox() {
  module aBox() {
   color("blue") 
   trr([0, 0, 0 ]) 
   taperBox(shipw, shiph, tilez9);
  }
  dx = shipw + 2 * dw + .05;
  dy = shiph + 2 * dw + .05;
  astack(3, [0, dy, 0])
  astack(3, [dx, 0, 0]) 
  trr([t0+.1, t0+.1, pp]) 
  aBox();
}

fortw = 36.1;
forth = 18.1;
fortox = t0 + 3 * (shipw + 2 * dw);
module fortBox() {
  module aBox() {
    color("red") taperBox(fortw, forth);
  }
  dx = fortw + 2 * dw + .1;
  dy = forth + 2 * dw + .1;
  astack(4, [dx, 0, 0])
  astack(2, [0, dy, 0])
  trr([fortox + .1, t0 + .1, pp])
  aBox();

}

coind = 24;
coinz = 1.8;  // stack of 30 <= 54mm
trayz = coind + t2;
trayw = ntx - 6 * (shiph+2*dw);
trayh = nty - t0;

module coin () { cylinder(h = coinz, r = coind/2); }
module coinTray(n = 33) {
 box([coind+1 + t2, n * coinz + t2, trayz]);
}
module woodTray() {
  box([trayw, trayh, trayz]);
}

module cardTray() {
  trr([t0, t0, tilez9 + t2]) box([h0+1, w0+1, 28 * t01]);

}

module neutralLid(f = 0) {
  color("lightblue")
  trr([0-p, t0, ntz - 2* t0]) cube([ntx-t0+f, nty-t2+f, t0+f]);
  trr([0-p,   -p, ntz - 2* t0]) cube([3*t0+pp, nty+pp, t2+f]);
  trr([ntx-3*t0-p,   -p, ntz - 2* t0]) cube([3*t0+pp, nty+pp, t2+f]);

}

// temple risers?, coin tray, wood tray, 
// worker/damage/stat tray, "special action" (temple) cards
// 9 & 1/2 ship-upgrade tile holders
module neutralTray() {
  difference() {
  roundedBox([ntx, nty, ntz], 1, [t0, t2, t0]);
  neutralLid(.2);
  }
  *cardTray();

  * atrans(loc, [[ntx-30, t0, trayz + t0]])
  coinTray(40);

  * atrans(loc, [[ntx-trayw, 0, t0]])
  woodTray();

  trr([t0, t0, t0]) shipBox();
  trr([t0, t0, t0]) fortBox();
}

// 0: all - assembled
// 1: single box
loc = 0; 

*if (loc == 0) astack(2, [csw+.2, 0, 0])
if (loc == 0) astack(2, [0, csh+.2, 0])
atrans(loc, [[pdo, 1, pdz], [0, 0, 0]]) playerBox();

// outer box:
module outerBox(tb = .2) {
   trr([-tb, -tb, -tb]) box([boxy + 2*tb, boxy + 2*tb, boxz + tb], tb);
}
* atrans(loc, [[0, 0, 0]]) outerBox(.02);

// playerboards
atrans(loc, [[0, 0, 0]]) trr([ pdo, 0, 0]) color("#af4900") cube([pdw, pdh, pdz]); // '#af4900'

// neutral tray:
atrans(loc, [[0, 0, 0]]) trr([pdo, 0, pdz]) neutralTray();
*atrans(loc, [[0, 0, 0]]) trr([pdo, 0, pdz]) neutralLid();

// combat boards:
*atrans(loc, [[0, 0, 0]]) trr([boxy/2, t0, boxz-cbz-p]) combatBoard();
