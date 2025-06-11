use <mylib.scad>;
is2D = true;

p = is2D ? 0 : .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
nCol = 3;           // determines metaSize of map & frame

h0 = 3.125*25.4;    // "ideal" size of cardboard hex (3 1/8 inch)
h2 = h0 + f ;       // 2H; H = 15.625 + fudge or shrinkage; + .9 mm / 5 gaps
// hs = (col-.5)*h2 for col = 3
echo("hs=", 2.5*h2, ">", 2.5*h0, "=", 2.5*(h2-h0), "per 2.5", "5 * (h2-h0)", 8*(h2-h0));
// radius of each hex; h2 is the measured ortho size (+ ~f)
r = h2 * sqrt3_2;

// 3.125 = 2H; R, H=sqrt3*R/2; R = H*2/sqrt3

// hex frame for settlers


// hexagon in NS topo:
module hexagon(tr=[0,0,0], r = r, t = t0, center = true) {
  translate(tr) cylinder(h = t, r=r, $fn=6, center = center);
}
module hexagon2D(tr=[0,0,0], r = r, t = t0, center = true) {
  x0 = r;
  y0 = 0;
  x1 = r * sin(30);
  y1 = r * cos(30);
  pts= [[x0, y0], [x1, -y1], [-x1, -y1], [-x0, y0], [-x1, y1], [x1, y1]];
  translate(tr) polygon(pts);
}
module aHexagon(tr=[0,0,0], r = r, t = t0, center = true) {
  if (is2D) {
    hexagon2D(tr, r, t, center);
  } else {
    hexagon(tr, r, t, center);
  }
}

// rtr: [tr, rotr]
// - rotr: [ax, ay, az, [cx, cy, cz]]
// r: (10) radius = edge
// t: (1) thickness
// center: (false) for z-axiz
module triangle(rtr=[0,0,0, [0,0,0, [0,0,0]]], r=10, t=1, center = false) {
  rtr = def(rtr, [0,0,0]);
  r = def(r, 10);
  trr(rtr)
  cylinder(h = t, r = r, center = center, $fn=3);
}

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

// 
module hexCol(n = 1, col = 0, h2 = h2, t = 1, h0 = h0, center = true) {
  r = h2 * sqrt3_2; // radius of hex with ortho x_width = h2 (~79 -> ~46)
  ne = (n % 2) == 0;
  y0 = (ne ? 0 : .5) * h2;
  // roughly: sheep, wheat, wood, brick, ore 
  colors = ["lightgreen","yellow","darkgreen","firebrick", "silver"];
  edge = "blue";
  desert = "wheat";
  nc = len(colors);
  nr2 = (n-1)/2;
  for (ri = [-nr2 : 1 : nr2]) 
    let (x = col * r, y = ri * h2, 
        rnd = floor(rands(0,nc,1)[0]), 
        colr = (ri == nr2) || (ri == -nr2) ? edge : (x == 0 && y == 0) ? desert : colors[rnd]
        )
    color(colr)
      aHexagon([x, y, 0], h0/sqrt3+p, t = t, center = center );
}

// col: place at 'col' of main board metaHex (0)
// h2: ortho size of hex cell; x_width (h2)
// t: thickness of hex
// h0: ortho size of actual hex (h2)
// center: (true)
module oneCol(col = 0, h2 = h2, t = 1, h0 = h2, center = true) {
  let(ac = abs(col), n = 2 * nCol + 1 - ac)
    hexCol(n, col, h2, t, h0);
}

// display with ideal size hex: 3.125" across width
module fullMap(h2 = h2, t = 1, h0 = h0, z0 = -2) {
  translate([0, 0, z0])  // below axis labels
  for (col = [-nCol : 1 : nCol]) oneCol(col, h2, t, h0);
}

