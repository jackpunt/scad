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

nd2 = 16 + 10 + 6;// 10+6;   // number in deck2: white, black/grey
ndeck = 48;//64 + nd2;
ntc = ndeck * tc; // width of cards in miniBox

bx = mcardw + 2 + 2*t0; // mcardw + slack
dz = 2;                  // extend boxes above cards
bz = 1.75*inch + t0 + dz;// extend boxes above cards
by = 21;                // total-y of playerBox
byc = 10 * tc + t0;      // thin section for cards (.4; >> .33) 4+1 = 5mm
bym = by -byc;           // taller than the meeples (8x12x12 ~1152 mm3) * 8 = 9200
byt = by -t0 + f;       // total width + fudge in multiPlayer
boxw = 2*t0 + (cardw + ecx) + (t0 + ntc + t0) + 2*t0; // exterior size of main box
boxy = t0 + (thf+ t0 + bx) + t0;
boxz = bz;


echo("bx * bym * bz = ", bx * bym * bz, bx/12, bym, bz, "by=", by, "bym=", bym); // 53000 > 8000
echo("boxw, boxy", boxw, boxy);
module playerBox(cx = 1) {
  trr([by, 0, 0, [0, 0, 90]]) {
  color("#e0e0e0d9")
  slotifyY2([bz-dz, .6*bx, 2*t0, 4], [bx*.5, byc + .2*t0, bz*.7], undef, 3, false)
  slotifyY2([bz- 0, .5*bx, 2*t0, 4], [bx*.5,      1.2*t0, bz*.5], undef, 3, false) {
    trr([0,  t0, 0]) box([bx, by- t0, bz- 0]);     // cardsBox (& meepleBox)
    trr([0, byc, 0]) box([bx, by-byc, bz-dz]);     // meepleBox
  }
  if (cx > 0) {
    trr([cx, 4*t0, t0, [90, 0, 0]]) mcard();
  }
  }
}
module multiPlayer(n = 6) {
  astack(n, [byt, 0, 0], tr0)
  // astack(3, [0, byt, 0], tr0) 
  playerBox();
}

module miniDeck(n = ndeck) {
  astack(n, [0, 0, tc], tr0) mcard();
}

module miniBox(n = ndeck, mbh = thf, cy = 0) {
  mbx = t0 + (n * tc) + t0;
  mbh = def(mbh, bx);
  mbz = bz - 0;
  trr([0, 0, 0]) {
    slotifyX2([mbz, mbh * .5, 2*t0, 4], [0 + t0/2, mbh/2, mbz/2], undef, 4, false)
    slotifyX2([mbz, mbh * .5, 2*t0, 4], [mbx-t0/2, mbh/2, mbz/2], undef, 4, false)
    box([mbx, mbh, mbz]);
    if (cy > 0) {
      trr([t0, cy, t0, [90, 0, 90]]) miniDeck(n);
    }
  }
} 

trackx = t0  + ecx;
module cardStack(n = 24 + 6) {
  trr([ecx, 0, 0]) astack(n, [0, 0, tc]) card();
}

trr([0, thf+t0, 0]) multiPlayer();

trr([trackx, f+side, 0]) trackStack();
trr([trackx-ecx, f+side, tsz-ecz]) cardStack();

trr([f+t0+cardw+ecx, f, 0]) miniBox(ndeck, thf, t0);

trr([6 * byt + f, thf+t0, 0]) miniBox(nd2, undef, 2);
trr([-t0, -t0, -t0]) color("red") box([boxw, boxy, boxz/3]);
