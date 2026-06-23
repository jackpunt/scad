// container trays: Money Cards & Container cubes; warehouse?
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1.2;    // print thicker, use 0.6 print head
f = .15;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

contX = 10;
contY = 20;
contZ = 10;

sample = false;

w00 = sample ? 30 : 64;  // official card size [long dimension]
h00 = sample ? 23 : 43;  // official card size [short dimension]
t00 = 12/36;             // mm per card
ncards = 36;

h0 = h00+2;   // leave some slack (sleeves some day?)
w0 = w00+2;   // assert: w0*3 < cardy-2*ty

bz = 3;       // z-height of card block
ang = atan2(-bz, w0);

box_h = 162;
box_w = 263;
box_z = 43;   // maybe 44 or 45 for tight fit; available box z

tx = 1;
ty = 1;
tz = 1;

// base size of tray for cards
trayx = 140;
trayy = 140;
trayz = ncards * t00 + bz + ty;
cardy = (trayy - ty)/3 + ty; // extrnal width of card box

// base size of tray for cubes
cboxx = 140;
cboxy = 140;
cboxz = 17.5;   // height of walls on containerBox


echo("w00, h00, t00, h0, w0", [w00, h00,t00, h0, w0, cardy-2*ty]);
// a stack of cyan cards (on lid) - pro'ly from chaos orientation; BYO 'tr'
// tr: offset card [x, y, z, r] with trr()
// - x: short dim of card (h00); 
// - y: long dim of card (w00); 
// - z: thickness (t00)
// - r: rotation [rx, ry, rz, cr] (cr: center of rotation: [x0, y0, z0])
// n: [1] cards in stack
// dxyz: [h00, w00, t00] dimension of card
// color: [cyan]
module card(tr = undef, n = 1, dxyz=[w00, h00, t00*.9], rgb="cyan")
{
  tr = def(tr, [ tx +  (h0 - h00) / 2, ty + (w0 - w00) / 2, tz ]);
  trr(tr) astack(n, [ 0, 0, t00 ], [0, ang, 0]) color(rgb, .5) roundedCube(dxyz, 3, true);
}

/** a container */
module container(c = "blue") {
  color(c)
  cube([contX, contY, contZ], false);
}

// size of posts:
px = 2; py = 2; pz = 2;

/** single box for 1 stack of cards */
module cardBox(nc = ncards) {
  x = trayx/2; y = cardy; z = trayz;
  dx = px; dy = py; tpz = trayz + pz;
  ss = false;

  slotifyX2([trayz, y/2, 3], [0, y/2, 4], undef, 3, ss)
  slotifyX2([trayz, y/2, 3], [x, y/2, bz], undef, 3, ss)
  slotifyY2([trayz, x/2, 3], [x/2, 0, 6], undef, 3, ss)
  slotifyY2([trayz, x/2, 3], [x/2, y, 6], undef, 3, ss)
  box([x, y, z]);
  trr([x * .75, 0, tz*.3, [0, ang, 0]]) color("red")  cube([9, y, bz]);
  astack(2, [ x-dx, 0, 0]) astack(2, [0, y-dy, 0]) color("green") cube([dx, dy, tpz]);

  atrans(loc, [[0, 0, 0], undef, 0]) card(undef, nc);

}

module containerBox() {
  x = cboxx/2; y = cboxy/3; z = cboxz;
  dx = px+f; dy = py+f; dz = pz + .8;
  f = 1;
  difference() 
  {
    box([x, y, z], [tx, ty, tz]);
    astack(2, [ x-px, 0, 0]) astack(2, [0, y-py, 0]) 
      trr([-pp, -pp, -pp]) cube([dx, dy, dz]);
  }
  atrans(loc, [[0,0,0]])
    astack(2, [0, contY+5*f, 0]) astack(6, [contX+f, 0, 0]) trr([tx, ty, tz]) container();
  // add bumps in corner:
  r = 2; d = 6;
  astack(2, [x - 2*d, 0, 0])
  astack(2, [0, y - 2*d, 0])
  trr([d, d, tz]) intersection() { sphere(r); trr([-r, -r, -p]) cube([2*r, 2*r, r]); }
}

loc = 2;

atrans(loc, [[0, 0, -trayz], undef, [0, 0, 0]]) cardBox();
atrans(loc, [[0, 0, 0], 0]) containerBox();

atrans(loc, [undef, undef, undef, [0, 0, 0]])
astack(3, [0, cardy-ty, 0]) cardBox();
