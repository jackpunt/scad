use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
module dice(tr=[0,0,0], ds = ds) {
  color("#DDDDDD")
  translate(tr) roundedCube([ds,ds,ds], 2, false);
}
module robber(tr = [0,0,0]) {
  color("black") 
  translate(v = tr) rotate([0,90,0]) cylinder(r1 = rs/2, r2 = 3, h = 32);
}
module slotbox(ch = ch, ss = false) {
  cz = 5; // cut a wide slot
  slotifyY2([boxz, cw-2*t0, 2*t0, 2], [0, -(ch-t0+p)/2, boxz-cz], undef, undef, ss)
  slotifyY2([boxz-cz, 25,   2*t0, 5], [0, -(ch-t0+p)/2,       4], undef,     2, ss)
  children(0);
}
module sidebox(dx = 0, y1 = y1+1, ss = false) {
  translate([dx+cw/2, ch+y1/2, 0]) 
  slotbox(-y1+3*t0+pp, ss)
  translate([-cw/2, -y1/2-t0,0])
  box([cw, y1, boxz]); // dice box
}
module cardbox() {
  slotbox()
  box([cw, ch, boxz], t0, undef, true);
  translate([0, 0, 1.5]) cube([cw, 7, 2.3], true);
  translate([0, 0, 1]) cube([cw, 10, 2], true);
}

module cardboxes() {
  locs = [[0,0], [0, 1], [0, 2], [0, 3], [1, 0], [1, 3]];
  for (rc = locs) let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1)
  translate([c*(cw-t0), r*(ch-t0)+ry, 0])
  cardbox();
}

// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s = is_list(size) ? size : [size,size,size]; // tube_size
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s[2], s[1], s[0]], rt, k, t);

 // endcaps
 hw0 = [s[2], s[1], 0];
 hwx = [s[2], s[1], s[0]];
 div(hw0, rc, k);
 div(hwx, rc, k);
}

module partTrays() {
  tw2 = 120 - 2 * t0;
  th2 = (220-ch) - 0 * t0;
  tw = tw2/2 - 2.1 * t0;
  th = th2/2 - 2.1 * t0;
  module partstray(tr=[0,0,0]) {
    // old tray: 85,500 mm^3, now: 74,500 mm^3
    echo("partstray: tw, th, boxz-1=", tw, th, boxz-1, tw*th*(boxz-1) );
    rt = 3;
    translate(tr) tray([tw, th, boxz-1+rt ], rt, 2);
  }
  for (ptr = [0 : 1], ptc = [1 : 2]) 
    let(x = 1.5*t0 + ptc * (tw+1.5*t0), y = ch + t0 + ptr * (th + .5*t0) )
      partstray([x, y, 1*t0]);
}

f = .18;

// trays for cards, player-bits, dice, robber, disks
tb = 3; // thickness of base

boxz = 22; // depth of boxes: city=19; 8-10-cards, 3-lever, 2-holding
cardw = 54; cw = cardw + 2 + 2 + 2*t0;
cardh = 81; ch = cardh + 2 + 6 + 2*t0;
ds = 15; rs = 15;

y1 = 220 - 2*(ch);
echo("y1=", y1);

loc = 0;

atrans(loc, [[0, ch+y1+3*t0, -t0],[0,0,0], []])
  partTrays();

atrans(loc, [[cw/2,ch/2,0], [], [cw/2, ch/2, 0]])
cardboxes();

sidebox(0);
atrans(loc, [undef, [0,0,0]]) {
  dice([t0, ch+t0, t0]); dice([ds+t0+f, ch+t0, t0]);
  robber([0, ch + ds + 2* t0 + rs/2, t0+rs/2]);
}

sidebox((cw-1)*3);

color("lightblue")
 translate([cw-t0, ch-t0, 0]) 
box([120-t0, 220-ch, boxz]);

atrans(2, [undef, undef, [0, -2, -1]]) 
 % cube([282, 220, 1]);
