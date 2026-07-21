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

ndeck = 64;
ntc = ndeck * tc;

bx0 = 2.5*inch + 4;
bz = 1.75*inch+t0;
by1 = 10 * tc + t0;
by2 = 20;
byt = by1 + by2 -t0 + .5;
boxw = cardw + ecx + t0 + ntc + 4*t0;
bx = (boxw-3*t0)/2;

module playerBox() {
  trr([0, t0, 0]) box([bx, by1, bz]);
  trr([0, by1, 0]) box([bx, by2, bz]);
}
module multiPlayer() {
  astack(2, [bx+.5, 0, 0], tr0)
  astack(3, [0, byt, 0], tr0) 
  playerBox();
}

module miniDeck(n = 64) {
  astack(n, [0, 0, tc], tr0) mcard();
}

module miniBox(n = ndeck) {
  box([ntc + 2*t0, thf+2*t0, bz]);
} 

trr([p-t0, p-t0, 0]) miniBox();
trr([0, 3*t0+f, 0, [90, 0, 90]]) miniDeck();
trr([0, thf, 0]) multiPlayer();

trr([ecx+ntc+2*t0 , t0+side, 0]) trackStack();

trr([-t0, -t0, -t0]) color("red") box([boxw, thf+ 3*( by1 + by2 + 3 * t0 ), 20]);
