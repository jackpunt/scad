use <mylib.scad>;

is2D = true;
p = is2D ? .001 : .001;
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

module hexCol(n, p = 0, colors) {
  h = r * sqrt3;
  trr([0, - ((n-1) * h/2), 0]) astack(n, [0, h, 0], undef, colors) aHexagon(tr0, r+p);
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
    translate([0, l1/2, -cp/2])  hexCol(n+1, cp); // col=3 --> 4 hexes
  }
}

module corner0(r=r, d=d) {
  rd = r+d;
  polygon(points = [[-r, 0], [-rd, 0], [-rd/2, -rd*sqrt3/2], [-r/2, -r*sqrt3/2]]);
}


// Add a hook (triangle) at one end; cut a hook (triangle) on the other end.
//
// child(0): fullFrame
// child(1): hook
// rtr0: place hook to add
// rtr1: place hook to subtract
// sf: scale hook to subtract
// (child(0) + rtr0() child(1)) - (rtr1() scalet(sf) child(1))
module addAndCut(rtr0, rtr1, sf) {
  sf = def(sf, [1, 1, 1]); // scale factors [sx, sy, sz]
  difference() 
  {
    union() {
      children(0); // aCube() ?
      trr(rtr0) children(1); // aTriangle(), the hook
    }
    // move to cut location, to subtract child(1)
    trr(rtr1) scalet(sf) children(1);
  }
}

hr = r*.2; // radius of hook triangle
hrot = -30; // rotation of hook triangle (-25)

// Place a hook (triangle) at rtr.
// hr: radius of hook triangle
// rtr: [dx, dy, tf {, rotr}] ([0, 0, 0])
//  - rotr: [rx, ry, rz {, cxyz}] ([0, 0, 0])
//  - cxyz: [cx, cy, cz] ([0, 0, 0])
module hook(hr = hr, rtr) {
  rtr = def(rtr, [0, -hr*.1, 0, [0, 0, hrot]]); // -25
  aTriangle(rtr, hr, tf+pp, true);
}

// hh: height of hook (hr * 1.1)
module hook2(hh) {
  hh = def(hh, hr * 1.1);
  ht = .7 * hh;   // x-width of pillar
  hy = .5 * hh;   // y-thick of crossbar
  hw = 1.6 * hh;  // x-width of crossbar
  ho = .5 * hw;   // x-offset of crossbar
  dx = .15 * hh;  // offsdet from rtr.x
  trr([dx - ht/2, -(hh+pp)/2, 0]) aCube([ht, hh+pp, t0]);
  trr([dx - ho, -hh, 0]) aCube([hw, hy, t0]);
  trr([dx-hw+ ho, +hh/2, 0]) aCube([hw, hy, t0]);
}

module edge(nr = 0, n = n) {
  trr([0, 0, 0, [0, 0, nr * 60, crr]])
  addAndCut([hx, 0, 0], [hx, n*h, 0]) {
    fullEdge(n); 
    hook();
  };
}
module corner(colr) {
  color(colr) 
  addAndCut([hx, 0, 0, [0, 0, 60, [-hx, 0, 0]]], [hx, 0, 0], [hsf, hsf, 1]) {
    corner0();
    hook();
  };
}

module both(n = n) {
  edge(0, n);
  corner();
}
module twoedge(n1, n2) {
  trr([0, n2*h, 0]) 
  color("brown") edge(0, n1);
  color("grey") edge(0, n2);
  corner();
}
module bigRing(n = n) {
  n1 = floor(n/2);
  n2 = n - n1;
  crr = [n*h*sqrt3_2, n*h/2, 0];
  aRing(6, [0, 0, 60, crr]) twoedge(n1, n2);
}


colors = ["lightgreen","yellow","darkgreen","firebrick", "silver"];

// ceil(n/2) + floor(n/2) hexes high, in i-th column
module oneCol(i, nh, yn, c1, c2) {
  n1 = ceil(nh/2);
  n2 = floor(nh/2); //n - n1;
  echo("oneCol", i, nh);
  // yn = n - dy*i - 6 + 5*dy - (n1-n2);
  xn = i;
  // yn = nh - dy*i - 6 + 5*dy - (n1-n2);
  trr([(xn)*h*sqrt3_2, (yn+1)*h/2, 0]) color(c1) astack(n1, [0, h, 0]) aHexagon(tr0);
  trr([(xn)*h*sqrt3_2, (yn-1)*h/2, 0]) color(c2) astack(n2, [0, -h, 0]) aHexagon(tr0);
}

// hexes that fill the interior of frame of order n
module fullMap(n) {
  function yn1 (i, nh) = nh - i -1 - (nh%2);
  function yn2 (i, nh) =      n -1 - (nh%2);
  n1 = n-1;
  for (i = [0 : n1] ) let(nh = i + n) oneCol(i, nh, yn1(i, nh), "blue", "red");
  for (i = [n : 2*n1] ) let(nh=3*n1+1-i) oneCol(i, nh, yn2(n, nh), "yellow", "green");
}

fullMap(10);


// two edges in close layout for printing:
module dualEdge(cr2) {
  trr([0, 2.35, 0]) edge();
  trr(cr2) edge();
}

d = r * .7;
rd = r + d;
n = 4;
crr = [n*h*sqrt3_2, n*h/2, 0]; // rotation around hex center
cr2a = [.85-h*sqrt3_2, h*.57, 0, [0, 180, 0, [0, n*h/2, 0]]]; // reflective for laser/wood
cr2b = [2.5-h*sqrt3_2, h*.47, 0, [0, 0, 180, [0, n*h/2, 0]]];// 220mm second instance
cr2c = [1.2-h*sqrt3_2, h*.57, 0, [0, 0, 180, [0, n*h/2, 0]]];// 220mm second instance


hf = f/2;             // fudge on hook size (shrink/grow)
hsf = (hr + hf)/hr;   // hook scale factor (allow for hf)
hx = -(r + d * .45);  // hook offset on butting joint

// loc: 0: design, 1: edge&corner, 2: 6-packed, 3: ?
loc = 4;
atrans(loc, [[0, 0, 0], [0, 2.35, 0], undef, 2]) edge();
atrans(loc, [[0, 0, 0]]) edge(1); // extra edge demo
atrans(loc, [[0, 0, p], [0, 0, 0]]) corner("red");

atrans(loc, [undef, 0, [0,0,0]]) astack(3, [r*.6+2*d, 0, 0]) dualEdge(cr2a);
atrans(loc, [undef, 0, 0, [0,0,0]]) astack(3, [r*.65+2*d, 0, 0]) dualEdge(cr2c);
atrans(loc, [undef, 0, [0, 0, 0], 2]) astack(6, [0, h, 0]) trr([-r, r, 0, [0, 0, -30]]) corner();
// astack2 is: aRing, with repeated rotation
atrans(loc, [undef, 0, 0, 0, [0,0,-pp]]) bigRing(9);

