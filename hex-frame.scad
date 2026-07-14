use <mylib.scad>;

is2D = true;
p = is2D ? 0 : .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
nCol = 3;           // determines metaSize of map & frame

// 2 Modes: 2D for laser/wood cut & 3D for plastic printer
// mostly the same, but 3D extrudes by t0

// the hexRad for this file
r = 10;

module hexagon3D(tr=[0,0,0], r = r, t = t0) {
  translate(tr) cylinder(h = t, r=r, $fn=6, center = false);
}
module hexagon2D(tr=[0,0,0], r = r, t = t0, center = false) {
  trr(tr) circle(r = r, $fn = 6);
}
// hexagon in NS topo:
// for 3D: center = true: z = -t/2
module hexagon(tr=[0,0,0], r = r, t = t0, center = false) {
  if (is2D) {
    hexagon2D(tr, r, t, center);
  } else {
    hexagon3D(tr, r, t, center);
  }
}

// for building a hook: 

// Triangle: base @ x = -r/2 , apex @ x = +r
// base point @ y = +/- r*sqrt3/2
// tr: [tr, rotr]
// - rotr: [ax, ay, az, [cx, cy, cz]]
// rt: (r) radius = edge
// t: (t0) thickness
// center: (false) for z-axiz
module triangle3D(tr=[0,0,0], rt=r, t=t0, center = false) {
  trr(tr)
  cylinder(h = t, r = rt, center = center, $fn=3);
}
module triangle2D(tr, r = r, t=1, center = false) {
  trr(tr) circle(r = r, $fn = 3);
}
// tr: trr ([0, 0, 0])
// rt: radius (r)
// t: thick (t0)
// center: z = -t/2 in 3D (false)
module triangle(tr, rt=r, t=t0, center = false) {
  tr = def(tr, [0,0,0]);
  rt = def(rt, r);
  t = def(t, t0);
  if (is2D) {
    triangle2D(tr, rt, t, center);
  } else {
    triangle3D(tr, rt, t, center);
  }
}

// hexagon2D([20, 0, 0], r, t0);
// hexagon3D([-20,0,0], r, t0);
// aHexagon();

triangle([r/2,r*sqrt3_2,0], r, t0);
