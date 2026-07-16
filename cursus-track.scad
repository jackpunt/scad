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

tc = .4;            // thicknes of card
rc = 3;             // radius of card corner

tf = 2.5;           // thicknes of frame
side = .25*inch;    // side rails

// frame to hold the [long | poker] track cards for Cursus Honorum
// with side-rails to attach strips with slot numbers.
// cube, cut-out card, cut-out tape strip & hinge space, add end-cap
// QQQ: to recess the slot numbers? (just on the end...?)

dpi = 300; dpm = 11.811;
// cardw = 1050; cardh = 750  // Poker
cardw = 1179/dpm; cardh = 732/dpm;   // Long (100 x 62)mm

module card(w = cardw, h = cardh, rc = rc) {
  color("lightblue") roundedCube([w, h, tc], rc, true); // QQQ: what is actual radius?
}
module card2(w = cardw, h = cardh, rc = rc) {
  sw = w/9;
  module slot(sw=sw, h = h/2) {
    cube([sw, h, tc], true);
  }
  intersection() {
    card();
    trr([0, h/2, 0])
    union() {
      trr([sw/4, 0, 0]) color("black") slot(sw/2, h);
      trr([sw, h/4, 0]) astack(8, [sw, 0, 0], tr0,  ["red", "yellow", "blue", "violet"]) slot();
      trr([sw, -h/4, 0]) astack(8, [sw, 0, 0], tr0,  ["violet", "blue", "yellow", "red"]) slot();
      trr([sw*8.75, 0, 0]) color("black") slot(sw/2, h);
    }
  }
}

module tape(w, h, t = .25) {
  trr([-w/2, -h/2, 0]) cube([w, h, t], false);
}

module track(w = cardw, h = cardh) {
  tw = 1*inch; th = 2.25*inch; // cutout for tape: width, height
  tt = .25; // thickness of tape, approx?
  cx = 5;   // cutout x-dim
  difference() 
  {
    trr([0, -side, 0]) cube([w, h + 2 * side, tf]);
    trr([0, 0, tf-tc+p]) card();
    trr([tw/2-p, h/2, tf-tt-tc+pp]) tape(tw, th, tt);
    trr([w-tw/2-p, h/2, tf-tt-tc+pp]) tape(tw, th, tt);
    // can not cut from bottom of frame!
    // trr([tw/2-p, h/2, -p]) tape(tw, th, tt);
    // trr([w-tw/2-p, h/2, -p]) tape(tw, th, tt);

    trr([+cx/2-p, h/2, -p]) tape(cx, th, tf+pp);
    trr([w-cx/2+p, h/2, -p]) tape(cx, th, tf+pp);
  }
}

// loc 0: with card, 1: for print
loc = 0;
track();
atrans(loc, [[0, 0, tf-tc]]) card2();
atrans(loc, [[7, 3, tf]]) astack(3, [0, 9, 0], tr0, ["green", "pink", "grey"]) cube([8,8,8]);
