use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
module dice(tr=[0,0,0], ds = ds) {
  color("#DDDDDD")
  translate(tr) roundedCube([ds,ds,ds], 2, false);
}
module cup(xyz=[47,47,47], t = t0) {
  // roundedRect fustrum:
  // vt: offset of base & walls (thickness)
  module vcup(base_xyc, top_xyz, vt = 0) {
    bx = base_xyc[0] - 2*vt;
    by = base_xyc[1] - 2*vt;
    rc = base_xyc[2] - vt;
    bxy = [bx, by];
    scal = [(top_xyz[0] - 2*vt)/bx, (top_xyz[1] - 2*vt)/by];
    trr([0, 0, vt])
    linear_extrude(height = top_xyz[2], scale = scal) 
    trr([-bx/2, -by/2, 0]) roundedRect(bxy, rc);
  }
  x0 = xyz[0];
  y0 = xyz[1];
  z0 = xyz[2];
  rc = 3;
  dz = z0;
  dx0 = x0;
  dy0 = y0;
  dx1 = x0;
  dy1 = y0;
  vt = 1.3;

  trr([dx1/2, dy1/2, 0]) intersection() 
  {
    // cup:
    difference() {
      vcup([dx0, dy0, rc], [dx1, dy1, dz], 0);
      vcup([dx0, dy0, rc], [dx1, dy1, dz], vt);
    }
    cube(size=[dx1+2*vt, dy1+2*vt, 169], center = true);
  }
}

module robber(tr = [0,0,0]) {
  color("black") 
  translate(v = tr) rotate([0,90,0]) cylinder(r1 = rs/2, r2 = 3, h = 32);
}
// 
ibz = 14;
module slotbox(ch = ch, ss = false) {
  r1 = .1; r2 = 5;
  cz = 3; // cut a wide slot, reducing height of 'box' for 25mm slot
  // 2 + .5mm to meet the roundedBox corner:
  slotifyY([2*(cbz-ibz), cw-2.5*t0, 2*t0, r1], [0, -(ch-t0+p)/2, cbz], undef, 2, false)
  slotifyY2([ibz,        25,        2*t0, r2], [0, -(ch-t0+p)/2,   4], undef,     2, ss)
  children(0);
}
module sidebox(dx = 0, y1 = y1, ss = false) {
  dr = (dx == 0) ? 27/2 : 0;
  cylr = (dx == 0) ? dr + 1.6 : -2; // t0 + 1.2/2
  cylz = 16;
  translate([dx, ch/2 - t0, 0]) 
  rc([ -cylr , 2*cylr-t0/2, cylz], 0, 3, 2, t0) // tr, rotid, q, rad, t, ss
  rc([ cylr , 2*cylr-t0/2, cylz], 0, 0, 2, t0)  // tr, rotid, q, rad, t, ss
  rc([ 0 , cylr, cylz], 1, 2, 2, 2*t0)          // tr, rotid, q, rad, t, ss
  slotbox(-2*y1+pp, ss)
  translate([-cw/2, 0, 0]) {
  difference() {
    union() {
      box([cw, y1+t0, cbz]); // dice box
      // add cylinders, maybe 0-radius:
      translate([cylr, cylr, 0]) pipe(rrh = [cylr, cylr, cylz]);
      translate([cw-cylr, cylr, 0]) pipe(rrh = [cylr, cylr, cylz]);
    }
    union() {
      dw = cw - 2*cylr; dy = cylr;
      // cut access slot:
      translate([dw/2, 2*cylr - dy, t0]) cube([cw-dw , cylr, cbz]);
      translate([t0, t0, t0]) cube([cylr, cylr, cbz]);
      // translate([t0, cylr, cylz-3.8]) cube([2, 6, 4.1]); // for clip-hole
      translate([cw-cylr, t0, t0]) cube([cylr, cylr, cbz]);
    }
  }
  dskz = 12.5/9; // empirical
  atrans(loc, [[cylr+f, cylr+f, t0+f], undef, undef, undef, undef, 0])
    astack(10, [0,0,dskz])
    color("yellow") disk(dr, dskz-.1)  ;
  }
}
module disk(r, h) {
  linear_extrude(height = h) 
  circle(r);
}

