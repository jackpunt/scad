// cubitos
use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

sample = false;

// box size and placement constraint (3x4 grid in square box)
wmax = 285/4;    // 95 (w0 < wmax)
hmax = 285/3;    // 71 (h0 < hmax)

w00 = sample ? 30 : 88;  // official card size [long dimension]
h00 = sample ? 23 : 63;  // official card size [short dimension]

t00 = .4;  // card thickness: sleeves bring thickness to ~.625 per card. (from min .4mm)
t01 = 6.25/12; // = .52mm; thickness when stacking sleeved cards (compressed)

// euroPoker size (with sleeves):
// width of card with sleeves
w0 = w00+2.5;
// height of card with sleeves
h0 = h00+3.0;
bt = 10 * t01 + 2 * t0; //


// a stack of cyan cards (on lid) - pro'ly from chaos orientation; BYO 'tr'
// tr: offset card 
// x: short dim of card (h00); y: long dim of card (w00); z: thickness (t00)
module card(tr = [ tw +  (h0 - h00) / 2, ty + tcg + (w0 - w00) / 2, -tz ], n = 1, dxyz=[h00, w00, t00], rgb="cyan")
{
  trr(tr) astack(n, [ 0, 0, t01 ]) color(rgb, .5) roundedCube(dxyz, 3, true);
}

// a stack of blue cards (in vbox)
module card2(tr = undef, n = 1, dxyz=[h0, w0, t00], rgb="blue")
{
  tr = def(tr, [tz, ty + tcg, tw, [0, -90, 0]]); // (bw-w0)/2
  card(tr, n, dxyz, rgb);
}

// box for setup (Events, VICI, markers, chips) cards:
// vt: interior box depth (~ t01 * number of cards + 2*t0) x-extent
// vw: interior box width (long dimension of card + 2*t0)  y-extent
// vh: interior box height (short dimension of card + bottom(t0) + top(3mm)) z-extent
// txyz: wall thickness (t0) [tx, ty, tz] 
// ambient: tcg thickness of cardguide
// total width: [vt + 2 * tx, vw + 2 * ty + 2 * tcg, vh + tz]
module vbox(loc = loc, vt0 = bt, vw0 = bw, vh0 = bh, txyz = t0) // txyz=[tz, ty, tw]
{
  ta = is_list(txyz) ? txyz : [txyz, txyz, txyz];
  tx = ta.x; ty = ta.y; tz = ta.z;
  vt = vt0 + 2 * tx; // external x-extent (card thickness)
  vw = vw0 + 2 * ty; // external y-extent (card width)
  vh = vh0 + 1 * tz; // internal + back wall
  echo("------ vbox: vt= ", vt, "vw=", vw, "vh=", vh);
  // vt: interior x-extent
  // tcg: width of each cardguide
  // ambient:
  module cardGuide(vt = vt0+pp, wcg = tcg) {
    // wcg: size of inset; squeeze
    // h0: height of flat part
    // h1: height of taper part
    // a: angle of taper
    wcg = def(wcg, 2); 
    h0 = 4; h1 = 7; a = 7;
    vh2 = vh * .7;
    // TODO: the trig to calc height of green cube (depends on angle a)
    difference() {
      translate([wcg/2 + p, 0, vh2]) color("green") cube([wcg, vt, h0 + 4 * h1], true);
      trr([wcg, 0, vh2+h1+h0, [0, -a, 0]]) color ("pink") cube([wcg, vt+pp, h0 + 2 * h1], true);
      trr([wcg, 0, vh2-h1-h0, [0, a, 0]]) color ("pink") cube([wcg, vt+pp, h0 + 2 * h1], true);
    }
  }
  // slotify the walls:
  vl = vt;
  sw = vw*.7;      // width of slot 
  dh = vh*.8;      // depth of slot (below the radius of tray)
  sr = min(5, dh/2, sw/2); // radius of slot
  hwtr0 = [dh, vw -2*ty, 2*tz, .1]; // ]height, width, translate, radius]
  hwtr1 = [dh, sw      , 2*tz, sr]; // ]height, width, translate, radius]
  ss = false;   // show slot

  { 
    // slotted box with card guides:
    slotify(hwtr0, [00+tx/2, vw/2, vh-(dh/2-sr)], 1, 0, ss) // tray bottom
    slotify(hwtr1, [vl-tx/2, vw/2, vh-(dh/2-sr)], 1, 3, ss) // outer slot
    box([vt, vw, vh], ta);
    if (w0 > 99) {
    translate([vt/2,  0+ty, 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vt/2, vw-ty, 0 ]) rotate([0,0,-90]) cardGuide();
    }
    atrans(loc, [undef, [bt - tz, 0, 0], 1, 1]) card2(undef, 11); // in the vbox
  }
}

