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
byc = t0 + nd2 * tc1 + t0;  // thin section for cards (10 * .35) 2 * 3.5 = 5.5mm
bym = t0 + 12.5;            // taller than the meeples
by = bym + 5.5;         // total-y of playerBox; meeples (8x12x12 ~1152 mm3) * 8 = 9200
byt = by + f;           // total width + fudge in multiPlayer
boxw = 2*t0 + (cardw + ecx) + 2*t0; // exterior size of main box
boxy = t0 + (thf+ t0 + bx) + t0;
boxz = bz;


echo("bx * bym * bz = ", bx * bym * bz, bx/12, bym, bz, "by=", by, "byc=", byc); // 53000 > 8000
echo("boxw, boxy", boxw, boxy);

// fortuitously, 48 cards fit in a playerBox, so we use it for the miniBox!
// nc: number of cards to fit
// cx: x-offset to show cards in stack
// meep: (false) if true show a meep cylinder in the mbox
module playerBox(nc = nd2, cx = 1, meep = false) {
  ncc = nc == 0 ? 48 : nc;   // 48 -> 18.8mm will fit in by=19mm playerBox
  byc = t0 + ncc * tc1 + t0;
  bdy = (nc > 0) ? byc : by; // offset div to full box-y
  dzd = (nc > 0) ? dz : 0;   // and div is full height-z
  echo("playerBox: nc=", nc, "cx=", cx, "byc=", byc);
  trr([by+t0, 0, 0, [0, 0, 90]]) {
  color("#e0e0e0d9")
  slotifyY2([bz-dzd, .6*bx, 2*t0, 4], [bx*.5, bdy + .2*t0, bz*.7], undef, 3, false)
  slotifyY2([bz-  0, .5*bx, 2*t0, 4], [bx*.5,      1.2*t0, bz*.5], undef, 3, false) {
    trr([0,  t0, 0]) box([bx, by, bz]);     // cardsBox (& meepleBox)
    divXZ([bz-dzd, bx, bdy]);
  }
  if (cx > 0) {
    trr([cx, byc, t0, [90, 0, 0]]) astack(ncc, [0, 0, tc1]) mcard();
  }
  }
  if (meep) trr([(by-byc)/4, cardw/2, 0, [0, 90, 0, [4, 0, 4]]]) meeple();
}
module multiPlayer(n = 6, cx = 2, meep = false) {
  astack(n, [byt, 0, 0])
  playerBox(nd2, cx, meep);
}


// miniBox(48) same size as playerBox, so we use playerBox, to be exact.
module miniBox2(n = ndeck, mbh = thf, cx = 0) {
  echo("miniBox2: n=", n, "cy=", cx);
  playerBox(0); 
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

mboxz = ndeck*tc1 + 2*t0; // miniBox-z when rotated to lay flat
trackx = t0 + ecx;        // x-offset to trackStack
cstackz = (24+6) * tc1 - ecz;
trkz = f + cstackz + (tsz - ecz);

module cardStack(n = 24 + 6) {
  trr([ecx, 0, 0]) astack(n, [0, 0, tc1]) card(cardw, cardh, tc0);
}

// loc: 0 - full stack, design mode
// 1: spread
loc = 0;
atrans(loc, [[0, 0, 0], 0]) trr([0, thf+t0, 0]) multiPlayer(6, loc==0 ? 2 : 0);

atrans(loc, [[0, 0, 0], 0]) {
  trr([bz+t0 + 3*t0+cardw/9, side/2, mboxz+trkz, [0, 90, 0]]) playerBox(16);
  trr([        3*t0+cardw/9, side/2, mboxz+trkz, [0, 90, 0]]) miniBox2(ndeck, undef, (loc == 0) ? 2 : 0);// miniBox(48, undef, loc==0 ? 2: 0);
}
atrans(loc, [[0, 0, 0]]) trr([trackx,     f+side, 0+cstackz]) trackStack();
atrans(loc, [[0, 0, 0]]) trr([trackx-ecx, f+side,  0]) cardStack();

atrans(loc, [[0, 0, 0], [-3-boxw, 0, 0]]) trr([-t0, -t0, -t0]) color("red") box([boxw, boxy, boxz/5]);