// for cards and tray names:
font = "Nunito:style=Bold";
// font = ".SF Compact Rounded";
// font = ".SF NS Rounded";

// Each of 6 boxes:
module cardbox(name, cutaway = false) {
  // echo("cardbox: name=", name);
  cut = cutaway ? [10, ch+f, cbz+f] : [0, 0, 0] ;
  difference() 
  {
    slotbox()
    roundedBox([cw, ch, cbz], 1, t0, undef, true);   // round the outer corners
    translate([(-8-cw)/2, (-f-ch)/2, -p]) cube(cut); // cutaway view
  }
  // fulcrum:    cutaway = true to see alignment
  a2 = -4.0;  // angle of cards on fulcrum
  s = 10;     // y-size of fulcrum (was also fontsize)
  translate([0.0, -8, 1.0]) {
    color("red")
    trr([0, 0, 1]) cube([cw, s, 4], true);    // wide base
    color("blue")
    trr([0, 0, 2.1, [a2, 0, 0]]) cube([cw, s-1, 3], true); // top bar
  }

  fs = 10; // font size
  {
    translate([0, -25, t0-p]) 
    linear_extrude(height = .8) 
    text(name, valign = "center", halign = "center", size = fs, font =font);
  }

  // Stack of cards, tilted:
  trt = [-0, 1.8, 1.1];
  atrans(loc, [trt, undef, undef, undef, undef, 0])
  cards(name, a2);
}

// Stack of 24 Cards
// name: print a name
// tile: rotation around x-axis
// n: number in stack
module cards(name = "foo", tilt = 0, n = 24) {
  dz = .325;  // z-thickness per card
  dy = tan(tilt) * dz;
  astack(n, [ 0, 0, dz ]) 
    trr([-cardw/2, -cardh/2, 0, [tilt, 0, 0, [0, cardh, 0]]]) {
    color("#aabbcc2f") roundedCube([ cardw, cardh, dz-.05 ], 3, true);
    translate([cardw/2, cardh/2, 0]) 
    color("black") text(name, halign = "center", font = font);
  }
}

cardLocs = [[1, 0, "sheep"], [1, 1, "wheat"], [1, 2, "ore"],
            [0, 0, "wood"], [0, 1, "brick"], [0, 2, "dev"], 
            ];

module cardboxes(i0, i1, cut = false) {
  locs = cardLocs;
  i0 = def(i0, 0);
  i1 = def(i1, len(locs)-1);
  for (i = [i0: i1]) let (rc = locs[i]) 
    let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1, name = rc[2])
  translate([c*(cw-t0), r*(ch-t0)+ry, 0])
  cardbox(name, cut);
}

function cutb(cw3 = cardw-11) = (cw - cw3)/2;
// viewport to cut from big lid
// t: z-depth of cut
module cutTop(t = tb) {
  // cut a viewport:
  // difference() 
  {
    cw3 = (cardw - 11);       // width of cutout
    dw = (cw - cw3) / 2;      // border around cutout
    dh = dw;                  // same border for height
    ch3 = ch - 2 * dh;        // height of cutout
    assert(dw + cw3 < cardw - 2 );
    // echo("cutTop: ", [dw, dh, -.5*tb], [cw, ch, t]);
    translate([dw, dh, -.5*tb])
     cube([cw3, ch3, t]);
  }
}

module addTop() {
  ta = 1; hw = 10;
  // short walls to keep cards from sliding out
  translate([ta, ta, p])
  box([-2*ta, -2*ta, hw+tb], [tw, tw, -1.5], [2, 2, 4]);
}

