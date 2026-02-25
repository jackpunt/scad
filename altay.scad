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

box_s = 285; // with .6 mm slack
box_z = 70;  // inner height of box

// plain card: 63 x 68
// sleeved card: 65 x 69
// l0: inner length of player tray
ll = (box_s - 6*t1 - 2*.3)/3; // ll = 90; ll / house_dim.y = 7.5
ww = (209 - 4*t0 - 0)/3; // mtray_l = ~209
l0 = 88; // extend tray, room for 7.5 houses; ~ 2 * (mtray_h = 3 * (w00 + t0) + t0);
w0 = 65; // w00 = w0 + slack;

// house turned on side in box:
house_dim = [33, 12, 25];

// space for sleeved card with 2mm slack:
// short side of card (67)
w00 = w0 + 2; 
// long side of card (ll = 90)
l00 = l0 + 2;
echo("ww=", ww, "w00=", w00, "ll = ", ll, "l00=", l00);

t2 = 1;       // thickness for alt boxes (vbox + player_box)
ty = t2;      // thick in y dir (short side wall)
tz = t2;      // thick in z dir (bottom of box)

tcg = sample ?  1.15 : (95-w0-2*ty)/2;  // inset for cardguide (wi+2*ty NTE tl = 95)

function tnc(nc) = nc * t01;

nc = 10;      // number of cards in vbox (& mkt_tray)
t01 = 6.25/12; // = .52mm; thickness when stacking sleeved cards (compressed)
bt = tnc(nc) + 2 * t2;  // vbox thickness [total for nc cards]
tth = bt * 1.2 + t0;     // mkt_tray height

wi = w0 + 2 * tcg; // interior width of vbox (y-extent @ loc = 2)
bw = wi + 2 * ty;  // card box width

// player box:
ot = 1.5;      // vbox extends over card. still fit upright in 70mm packing box
hi = w0 + ot ; // interior height of vbox (short dimension of card)
bh = hi + t2;  // card box height

// a stack of cyan cards (on lid) - pro'ly from chaos orientation; BYO 'tr'
// tr: offset card stack
// x: short dim of card (h00); y: long dim of card (w00); z: thickness (t00)
module card(tr = [ tw +  (h0 - h00) / 2, ty + tcg + (w0 - w00) / 2, -tz ], n = 1, dxyz=[h00, w00, t00], rgb="cyan")
{
  trr(tr) astack(n, [ 0, 0, t01 ]) color(rgb, .5) roundedCube(dxyz, 3, true);
}

house_names = ["RED", "YELLOW", "GREEN", "BLUE"];
house_colors = ["red", "yellow", "green", "#40acff"];

// astack of house sized cubes, colored per-player
module house(pi = 0, n = 1) {
  hc = house_colors[pi];
  dx = [2, 4, 6, 1][pi]; // houses are a bit smaller than house_dim.x
  hx = house_dim.x - dx;
  astack(n, [0, house_dim.y + .1, 0])
  color(hc, .6)
  trr([dx/2, 0, 0]) cube([hx, house_dim.y, house_dim.z]);
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

// player box length for storing Village pieces:
pbl = 62.79;  // can fit 4 boxes in ~285 mm
// echo("pbl ~~", (box_s-1)/4 - (bt+t2), 4*(pbl+bt+t2));

// conjoined vbox & cubic box for houses
// pi: player_id: 0..3
module player_box(pi = 0) {
  xy = amul([[0, 1, 0], [1, 1, 0], [2, 1, 0], [3, 1, 0]][pi], [bt + t2 + pbl+.1, 193, 1]);
  trr(xy)
  translate([pbl, 0, 0]) union() {
    vbox();
    trr([t2-pbl, 0, 0]) box([pbl, bw, bh]);
  }
}

// make finger slots on both sides of box...
module dual_slots(h, sw, dx1, dy, ss = false) {
  tabh = 20;
  sr = sw/2;
  if (len(dy) > 1) {
    slotifyY2([h,   sw, t1*2], [dx1, dy[0]-1, -sr], undef, 1, ss)
    slotifyZ([tabh, sw, t1*2], [dx1, dy[0]-0,   1], 2, undef, ss)
    slotifyY2([h,   sw, t1*2], [dx1, dy[1]-1, -sr], undef, 1, ss)
    slotifyZ([tabh, sw, t1*2], [dx1, dy[1]-0,   1], 2, undef, ss)
    children();
  } else {
    slotifyY2([h,   sw, t1*2], [dx1, dy[0]-1, -sr], undef, 1, ss)
    slotifyZ([tabh, sw, t1*2], [dx1, dy[0]-0,   1], 2, undef, ss)
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
  dx = def(tr[0], t1/2);
  dy = def(tr[1], 20);
  slotifyX2([h, sw, t1*2], [dx, dy, -sr], undef, 1, ss)
  slotifyX([tabh, sw, t1*2], [dx, dy, 1], 3, undef, ss)
  children();
}

divw = 1;  // width of short divider between houses
// ptray_w:  t1 + w00 + t1 + house_dim.x + divw + house_dim.x + t1;
ptray_w = w00 + 3 * t1 + 2 * house_dim.x + divw;  // ~ 140
ptray_l = l00 + 2 * t1 + 1;     // 96 > (84 = 7 * house_dim.y)
ptray_h = house_dim.z + 1 + t0; // z-height of player trays (t0 base + t0 map_indent)

// w: outer width-x (ptray_w)
// l: outer length-y (ptray_l)
// pi: player id (0)
// nh: number of houses in tray (0)
module player_tray(pi = 0, w = ptray_w, l = ptray_l, nh = 0) {
  w = def(w, ptray_w);
  l = def(l, ptray_l);
  xy = amul([[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 1, 0]][pi], [w+.1, l+.1, 1]);
  h = ptray_h + 2; // extend for map
  sw = 18;        // slot width
  house_w = 2 * house_dim.x + divw; // interior width of house side
  card_w = w00; // interior of card side: total - house_interior - main_div = w00
  name = house_names[pi];

