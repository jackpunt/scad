use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 2; // base & wall thickness
t1 = t0 + .4; // side wall for camber 
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
sample = false;

// four per-player trays
// 2 trays for market cards; tray for tech cards
// tray for resources
// tray for {1, 2, 3} hex tokens, VP flags, first-player

// dimension of sleeved cards:
l0 = 90;
w0 = 64; // w00 + 2mm (sleeves) + 2mm (slack); retain 60.4 for slider compat

// house turned on side in box:
house_dim = [33, 12, 25];

// space for sleeved card with 2mm slack:
// short side of card (66)
w00 = w0 + 2; 
// long side of card (92)
l00 = l0 + 2;

t2 = 1;       // thickness for alt boxes
ty = t2;      // thick in y dir (short side wall)
tz = t2;      // thick in z dir (bottom of box)

tcg = sample ?  1.15 : (95-w0-2*ty)/2;  // inset for cardguide (wi+2*ty NTE tl = 95)

nc = 10;      // number of cards in box
t01 = 6.25/12; // = .52mm; thickness when stacking sleeved cards (compressed)
bt = nc * t01 + 2 * t2;  // box thickness [total for nc cards]

wi = w0 + 2 * tcg; // interior width of box (y-extent @ loc = 2)
bw = wi + 2 * ty;  // card box width

ot = 1.5;      // vbox extends over card. still fit upright in 70mm packing box
hi = w0 + ot ; // interior height of vbox (short dimension of card)
bh = hi + t2;  // card box height

// a stack of cyan cards (on lid) - pro'ly from chaos orientation; BYO 'tr'
// tr: offset card 
// x: short dim of card (h00); y: long dim of card (w00); z: thickness (t00)
module card(tr = [ tw +  (h0 - h00) / 2, ty + tcg + (w0 - w00) / 2, -tz ], n = 1, dxyz=[h00, w00, t00], rgb="cyan")
{
  trr(tr) astack(n, [ 0, 0, t01 ]) color(rgb, .5) roundedCube(dxyz, 3, true);
}

// (from civo?) cards:
// loc: for atran()
// vt: interior box depth (~ t01 * number of cards + 2*t0) x-extent
// vw: interior box width (long dimension of card + 2*t0)  y-extent
// vh: interior box height (short dimension of card + bottom(t0) + top(3mm)) z-extent
// txyz: wall thickness (t0) [tx, ty, tz] 
// ambient: tcg thickness of cardguide
// total width: [vt + 2 * tx, vw + 2 * ty + 2 * tcg, vh + tz]
module vbox(loc = loc, vt0 = bt, vw0 = wi, vh0 = hi, txyz = t2) // txyz=[tz, ty, tw]
{
  ta = is_list(txyz) ? txyz : [txyz, txyz, txyz];
  tx = ta.x; ty = ta.y; tz = ta.z;
  vt = vt0 + 2 * tx; // external x-extent (card thickness)
  vw = vw0 + 2 * ty; // external y-extent (card width: bw)
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
    slotifyX(hwtr1, [vl-tx/2, vw/2, vh-(dh/2-sr)], 1, 3, ss) // outer slot
    box([vt, vw, vh], ta);
    if (w0 > 99) {
    translate([vt/2,  0+ty, 0 ]) rotate([0,0, 90]) cardGuide();
    translate([vt/2, vw-ty, 0 ]) rotate([0,0,-90]) cardGuide();
    }
    atrans(loc, [undef, [bt - tz, 0, 0], 1, 1]) card2(undef, 11); // in the vbox
  }
}