// nsnc: [ns, nc] #straight, #corner ([1, 1])
// wf: x_width of frame piece (h2 / 2)
// oz: offset_z (1)
// ring: make a ring of six fullFrame (0)
module frame(nsnc, wf = h2/2, oz = 1, ring = undef, solid = false) {
  nsnc = def(nsnc, [1, 1]);
  wf = def(wf, h2/2); // width of frame
  oz = def(oz, is2D ? 0 : 1);
  tf = is2D ? 0 : 3+pp;// thickness of frame
  col = nCol;          // placement of frame
  R = h2/sqrt3;  H = h2/2; 
  // kx: x-displacement of edge; NNE/SSE corner of hex in col
  kx =  R * (3 * col + 1) / 2; // R/2 + col * 1.5 * R;
  rt = (kx + wf)/1.5;  // 'radius' of intersecting triangle
  fh = (col + 1) * h2; // total frame height
  hr = 8;              // radius of hook triangle
  hs = (col - .5) * h2;// height of straight part
  csp = kx+wf/2;       // center of straight part (x-coord)

  // one edge of external (fh) x MetaHex:
  module fullFrame() {
    // cut the adjacent hexes:
    difference() 
    {
      // make edge piece as trapezoid:
      intersection() 
      {
        // echo("frame: col, H, R, kx, rt=", [col, H, R, kx, rt]);
        translate([kx, -fh/2, oz-tf/2+p])
          aCube([wf, fh, tf-pp], false);
        // color("cyan") 
        aTriangle([rt, 0, oz, [0, 0, 180]], rt, t=tf, center = true);
      }
      // the adjacent hexes:
      translate([0, 0, oz]) hexCol(col+1, col, h2, tf+pp, h2); // col=3 --> 4 hexes
    }
  }

  // given two fullFrames connected: 
  // - cut to 2 frames (for straightPart & cornerPart)
  // - trim cornerPart to size
  // - addHooks to each
  // hs: height of straight cut
  // children(0) straight frame
  // children(1) tilted frame
  module cutit(ns=1, nc=1, hs = hs) {
    es = (fh-hs)/2;  // end size
    ec = -wf*.66;    // intersects ray from center @ 30', 

    // Place a hook (triangle) at rtr.
    // hr: radius of hook triangle
    // rtr: [dx, dy, tf {, rotr}] ([0, 0, 0])
    //  - rotr: [rx, ry, rz {, cxyz}] ([0, 0, 0])
    //  - cxyz: [cx, cy, cz] ([0, 0, 0])
    module hook(rtr, hr = hr) {
      trr(rtr) aTriangle([0, 0, 0], hr, tf+pp, true);
    }

    // Add a hook (triangle) at one end; cut a hook (triangle) on the other end.
    //
    // Given: child(0) is centered, child(1) is positioned at top.
    // - sf[3] --> center; rtr --> bottom
    // 
    // add child(1) then subtract rtr(sf(child(1), -rtr/2))
    // child(0)+child(1)-tr(rtr, child(1)*sf)
    // for ex: addAndCut([0, -hs, 0], [-wf*.2, -hs/2, 0]) straightPart() trr([wf*.2, hs/2, 0]) hook();
    // sf: [sx, sy, sz {, cxyz }] ([0, 0, 0])
    // - cxyz: [cx, cy, cz] ([1, 1, 1])
    module addAndCut(rtr, sf) {
      rtr = def(rtr, [0, 0, 0]);
      sf = def(sf, [1, 1, 1]); // scale factors [sx, sy, sz]
      difference() 
      {
        union() {
          children(0);
          children(1); // add child(1)
        }
        // move to cut location, to subtract child(1)
        trr(rtr) scalet(sf)  children(1);
      }
    }
    module maybe_dup_trt(trt) {
      if (is_undef(trt)) {
        children();
      } else {
        dup(trt) children();
      }
    }
    // ys = hs or es; zr = 30 or 60
    module makePart(trf, trt, ys, colr = undef) {
      trh = [wf*.2, ys/2, 0, [0, 0, 30]];
      mtrh = amul(as3D(trh), [-1, -1, -1]);
      color(colr)
      intersection()  // straight section
      {
        children(0);
        translate(trf) 
        maybe_dup_trt(trt)
        addAndCut([0, -ys, 0], [(hr+f)/hr, (hr+f)/hr, 1, mtrh]) {
          aCube([wf, ys, tf+pp], true);
          hook(trh);
        }
      }
    }
    // extract straight part of child(0) = fullFrame
    module straightPart(trf) {
      makePart(trf, undef, hs) children(0);
    }

