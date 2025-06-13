use <mylib.scad>;
is2D = true;

p = is2D ? 0 : .001;
pp = 2 * p;
t0 = 1;
f = .18;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
nCol = 3;           // determines metaSize of map & frame

h0 = 3.125*25.4;    // "ideal" size of cardboard hex (3 1/8 inch = 79.375mm)
h2 = h0 + f ;       // 2H; H = 15.625 + fudge or shrinkage; + .9 mm / 5 gaps
// hs = (col-.5)*h2 for col = 3
echo("h2=", h2, "hs=", 2.5*h2, ">", 2.5*h0, "=", 2.5*(h2-h0), "per 2.5", "5 * (h2-h0)", 8*(h2-h0));
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
  hf = (col + 1) * h2; // total frame height
  hr = 8;              // radius of hook triangle
  hs = (col - .5) * h2;// height of straight part
  csp = kx+wf/2;       // center of straight part (x-coord)
  hsf = (hr+f)/hr;     // hook scale factor
  echo("frame: f=", f, "hsf = ", hsf, "solid =", solid);

  ns = nsnc[0];    // number of straightParts to make
  nc = nsnc[1];    // number of cornerParts to make
  es = (hf-hs)/2;  // end size = heightOfFullFrame - heightOfStraightPart
  // (es + hs)/2 => hf/2/2 - hs/2/2 + hs/2 => hf/4 + hs/2; h2 + hs/2
  ec = -wf*.667;    // intersects ray from center @ 30', 

  // one edge of external (hf) x MetaHex:
  // - make a long cube
  // - interect with sector triangle to make trapezoid
  // - subtract hexCol
  module fullFrame() {
    // cut the adjacent hexes:
    difference() 
    {
      // make edge piece as trapezoid:
      intersection() 
      {
        // echo("frame: col, H, R, kx, rt=", [col, H, R, kx, rt]);
        translate([kx, -hf/2, oz-tf/2+p]) aCube([wf, hf, tf-pp], false);
        // color("cyan") 
        aTriangle([rt, 0, oz, [0, 0, 180]], rt, t=tf, center = true);
      }
      // the adjacent hexes:
      translate([0, 0, oz]) hexCol(col+1, col, h2, tf+pp, h2); // col=3 --> 4 hexes
    }
  }

  // Place a hook (triangle) at rtr.
  // hr: radius of hook triangle
  // rtr: [dx, dy, tf {, rotr}] ([0, 0, 0])
  //  - rotr: [rx, ry, rz {, cxyz}] ([0, 0, 0])
  //  - cxyz: [cx, cy, cz] ([0, 0, 0])
  module hook(rtr, hr = hr) {
    aTriangle(rtr, hr, tf+pp, true);
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
  module maybe_dup_trt(trt) {
    if (is_undef(trt)) {
      children();
    } else {
      dup(trt) children();
    }
  }
  // ys = hs or es; zr = 30 or 60
  // trf: move part to final location
  // trt: rotate cutoff part (for corner)
  // child(0) = fullFrame
  module makePart(trf, trt, ys, colr = undef) {
    hsf = solid ? (hr+.06)/hr : hsf;
    trh = [wf*.2, ys/2, 0, [0, 0, 30]];
    trh1 = adif(trh, [0, ys, 0]);

    mtrh = amul(as3D(trh), [-1, -1, -1]); // minus(trh)
    color(colr)
    intersection()  // straight section
    {
      children(0);  // fullFrame - straight up
      translate(trf) 
      maybe_dup_trt(trt)
      addAndCut(trh, trh1, [hsf, hsf, 1] )
      {
        aCube([wf, ys, tf+pp], true);
        hook([0,0,0], hr);
      }
    }
  }
  // cut & hook a straightPart from child(0) = fullFrame
  module straightPart(trf = [csp, 0, oz]) {
    // dup([0, -hs -f/4, 0], undef, "red")
    makePart(trf, undef, hs) children(0); // hs: cut fullFrame at +/- hs/2
  }

  // cut, dup_trt, & hook a cornerPart from child(0) = fullFrame
  module cornerPart(trf = [csp, (es+hs)/2, oz]) {
    trt = [0, 0, p, [0, 0, 60, [ec, 0, 0]]];
    makePart(trf, trt, es, "red") children(0);
  }

  // add hook to small section of child(0) [which is typically a fullFrame]
  module testHook() {
    trr([-csp-hr, -hs/2, 0]) // center at (0,0)
    intersection() 
    {
      trr([csp, hs/2, 2*abs(oz)]) color("cyan") aCube([wf, wf, 8*abs(oz)], true);
      union () {
        cornerPart([csp, (es+hs)/2, oz]) children(0);
        // trr([0, -hr/2-2, 0]) // separate for printing
        straightPart([csp, 0, oz]) children(0); // translate to location of frame
      }
    }
}

  // given two fullFrames connected: 
  // - cut to 2 frames (for straightPart & cornerPart)
  // - trim cornerPart to size
  // - addHooks to each
  // hs: height of straight cut
  // children(0) straight frame
  // children(1) tilted frame
  module cutit(hs = hs) {
    if (solid) {
      ww = wf*.5; wh=wf*.75;
      // another weld to make a single piece for laser cut:
      color("cyan") trr([kx+ww, hs*.74, tf/2, [0,0,30]]) aCube([ww, wh, tf], true);
      cornerPart([csp, (es+hs)/2, oz]) children(0);
      straightPart([csp, 0, oz]) children(0); // translate to location of frame
    } else {
      if (nc > 0) for (i = [0 : nc-1])
      trr([i * -30, i *-20, 0])
      cornerPart([csp, (es+hs)/2, oz]) children(0);

      if (ns > 0) for (i = [0 : ns-1])
      trr([i * -(wf+3), 0, 0])
      straightPart([csp, 0, oz]) children(0); // translate to location of frame
    }
  } // end of module cutit()

  // make 2 fullFrames (straight & tilted), cut, hook, weld...
  module frameCutAndRepeat(hs) {
      cutit(hs)
      dup([0, 0, -pp], [0, 0, 60])
        fullFrame();
  }

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
  echo("frame: ring=", ring, "solid=",solid);
  if (!is_undef(ring)) 
  {
    ringit(ring)
    frameCutAndRepeat(hs);
  } else 
  if (solid && nc == 0 && ns == 0) {
    echo("frame: testHook")
    testHook() fullFrame();;
  } else
  if (solid) {
    echo("frame: solid");
    // for 6 on 12 x 12 board
    color("cyan")
    trr([kx -56, 42, -3]) cube([12 * 25.4, 12 * 25.4, t0], true);
    for (i = [0 : max(ns, nc)-1]) {
    trr([i * (21 - 3*wf), 30, 0, [0, 0, -5.6]])
    dup([2*kx+h0+1, h0/2+36, 0], [0, 0, -180]) 
    union() 
    {
      color("green") weld();
      frameCutAndRepeat(hs);
    }
    }
  }
  else
  {
    frameCutAndRepeat(hs);
  }
}
// frame(nsnc, wf=h2/2, oz=1, ring=0, solid=false)
frame([0, 3], undef, 0, undef, is2D); // debug: simple full frame
// frame(undef, undef, undef, undef, is2D); // for laser cutting; solid && is2D
// frame([0, 3]);  // corners
// frame([3, 0]);  // straight (< 220 printer plate)
// frame([1, 1], undef, undef, undef, is2d); //fullMap(h2, 2, h0, .5);
// aHexagon();
