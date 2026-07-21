use <mylib.scad>;
include <cursus-track.scad>;

// 6 small boxes for cards & meeps
// large box for 6-track folded, deck of 64 + 12, plus the small boxes

// dpi = 300; dpm = 11.811;
// mini-cards: 525 x 750 px 
mcardw = 63.5;  //  750 / dpm;
mcardh = 44.5;  //  525 / dpm;
echo ("mcardw = ", mcardw, "mcardh =", mcardh);
// tc = 0.4;            // thicknes of card (> actual: .33 mm)
// rc = 3.0;           // radius of card corner 35.433 px



module mcard(w = mcardw, h = mcardh, tc = tc, rc = rc) {
  trr([0, 0, pp]) color("lightblue") roundedCube([w, h, tc], rc, true); // QQQ: what is actual radius?
}
// mcard();

nd2 = 10+6;   // number in deck2: white, black/grey
ndeck = 64 + nd2;
ntc = ndeck * tc; // width of cards in miniBox

bx0 = 2.5*inch + 4;
dz = 2;                  // extend boxes above cards
bz = 1.75*inch + t0 + dz;// extend boxes above cards
by1 = 10 * tc + t0;      // thin section for cards
by2 = 16;                // taller than the meeples (8x12x12 ~1152 mm3) * 8 = 9200
byt = by1 + by2 -t0 + .5;
boxw = t0 + t0 + cardw + t0 + t0 + ecx + t0 + ntc + t0; // exterior size of main box
boxy = thf+ 3 * (byt + t0);
boxz = bz;

bx = (boxw-4*t0)/2;       // fit playerBoxes to size of outer box
echo("bx * by2 * bz = ", bx * by2 * bz, bx/12, by2, bz); // 53000 > 8000
echo("boxw, boxy", boxw, boxy);
module playerBox(cx = 3) {
  color("#e0e0e0d9")
  slotifyY2([bz-dz, .5*bx, 2*t0, 4], [bx*.5, by1 + .2*t0, bz*.7], undef, 3, false)
  slotifyY2([bz- 0, .6*bx, 2*t0, 4], [bx*.5,      1.2*t0, bz*.5], undef, 3, false) {
    trr([0,  t0, 0]) box([bx, by2+by1-t0, bz- 0]);     // cardsBox (& meepleBox)
    trr([0, by1, 0]) box([bx, by2,        bz-dz]);     // meepleBox
  }
  if (cx > 0) {
    trr([cx, 4*t0, t0, [90, 0, 0]]) mcard();
  }
}
module multiPlayer() {
  astack(2, [bx+.5, 0, 0], tr0)
  astack(3, [0, byt, 0], tr0) 
  playerBox();
}

module miniDeck(n = ndeck) {
  astack(n, [0, 0, tc], tr0) mcard();
}

module miniBox(bz, cy = 0) {
  ntb = nd2 * tc; // for white, black/grey cards
  mbx = t0 + ntc + t0;
  mbh = thf - 2*f + t0 * .5;
  mbz = bz - t0;
  trr([t0+f, t0+f, 0]) {
    slotifyX2([mbz, mbh * .5, 2*t0, 4], [0 + t0/2, mbh/2, mbz/2], undef, 4, false)
    slotifyX2([mbz, mbh * .5, 2*t0, 4], [mbx-t0/2, mbh/2, mbz/2], undef, 4, false)
    box([mbx, mbh, mbz]);
    if (cy > 0) {
      trr([t0, cy, t0, [90, 0, 90]]) miniDeck();
    }
  }
} 

trackx = t0 + t0 + ntc + t0 + ecx;
module cardStack(n = 24 + 6) {
  trr([ecx, 0, 0]) astack(n, [0, 0, tc]) card();
}

trr([0, thf, 0]) multiPlayer();

trr([trackx, t0/2+side, 0]) trackStack();
trr([trackx-ecx, t0/2+side, tsz]) cardStack();

trr([p-t0, p-t0, 0]) miniBox(bz, t0);
trr([-t0, -t0, -t0]) color("red") box([boxw, boxy, boxz/3]);
