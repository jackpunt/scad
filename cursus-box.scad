use <mylib.scad>;
include <cursus-track.scad>;

// 6 small boxes for cards & meeps
// large box for 6-track folded, deck of 64 + 12, plus the small boxes

// dpi = 300; dpm = 11.811;
// mini-cards: 525 x 750 px 
mcardw = 63.5;  //  750 / dpm;
mcardh = 44.5;  //  525 / dpm;
echo ("mcardw = ", mcardw, "mcardh =", mcardh);
// tc0 = 0.33;         // thicknes of card, tc1 = tc0 + .02 (stack-z)
// rc = 3.0;           // radius of card corner 35.433 px

module meeple() {
  color("orange") cylinder(8, 6, 6);
}

module mcard(w = mcardw, h = mcardh, tc = tc0, rc = rc) {
  trr([0, 0, pp]) color("lightblue") roundedCube([w, h, tc], rc, true); // QQQ: what is actual radius?
}

// 80 Cards
nd2 = 10;           // cards in playerBox: 4-bidValue, 6-bidCol
ndeck = 48;         // half the 80 cards

bx = mcardw + 2 + 2*t0; // mcardw + slack
dz = 2;                  // extend boxes above cards
bz = 1.75*inch + t0 + dz;// extend boxes above cards
byc = t0 + nd2 * tc1 + t0;  // thin section for cards (.4; >> .33) 4+1 = 5mm
bym = 13.5;                 // taller than the meeples
by = bym + byc;        // total-y of playerBox; meeples (8x12x12 ~1152 mm3) * 8 = 9200
byt = by + f;           // total width + fudge in multiPlayer
boxw = 2*t0 + (cardw + ecx) + 2*t0; // exterior size of main box
boxy = t0 + (thf+ t0 + bx) + t0;
boxz = bz;


echo("bx * bym * bz = ", bx * bym * bz, bx/12, bym, bz, "by=", by, "bym=", bym); // 53000 > 8000
echo("boxw, boxy", boxw, boxy);
module playerBox(cx = 1) {
  trr([by, 0, 0, [0, 0, 90]]) {
  color("#e0e0e0d9")
  slotifyY2([bz-dz, .6*bx, 2*t0, 4], [bx*.5, byc + .2*t0, bz*.7], undef, 3, false)
  slotifyY2([bz- 0, .5*bx, 2*t0, 4], [bx*.5,      1.2*t0, bz*.5], undef, 3, false) {
    trr([0,  t0, 0]) box([bx, by,     bz- 0]);     // cardsBox (& meepleBox)
    trr([0, byc, 0]) box([bx, bym+t0, bz-dz]);     // meepleBox
  }
  if (cx > 0) {
    trr([cx, byc, t0, [90, 0, 0]]) astack(nd2, [0, 0, tc1]) mcard();
  }
  }
  trr([(bym-t0)/2, cardw/2, 2]) meeple();
}
module multiPlayer(n = 6) {
  astack(n, [byt, 0, 0])
  playerBox();
}

module miniDeck(n = ndeck) {
  astack(n, [0, 0, tc1]) mcard();
}

module miniBox(n = ndeck, mbh = thf, cy = 0) {
  mbx = t0 + (n * tc1) + t0;
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

mboxz = ndeck*tc1+2*t0; // miniBox-z when rotated to lay flat
trackx = t0 + ecx;      // x-offset to trackStack
module cardStack(n = 24 + 6) {
  trr([ecx, 0, 0]) astack(n, [0, 0, tc1]) card(cardw, cardh, tc0);
}

trr([t0, thf+t0, 0]) multiPlayer();

trr([trackx-ecx, f+side, tsz-ecz+mboxz-ecz -tc]) cardStack();
trr([trackx,     f+side,       f+mboxz-ecz]) trackStack();
astack(2, [bz+f, 0, 0])
trr([2*t0+cardw/18, side/2, mboxz, [0, 90, 0]]) miniBox(ndeck, undef, 2);

trr([-t0, -t0, -t0]) color("red") box([boxw, boxy, boxz/4]);

