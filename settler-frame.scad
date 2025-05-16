use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
f = .35;
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866

h2 = 3.125*25.4; // 2H; H = 15.625

// 3.125 = 2H; R, H=sqrt3*R/2; R = H*2/sqrt3

// hex frame for settlers
r = h2/2 *2 * sqrt3;
module hexagon(tr=[0,0,0], r = h2/sqrt3, t = t0, center = true) {
  translate(tr) cylinder(h = t, r=r, $fn=6, center = center);
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
// 3.125" across width
module fullMap(h2 = h2) {
  rmm = [[-3,3], [-3,2], [-2,2], [-2, 1]];
  translate([0,0,-2]) {
  for (col = [-3:1:3]) let(ac = abs(col), ce = (col % 2 == 0), rm=rmm[ac])
    for (row = [rm[0] : 1 : rm[1]]) 
      let(x = col*r/2, y = (ce) ? row*h2 : (row+.5)*h2)
      echo("col, row=", col, row, "ce=", ce, "x, y=", x, y)
      color(row == 0 && col == 0 ? "blue" : (row+col)%2 == 0? "green":"yellow")
        hexagon([x, y, 0], h2/sqrt3+p, t= 5 );
  }
}

// col: place at 'col' of main board metaHex (0)
// h2: ortho size of hex, x_width (h2)
// dz: thickness
// center: 
module oneCol(col = 0, h2 = h2, dz = 5, center = true) {
  r = h2 * sqrt3; // radius of hex with ortho x_width = h2 (~79 -> ~46)
  rmm = [[-3,3], [-3,2], [-2,2], [-2, 1], [-1, 0]];
  let(ac = abs(col), ce = (col % 2 == 0), rm=rmm[ac])
  for (row = [rm[0] : 1 : rm[1]]) 
    let(x = col*r/2, y = (ce) ? row*h2 : (row+.5)*h2)
      color(row == 0 && col == 0 ? "blue" : (row+col)%2 == 0? "green":"yellow")
        hexagon([x, y, 0], h2/sqrt3+p, t = dz, center = center );
}

// TODO: add hook to one end, subtract it from other

// h2: orther size of hex; x_width (h2)
// wf: x_width of frame piece (h2*33/80)
// oz: offset_z
module frame(h2 = h2, wf, oz = 1) {
  wf = def(wf, h2*.5); // width of frame
  dz = 3+pp;       // thickness of frame
  col = 3;         // placement of frame
  H = h2/2; R = h2/sqrt3;
  k =  R * (3 * col + 1) / 2; // R/2 + col * 1.5 * R;
  wt = (k + wf)/1.5;  // 'radius' of intersecting triangle
  fh = 4 * h2;     // total frame height
  hr = 8;          // radius of hook triangle
  hs = 2.5 * h2;   // height of straight part
  csp = k+wf/2;    // center of straight part (x-coord)
  module fullFrame() {
    // cut the adjacent hexes:
    difference() 
    {
      // make edge piece as trapezoid:
      intersection() 
      {
        // echo("frame: col, H, R, k, wt=", [col, H, R, k, wt]);
        translate([k, -fh/2, oz-dz/2+p])
          cube([wf, fh, dz-pp], false);
        // color("cyan") 
        triangle([wt, 0, oz, [0, 0, 180]], wt, t=dz, center = true);
      }
      // the adjacent hexes:
      translate([0, 0, oz]) oneCol(col, h2, dz+pp);
    }
  }

  // hs: height of straight cut
  // children(0) straight frame
  // children(1) tilted frame
  module cutit(hs = hs) {
    es = (fh-hs)/2;  // end size
    ec = -wf*.66;    // intersects ray from center @ 30', 

    // Place a hook (triangle) at rtr.
    // hr: radius of hook triangle
    // rtr: [dx, dy, dz {, rotr}] ([0, 0, 0])
    //  - rotr: [rx, ry, rz {, cxyz}] ([0, 0, 0])
    //  - cxyz: [cx, cy, cz] ([0, 0, 0])
    module hook(rtr, hr = hr) {
      trr(rtr) triangle([0, 0, 0], hr, dz+pp, true);
    }
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
      sf = def(sf, [1, 1, 1]);
      difference() 
      {
        union() {
          children(0);
          children(1);
        }
        // move to cut location
        trr(rtr) scalet(sf)  children(1);
      }
    }
    // extract straight part of child(0) = fullFrame
    module straightPart(tr) {
      trh = [wf*.2, hs/2, 0, [0, 0, 30]];
      mtrh = amul(as3D(trh), [-1, -1, -1]);
      intersection()  // straight section
      {
        children(0);
        translate(tr) 
        addAndCut([0, -hs, 0], [(hr+f)/hr, (hr+f)/hr, 1, mtrh]) {
          cube([wf, hs, dz+pp], true);
          hook(trh);
        }
      }
    }

    // child(0) fullFrame
    module cornerPart(trf) {
      trt = [0, 0, p, [0, 0, 60, [ec, 0, 0]]];
      trf = def(trf, [csp, (es+hs)/2, oz]);
      trh = [wf*.2, es/2, 0, [0, 0, 30]]; // place hook at top of cube
      mtrh = amul(as3D(trh), [-1, -1, -1]); // unhook

      translate([p, p, pp]) // cosmetic
      color("red")
      intersection()
      {
        children(0);   // fullFrame
        translate(trf) {
          dup(trt)
          addAndCut([0, -es, 0], [(hr+f)/hr, (hr+f)/hr, 1, mtrh]) {
            cube([wf, es, dz+pp], true);   // cube @ (0,0)
            hook(trh);        // hook at top
          }
        }
      }
    }

    translate([0, -hr*.7, 0]) 
    straightPart([csp, 0, oz]) children(0); // translate to location of frame
    cornerPart([csp, (es+hs)/2, oz]) children(0);
    
  }
  intersection() 
  {
  cutit()
  dup([-0*f, 0*f, -pp], [0, 0, 60])
  fullFrame();
  trr([csp+2, hs/2, 2*abs(oz)]) color("cyan") cube([wf, wf, 8*abs(oz)], true);
  }
}

// translate(v = [-250, 0, -4]) 
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
frame(h2);


// TODO: partition as straight piece & corner piece:

