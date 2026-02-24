use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 2; // base & wall thickness
t1 = t0 + .4; // side wall for camber 
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

// four per-player trays
// 2 trays for market cards; tray for tech cards
// tray for resources
// tray for {1, 2, 3} hex tokens, VP flags, first-player

// dimension of sleeved cards:
l0 = 90;
w0 = 64; // w00 + 2mm (sleeves) + 2mm (slack); retain 60.4 for slider compat

// house turned on side in box:
house_dim = [33, 12, 25];

// space for sleeved card:
w00 = w0 + 2;
l00 = l0 + 2;

module vbox(dim=[10, 10, 10], t=t0, dt = undef) {
  w = dim.x;
  l = dim.y;
  h = dim.z;
  dt = def(dt, t/2);
  linear_extrude(height = h, center = true, scale = [1+2*dt/w, 1 + 2*dt / l]) 
  difference() {
    square([dim.x, dim.y], true);
    square([dim.x - t0, dim.y - t0], true); 
  }
}

// make finger slots on both sides of box...
module dual_slots(h, sw, dx1, dy) {
  tabh = 20;
  sr = sw/2;
  slotifyY2([h, sw, t0*2], [dx1, dy[0]-1, -sr], undef, 1, false)
  slotifyZ([tabh, sw, t0*2], [dx1, dy[0]-0, 1], 2, undef, false)
  slotifyY2([h, sw, t0*2], [dx1, dy[1]-1, -sr], undef, 1, false)
  slotifyZ([tabh, sw, t0*2], [dx1, dy[1]-0, 1], 2, undef, false)
  children();
}

// h: height of wall
// sw: slot width
// tr: [dx, dy]
// dy: translate on y axis
// dx: translate on x axis
module card_slot(h, sw, tr) {
  tabh = 20;
  sr = sw/2; // slot radius
  dx = def(tr[0], t0/2);
  dy = def(tr[1], 20);
  slotifyX2([h, sw, t0*2], [dx, dy, -sr], undef, 1, false)
  slotifyX([tabh, sw, t0*2], [dx, dy, 1], 3, undef, false)
  children();
}
module player_tray(w, l) {
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
divw = 1;  // width of short divider between houses
// tray_2:  t1 + w00 + t1 + house_dim.x + divw + house_dim.x + t1;
tray_w = w00 + 3 * t1 + 2 * house_dim.x + divw;  // ~ 140
tray_l = l00 + 2 * t1;     // 96 > (84 = 7 * house_dim.y)
player_tray(tray_w, tray_l);