// tray is a rounded tube (kut) with end caps [from civo_tray]
// size: [x: length, y: width_curved, z: height_curved] external, txyz fills inside.
// rs: radii of scoop for tray
// rc: radii of caps  [bl, tl, tr, br] (2)
// k0: cut_end default: cut max(top radii) -> k
// txyz: (t0 -> [t0, t0, t0])
module tray(size = 10, rs = 2, rc = 0, k0, txyz = t0) {
  rs = def(rs, 2);
  rc = def(rc, 0);

 ta = is_list(txyz) ? txyz : [txyz, txyz, txyz];
 s0 = is_list(size) ? size : [size, size, size]; // tube_size
 s = [s0.x, s0.y, s0.z];
 rm = is_list(rs) ? max(rs[1], rs[2]) : rs;   // round_max of tl, bl
 k = is_undef(k0) ? -rm : k0;
//  echo("tray: rs =", rs, "ta =", ta);
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s.z, s.y, s.x], rs, k, ta);

 // endcaps
 hw0 = [s.z, s.y, 0];
 hwx = [s.z, s.y, s.x-ta.x];
 div(hw0, rc, k, ta.x);
 div(hwx, rc, k, ta.x);
}

dieSize = 12;
module die(trr = [0,0,0], dieSize = dieSize) {
  trr(trr)
  color("red") roundedCube(dieSize);
}

// bw: allocated width (cols)
// bh: allocated height (rows)
// snr: [cs, nc, nr]
// cs: child size; begin grid @ (cs, cs+1)
// nc: columns
// nr: rows
module partsGrid(bw, bh, snr=[5, 10, 20]) {
  snr = def(snr, [5, 10, 20]);
  cs = snr[0]; nc = snr[1]; nr = snr[2];
  xi = (bw - cs) / nc;
  x0 = (bw - cs - xi * (nc - 1) + cs)/2;
  xm = bw - cs;
  yi = (bh - cs) / nr;
  y0 = (bh - cs - yi * (nr - 1) + cs)/2;
  yl = bh - cs;
  translate([0, 0, t0])
  gridify([x0, xi, xm], [y0, yi, yl], 2) cube([cs, cs, cs], true);
}

// h: height of lid (h0)
// w: width of a card (w0)
// lt: thickness of lid (lt)
// rt: radius [total] of hinge (hr + dr = 3)
// ang: angle to block rotation
// zh: ambient z-coord of hinge
module lid(loc = loc, h = h0, w = w0, lt = lt, rt = rt, ang = ang ) {
  et = -1.4;// .6;    // extend length of lid to reach end of tray
  ym = zd + rt + sep; // push out to clear (zd + rt + sep = 7.3)
  xm = hh + sep - ty;        // from exterior to inner ball; sep = .2, th = 1.2 !
  wxm = w - 2*xm;            // width inside hinge
  lh = h - ym + et;          // lid height - green part [+ et to clear top edge when closed]
  fl = (rt+.5)/2;             // feet length/2
  lhh = lh - 3 + .3;         // TODO: correct formula for '2.7' axis of hinge; zh = 11.9
  echo("lid: [zh, rt, ht, sep, wxm, xm, ym, lh, lhh] =", [zh, rt, ht, sep, wxm, xm, ym, lh, lhh]);
  // czz: cut slot for card depth (so: czz > t01 sleeved-card thickness)
  // cz: extent of 'hook' in z dir; beyond czz; (overhang when printing!)
  // cx: extent of 'hook' in x dir
  module clip(czz = t01+.9, cz = 1, cx = ty+2*tcg+.5) {
    dc = 0; // cut a bit wider than card
    lh0 = cl;
    // cl: length of clip along the lid; w0 = tl-2*ty-2*tcg; lid-width: bw = w0+2*tcg; bw = tl - 2*ty; tl = bw+2*ty
    differenceN(1) 
    {
      trr([0 -ty, lh0  , -p ]) cube([bw+2*ty, cl,    czz+cz+lt], false); // base clip
      trr([cx-ty, lh0-p, lt]) cube([bw+2*ty-2*cx, cl+pp, czz+cz+pp], false); // cut center
      trr([0 -dc, lh0-czz*.6, -czz*2.5, [90,0,0,[0,czz,cl]]]) divXY([bw+2*dc, czz*4, 0+pp], czz*1.5, undef, cl*1.3);
    }
  }

