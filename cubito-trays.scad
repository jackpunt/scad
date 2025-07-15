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
tw = 1.75;
tz = 1;
twf = tw+f;

xs = 216;
ys = 216;
dxs = 1;
dys = 1;
th = 2*dieSize;   // total allocated height: 2*diceSize + 3*tz
high = th + 3 * tz;
rad = 4;
gsize = 62.275; // size of larger partition, for grey cubes

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
  
  dl = 4*twf + gap;
  dw = 2.5*twf + gap; // lid, base & half of center divider
  len = def(len, xs - dl);
  // half the base, 2 tw,  
  wid = def(wid, (ys/2 - dw)/ 2);
  h = def(h, high - tz);
  td = 1; // thickness of divs
  csize = (len - 3*td-2*gsize)/2; // size for cardboard bits
  ds = 12;

  echo("partsTray: [len, wid, h, csize]", [len, wid, h, csize]);
  trr([(xs-len)/2, 2*twf+gap/2, tz]) { // tw * 2 + gap/2
    // trr([0, wid, 0]) box([len, wid, h]);
    // dup([0, wid + gap/2, 0], undef, "orange", "green") 
    {
      tray([len, wid, h+2*rad], rad, rad, -2*rad, [tz, tw, tw] );
      dup([ csize, 0, 0], 2)
      div([h+2*rad, wid, len/2-csize], rad, -2*rad, td);
    }
    // --- put a die in it:
    atrans(loc, [[0,0,0], undef, 1, 1, 1, 1])
    gridify(d1 = [twf, ds+.02, gsize-ds], d2 = [twf, ds+.1, wid-ds],rid= 2)
    die([0, 0, tz], ds);
    // die([10, 10, tz + dieSize]);
  }
}

bw0 = 56.5;
bw1 = 60;
// built a z = 0; partsTray above, lidTray 'below'
// len: xs - 2*twf
// wid: ys - w*twf
module baseTray(len, wid, h = high) {
  cl = 2*(tw + 3);
  len = def(len, xs-2*twf);
  wid = def(len, ys-2*twf);
  dy = (bw0 + bw1 + 2*twf);
  ang = 3;
  dz = cl * tan(ang);
  aty = 4*tw;
  trr([(xs - len)/2,  twf, 0]) {
    box([len, wid, h], [tw, tw, tz] );
    echo ("baseTray: dy=", dy, "rem=", ys-dy -tw/2);
    echo ("baseTray: len=", len, "rem=", xs-len -tw/2);
    dup([0,0,0,[0, 0, 180, [len/2, dy, 0]]]) 
    {
      trr([.0, dy-aty/2, dz-.4, [0, ang, 0, [0, 0, h]]]) cube([tw, aty, h-dz]);
      trr([0, dy-tw/2, 0]) cube([cl/2, tw, h]);
    }
    // pull tab:
    ptw = 20;
    dup([0,0,0, [0, 0, 180, [len/2, wid/2+ptw/2, 0]]], 1, "red", "green")
      trr([-2, wid/2, 0]) cube([3, ptw, tz]);
  }
}

module lidTray(len = xs, wid = ys, h = high+tz-6, dx = dxs, dy = dys) {
  trr([(xs-(len+dx))/2, (ys - (wid+dy))/2, -tz, [-0, 0, 0]]) {
    box([len+dx, wid+dy, h], [tw, tw, tz] );
  }
}
echo("parts trays: [xs, ys, tw, tz, high]", [xs, ys, tw, tz, high]);
loc = 4;
atrans(loc, [[0,0,0], [0,0,0], undef, 1, undef, 1, 2, 1 ]) {
  trr([0, bw0+f*2, 0]) partsTray(undef, bw1);
  trr([0, 0, 0]) partsTray(undef, bw0-5);
}
atrans(loc, [[0,0,0], undef, [0,0,0], 2, 1, 1, 2, 2 ]) 
  baseTray();
atrans(loc, [[0,0,0], undef, 1, 1, [0,0,high], 4, 4, 4 ]) 
  // mirror([0,0,1]) 
  trr([0,0,-high])
  lidTray();