  // rotate right-side boxes:
  r0 = pi >= 2 ? [0, 0, 180, [w/2, l/2, 0]] : [0, 0, 0];
  xyr = [xy.x, xy.y, xy.z, r0];
  trr(xyr)
  differenceN(5) {
    trr([t1+card_w+t1+.1,                      t1+.2, 0]) house(pi, nh);
    trr([t1+card_w+t1+.1 + house_dim.x + divw, t1+.2, 0]) house(pi, nh);
    color(house_colors[pi])
    card_slot(h, sw, [t1/2, l/2])
    box([w, l, h], [t1, t1, t0] ); // [x=w, y=l, z=h]
    div([h, l, t1 + card_w], 0, 0, t1); // between cards * villages
    div([10, l, t1 + card_w + t1 + house_dim.x], 0, 0, divw); // between villages
    // engrave:
    trr([w00 + house_w/3, l/2, t0-.5, [0, 0, 90]]) linear_extrude(height = 1.5) 
    text(name, halign = "center", size=6, font="Nunito:style=Bold");
  }
}

// player_tray in 2 X 2 array:
module four_tray(nh = 0) {
  difference() {
  union() {
    player_tray(0, undef, undef, nh);
    player_tray(1, undef, undef, nh);
    player_tray(2, undef, undef, nh);
    player_tray(3, undef, undef, nh);
  }
  map_block();
  }
}

// map dimensions:
mapw = 240;
mapl = 171;
mapz = 10+2;   // +2 for rule book
module map_block() {
  x0 = (2 * ptray_w - mapw) / 2; // center over four trays
  y0 = (2 * ptray_l - mapl) / 2; // center over four trays
  z0 = ptray_h;
  trr([x0, y0, z0]) 
  color("tan", .3)
  cube([mapw, mapl, mapz]);
}



// xyz: size of cube: [w00, 40, 4]
// tr: translate: [0, tr, t1]
// r: rotate angle: (-5)
module wedge(xyz, tr = 20, r = -3) {
  x = def(xyz.x, w00);
  y = def(xyz.y, 20);
  z = def(xyz.z, 4);
  ra = is_list(r) ? r : [r, 0, 0];
  tra = is_list(tr) ? tr : [0, tr, t0, ra];
  difference() {
    trr(tra) cube([x, y, z]);
    trr([tra.x-p, tra.y, -z]) cube([x+pp, y*1.1, z]);
  }
}

mbh = bt * 1.2 + t0 +.35;
module mkt_box(w = w00, l = l00, ta = [t0, t0, t0]) {
  bxyz = adif([w, l, mbh], amul(ta, [-2, -2, 0])); // add 2 wall thichness, 0 floor
  dual_slots(mbh, 18, bxyz.x/2, [t0, bxyz.y])
  box(bxyz, ta);
  // wedge();
}

mtray_l = 3 * (w00 + t0) + t0;
mtray_w = l00 + 2*t0;
echo("mtray_l=", mtray_l);
module mkt_tray(w = w00, l = l00) {
  astack(3, [0, w + t0, 0]) 
  trr([l + 2 * t0, 0, 0, [0, 0, 90]]) mkt_box(w, l);
}

module more_mkts(w = w00, l = l00, n = 3, t = t0) {
  tw = (l + t0) + t0 + .3;
  astack(n, [tw, 0, 0]) mkt_tray();
}

ntc = 28;
tbh = tnc(ntc) * 1.2 + t0;   // tech box height
module tech_box(w = w00, l = l00, ta = [t0, t0, t0]) {
  bxyz = adif([w, l, tbh], amul(ta, [-2, -2, 0])); // add 2 wall thichness; 0 floor...
  dual_slots(tbh, 18, bxyz.x/2, [t0, bxyz.y])
  box(bxyz, ta);
}

// w: inside width (w00)
// l: inside length (w00)
// n: astack of n (3)
// t: thickness of walls & base (t0)
module tech_tray(w = w00, l = l00, n = 3, t = t0) {
  astack(n, [w + t0, 0, 0], undef, house_colors) tech_box(w, l);
}
// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
// divs: [divx0, divx1, ...]
// t: (t0) thickness of tube
module tray(size = 10, rt = 2, rc = 2, k0, divs = [], t = t0) {
  s = is_list(size) ? size : [size,size,size]; // tube_size
  rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
  k = is_undef(k0) ? -rm : k0;
  translate([s[0], 0, 0])
  rotate([0, -90, 0])
  roundedTube([s.z, s.y, s.x], rt, k, t);

