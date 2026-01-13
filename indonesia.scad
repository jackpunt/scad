use <mylib.scad>;
is2D = true;

p = is2D ? 0 : .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
mmpi = 25.4;

xwide = 11 * mmpi;
yhigh = 8.5 * mmpi;

hr = 20; // radius of triangular hook
psep = 0; // separation of pages
hd = 0; // underlap pages by depth of hook (offset from center?)

solid = false;
// TODO: test this for laser cutter!
hsf0 = is2D ? -0.1 : 0.06; // reduce by 2D beam width; increase by 3D-fudge
hsf1 = is2D ? (hr+hsf0)/hr : (hr + f)/hr;
hsf2 = 1-(1-hsf1)*1;
// hsf = [hsf1, hsf2, 1];
hsf = [hsf1, hsf1, 1];
// hsf = [1, 1 ,1];
tf = 2; // when solid == true (fudge t to make it larger)
echo([is2D, hsf0, hsf1, hsf2, hsf], "hsf=", hsf);

// from settlers-frame:
// t & center and ignored, there is no z-axis
module triangle2D(rtr=[0,0,0, [0,0,0, [0,0,0]]], r=10, t=1, center = true) {
  rtr = def(rtr, [0,0,0]);
  r = def(r, 10);
  pts = [[r, 0], [-r/2, r * sqrt3_2], [-r/2, -r*sqrt3_2]];
  trr(rtr)
  polygon(pts);
}

// draw a [2|3]D triangle around [0,0] apex -> East
module aTriangle(rtr, r, t, center) {
  if (is2D) {
    triangle2D(rtr, r, t, center);
  } else {
    triangle(rtr, r, t, center);
  }
}

// Place a hook (triangle) at rtr.
// rtr: [dx, dy, tf {, rotr}] ([0, 0, 0])
//  - rotr: [rx, ry, rz {, cxyz}] ([0, 0, 0])
//  - cxyz: [cx, cy, cz] ([0, 0, 0])
// hr: radius of hook triangle
module hook(rtr, hr = hr, sf) {
  cx = rtr[0];
  cy = rtr[1];
  sf = def(sf, [1, 1, 1]); // scale factors [sx, sy, sz]
  scalet(sf)
  aTriangle(rtr, hr, tf+pp, true);
}

module page(xwide = xwide, yhigh = yhigh) {
  if (is2D) {
    square([xwide, yhigh], true);
  } else {
    cube([xwide, yhigh, t0]);
  }
}

// tb: +1 add hook to top, -1 cut hole on bottom
// children(0) is the page
module tbhook(tb, sf=hsf) {
  dx = xwide/4;
  dy = yhigh/2;
  rr = [0, 0, 30];
  if (tb > 0) {
    union() {
      children(); // add the protruding 'hook'
      hook([-dx, tb * dy, 0, rr], hr);
      hook([+dx, tb * dy, 0, rr], hr);
    }
  } else if (tb < 0) {
    difference() 
    {
      children(); // cut a hole for the hook (oversize)
      trr([-dx, tb * dy, 0]) hook([0,0,0, rr], hr, sf);
      trr([+dx, tb * dy, 0]) hook([0,0,0, rr], hr, sf);
    }
  } else {
    children();
  }
}

module lrhook(lr, sf = hsf) {
  dx = xwide/2;
  dy = yhigh/4;
  rr = [0, 0, 60];
  if (lr > 0) {
    union() {
      children();
      hook([lr * dx, +dy, 0, rr], hr);
      hook([lr * dx, -dy, 0, rr], hr);
    }
  } else if (lr < 0) {
    difference() {
      children();
      trr([lr * dx, +dy, 0]) hook([0,0,0, rr], hr, sf);
      trr([lr * dx, -dy, 0]) hook([0,0,0, rr], hr, sf);
    }
  } else {
    children();
  }
}
// add (union) the hook parts on top or bottom, left or right
// tb: -1 (hole on bottom of page) or +1 (hook on top of page)
// lr: array of: [(hole on left), +1 (hole on right)]
// children(0): page
module addHooks(tb, lr) {
  tbhook(tb)
  lrhook(lr[0])
  lrhook(lr[1])
  children();
}

// [+bottom & (+right), +bottom & (-left, +right), +bottom, (-left)]
// [-top & +right, -top, -left, +right, +-top, -left]
colors = ["red", "blue", "green", "lightblue", "grey", "purple"];
c = 0;
// row spec:
// [(+1 = top, -1 = bottom), [left=(-1, 0, 1), right=(-1, 0, 1)], ...]
row0 = [-1, [[0, 1], [-1, 1], [-1, 0]]];
row1 = [+1, [[0, 1], [-1, 1], [-1, 0]]];
module pages(rows) {
  for (i = [0 : len(rows)-1]) {
    row = rows[i];
    tb = row[0];
    lrs = row[1];
    echo("row=", row, "lrs=", lrs);
    for (j = [0 : len(lrs)-1]) {
      lr = lrs[j];
      c = ((i * 3 + j)) % len(colors);
      color (colors[c])
      trr([(xwide+hd+psep) * j, (yhigh+hd+psep) * -i, -c*.1])
      addHooks(tb, lr)
      page();
    }
  }
}

pages([row0, row1]);
// pages([ [+1, [[0, 1]]] ]);
// trr([0,0,-1]) color("lightblue") square([12*mmpi, 12*mmpi], true);
