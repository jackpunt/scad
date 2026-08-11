use <mylib.scad>;

is2D = true;
p = is2D ? .001 : .001;
pp = 2 * p;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
inch = 25.4;        // mm per inch
tr0 = [0, 0, 0];    // CONST


// frame to hold the [long | poker] track cards for Cursus Honorum
// with side-rails to attach strips with slot numbers.
// cube, cut-out card, cut-out tape strip & hinge space, add end-cap
// QQQ: to recess the slot numbers? (just on the end...?)

dpi = 300; dpm = 11.811;
// long = false;
// cardw = (long ? 1179 : 1050) / dpm; 
// cardh = (long ?  732 :  750) / dpm;
// cardw = 1050/dpm; cardh = 750/dpm;  // Poker
cardw = 100.2 + 0*1179/dpm; cardh = 62.3 + 0* 732/dpm;   // Long (100 x 62)mm
cf = 4*f;           // fudge size of card for cutout
rf = -.5;            // fudge corner radius
tc0 = .33;          // thickness of card
tc1 = tc0 + .02;    // stack-z
tc = .5;            // allocated thickness to cut out for card (> actual: .33 mm)
rc = 3.0;           // radius of card corner (actual = 3mm)

tf = 2.3;           // z-thickness of frame
side = .32*inch;     // side rails (.32 -> .813 mm; .30 -> .762mm)
thf = cardh + 2 * side; // total y-height of frame [track]
echo("cardw, cardh", cardw, cardh, "+cf", cardw+cf, cardh+cf);
// "cardw, cardh", 99.8222, 61.9761, "+cf", 100.902, 63.0561 (original; cf = 6*f)
// "cardw, cardh", 100.2  , 62.3   , "+cf", 100.920, 63.02 (new; cf = 4*f)

module card(w = cardw, h = cardh, tc = tc0, rc = rc) {
  color("lightblue") roundedCube([w, h, tc], rc, true); // QQQ: what is actual radius?
}

// card with colored slots
module card2(w = cardw, h = cardh, tc = tc0, rc = rc) {
  color0 = ["red", "#fff205", "#0066CC", "#c941ff"];
  color1 = ["#c941ff", "#0066CC", "#fff205", "red"];
  wl = .5;   // width of black line down the center

  sw = w/9;
  module slot(sw=sw, h = h/2) {
    cube([sw, h, tc], true);   // a block of color, called 'slot' in ng/columns
  }
  trr([0, 0, tf-tc])
  intersection() {
    card(w, h, tc, rc);    // cut to shape of card
    trr([0, h/2, 0])
    union() {
      trr([sw/4, 0, 0]) color("black") slot(sw/2, h);
      trr([sw, +h/4, 0]) astack(8, [sw, 0, 0], tr0, color0) slot();
      trr([sw, -h/4, 0]) astack(8, [sw, 0, 0], tr0, color1) slot();
      trr([sw*8.75, 0, 0]) color("black") slot(sw/2, h);
      trr([(w-wl)/2, 0, p]) color("black") slot(wl, h);
    }
  }
}

// cutout for recessing tape:
module tape(w, h, t = .25) {
  trr([-w/2, -h/2, 0]) cube([w, h, t], false);
}

xw = -.0;   // trim width (so end-corner is truncated)
ecx = 14;   // endcap x-width: cardw + ecx (total width) = 114mm (4.5")
ecz = 2;    // endcap z-height above track
tt = .35;   // thickness of tape, approx?

// w: x-size (cardw)
// h: y-size (cardh)
// endcap: endcap x-size (0)
module track(w = cardw, h = cardh, endcap = 0) {
  tw = 1*inch; th = 2.15*inch; // cutout for tape: x-width, y-height
  cx = 2.5; // cutout x-dim for tape/hinge
  alx = 4;
  aly = 2.5;
  aey = cardh/2 - 2.44;
  ect = 1; // endcap 'rail' thickness
  ech = 2 * (side - ect);  // endcap y-height beyond card, leaving rail

  module align(ex, ey = aey, df = 0) {
   * color("blue")
    trr([ex-alx/2, ey - df/2 + (cardh - aly)/2, -p]) cube([alx, aly + df, tf - tc + 2*pp]);
  }
  differenceN(3, endcap == 0 ? 0 : 2) 
  {
    difference() {
      trr([-xw, -(thf-cardh)/2, 0]) cube([w+2*xw, thf, tf]);
      trr([w-(cx/2-p), h/2, -p]) tape(cx, th, tf+pp);     // hinge cut using 'tape' cube
      if (endcap == 0) {
      trr([0+(cx/2-p), h/2, -p]) tape(cx, th, tf+pp);     // hinge cut using 'tape' cube
      }
    }
    align(w, aey);  // add tang
    align(0, -aey); // add tang

    align(w, -aey, f); // cut slot
    trr([-cf/2, -cf/2, tf-tc+p]) card(cardw+cf, cardh+cf, tc, rc - rf);  // cutout card
    trr([w-tw/2, h/2, tf-tt-tc+pp]) tape(tw, th, tt);  // actual 'tape' cutout

    // differenceN will elide for endcap:
    align(0, aey, f); // cut slot
    trr([0+tw/2, h/2, tf-tt-tc+pp]) tape(tw, th, tt);  // actual 'tape' cutout
  }
  if (endcap > 0) {
    ecx = endcap;
    ecy = (thf-cardh)/2;
    difference() {
      trr([-ecx, -ecy, 0]) roundedCube([ecx+w/18, thf, tf+ecz], 2, true);
      trr([-ecx+ect, -ech/2, tf+p]) roundedCube([ecx+w/18, h+ech, ecz], .8, true); // roundedCube for cubes
      trr([-cf/2, -cf/2, tf-tc+pp]) card(w+cf, h+cf, tc, rc - rf); // actual card cutout
    }
  }
}

// track thickness, including bottom tape & folding fudge:
tzt = tf + tt + f;
tsz = 4 * (tzt) + 2 * (tzt + ecz); // total z-height of folded stack

// note: endcap extends to -ecx
module trackStack(dx = 0) {
  trr([dx, 0, 0, [180, 0, 0, [0, cardh/2, (ecz+tf)/2]]])  track(cardw, cardh, ecx);
  trr([dx, 0, ecz + tzt]) astack(4, [0, 0, tzt], tr0) track();
  trr([dx, 0, ecz + tzt*5 ]) track(cardw, cardh, ecx);
}

trp = [cardw + 1.0, 0, 0]; // space for print
tr2 = [cardw + 0.05, 0, 0]; // space for view
module show(loc = 0) {
  atrans(loc, [tr0, 0, 0, 0, undef]) track(cardw, cardh, loc<3 ? ecx : 0);    // single
  atrans(loc, [tr0, 0, undef, undef]) astack(loc + 1, tr2) { track(); *card2(); };
  // 4: --> four tracks for print
  atrans(loc, [undef, 0, 0, 0, tr0]) astack(2, [0, thf+2, 0]) astack(2, trp) track(); // four tracks for print
  // 1 & 2:  show some cubes:
  cs = 8;
  // atrans(loc, [[1-cs/2, .1, tf], 0]) astack(2, [-9, 0, 0], tr0) astack(4, [0, cs+.21, 0], tr0, ["green", "pink", "grey"]) cube([cs,cs,cs]);
}

// loc:
// 0: endcap w/card & cubes
// 1: double, w/cards & cubes, 
// 2: endcap-print, 
// 3: single-print
// 4: quad-print
// 5: none - as library
show(5);
