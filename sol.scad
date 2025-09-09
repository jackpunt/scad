// sol
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1.6;           // wall thickness of box
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
pb0 = t0 + 2;        // thickness of bottom of parts boxes, for inset

tf = t0/2;           // slack between part boxes

sample = false;

// box size and placement constraint (3x4 grid in square box)
wmax = 250;    // box
hmax =  74;    // box
docz =  16;    // height of docs & map

w00 = sample ? 30 : 88;  // official card size [long dimension]
h00 = sample ? 23 : 63;  // official card size [short dimension]

t00 = .4;  // card thickness: sleeves bring thickness to ~.625 per card. (from min .4mm)
t01 = 6.25/12; // = .52mm; thickness when stacking sleeved cards (compressed)

// euroPoker size (with sleeves):
// width of card with sleeves
w0 = w00+2.5;  // 
// height of card with sleeves
h0 = h00+3.0;


// card box: outer size = (w00 + 5mm + 2 * t0) X 250 (full width of box) tilt the divs so only 64mm high
cbf = 2.5;                // slack on side of cards
cbz = hmax - docz;        // height
cbw = w0 + cbf + 2 * t0;  // outer width of long box [93 + 2*t0 = ~95.4]
cbl = wmax  - tf;        // outer length
tilt = asin((2 * cbz - pb0) / (cbw)); // ~ 57 degrees: asin(56/66)
//
// parts box: 250/4 X (250 - cbw)
pbw = wmax/4 - tf;
pbl = wmax - cbw - tf;   // 
pbz = (cbz + pb0) / 2;    // pb0 overlap
//
hcz =   6;        // hold-cards stack z 
hcy = 100;
hcx = 174;

// marker tray
mtz = cbz - pbz;
mtl = wmax - pbw - 2* tf;         // 3 of 4 widths; pbx*3
mtw = pbl - hcy - tf;    // hcy hold-card length (y-axis)

// energy trays
etz = cbz - pbz - hcz;  
etl = mtl / 2 - tf;       // x-axis
etw = pbl - mtw - tf; // y-axiz
echo("[etl, etw, etz]", [etl, etw, etz], pbl, mtw);

// diva: y-angle of divs
// divx: offsets to each div
module cardBox(diva, divx = [0, 10, 20], t0 = t0) {
  ndiv = len(divx);
  box([cbl, cbw, cbz], t0);
  // for (i = [0 : ndiv-1]) {
  //   trr([divx[i], 0, 0, [0, diva, 0]])
  //   cube([mtz, mtw, t0]);
  // }
}
module partsBox(t0 = t0) {
  box([pbw, pbl, pbz], t0);
}

module markerTray(t0 = t0) {
  box([mtl, mtw, mtz], t0);
}

module energyTray(t0 = t0) {
  box([etl, etw, etz], t0);
}

loc = 0;
echo("cards");
atrans(loc, [[tf/2, tf/2, 0], 0]) { trr([0, 0, 0]) cardBox(tilt); }
echo("parts");
atrans(loc, [[tf/2, cbw + tf, 0], 0]) { 
  for (i = [0 : 3]) 
  trr([i * (pbw+tf), 0, 0]) partsBox(); 
  trr([3 * (pbw+tf), 0, pbz-pb0]) partsBox();
  }
echo("markerTray");
atrans(loc, [[tf/2, cbw + tf, pbz+.1], 0]) { markerTray(); }
echo("energyTray");
atrans(loc, [[tf/2, cbw + tf + mtw + tf, pbz+.1], 0]) { 
  for (i = [0 : 1]) trr([i * (etl+ tf), 0, 0]) color("grey") energyTray(); 
}
