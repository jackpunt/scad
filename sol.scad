// sol
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1.6;           // wall thickness of box
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

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
divx = w0 + 1;
opp = cbz - t0;// cbz - t0; 
hyp = divx;
tilt = asin(opp/hyp); // ~ 38 degrees
//
// parts box: 250/4 X (250 - cbw)
pbw = wmax/4 - tf;
pbl = wmax - cbw - tf;   // 
pbz = cbz / 2;           //
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
echo("[etl, etw, etz]", [etl, etw, etz], opp, hyp, tilt);

// diva: y-angle of divs
module cardBox(diva, ndiv=1, s0 = t0, t0 = t0) {
  cdz = sin(diva) * divx;
  dx = (cbl-cdz-t0/cos(diva)) / (ndiv+1);
  differenceN() { 
  union()  {
  box([cbl, cbw, cbz], t0);
  for (i = [1 : ndiv]) {
    trr([t0 + i * dx, 0, 0, [0, 90-diva, 0, [s0, 0, 0]]])
    slotify2([divx, cbw/2, 2*s0], [s0/2, cbw/2, divx*.7], undef, 4, false)
    {
      cube([s0+pp, cbw, divx-s0]);
    }
  }
  }
    trr([cbl-t0-p, t0, t0-p]) cube([max(s0, t0)+pp, cbw-2*t0, cbz+pp]);
    // trr([cbl-0-p, -p, t0-p]) cube([max(s0, t0)+pp, cbw+pp, cbz+pp]);
  }
}
module partsBox(t0 = t0, color = undef) {
  color(color)
  box([pbw, pbl, pbz], t0);
}

module markerTray(t0 = t0) {
  box([mtl, mtw, mtz], t0);
}

module energyTray(t0 = t0) {
  box([etl, etw, etz], t0);
}

z2 = pbz + .1;  // slight raise for visibility
x2 = cbl + tf;  // offset x when z == 0

// loc = 0: assembled view
// loc = 1: all at z=0;
// (if you have 250 mm plate!) 
// loc = 2: print 1 
// loc = 3: print 2
loc = 0;

echo("cardBox");
atrans(loc, [[0, 0, 0], 0, 0, undef]) { 
  trr([0, 0, 0]) cardBox(tilt, 10, 3); 
}

echo("partBox");
// optional colors:
colors = ["lightblue", "silver", "purple", "lightgreen", "grey"];
atrans(loc, [[0, cbw, 0], 0, 0, undef]) { 
  for (i = [0 : 3]) 
  trr([i * (pbw+tf), 0, 0]) partsBox(t0, colors[i]); 
}
atrans(loc, [[0, cbw, z2], [x2, cbw + tf, 0], undef, 1]) { 
   partsBox(t0, colors[4]);
}

echo("markerTray");
atrans(loc, [[tf + pbw, cbw, z2], [x2 + pbw + tf, cbw + tf, 0], undef, 1]) { markerTray(); }

echo("energyTray");
atrans(loc, [[tf + pbw, cbw + mtw + tf, z2], [x2 + pbw + tf, cbw + tf + mtw + tf, 0], undef, 1]) { 
  for (i = [0 : 1]) trr([i * (etl+ tf), 0, 0]) color("darkgrey") energyTray(); 
}