// cut holes in cardLid
module cardtops(i0, i1, cut = false) {
  locs = cardLocs;
  i0 = def(i0, 0);
  i1 = def(i1, len(locs)-1);
  difference() 
  {
    children(0); // the big lid
    for (i = [i0: i1]) let (rc = locs[i]) 
      let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1)
      // echo("cardtops: ", [c*(cw-t0), r*(ch-t0)+ry, 0])
      translate([c*(cw-t0), r*(ch-t0)+ry, cbz+1])
        cutTop(2);
    // cutout grid above sideboxes:
    gh = 30; cs = 7;
    trr([0, (clh - gh) / 2, clz]) 
      cubesGrid(clw, gh, [cs, 5, 4], 1);
  }
  tw = 1; hw = cbz-cbz+1; hw0 = cbz - ibz-hw+1;
  // add retainer walls at end of  cardbox:
  for (i = [i0: i1]) let (rc = locs[i]) 
    let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1, cz = 11)
    translate([c*(cw-t0), r*(ch-t0)+ry, 0])
    translate([1.5*t0, 1.5*t0, cbz-hw]) 
    {
      roundedBox([cw - 3*t0, ch-3*t0, hw+pp], 2, [tw, tw, -1.5], [2, 2, 4]);
      translate([cw/2, t0/2, -hw0/2-p])  cube([10, 1, hw0], true); // tab in slot
    }

  // retainer bar for disks
  dr = (true) ? 27/2 : 0; // disk radius
  cylr = (true) ? dr + 1.6: 0; // t0 + 1.2/2
  rr = 3; // reduce radius
  cylz = 16; kz = 1; cylz2 = cbz-cylz+kz;
  translate([ cylr/2, ch + t0 + cylr, cylz-kz]) 
  cube([cw-cylr, 1.5* t0, cylz2]);
}

// lid for cardsTray
// ambient:
// clw
// clh
// clz
// r180 (rotation & center) 
module cardsLid() {
  // align lid with box:
  p0 = -(t0+2*f);
  {
  // add clips:
  cx = 1+2*f; d0 = (t0 + cx/2); 
  tr = [p0, (lh-f)/2, cbz - clz + 4 -f]; // 4mm up from bottom edge
  clips(tr, [d0, clw-d0], 10, cx);

  cardtops()
  atrans(0, [[p0, p0, clz-lz +t0, r180]]) // flip in place; align with cardbox
    box([clw, clh, clz]);
  }
}

// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s = is_list(size) ? size : [size,size,size]; // tube_size
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0+p])
 rotate([0, -90, 0])
 roundedTube([s[2], s[1], s[0]], rt, k, t);

 // endcaps
 hw0 = [s[2], s[1], 0];
 hwx = [s[2], s[1], s[0]];
 div(hw0, rc, k);
 div(hwx, rc, k);
}

// nx: columns of partTrays
// ny: rows of partTrays
nx = 1; ny = 4; 
module partTrays(mr, mc) {
  mr = def(mr, (loc >= 8) ? loc-8 : ny);
  mc = def(mc, nx);
  mx = t0 / nx; my = t0 / ny;
  tw2 = bw - 2 * t0 - mx;
  th2 = bh - 2 * t0 - my;
  tw = tw2/nx;
  th = th2/ny;
  px0 = (bw - nx * tw) / 2;
  py0 = (bh - ny * th) / 2;
  roadx = (1+2/16) * 25.4;  // note road is (1 x 3/16 x 3/16)
  echo("partsTray: roadx=", roadx, "interior width=", th-my-3*t0);
  module partstray(tr=[0,0,0]) {
    // old tray: 85,500 mm^3, now: 85,868.5 mm^3 (less for radius)
    // echo("partstray: tw, th, boxz-1=", tw, th, boxz-2.1, tw*th*(boxz-2.1) );
    rt = 10;
    trayz = boxz - t0;
    translate(tr) {
      tray([tw - mx, th - my,  trayz + rt], rt, 2, -10 );
      div([trayz + rt, th-my, roadx + t0], rt, -rt);
    } 
  }
  astack(mc, [tw, 0, 0]) astack(mr, [0, th, 0])
      partstray([px0, py0, 1]); // above the blue box
}

