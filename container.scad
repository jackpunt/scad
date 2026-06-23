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

box_x = 162;
box_y = 263;
box_z = 43;   // 47-dh => 43 or 44 for tight fit; available box z
bt = 2;

tx = 1;
ty = 1;
tz = 1;
tl = 1.2;   // lid thickness: XY
dl = tl;    // offset for lid XY

// base size of tray for cards
trayx = 140;
trayy = 140;
trayz = ncards * t00 + bz + ty;

cardx = (trayx - tx)/3 + tx;
cardy = (trayy - ty)/2 + ty; // extrnal width of card box
cardz = trayz;


// base size of tray for cubes
cboxx = trayx;
cboxy = trayy;
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
module card(tr = undef, n = 1, dxyz=[h00, w00, t00*.9], rgb="cyan")
{
  tr = def(tr, [ tx +  (h0 - h00) / 2, ty + (w0 - w00) / 2, tz ]);
  trr(tr) astack(n, [ 0, 0, t00 ], [-ang, 0, 0]) color(rgb, .5) roundedCube(dxyz, 3, true);
}

/** a container */
module container(c = "blue") {
  color(c)
  cube([contX, contY, contZ], false);
}

// size of posts:
px = 1.6; py = 8; pz = 2;

/** single box for 1 stack of cards */
module cardBox(nc = ncards) {

  dx = px; dy = py; tpz = trayz + pz;
  ss = false;

  slotifyX2([trayz, cardy/2, 3], [0, cardy/2, 4], undef, 3, ss)
  slotifyX2([trayz, cardy/2, 3], [cardx, cardy/2, bz], undef, 3, ss)
  slotifyY2([trayz, cardx/2, 3], [cardx/2, 0, 6], undef, 3, ss)
  slotifyY2([trayz, cardx/2, 3], [cardx/2, cardy, 6], undef, 3, ss)
  box([cardx, cardy, cardz]);
  // crossbar:
  trr([0, cardy * .75, tz*.3, [-ang, 0, 0]]) color("red")  cube([cardx, 10, bz]);
  // pillars:
  astack(2, [ cardx-dx-p, 0-p, 0]) astack(2, [0-p, cardy-dy-p, 0]) color("green") cube([dx, dy, tpz]);
  // cards:
  atrans(loc, [[0, 0, 0], undef, 0]) card(undef, nc);
}

/** holds the 3 cylinders & 10/17mm of disks */
module sideTray(z = 22) {
  x = box_x - trayx -dl; x2 = x/2;
  y = trayy; r = 10;
  dh = 17/10;
  echo("box_x - cboxx", box_x - cboxx - tx - tx);
  slotifyY2([z, x-8, 4], [x2, 0, z * .4], undef, 3)
  box([x, y, z], [tx, ty, tz]);
  astack(4, [0, 35, 0]) 
  slotifyY2([z-2, x-8, 4], [x2, 20, z * .4], undef, 3) divXZ([z-2, x, 20], 0, 0, ty);

  atrans(0, [[0, 0, 0]]) 
  astack(10, [0, dh, 0]) color("blue") trr([x2, 3, r + tz, [90, 0, 0]])   
  cylinder(h = dh*.9, r = r, center = false);
  astack(3, [0, 35, 0]) color("orange") trr([x2, 38, r + tz, [90, 0, 0]]) cylinder(h = 30, r = r, center = true);
  // trr([tx, r + ty, r + tz, [0, 90, 0]]) cylinder(h = 20, r= 5, center = false);
}

// loc = 5; stack of 6 cardBox()
module cardTray() {
  astack(3, [cardx - tx-p, 0, 0]) trr([0, 0, 0, [0, 0, -180, [cardx/2, cardy/2, 0]]]) cardBox();
  astack(3, [cardx - tx-p, 0, 0]) trr([0, cardy-ty, 0]) cardBox();
  * trr([3 * cardx - 2*tx + f, 0, 0])
  sideTray();
}


// loc = 4; stack of 6 containerBox()
module containerTray() {
  astack(2, [0, cardy - ty-p, 0])
  astack(3, [cardx - tx-p, 0, 0])  containerBox();
}

// loc 1: single box
module containerBox() {
  x = cardx; y = cardy; z = cboxz; //cboxx/2; y = cboxy/3; z = cboxz;
  dx = px+f; dy = py+f; dz = pz + .8;
  f = 1;
  difference() 
  {
    box([x, y, z], [tx, ty, tz]);
    astack(2, [ x-px, 0, 0]) astack(2, [0, y-py, 0]) 
      trr([-pp, -pp, -pp]) cube([dx, dy, dz]);
  }
  // add bumps in corner:
  r = 2; d = 6;
  astack(2, [x - 2*d, 0, 0])
  astack(2, [0, y - 2*d, 0])
  trr([d, d, tz]) scale([1,1,.8]) intersection() { sphere(r); trr([-r, -r, -p]) cube([2*r, 2*r, r]); }

  // containers to view: (loc 0)
  atrans(loc, [[0,0,0]])
   trr([1, 1, 0])  astack(3, [0, contY+2*f, 0]) astack(4, [contX+f, 0, 0]) trr([tx, ty, tz]) container();
}

zh = 47;
zd = 4;
/** 
* zh: total z-height
* zd: reserve for docs
*/
module containerLid(zh = zh, zd = zd) {
  zz = zh - zd - cboxz - cardz; 
  echo("lid: zz =", zz, zz+cardz-ty-tz, cboxz+cardz+zz) ;
  x = trayx+2*tx; y = trayy + 2*ty; z = cboxz;
  color("red")
  box([x, y, zz], [tl + tx, tl + ty, -p], [2, 2, 2] );

  difference() {
    box([x, y, z], [tl, tl, tz]);
    cubesGrid(bw = trayx, bh = trayy, stt = [8, 2.5, 2.5], t = 3);
  }
}

/** big box, top/useful half */
module bbox() {
  // box_x, _y are interior dimensions. bt: thickness of cardboard
  trr([-dl-bt-f, -dl-bt-f, -bt-f]) box([box_x+2*bt, box_y+2*bt, box_z+f+bt], [bt, bt, bt]);
}
%bbox();

// 0: both, 1: contBox, 2: cardBox, 3: both Trays, 4: contTray, 5: cardTray
// 6: both+lid, 7: lid-print
loc = 6;

atrans(loc, [[0, 0, -trayz], undef, [0, 0, 0]]) cardBox();
atrans(loc, [[0, 0, 0], 0]) containerBox();

atrans(loc, [undef, 0, 0, [0, 0, 0],     0, 3, 3]) cardTray();
atrans(loc, [undef, 0, 0, [0, 0, trayz], 3, 0, 3]) containerTray();

atrans(loc, [undef, 0, 0, 0, 0, 0, [-tl, -tl, zh-zd, [0, 180, 0, [(trayx+2*tx)/2, (trayy+2*ty)/2, 0]]], [-tx, -ty, 0]]) containerLid();