// make finger slots on both sides of box...
module dual_slots(h, sw, dx1, dy, ss = false) {
  tabh = 20;
  sr = sw/2;
  if (len(dy) > 1) {
    slotifyY2([h, sw, t0*2], [dx1, dy[0]-1, -sr], undef, 1, ss)
    slotifyZ([tabh, sw, t0*2], [dx1, dy[0]-0, 1], 2, undef, ss)
    slotifyY2([h, sw, t0*2], [dx1, dy[1]-1, -sr], undef, 1, ss)
    slotifyZ([tabh, sw, t0*2], [dx1, dy[1]-0, 1], 2, undef, ss)
    children();
  } else {
    slotifyY2([h, sw, t0*2], [dx1, dy[0]-1, -sr], undef, 1, ss)
    slotifyZ([tabh, sw, t0*2], [dx1, dy[0]-0, 1], 2, undef, ss)
    children();
  }
}

// h: height of wall
// sw: slot width
// tr: [dx, dy]
// dy: translate on y axis
// dx: translate on x axis
module card_slot(h, sw, tr, ss = false) {
  tabh = 20;
  sr = sw/2; // slot radius
  dx = def(tr[0], t0/2);
  dy = def(tr[1], 20);
  slotifyX2([h, sw, t0*2], [dx, dy, -sr], undef, 1, ss)
  slotifyX([tabh, sw, t0*2], [dx, dy, 1], 3, undef, ss)
  children();
}

divw = 1;  // width of short divider between houses
// tray_2:  t1 + w00 + t1 + house_dim.x + divw + house_dim.x + t1;
tray_w = w00 + 3 * t1 + 2 * house_dim.x + divw;  // ~ 140
tray_l = l00 + 2 * t1;     // 96 > (84 = 7 * house_dim.y)

module player_tray(w = tray_w, l = tray_l) {
  h = house_dim.z + t0;
  sw = 18;
  dx1 = house_dim.x/2+t0;
  dy = [t0, l];
  house_w = 2 * house_dim.x + divw;
  card_w = w - house_w - t1;

  // suitable for card boxes:
  card_slot(h, sw, [t0/2, l/2])
  box([w, l, h], t1 ); // [x=w, y=l, z=h]
  div([h, l, t1 + w00], 0, 0, t1); // between cards * villages
  div([10, l, t0 + w00 + t0 + house_dim.x + divw/2], 0, 0, divw); // between villages

  // translate(v = [w/2, l/2-l*1.1, h/2]) 
  // vbox([w, l, h], t0, 1);

}

// box length for storing Village pieces:
bl = 63.5;  // can fit 4 boxes in 288 mm
module player_box() {
  translate([bl, 0, 0]) union() {
  vbox();
  trr([t2-bl, 0, 0]) box([bl, bw, bh]);
  }
}
module four_box() {
  for (xi = [0: 3]) {
    trr([xi * (bt+bl+t2+.1), 193, 0 ]) player_box();
  }
}


// xyz: size of cube: [w0, 40, 4]
// tr: translate: [0, tr, t2]
// r: rotate angle: (-5)
module wedge(xyz, tr = 20, r = -3) {
  x = def(xyz.x, w0);
  y = def(xyz.y, 20);
  z = def(xyz.z, 4);
  ra = is_list(r) ? r : [r, 0, 0];
  tra = is_list(tr) ? tr : [0, tr, t2, ra];
  difference() {
    trr(tra) cube([x, y, z]);
    trr([tra.x-p, tra.y, -z]) cube([x+pp, y*1.1, z]);
  }
}
module tech_box(w = w0, l = l0) {
  bh = bt * 1.2 + t0;
  dual_slots(bh, 18, w/2, [t0, l])
  box([w, l, bh], [t2, t2, t0]);
  // wedge();
}
module three_tech(w = w0, l = l0) {
  for (xi = [0 : 2]) {
    trr([xi * (w), 0, 0]) 
    tech_box(w, l);
  }
}
module more_techs(w = w0, l = l0, n = 3) {
  for (xi = [0 : n-1]) {
    trr([l + xi * (l+.2), 0, 0, [0, 0, 90]]) three_tech(w, l);
  }
}

loc = 0;
// trr([200, 0, 0]) player_tray(tray_w, tray_l);
four_box();
// tech_box();
more_techs(w0, l0, 3);

// TODO: overlay 'map' & booklet
