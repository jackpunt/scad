// cubitos trays
use <mylib.scad>;
use <cubitos.scad>;

p = .001;
pp = 2 * p;
t0 = 1.8;    // print thicker
f = .25;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
dieSize = 12;
tw = 1.8;
tz = 1;

xs = 216;
th = 2*dieSize;   // total allocated height: 2*diceSize + 3*tz
high = th + 3 * tz;
rad = 4;
csize = 40; // size for cardboard bits

// TODO: use roundTube & divXY before rotation
module tray2(size = 10, rs = 2, rc = 0, k0, txyz = t0) {
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
  {
  roundedTube([s.z, s.y, s.x], rs, k, ta);
  // divXY([s.z, s.y, 0], rc, k, ta.x);
  // divXY([s.z, s.y, ta.z], rc, k, ta.x);
  }
  // endcaps
  hw0 = [s.z, s.y, 0];
  hwx = [s.z, s.y, s.x-ta.x];
  div(hw0, rc, k, ta.x);
  div(hwx, rc, k, ta.x);
}

module partsTray(len, wid, h , rad = rad) {
  gap = f; // gap around each tray
  dl = 4*(tw+f) + gap;
  dw = 2.5*(tw+f) + gap; // lid, base & half of center divider
  len = def(len, xs - dl);
  // half the base, 2 tw,  
  wid = def(wid, (xs/2 - dw)/ 2);
  h = def(h, high - tz);
  echo("partsTray: h=", h);
  trr([(xs-len)/2, 2*(tw+f)+gap/2, tz]) { // tw * 2 + gap/2
    // trr([0, wid, 0]) box([len, wid, h]);
    // dup([0, wid + gap/2, 0], undef, "orange", "green") 
    {
      tray([len, wid, h+2*rad], rad, rad, -2*rad, [tz, tw, tw] );
      dup([-csize, 0, 0])
      dup([ csize, 0, 0])
      div([h+2*rad, wid, len/2], rad, -2*rad);
    }
    // --- put a die in it:
    die([10, 10, tz+.8]);
    die([10, 10, tz + dieSize]);
  }
}

// built a z = 0; partsTray above, lidTray 'below'
module baseTray(len, wid, h = high) {
  cl = 2*(tw + 3);
  len = def(len, xs-2*(tw+f));
  wid = def(len, xs-2*(tw+f));
  trr([(xs - len)/2,  (tw+f), 0]) {
    box([len, wid, h], [tw, tw, tz] );
    trr([0, wid/2, 0]) 
    differenceN(1) {
      cube([len, 2, h]);
      trr([cl/2-p, 0-p, 0-p]) cube([len-cl+pp, 2+pp, high+pp]);
    }
  }
}

module lidTray(len = xs, wid = xs, h = high+tz) {
  trr([(xs-len)/2, 0, -tz, [-0, 0, 0]]) {
    box([len, wid, h], [tw, tw, tz] );
  }
}
echo("parts trays: [xs, tw, tz, high]", [xs, tw, tz, high]);
loc = 0;
atrans(loc, [[0,0,0], [0,0,0], undef, 1, undef ]) 
  partsTray();
atrans(loc, [[0,0,0], undef, [0,0,0], 2, undef ]) 
  baseTray();
atrans(loc, [[0,0,0], undef, undef, 1, [0,0,0] ]) 
  lidTray();
