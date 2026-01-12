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

psep = 20; // separation of pages
hr = 20; // radius of triangulr hook
hd = 10; // depth of hook (offset from center?)

solid = false;
hsf0 = solid ? -0.1 : 0.06; // reduce by 2D beam width; increase by 3D-fudge
tf = 2; // when solid == true


// from settlers-frame:
// t & center and ignored, there is no z-axis
module triangle2D(rtr=[0,0,0, [0,0,0, [0,0,0]]], r=10, t=1, center = true) {
  rtr = def(rtr, [0,0,0]);
  r = def(r, 10);
  pts = [[r, 0], [-r/2, r * sqrt3_2], [-r/2, -r*sqrt3_2]];
  trr(rtr)
  polygon(pts);
}
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
module hook(rtr, hr = hr) {
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
module tbhook(tb) {
  dx = xwide/4;
  dy = yhigh/2;
  rr = [0, 0, 30];
  if (tb > 0) {
    union() {
      children(0);
      hook([-dx, tb * dy, 0, rr]);
      hook([+dx, tb * dy, 0, rr]);
    }
  } else if (tb < 0) {
    difference() 
    {
      children(0);
      hook([-dx, tb * dy, 0, rr]);
      hook([+dx, tb * dy, 0, rr]);
    }
  } else {
    children(0);
  }
}

module lrhook(lr) {
  dx = xwide/2;
  dy = yhigh/4;
  rr = [0, 0, 60];
  if (lr > 0) {
    union() {
      children(0);
      hook([lr * dx, +dy, 0, rr]);
      hook([lr * dx, -dy, 0, rr]);
    }
  } else if (lr < 0) {
    difference() {
      children(0);
      hook([lr * dx, +dy, 0, rr]);
      hook([lr * dx, -dy, 0, rr]);
    }
  } else {
    children(0);
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
  children(0);
}

// [+bottom & (+right), +bottom & (-left, +right), +bottom, (-left)]
// [-top & +right, -top, -left, +right, +-top, -left]

// row spec:
// [(+1 = top, -1 = bottom), [left=(-1, 0, 1), right=(-1, 0, 1)], ...]
row0 = [-1, [[0, 1], [-1, 1], [-1, 0]]];
row1 = [+1, [[0, 1], [-1, 1], [-1, 0]]];
module pages(rows) {
  for (i = [0 : len(rows)-1]) {
    row = rows[i];
    echo("i=", i, "row=", row);
    tb = row[0];
    lrs = row[1];
    echo("row=", row, "lrs=", lrs);
    for (j = [0 : len(lrs)-1]) {
      lr = lrs[j];
      echo("  j=", j, "lr=", lr);
      l = lr[0];
      r = lr[1];
      echo("    l=", l, "  r=", r);
      trr([(xwide+hd+psep) * j, (yhigh+hd+psep) * -i, 0])
      addHooks(tb, lr)
      page();
    }
  }
}

pages([row0, row1]);
