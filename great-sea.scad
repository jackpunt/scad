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
t2 = 2*t0;

sample = false;  // true to print mini-box

mapz = 11.5;   // map thickness reduces availablbe box depth

// box size and placement constraint (3x4 grid in square box)
boxy = 220;    // internal XY-dim of cardboard box (components must fit within)
boxz = 65 - mapz;    // internal height of cardboard box (components must fit within)

w00 = sample ? 27 : 54;  // official card size [short dimension]
h00 = sample ? 42 : 86;  // official card size [long dimension]

t00 = 8/24;    // = .333mm card thickness: sleeves 60 mics = .06 mm ==> .393 == .4 with sleeves?
t01 = .400;    // = .33 + .6 mm; thickness when stacking sleeved cards (compressed) TBD when sleeve arrive.

// euroPoker size (with sleeves):
// width of card with sleeves
w0 = w00+2.5;
// height of card with sleeves
h0 = h00+3.0;
npc = 30;    // number of player cards
pbt = npc * t01 + 2 * t0; // player box thick?

pdw = 216;   // playerBoard
pdh = 133;
pdz = 21;
pdo = 2;

csw = h0 + t2;  // cardSection
csh = w0 + t2;
psz = 30;       // 3 cm depth

module playerBox() {
  // hold 3 * (8 combat) + 6 * (1 Action)
  module cardSection(npc = npc) {
    box([csw, csh, pbt]);
  }
  module partsSection() {
    box([csw, csh, psz], [t0, t0, -1], [2, 2, 1.1]);
  }
  cardSection();
  partsSection();
}
astack(2, [csw, 0, 0])
astack(2, [0, csh, 0])
trr([pdo, pdo, pdz]) playerBox();

// outer box:
module outerBox(tb = .2) {
   trr([-tb, -tb, -tb]) box([boxy + 2*tb, boxy + 2*tb, boxz + tb], tb);
}
% outerBox(.02);

// playerboards
trr([ pdo, 0, 0]) color("#af4900") cube([pdw, pdh, pdz]); // '#af4900'


trr([-30, 0, 0]) box([20, 20, 5], [1, 1, -1], [2, 2, 1.1]);
