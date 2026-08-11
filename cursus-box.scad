use <mylib.scad>;
include <cursus-track.scad>;

t0 = 1;               // not in cursus-track: thickness of box
bt0 = 1.3;

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

// 80 Cards: 64 + 16 = 48 + 16 + 16
nd2 = 10;           // cards in playerBox: 4-bidValue, 6-bidCol
ndeck = 48;         // most of the 80 cards (48 + 32)
ncard = 18;         // non-deck cards (white, black/grey)

bx = mcardw + 2 + 2*t0; // external minibox: mcardw + slack=2, 2 * wall thickness = t0
dz = 2;                  // extend boxes above cards
bz = 1.75*inch + t0 + dz;// extend boxes above cards
byc = t0 + nd2 * tc1 + t0;  // thin section for cards (10 * .35) 2 * 3.5 = 5.5mm
bym = t0 + 12.5;            // taller than the meeples (8x12x12 ~1152 mm3) * 8 = 9200
by = bym + 5.7;         // total-y of playerBox; 19.2mm
byt = by + f;           // total width + fudge in multiPlayer
byp = by + 1;           // playerBox spaced for print
pbwide = 6 * byt;       // playerBox stack width
tswide = bt0 + bt0 + cardw + ecx + bt0; // track & ecx + extra 2*t0 fudge space.
echo("pbwide, tswide =", pbwide, tswide); // interior x-width required

// boxw = bt0 + max(pbwide, tswide) + bt0; // exterior size of main box
boxy = bt0 + (thf+ 2*bt0 + bx) + bt0;    //
boxz = bz/1 + bt0 * 2; // base, slack for 3 cards
boxw = 120.68; //boxy = 151.856;       // orig box size
// "boxw, boxy", 120.68, 151.856, 4.75118, 5.97858
// "boxw, boxy", 118.88, 151.256, 4.68031, 5.95496

// bxyz: [boxw, boxy, boxz
// c: ("red")
// tt: div thickness (bt0)
module mainBox(bxyz, c = "red", tt = t0) {
  boxw = def(bxyz[0], boxw); 
  boxy = def(bxyz[1], boxy);
  boxz = def(bxyz[2], boxz);
  // on a hot day, printer fan crushes the near wall! add a support strut:
  slotifyY2([boxz, boxw*.7, tt*2, 18], [boxw/2, thf+1.3*bt0+tt, boxz*.3], undef, 20)
  divXZ([boxz, boxw, thf+1.5*bt0], 0, 0, tt);
  color(c)
  box(lwh=[boxw, boxy, boxz], t=bt0, r=.6);
}

font = "Baskerville:style=Bold Italic";
fontsize = 10;
module ttext(str="title", d = .6) {
  trr([0, 0, 0, [180, 0, 0, [0, 0, d/2]]])
  linear_extrude(height = d) 
  rotate([0, 0, 90]) text(text=str, font=font, size=fontsize, halign="center", valign="center");
}

lt = 1.5;     // lid thickness
module mainLid(fl = f, lz = 18, c = "green") {
  dxy = lt + fl;   // extend around box
  sr = 40;         // slot radius]
  lh = fontsize * 1.3; // line height
  color(c)
  trr([-dxy, -dxy, 0]) 
  slotifyX2([lz+dxy, sr, 3*dxy, sr/3], [boxw+dxy, boxy/2, lz - sr/2], undef, 3)
  slotifyX2([lz+dxy, sr, 3*dxy, sr/3], [       0, boxy/2, lz - sr/2], undef, 3)
  difference() {
    box([boxw + 2*dxy, boxy + 2*dxy, lz + dxy], lt);
    trr([boxw/2-lh/2, boxy/2, -p]) ttext("Cursus");
    trr([boxw/2+lh/2, boxy/2, -p]) ttext("Honorum");
  }
}

echo("bx * bym * bz = ", bx * bym * bz, bx/12, bym, bz, "by=", by, "byc=", byc); // 53000 > 8000
echo("boxw, boxy", boxw, boxy, boxw/inch, boxy/inch);

