use <mylib.scad>;

is2D = true;
p = is2D ? 0 : .001;
pp = 2 * p;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
inch = 25.4;        // mm per inch
tr0 = [0, 0, 0];    // CONST
tf = 1;             // thicknes of frame
t0 = tf;            // or we just use tf...

nCol = 11;          // determines metaSize of map & frame

// 2 Modes: 2D for laser/wood cut & 3D for plastic printer
// mostly the same, but 3D extrudes by t0

// the hexRad for this file
// radius of each hex; h2 is the measured ortho size (+ ~f)
r = 19.4; // mm on sticky mat
h = r*sqrt3;

module hexagon3D(tr=[0,0,0], r = r, t = t0) {
  translate(tr) cylinder(h = t, r=r, $fn=6, center = false);
}
module hexagon2D(tr=[0,0,0], r = r, t = t0, center = false) {
  trr(tr) circle(r = r, $fn = 6);
}
// hexagon in NS topo:
// for 3D: center = true: z = -t/2
module aHexagon(tr=[0,0,0], r = r, t = t0, center = false) {
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
module aTriangle(tr, rt=r, t=t0, center = false) {
  tr = def(tr, [0,0,0]);
  rt = def(rt, r);
  t = def(t, t0);
  if (is2D) {
    triangle2D(tr, rt, t, center);
  } else {
    triangle3D(tr, rt, t, center);
  }
}
module cube2D(xyz = [10, 10, 10], center = false) {
  square(as2D(xyz), center);
}
module aCube(xyz, center) {
  if (is2D) {
    cube2D(xyz, center);
  } else {
    cube(xyz, center);
  }
}

module hexCol(n, p = 0) {
  h = r * sqrt3;
  trr([0, - ((n-1) * h/2), 0]) astack(n, [0, h, 0]) aHexagon(tr0, r+p);
}

// edge frame hooking n hexes 
// n: number of hexes inside (order-11 board: edge is n=10, plus 2 corner caps)
// d: frame depth (.5 * r)
module fullEdge(n, d = .7 * r) {
  l0 = n * h; // length of stack of n hexes
  l1 = l0 + 0 * d;    // will stand up the y-axis, at x=0
  cp = is2D ? 0 : pp; // add pp for scad rendering
  // cut the adjacent hexes:
  difference() {
    trr([-d-r, 0, 0]) aCube([d+r/2, l1, tf], false);
    // the adjacent hexes:
  #  translate([0, l1/2, -pp/2])  hexCol(n+1, cp); // col=3 --> 4 hexes
  }
}

module corner() {

}

n = 6;
fullEdge(n);
trr([0, n * h, 0, [0, 0, -60]]) fullEdge(n);