  // offset from tray: (hy & zd are both 4.1; zh = (15-4.1) = 11.9)
  trr([ty, -zh -lhh, 0]) {
    trr([0, -ym, 0])
    differenceN(2)
    {
      color ("green") cube([w, lh, lt]);                // base lid
      // trr([-ty, ce, 0 ]) cube([tl, cl, lt], false);    // clips
      clip();
      partsGrid(w, lh, w > 60 ? [8, 6, 5]: [8, 2, 2]); // perforation
    }

    // hinge connection & "tray"
    differenceN(4) {
      trr([xm, lh-ym, 0])  cube([wxm, ym-hr, lt], false); // tang (extend to support angle block)
      trr([xm, lh-rt, dr+3, [-90-ang,0,0]]) trr([0,.22,.42]) cube([wxm, 2*rt, 1*rt], false); // angle block
      trr([w/2, lh-rt, dr+3, [50,0,0]]) trr([0,0,fl]) cube([wxm, 1.5*dr, 2*fl], true); // feet
      trr([w/2, lhh, hy, [0, 90, 0]]) cylinder(wxm, rt, rt, $fn=30, center = true); // cyl block
      //--- cut center, and bottom of angle
      trr([w/2, lh-ym/2+p, 7]) cube([bwc, 16, 18], true); // cut center of blocks & tang
      trr([w/2, lh-ym, -2 -p]) cube([tl, ym * 2, 4], true); // cut bottom of ang block 
    }
  atrans(loc, [undef, [0, 0, 2, [0, 0, 0]], 1]) // tilt 2-degrees
    card([(bw-w0)/2, zd-ht, 0], 1, [w0, h0, t01]);//lh/2-ym+rt -w0/2
  }
}
ce = 0;     // clip offset
cl = 2.7;   // clip length
cf = .155;  // empirical fudge for clip/hole (reduce friction b/c not square inside corner)
ch = ce + cl + cf; // hole length for clip
chd = 2;    // under cut (over close lid)

module trayAndLid(loc=loc) {
  cx = tl - dz * 2;
  cz = zd+hr+dr+sep;       // clearance in back wall for lid
  cc = zd - (hr + dr) +2.2; // cut top corner for hinge clearance
  bx = 0; //2 * hh + 2 * sep;
  by = 1.5;   // lid blocker  (beyond tw)
  bz = (ht - zd) - (hr+dr) - sep;   // lid blocker (8.9)
  kz = lt + 2;  // cut at front edge of scoop; for lid warp

  mnt0 = [hr, -90, 0, 0];
  mnt1 = [hr,  90, 0, 0];
  sep = .2; et = -1.4;
  lh0 = 0;//(h0 - (zd + rt + sep) + et)/4;
  sz = t01+.9 + 1 + lt + f;  //lt+chd;// 
  rotate([90, 0, 0])
  {
    differenceN(1) {
      color("blue")
      tray([tl, bh+tw, zt], [0, rs, 1, 1], 0, undef, [ty, tw]);
      // back side slot for lid clearance:
      trr([dz, -pp, zh - cz + zd ]) cube([cx, tw+ by+2*pp, cz + p]);
      // top corner for lid clearance:
      trr([ty-p, -pp, zh - cc + zd ]) cube([tl-2*ty+pp, 2*tw + 2*pp, cc + pp]);
      // front edge: extra space because lid may warp down
      trr([ty, bh-tw, ht-kz+pp ]) cube([tl-2*ty, 2*tw, kz], false);
      // hole for front clip: .2 overcut
      *trr([-p, th-ch+p, ht-(lt + chd)+pp ]) cube([tl+pp, ch+pp, lt + chd], false);
      // hole for lid clip:  (end of lid: h0+1.9)
      trr([0-p, h0+1.9-2*cl-cf+p  , ht-sz+pp ]) cube([tl+pp, 2*cl+cf+pp, sz+pp], false); // base clip
    }
    trr([ 0, hy, zh, [0,  90, 0]]) hinge(dz, hr, dr, mnt0, sep );
    trr([tl, hy, zh, [0, -90, 0]]) hinge(dz, hr, dr, mnt1, sep );
    difference() {
      trr([tl/2  , by/2 -p + tw, bz/2]) cube([tl-2*bx, by, bz], true); // angle stop block
      trr([tl/2+p, by/2 +p + tw, bz/2]) cube([bwc+pp, by+pp, bz+pp], true); // back wall cut
    }
    color("red") 
    for (x = [0: (dieSize+2.8) : bw*.4]) {
      trr([bw/2+x, tw, tz-pp]) cube([ty, bh-rs+6, 1.2]);
      trr([bw/2-x, tw, tz-pp]) cube([ty, bh-rs+6, 1.2]);
      atrans(loc, [undef, [0,0,0],1,1,0,0,1])
        die([bw/2-x+1.75, tw+1, tz]);
    }
  }
  // AND lid:
  atrans(loc, lidtrans)
  lid(loc, th, bw, lt );

}