// cs: child size; begin grid @ (cs, cs+1)
// nc: columns
// nr: rows
module partsGrid(cs = 5, nc = 10, nr = 20) {
  x0 = cs;
  xi = (bw - cs) / nc;
  xm = bw - cs;
  y0 = cs + 1;
  yi = (bh - cs) / nr;
  ym = bh - cs;
  translate([0, 0, -t0])
  gridify([x0, xi, xm], [y0, yi, ym], 2) cube([cs, cs, cs]);
}

module clip(tr, wx = 2, ly = 3, hz = 2) {
  translate(tr) cube([wx, ly, hz], true);
}
module hole(tr, wx = 2, ly = 3, hz = 2) {
  translate(tr) cube([wx, ly+5*f, hz+5*f], true);
}
module clips(tr, xa, dy = 30, wx = 2, ly = 3, hz = 2) {
  for (x = xa, iy = [-dy: dy: dy]) 
  {
    clip([tr[0]+x, tr[1]+iy, tr[2]], wx, ly, hz);
    // clip([tr[0]+x1, tr[1]+iy, tr[2]], wx, ly, hz);
  }
}
module holes(tr, xa, dy = 30, wx = 2, ly = 3, hz = 2) {
  for (x = xa, iy = [-dy: dy: dy]) 
  {
    hole([tr[0]+x, tr[1]+iy, tr[2]], wx, ly, hz);
  }
}

// lid z:
lz = 11;
// depth to clips/holes
sd = 7;

module partsLid(lw = lw, lh = lh, lz = lz, sd = sd) {
  sd = is_undef(sd) ? 7 : sd;
  union() {
  translate([f, -f, 0])
  difference() {
    box([lw, lh, lz]); // partslid
    partsGrid();
  }

  // add clips:
  cx = 1+f; d0 = (t0+cx/2);
  tr = [f, (lh-f)/2, t0+sd+f];
  color("red") clips(tr, [00+d0, lw-d0], 30, cx);
  }
}

// bluebox: holds the partTrays (with partsLid)
// parts vol = ~79,000 cu-mm
module bluebox() {
  hm = .8;
  difference() {
    color("lightblue")
    box([bw, bh, boxz]);
    holes([0, bh/2, boxz-sd], [t0/2, bw-t0/2], 30); // for clips

    for (ix = [0 : nx-1], iy = [0 : ny-1]) 
      let(hw = hm*bw/nx, hh = hm*bh/ny)
      translate([ix * bw/nx +hw/2+ hw*(1-hm)/2, iy*bh/ny + hh/2 + hh*(1-hm)/2  , -t0])
      cube([hw, hh, 5], true); // open bottom
  }
}

f = .18;  // snug fudge factor

// trays for cards, player-bits, dice, robber, disks
tb = 3; // thickness of base

// depth of boxes: city=19; 8-10-cards, 3-lever, 2-holding (+2 for bottom!)
boxz = 26; // bluebox for parts
cbz = 18;  // cardbox height: independent of bluebox: boxz
cardw = 54; cw = cardw + 2 + 2 + 2*t0; // cw = cardw + sleeve + gap + box wall
cardh = 81; ch = cardh + 2 + 2 + 2*t0; // ch = cardh + sleeve + GAP + box wall
// dice size
ds = 16;
// robber size
rs = 15;