  if (!is_undef(divs) && len(divs) > 0)
    for (dx = divs) {
      div([s.z, s.y, dx], rc, k, t);
    }
  // endcaps
  for (x = [0, s.x]) {
    div([s.z, s.y, x], rc, k, t);
  }
}

stackh = mbh + ptray_h + mapz;
echo("stackh=", stackh, ptray_l);

rtray_w = 3 * (w00 + t0); // res_tray adds extra t0 endcap
rtray_l = box_s - mtray_l + 1.3; 
rtl = 1;               // res_tray lid thickness
rtl2 = 2 * (rtl+f);    // thickness of lid * 2 - fudge
rtray_h = stackh - mbh - tbh - rtl -.1;
rtt = 1.6;             // thickness of res_tray walls

// 6 bin tray for resources & coins
// res_w: width (x) of tube, tray gets extra t-sized endcap
// res_l: length (y) of tube, 
module res_tray(res_w = rtray_w - rtl2, res_l = rtray_l - rtl2) {
  res_h = rtray_h;
  rad = res_h * .7;
  ndiv = 5;
  dx = res_w / (ndiv+1);
  dl = .6;
  echo("res_tray: rtray_l=", rtray_l, " res_l=", res_l, "rtl=", rtl);
  echo("res_tray: dx=", dx, "res_l*dl", res_l*dl, "res_h=", res_h, "dx=", dx, 
       "cubic=", (dx-1)*(res_l-rtt)*dl*(res_h-rtt));
  divs = [ for (i = [0 : ndiv] ) i * dx ];
  tray([res_w, res_l, 2 * res_h], [rad, 8, rad, rad], 2, -res_h, divs, rtt);
  trr([0, dl * res_l, 0]) cube([res_w - dx, 1, res_h]);
}
module res_lid(res_w = rtray_w + rtt, res_l = rtray_l, res_h = rtray_h - mbh + .5) {
  echo("res_lid: res_l=", res_l, "rtl=", rtl);
  color("lightblue")
  difference() 
  {
    box([res_w, res_l, res_h], rtl);
    cubesGrid(bw = res_w, bh = res_l, stt = [5, 2, 2], t = 3);
  }
}

// expect to make 4 of these:
module spacer(w = (box_s-1)/2 , l = (box_s-1)/2, h = (box_z - stackh) ) {
  cs = 11.5;
  d = 1.2;
  difference() {
    cube([w, l, h]);
    cubesGrid(bw = w, bh = l, stt = [cs, d, d], t = h  );
  }
}
module four_space(w = (box_s-1)/2 , l = (box_s-1)/2, h = (box_z - stackh)) {
  astack(2, [w, 0, 0])
  astack(2, [0, l, 0])
  spacer();
}

// loc: 0=whole stack, 1=mkt_trays, 2=tech_tray, 3 = four_tray, 4 = four_tray(7), 5 = res_tray
loc = 6;
y1 = ptray_l * 2 + .3;  // maybe displays beyond box_s?
y2 = mtray_l - rtl + .3;

// trr([200, 0, 0]) player_tray(ptray_w, ptray_l);
atrans(loc, [[0, 0, tth+p], undef, undef, [0, 0, 0], 3]) four_tray([7, 0, 0, 0, 7][loc]);
atrans(loc, [[0, 0, tth+p], undef, undef]) map_block();
atrans(loc, [[0, 0, 0], 0, undef, undef]) more_mkts();
atrans(loc, [[mtray_l, y1, rtray_h+rtl, [0, 0, 90]], 0, undef, undef]) mkt_tray(); //[0, 0, 90, [mtray_w/2, mtray_l/2, 0]]

atrans(loc, [[0, y1, stackh - tbh], undef, [0, 0, 0], undef]) tech_tray();
atrans(loc, [[0 + rtl2/2, y2 + rtl2/2, 0], undef, undef, undef, undef, 0]) res_tray();
atrans(loc, [[0,          y2,  rtl + .1, [180, 0, 0, [0, rtray_l/2, rtray_h/2]]], 
              undef, undef, undef, undef, 0, 0]) res_lid();
// tweaked so res_lid overhangs mkt_tray; extending rtray_l by rtl
// increase ptray_h by 1, so increase rtray_h by 1; more cubic mm in res_tray.
atrans(loc, [[0, 0, stackh], [-box_s/2, -box_s/2, 0]]) four_space();