// allow for 12 cards per color, * .625 = 7.5mm
tw = 1.4;   // thickness of tray back wall (in print z-coord); tray-x
ty = 1.1; // thickness of walls, tray endcap (in print y-coord);
tz = 1;   // thickness of tray bottom 
tcg = sample ?  1.15 : (95-w0-2*ty)/2;  // inset for cardguide (bw+2*ty NTE tl = 95)
bw = w0 + 2 * tcg; // interior width of box (y-extent @ loc = 2)
bwc = bw * .7;  // center cut (backwall, hinge)
ot = .5;       // vbox extends over card. still fit upright in 70mm packing box
bh = h0 + ot ; // interior height of vbox (short dimension of card)
th = bh + tw;  // total exterior "height" (short dimension of card) of box: [tl, th]
// holds 11.5 std cards OR: 7-9 std + 3-5 thin cards
vbd = 6;   // 11.5 * t01; 3 * (ht+vbd) = 66; fits beside maps! 
lt = 1.8;   // lid thickness

tt = 1;    // tw or tz
tl = bw + 2 * ty; // total y-length: box & lid (width of card + 2*ty + 2*tcg)

ht = dieSize + .6 + tz + lt;   // height of tray
rs = 18;   // radius of scoop
zt = ht+rs;// z-extent before kut

hh = 3;    // hinge height for each of socket and ball
hr = 1.5;  // hinge radius (cone)
dr = 1.5;  // hinge thickness (around cone) radius total: 
rt = hr + dr;
hy = 4.1;  // hinge z (pre rotation, the y-coord of axle)
sep = .2;

zd = 4.1;         // down from top of tray (coincidentally? == hy)
zh = ht - zd;     // z for hinge
dz = 3;           // block size of hinge
// hinge([ 0, hy, zh, [0, 0, 0]], 3, undef, undef, [1, 180, 90], .2 );

// location of axle in lid space: sum of translations
ar = [-3, -zh, hy]; // 3 = ym = (ht - zh) + rt + sep;
ang = 22;  // angle to block lid/hinge

lidtrans = [
    [0, 0, 0], 
    0, 
    [0, 0, 0, [ang, 0, 0, ar]], 
    [0, 0, 0, [-90.0, 0, 0, ar]], 
    undef, 
    [0, 0, 0, [ang, 0, 0, ar]], 
    [0, 0, 0, [85, 0, 0, ar]],
    undef, 
    undef,
    ];

boxtrans = [
  [0, 0, 0, [  0, 0, 0]], // 0
  [0, tl, 0, [-90, 0, -90]], // 1
  1,
  1,
  0, 
  0,
  1,
  1, 
  undef,
  ];

// TODO: grey-tray (64 dice, 12 player blocks, hands, credits)
// layout in box
module wholebox(loc = loc) {
  if (!sample)
  trr([tl, -tz, 0, [0, 0,  90]]) vbox(loc, vbd, bw, bh, [tz, ty, tw]);
  trayAndLid(loc);
}

atrans(loc, boxtrans) atrans(loc, [undef, [0,0,0], 1, 1, 1, 1, 1])
  trr(ar) color("cyan") cube([tl+10, .05, .05]); // hinge axis

echo("toplevel: [tl, bw, bh, bh+tw, ht, vbd, ht+vbd, tcg, tw, ty, tz] =\n ---- toplevel:  ", [tl, bw, bh, bh+tw, ht, vbd, ht+vbd, tcg, tw, ty, tz]);
differenceN(1,1) {
  atrans(loc, boxtrans)
    wholebox();
  atrans(loc, [undef, [-tw, -5, -vbd-3*ty],1,0,0,0,1])
    cube([bw+2*tw, 8, ht + vbd + 4*ty]); // cutaway view
}

loc = 0;

// 0: print
// 1: view w/dice & card @ 90
// 2: view w/dice & card @-25
// 3: view w/dice & lid  @ 0
// 4: print - no lid 
// 5: print - lid open?
// 6: view w/dice & lid @ -90
// 7: view - no lid