// fortuitously, 48 cards fit in a playerBox, so we use it for the miniBox!
// nc: number of cards to fit
// cx: x-offset to show cards in stack
// meep: (false) if true show a meep cylinder in the mbox
module playerBox(nc = nd2, cx = 1, meep = false) {
  ncc = (nc > 0) ? nc : 48;   // 48 -> 18.8mm will fit in by=19mm playerBox
  byc = t0 + ncc * tc1;
  // hack to remove slot unless doing a miniBox2:
  t0__2 = (nc > 0 && nc < 15) ? t0 * -2 : t0 * .2;
  // echo("playerBox: nc=", nc, "cx=", cx, "byc=", byc);
  trr([by, 0, 0, [0, 0, 90]]) {
    color("#e0e0e0d9") {
      if (nc > 0) {
      slotifyY2([bz-dz, .6*bx, 2*t0, 4], [bx*.5, byc- t0*-.5, bz*.7], undef, 3, false)
        divXZ([bz-dz, bx, byc], 0);
      }
      slotifyY2([bz- 0, .6*bx, 2*t0, 4], [bx*.5, by - t0__2, bz*.7], undef, 3, false)
      slotifyY2([bz- 0, .5*bx, 2*t0, 4], [bx*.5,      t0*.2, bz*.5], undef, 3, false)
        box([bx, by, bz]);     // cardsBox (& meepleBox)
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
module miniBox2(n = ndeck, mbh = bx, cx = 0) {
  echo("miniBox2: n=", n, "cy=", cx);
  playerBox(0, cx); 
}
module miniBox(n = ndeck, mbh = bx, cy = 0) {
  mbx = t0 + (n * tc1) + t0;
  mbh = def(mbh, bx);
  mbz = bz - 0;
  trr([0, 0, 0]) {
    slotifyX2([mbz, mbh * .5, 2*t0, 4], [0 + t0/2, mbh/2, mbz/2], undef, 4, false)
    slotifyX2([mbz, mbh * .5, 2*t0, 4], [mbx-t0/2, mbh/2, mbz/2], undef, 4, false)
    box([mbx, mbh, mbz]);
    if (cy > 0) {
      trr([t0, cy, t0, [90, 0, 90]]) astack(n, [0, tc1, 0]) mcard();
    }
  }
} 
ncardz = (24 + 6);
mboxz = ndeck*tc1 + 2*t0; // miniBox-z when rotated to lay flat
trackx = bt0 + ecx;       // x-offset to trackStack
cstackz = ncardz * tc1 - ecz;     // above stack of 24 track cards
trkz = f + cstackz + (tsz - ecz); // folded track z-extent

module cardStack(n = ncardz) {
  trr([ecx, 0, 0]) astack(n, [0, 0, tc1]) card(cardw, cardh, tc0);
}
u10 = [];
// loc: 0 - full stack, design mode
// 1: print all
// 2: miniBox2(ndeck) & cardBox = playerBox(ncard)
// 3: miniBo2, cardBox, playerBox(nd2)
// 4-8: multiPlayer(loc-2)
// 10: print mainBox
loc = 9;
show(5);
// 0 miniBox & pb(ncard) @ 90-degrees
atrans(loc, [[0, 0, 0]]) {
  trr([      f+  1*bt0, side/2, mboxz+trkz, [0, 90, 0]]) miniBox2(ndeck, undef, (loc == 0) ? 2 : 0);
  trr([bz+t0/2+ 1*bt0, bz+side, mboxz+trkz, [0, 90, -90]]) playerBox(ncard, (loc==0) ? 2 : 0);
}
// 0: trackStack & cardStack
atrans(loc, [[0, 0, 0]]) trr([trackx,     f+side, 0+cstackz]) trackStack(-1);
atrans(loc, [[0, 0, 0]]) trr([trackx-ecx, f+side,  0]) cardStack();
// 0 & 1: "red" box
atrans(loc, [[0-f/2, 0, 0], [-(3+boxw), 0, 0], undef, 2,
    2, 2, 2, 2, 2, 2, 0,]) trr([-bt0, -bt0, -bt0]) mainBox();
atrans(loc, [[0-f/2, 0, 0], [-2*(3+boxw), 0, 0], undef, 2,
    2, 2, 2, 2, 2, 0,]) trr([-bt0, -bt0, -bt0 - lt]) mainLid(.12, boxz-f, "purple");
// 0 & 1: full & print-6
atrans(loc, [[0, thf + 2*t0, 0], 0]) multiPlayer(6, loc==0 ? 2 : 0);
// 2: minBox2 & playerBox(ncard) & playerBox(nd2)
atrans(loc, [undef, [0, 0, 0], 1, 1]) {
  trr([    0, 0, 0]) miniBox2(ndeck);
  trr([byp, 0, 0]) playerBox(ncard, 0); // cardBox
  if (loc == 3)  // one of each
  trr([byp * 2, 0, 0]) playerBox(nd2, 0);
}
// 4--8: multiPlayer(loc-2) print (no cards)
atrans(loc, [undef, 0, 0, 0, [0, 0, 0], 4, 4, 4, 4]) astack(loc-2, [byp, 0, 0]) playerBox(nd2, 0);

