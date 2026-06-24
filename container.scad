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
lt = 1.4;   // lid thickness: XY
lz = 1.5;   // lid thickness: Z
dl = lt+f;    // offset for lid XY

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

/** auction reservation disk */
module disk(r = 10) {
  dh = 17/10;
  astack(10, [0, 0, dh]) color("blue") 
    cylinder(h = dh*.9, r = r);
}

/** holds the 3 cylinders & 10/17mm of disks */
module sideTray(z = 22) {
  // x = box_x - trayx -dl; 
  x = 20;
  x2 = x/2;
  y = trayy; r = 10; pz = 18;
  echo("box_x - cboxx", box_x - cboxx - tx - tx);
  cube([x, y, 1]);    // base board
  astack(4, [0, 2 * (r + ty), 0]) trr([x2, r+2, 0]) 
  difference()
  {
    pipe([r+tx+f, r+tx+f, pz], 1);
    trr([0, 0, pz/2]) cube([x+4, x*.5, pz+pp], true);
  }


  atrans(0, [[x2, r+2, tz]]) {
    astack(3, [0, 2 * (r + ty), 0]) color("orange") cylinder(h = 30, r = r);
    // trr([0, 6 * (r + ty), 0]) disk();
  }
}

// loc = 5; stack of 6 cardBox()
module cardTray() {
  astack(3, [cardx - tx-p, 0, 0]) trr([0, 0, 0, [0, 0, -180, [cardx/2, cardy/2, 0]]]) cardBox();
  astack(3, [cardx - tx-p, 0, 0]) trr([0, cardy-ty, 0]) cardBox();
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
  f = .125;
  zz = zh - zd - cboxz - cardz; 
  echo("lid: zz =", zz, zz+cardz-ty-lz, cboxz+cardz+zz) ;
  x = trayx + 2*dl; y = trayy + 2*dl; z = zh -zd - cardz -3; cs = 7.6; st = 10;
  trr([-f, -f, 0]) {
    color("red")
    box([x, y, zz], [lt + tx+f*2, lt + ty + f*2, -p], [2, 2, 2] );

    difference() {
      box([x, y, z], [lt, lt, lz]);
      cubesGrid(bw = x, bh = y, stt = [cs, st-cs, st-cs], t = 3);
    }
  }
}

module wareBox() {
  x = 125; y = 60; z = 20;    // 125, 60, 15-20
  box([x, y, z], [tx, ty, tz]);
  echo("wareBox:", x*y*z, "~", 15*20*20*20);
}
module factorBox() {
  dh = 17/10;
  x = 35; y = 119; z = 17; dz = 17; wx = dh*10+2;  // wx = 10*dh - f
  by = 2 * (10 + tx); sw = by*.6;     // box y-height (disc radius = 10)
  fx = .25;

  trr([x-wx, .5-by, 0])
  slotifyX2([dz, sw, 3], [wx-1, by/2, 5], undef, 1) 
  slotifyX2([dz, sw, 3], [0, by/2, 5], undef, 1) {
    box([wx, by, dz]);
    astack(2, [wx-1-2*fx,0,0], undef, ["red", "blue"])
    trr([.5+fx, 0, z/2, [-90,0,0]]) cylinder(h = by, r = .5);
  }
  box([x, y, z]);
 * trr([x-wx+tx, -10.5, 11, [0, 90, 0]]) disk();
  echo("factorBox:", x*(y - 20)*z, "~", 5*4*8*20*15);
}

/** big box, top/useful half */
module bbox() {
  // box_x, _y are interior dimensions. bt: thickness of cardboard
  // color("tan")
  trr([-dl-bt-f, -dl-bt-f, -bt-f]) box([box_x+2*bt, box_y+2*bt, box_z+bt+f], [bt, bt, bt]);
}
*bbox();

// 0: both, 1: contBox, 2: cardBox, 3: both Trays, 4: contTray, 5: cardTray
// 6: both+lid, 7: lid-print
loc = 9;

atrans(loc, [[0, 0, -trayz], undef, [0, 0, 0]]) cardBox();
atrans(loc, [[0, 0, 0], 0]) containerBox();

atrans(loc, [undef, 0, 0, [0, 0, 0],     0, 3, 3]) cardTray();
atrans(loc, [undef, 0, 0, [0, 0, trayz], 3, 0, 3]) containerTray();

// 6, 7: containerLid
atrans(loc, [undef, 0, 0, 0, 0, 0, [-lt, -lt, zh-zd, [0, 180, 0, [(trayx+2*lt)/2, (trayy+2*lt)/2, 0]]], [-lt, -lt, 0]]) containerLid();
// 8: sideTray
*atrans(loc, [undef, 0, 0, 0, 0, 0, 8, 0, [trayx,0,0]]) sideTray();
// 9: wareBox
*atrans(loc, [undef, 0, 0, 0, 0, 0, 9, 0, 0, [0, trayy+35, 9]]) wareBox();
atrans(loc, [undef, 0, 0, 0, 0, 0, 9, 0, 0, [125+f, trayy+dl, 0]]) factorBox();

echo(125*60*20, 35*120*40, 15*20*8*20);