    // child(0) fullFrame
    module cornerPart(trf) {
      trt = [0, 0, p, [0, 0, 60, [ec, 0, 0]]];
      trf = def(trf, [csp, (es+hs)/2, oz]);
      makePart(trf, trt, es, "red") children(0);
    }

    if (solid) {
      ww = wf*.5; wh=wf*.75;
      for (i = [0 : nc -1]) {
        // another weld to make a single piece for laser cut:
        color("cyan") trr([kx+ww, hs*.74, tf/2, [0,0,30]]) aCube([ww, wh, tf], true);
        trr([i * -30, i *-20, 0]) cornerPart([csp, (es+hs)/2, oz]) children(0);
        trr([i * -(wf+3), 0, 0]) straightPart([csp, 0, oz]) children(0); // translate to location of frame
      }
    } else {
    if (nc > 0) for (i = [0 : nc-1])
    trr([i * -30, i *-20, 0])
    cornerPart([csp, (es+hs)/2, oz]) children(0);

    if (ns > 0) for (i = [0 : ns-1])
    trr([i * -(wf+3), 0, 0])
    straightPart([csp, 0, oz]) children(0); // translate to location of frame

    // small test of hook:
    if (nc == 0 && ns == 0) {
      intersection() 
      {
        trr([csp+2, hs/2, 2*abs(oz)]) color("cyan") aCube([wf, wf, 8*abs(oz)], true);
        union () {
          cornerPart([csp, (es+hs)/2, oz]) children(0);
          trr([0, -hr/2-2, 0])
          straightPart([csp, 0, oz]) children(0); // translate to location of frame
        }
      }
    }
    }
  } // end of module cutit()

  // extract a piece of fullFrame that straddles the straightPart & cornerPart
  // --> given: child(0) is a fullFrame <-- Ehh, just make a fullFrame()
  module weld(y0 = hs/3) {
    tp = is2D ? 0 : p;
    tpp = tp + tp;
    hw = solid ? y0 : 0;
    echo("weld: solid=", solid, "hw = ", hw, "wf=", wf);
    intersection() 
    {
      fullFrame();
      translate([kx, hw, -0]) aCube([wf, wf, tf+pp]);
    }
  }

  module ringit(n = 5) {
    for (i = [0 : n]) {
      dup([0,0,0], [0, 0, 60 * i]) children(0);
    }
  }

  if (!is_undef(ring)) 
  {
    ringit(ring)
    fullFrame();
  } else 
  if (solid) {
    // for 6 on 12 x 12 board
    // color("cyan")
    // trr([kx -56, 42, -3]) cube([12 * 25.4, 12 * 25.4, t0], true);
    // dup([21-3*wf, 0, 0])
    // dup([21-3*wf, 0, 0])
    trr([0, 30, 0, [0, 0, -5.6]])
    dup([2*kx+h0+1, h0/2+36, 0], [0, 0, -180]) 
    union() 
    {
      color("green") weld();
      cutit(nsnc[0], nsnc[1], hs)
        dup([0, 0, -pp], [0, 0, 60])
        fullFrame();
    }
  }
  else
  {
    cutit(nsnc[0], nsnc[1], hs)
      dup([0, 0, -pp], [0, 0, 60])
      fullFrame();
  }
}
// frame(nsnc, wf=h2/2, oz=1, ring=0, solid=false)
// frame([1, 0], undef, 0, 0); // debug: simple full frame
frame(undef, undef, undef, undef, true); // for laser cutting; solid && is2D
// frame([0, 3]);  // corners
// frame([3, 0]);  // straight (< 220 printer plate)
// frame(undef, undef, undef, 5); fullMap(h2, 2, h0, .5);
// aHexagon();
