use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

module dia1(x, y, z, x1, z1) {
  rotate(90, [1, 0, 0])
  linear_extrude(height = y, center = true) 
  polygon([[x1/2, z], [x/2, z1], [x/2, z]]);
}
module dia2(x, y, z, x2, z2, f=.3) {
  xf = (x<0) ? (x/2+f) : (x/2-f);
  rotate(90, [1, 0, 0])
  linear_extrude(height = y, center = true) 
  polygon([[x2, 0], [xf, 0], [x2, z2]]);
}
module slot(z, d, len, x1=11) {
  $fs = .1;
  linear_extrude(height = z) 
  trr([x1, 0, 0]) 
  hull() 
  {
    trr([-len/2, 0, 0]) circle(r = d/2);
    trr([len/2, 0, 0]) circle(r = d/2);
  }
}
// cut center bottom
// xb width at bottom
// xt width at top
// y depth of part
// z height of cut
module centercut(xb, xt, y, z) {
  rotate(90, [1, 0, 0])
  linear_extrude(height = y, center = true) 
  // start at bottom left:
  polygon([[-xb/2, 0], [-xt/2, z], [xt/2, z], [xb/2, 0]]);

}
// small slots above center cut
// a bit of overhang here:
module clipcut(xb, xt, y, z) {
  y0 = 1;
  z0 = 1;
  xl = xt-1;
  dy = y<0 ? (y+y0) : (y-y0);
  trr([0, dy/2, z+z0/2]) cube([xl, y0, z0],true);
}

x = 45; // total width
y = 10; // total depth
z = 15; // total height
module block() {
  z1 = 2; // height of short edge 
  x1 = 8; // width of top flat
  d0 = 7; // center hole diameter
  d1 = 3; // dia of slot
  sl = 11; // slot length (end to end)
  sx = 13; // slot x offset
  // ang = asin((z-z1)/((x-x1)/2));
  difference() 
  {
    trr([0,0,z/2]) cube([x-p, y-p, z-p], true);
    dia1( x, y, z,  x1, z1);
    dia1(-x, y, z, -x1, z1);
    dia2( x, y, z,  (x/2-10), 3);
   # dia2(-x, y, z, -(x/2-10), 3);
    trr([0, 0, z/2]) cylinder(h = z, r = d0/2, center = true);
    slot(z, d1, sl-d1,  sx);
    slot(z, d1, sl-d1, -sx);
    centercut(10, 8,  y, z-7.5);
    clipcut(  10, 8,  y, z-7.5);
    clipcut(  10, 8, -y, z-7.5);
  }
}

// loc=0: upright as pyramid 
// l0c=1: lying flat
loc = 0;
atrans(loc, [[0,0,0], [0,0,y/2, [-90, 0, 0]]])
block();

// cube([45,10, 15], true);