// tray height = 206
th = 206;
// size of gap between two rows of boxes:
y1 = th - 2*(ch)-t0;
// tw = total width - t0;
tw = 3 * (cw - t0);
// bluebox width:
bw = (282-30) - tw - 2; // inset by 2mm
// bluebox 'height': (max 220 due to plate size of FlashForge!)
bh = 2 * ch + y1 - t0;  // 220 - 2*t0
// partsLid:
lw = bw + 2*t0 + 2*f;
lh = bh + 2*t0 + 2*f;

echo("y1=", y1, "bw=", bw, "bh=", bh, "tw=", tw, "th=", th );
echo("parts vol: bw*bh*(boxz-2*t0)", (bw-4)*(bh-8)*(boxz-2)/4);

// cardsLid metrics:
clw = 3 * (cw) + 4*f;
clh = 2 * (ch) + 0 + y1 + t0 + 4*f; // bh + 2*t0 + 2*f
clz = lz + (cbz-cbz); // lidz
// rotate in place:
r180 = [0, 180, 0, [clw/2, clh/2, cbz/2]];

// 0: all, 1: cardboxes, 2: bluebox & partsLid, 3: partTrays, 4: cardsLid,
// 5: packed, 6: bluebox & partsLid (fit); 7: bluebox & partTrays (fit)
// 8: bluebox, 9..12: partsBox
loc = 4;

// CardTray-1:
difference() {
  atrans(loc, [[cw/2, ch/2, 0], 0, undef, undef, undef, 0])
  {
    cardboxes();
    for (i = [0 : 2]) sidebox((cw-1)*i);
  }
  {
    // cut holes for clips:
    dx = 1.5*t0; 
    holes([0, (lh-f)/2, cbz - lz + 4], [-t0 + dx, tw+2*t0 - dx], 10, 4);
  }
}
// cardsLid-4
atrans(loc, [[-clw-2*t0, 0, t0, r180], // 0: placement to view
              2, undef, undef,
              [0, 0, t0, r180],    // 4: placement to print
              [0, 0, 0],           // 5: align with box
              ]) {
  cardsLid(); // loc: { 0, u, u, u, 4, 5 }
}

atrans(loc, [[cw+t0, ch+t0, t0], undef, undef, undef, undef, 0]) {
  astack(2, [ds+f, 0, 0]) dice([0, 0, 0]);
  robber([cw, t0 + rs/2, rs/2]);
}

// partsBox-2 w/Lid
bbx0 = bh; bby0 = th+t0;
atrans(loc, [[bbx0, bby0, 0, [0, 0, 90]], undef, [0, 0, 0], undef, undef, 0, 0, 0, 0]) 
  bluebox();

atrans(loc, [[bbx0-bh-t0, bby0-t0, 0, [0, 0, 90]], undef, [bw + 2, -t0, 0], undef, undef, 
             [bbx0+t0, bby0+lw-t0, boxz+t0, [0, 180, 90]], 5,
             ])
  partsLid(); // blueBox lid

// partTrays-3x4
atrans(loc, [[bbx0, bby0+bw, -t0, [0, 0, 90]], 
             undef, undef, 
             [0, 0, -t0],
             undef, 
             [bbx0, bby0, t0, [0, 0, 90]], undef,  5, undef, 3, 3, 3, 3])
  partTrays();  // (0,0);            // partTrays
// Roads: 1 X 3/16 X 3/16
// City: 3/4 X 3/4 X 10mm
// House: 9 X 14 X 12 mm
// rl = 25.4; rw = rl * 3/16; rh = rw;
// translate([cw-1, 7, t0]) rotate([0,0,90]) partTrays(0,0);

atrans(loc, [[clw,0,0], undef, undef, undef, undef, 0]) cup();

// show printer plate:
*atrans(loc, [undef, undef, undef, undef, undef, [-1, -1, -2]]) 
 color("tan") cube([220, 220, 1]);
// show packing box:
atrans(loc, [[-230, -2, -1.1], undef, undef, undef, undef, [-.5, -1.5, -1]]) 
 color("brown") cube([230, 285, 1]);

