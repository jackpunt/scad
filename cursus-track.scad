use <mylib.scad>;

is2D = true;
p = is2D ? .001 : .001;
pp = 2 * p;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
inch = 25.4;        // mm per inch
tr0 = [0, 0, 0];    // CONST
t0 = 1;             // not in use?


// frame to hold the [long | poker] track cards for Cursus Honorum
// with side-rails to attach strips with slot numbers.
// cube, cut-out card, cut-out tape strip & hinge space, add end-cap
// QQQ: to recess the slot numbers? (just on the end...?)

dpi = 300; dpm = 11.811;
// long = false;
// cardw = (long ? 1179 : 1050) / dpm; 
// cardh = (long ?  732 :  750) / dpm;
// cardw = 1050/dpm; cardh = 750/dpm;  // Poker
cardw = 1179/dpm; cardh = 732/dpm;   // Long (100 x 62)mm
tc = .4;            // thicknes of card (> actual: .33 mm)
rc = 3;             // radius of card corner

tf = 2.5;           // thicknes of frame
side = .3*inch;     // side rails
thf = cardh + 2 * side; // total height of frame

module card(w = cardw, h = cardh, tc = tc, rc = rc) {
  color("lightblue") roundedCube([w, h, tc], rc, true); // QQQ: what is actual radius?
}

// card with colored slots
module card2(w = cardw, h = cardh, rc = rc, rc = rc) {
  color0 = ["red", "#fff205", "#0066CC", "#c941ff"];
  color1 = ["#c941ff", "#0066CC", "#fff205", "red"];

  sw = w/9;
  module slot(sw=sw, h = h/2) {
    cube([sw, h, tc], true);
  }
  trr([0, 0, tf-tc])
  intersection() {
    card();
    trr([0, h/2, 0])
    union() {
      trr([sw/4, 0, 0]) color("black") slot(sw/2, h);
      trr([sw, +h/4, 0]) astack(8, [sw, 0, 0], tr0, color0) slot();
      trr([sw, -h/4, 0]) astack(8, [sw, 0, 0], tr0, color1) slot();
      trr([sw*8.75, 0, 0]) color("black") slot(sw/2, h);
    }
  }
}

// cutout for recessing tape:
module tape(w, h, t = .25) {
  trr([-w/2, -h/2, 0]) cube([w, h, t], false);
}

module track(w = cardw, h = cardh, endcap = 0) {
  tw = 1*inch; th = 2.15*inch; // cutout for tape: width, height
  tt = .35; // thickness of tape, approx?
  xw = .4; // extra width
  cx = 5+xw;   // cutout x-dim
  differenceN(1, endcap == 0 ? 0 : 2) 
  {
    trr([-xw/2, -(thf-cardh)/2, 0]) cube([w+xw, thf, tf]);
    trr([0, 0, tf-tc+p]) card();

    trr([w-tw/2-p, h/2, tf-tt-tc+pp]) tape(tw, th, tt);  // actual 'tape' cutout
    trr([w+xw-cx/2+p, h/2, -p]) tape(cx, th, tf+pp);     // hinge cut using 'tape' cube
    // elide for endcap:
    trr([0+tw/2-p, h/2, tf-tt-tc+pp]) tape(tw, th, tt);  // actual 'tape' cutout
    trr([0-xw+cx/2-p, h/2, -p]) tape(cx, th, tf+pp);     // hinge cut using 'tape' cube
  }
  if (endcap > 0) {
    ecr = 2;
    ecy = (thf-cardh)/2;
    difference() {
    trr([-endcap, -ecy, 0]) cube([endcap+w/18, thf, tf+ecr]);
    trr([-endcap+1, 0, tf]) card(w, h, rc, tf);
    trr([0, 0, tf-tc+p]) card();
    }
  }
}


tr2 = [cardw+.1, 0, 0];
// loc 0: with card, 1: for print, 2: second track, 3: print?
loc = 0;
atrans(loc, [tr0, 0, 0, 0, 0]) track();
atrans(loc, [tr0, 0, 0, 0, 0]) track(cardw, cardh, 8);
atrans(loc, [undef, 0, tr2, tr2]) track();
atrans(loc, [undef, 0, 0, 0, tr0]) astack(2, [0, thf+2, 0]) astack(2, [cardw+1, 0, 0]) track();
atrans(loc, [tr0, undef, 0])  card2();
atrans(loc, [tr0, undef, tr2]) card2();
cs = 8;
atrans(loc, [[cardw/9-cs/2, .1, tf], undef, 0]) astack(4, [0, cs+.21, 0], tr0, ["green", "pink", "grey"]) cube([cs,cs,cs]);
