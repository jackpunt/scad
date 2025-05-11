use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;

// children(0) - base plate
// children(1) - motif to subtract 
// txyz: [x, y, z] initial offset
// dxyz: [dx, dy, dz] delta per iteration
// mxyz: [mx, my, mz] max value of iteration
module perforate(txyz, dxyz, mxyz) {
  // echo("perf: x,y,z=", [ txyz, dxyz, mxyz ]) //
  difference() {
    children(0);
    for (x = [txyz[0]:dxyz[0]:mxyz[0]], //
         y = [txyz[1]:dxyz[1]:mxyz[1]], //
         z = [txyz[2]:dxyz[2]:mxyz[2]]) //
      translate([ x, y, z ]) children(1);
  }
}

tb = 3; // thickness of base
hw = 4; // height of 'wall' on lid
tw = 1; // thickness of 'wall' on lid
ta = 3; // thickness of acrylic walls
cardw = 54;
cardh = 81;

// xx: size on x-axis (outer size of underlying acrylic cell)
// yy: size on y-axis (outer size of underlying acrylic cell)
// x0: left of cell
// y0: top of cell
// pa: post args (undef --> just make walls)
// - ph: post height (required)
// - cxdx: [cut, ddx] ([0, 0])
// - ipd: inter-post distance, approx (5)
// - pdy: inter-post distance, exact (computed from ipd)
module cell(xx, yy, x0=0, y0=0, pa) {
  if (is_undef(pa)) {
    // cut a viewport hole:
    difference() {
      cw = 2 * (cardw - 3) - xx; // width of cutout
      dw = (xx - cw) / 2;        // border around cutout
      dh = dw;                   // same border for height
      ch = yy - 2* dh;           // height of cutout
      assert(dw + cw < cardw - 2);
      children(0);
      translate([x0+dw, y0+dh, -.5*tb]) cube([cw, ch, 2*tb]);
    }
    // short walls to keep cards from sliding out
    translate([x0+ta, y0+ta, p])
    box([xx-2*ta, yy-2*ta, hw+tb], [tw, tw, -1.5], [2, 2, 4]);
  } else {
    // else make posts below the y-walls:
    // ph, cw, ipd=3, pdy, pd
    ph = pa[0];
    cxdx = def(pa[1], [0,0]);
    cx = def(cxdx[0], 0);
    dx = def(cxdx[1], 0);
    ipd = def(pa[2], 5);
      ty = yy - 2 * ta - tw; // total y interval
      np = floor(ty/ipd);
    pdy = def(pa[3], ty/(np-1));
    pd = def(pa[4], tw);
    x1 = (x0 < cx) ? x0 : x0 + dx;

    echo("cell: ph, x0, ta, xx, pdy, ipd, pd=", ph, x0, ta, xx, pdy, ipd, pd);
    posts(ph, [x1+ta,       y0+ta, 0], [0, pdy, 0], np, pd);
    posts(ph, [x1-ta+xx-tw, y0+ta, 0], [0, pdy, 0], np, pd);
    children(0);
  }
}

module cells(pa) {
  r2 = 220-121;
  y2 = 220-118;
  w2 = 24;
  cell(67, 121, 0,  0, pa)        // ore
  cell(91-w2, r2, w2, 118, pa)    // wheat
  cell(155-88, r2, 88, 118, pa)   // sheep
  cell(218-152, r2, 152, 118, pa) // wood-brick

  cell(64, 93, 215, 0, pa)        // dev cards
  cell(64, r2, 215, 118, pa)      // brick-wood
  children(0);
}

module base(dx = 20, dy = 20, dz = tb) {
  cube([dx, dy, dz]);
}
// v: depth of underlying plate (dist between peg and top disk)
// d: thickness of top disk
// r: radius of top disk
module pegPlate(v = 3, d = 2, r = 5, f = .5) {
  r0 = 2.5; // peg radius
  children(0);
  cylinder(h = v+v+p, r = r0, $fn = 30); // post
  dr = .6; dzr = .33; dzz = .6 * dr*dzr; // start the enlarge a bit below the top plate
 % for (rp = [r0 : dr : r]) let ( dz = (rp - r0)*dzr) 
    // echo("r, rp, dr, dz=", r, rp, dr, dz )
    translate([0, 0, v+v+dz-dzz]) cylinder(h = d-dz+dzz, r = rp, $fn = 30); // collar
    rp = r; dz = (rp - r0)*dzr;
    translate([0, 0, v+v+dz-dzz]) cylinder(h = d-dz+dzz, r = rp, $fn = 30); // collar
}
// cut a circle and slot
// tr: translate to center of circle ([0, 0, 0])
// ds: translate from post to extend slot ([-2*r, 0, 0])
// v: thickness of plate 
module matingSlot(tr = [0,0,0], ds, v = 3, r = 5, f = .5, r0 = 2.5) {
  ds = is_undef(ds) ? [-(r+r), 0, 0] : ds;
  difference() {
    children(0);
    translate(adif(tr, [0,0,p])) {
      cylinder(h = v * 2, r = r+f);  // hole
      hull() {
        cylinder(h = v+pp, r = r0, $fn=30); // post
        translate(ds)  cylinder(h = v+pp, r = r0+f, $fn=30);
      }
    }
  }
}

module cut_ls(txyz = [0, 0, 0]) {
  translate(txyz)
  intersection() {
    children(0);
    children(1);
  }
}
module cut_rs(txyz=[0, 0, 0]) {
  translate(txyz)
  intersection() {
    children(0);
    children(1);
  }
}


// split base into ls & rs
// txyz: translate for rs
// ls: children(0)
// rs: children(1)
// base: children(2)
module cut(txyz) {
  echo("cut: txyz=", txyz);
  cut_ls(    ) { children(0); children(2); }
  cut_rs(txyz) { children(1); children(2); }
}

// cut plate in two; make slots and tabs @ cx
// children(0): base object
// bb: big block, size of base object
// tr: translate bb to base; put z on midline for tabs/slots ([0,0,0])
// cx: x-coord to make the cut (through YZ plane)
// txyz: translate rs ([sx+2*t0, 0, 0])
// z0: midline to place the tabs/slots (bb.z/2)
// dsz: differential offset from midline of tabs/slots (0)
// sz: thickness of tab (1); slot = sz +/- fs
// sy: breadth of tab (bb[1]/(4*ns+1))
// sx: insertion depth of tab (10)
// fs: ([f, f, f]) expand slot & shrink tab; applied to sx, sy, sz
// ns: (3) number of tabs per side
// ambient
// f: shrinkage (.35)
module zipper_x(bb, tr, cx, txyz, z0, dsz = 0, sz, sy, sx, fs = f, ns = 3) {
  fs = is_undef(fs) ? f : fs;
  fsxyz = is_list(fs) ? fs : [fs, fs, fs];
  tr = is_undef(tr) ? [0, 0, 0] : tr;
  sx = is_undef(sx) ? 10 : sx;   // penetration depth of slot/tab
  // Layout(Y): solid(sy) : tab(sy) : solid(sy) : slot(sy) ... solid(sy)
  sy0 = bb[1] / (4 * ns+1);    // default for sy
  sy = is_undef(sy) ? sy0 : sy; // width of slot/tab (+/- f)
  sz = is_undef(sz) ? 1 : sz;

  txyz = is_undef(txyz) ? [sx+2*t0, 0, 0] : txyz;
  z0 = is_undef(z0) ? bb[2] / 2 : z0;
  // ns = 3;
  echo("zipper: bb, tr, cx, txyz, dsz, sz =", bb, tr, cx, txyz, dsz, sz);
  echo("zipper: ns, sx, sy, sz, f =", ns, sx, sy, sz, f);
  // add tab to children(0)
  // add tabs to children(ch) ch: -1(ls) OR +1(rs)
  module addTabs(cx, ch = 0) {
    union() {
      children(0);
      for (i = [0 : ns - 1]) let (ii = (4 * i + 4.5+ch) % (ns * 4)) 
        translate([cx - ch * (sx - p) / 2 , ii * sy0, z0 + ch * dsz])
      color("pink")  cube([sx, sy, sz], true);
    }
  }
  // cut slots in children(0)
  // ch indicages whether ls(-1) or rs(+1) is being cut
  module cutSlots(cx, ch = 0) {
    difference() {
      children(0);
      sxf0 = sx + fsxyz[0];
      for (i = [0 : ns - 1]) let (ii = (4 * i + 2.5+ch) % (ns * 4)) 
        translate([cx + ch * (sxf0 - p) / 2, ii * sy0, z0 - ch * dsz])
      #  cube([sxf0, sy + fsxyz[1], sz + fsxyz[2]], true);
    }
  }
  // add tabs & slots
  module addSlots_Tabs() {
    // ls
    cutSlots(cx, -1) 
    addTabs(cx, -1) 
    children(0);
    // rs
    cutSlots(cx + txyz[0], 1)
    addTabs(cx + txyz[0], 1)
    children(1);
  }

  // cut children(0) in 2 pieces, addSlots_Tabs to each side
  addSlots_Tabs() {
    echo("addSlots_Tabs: tr, txyz", tr, txyz)
    // ls, tr(rs)
    intersection() // create ls
    {
      translate(tr) cube([cx, bb[1], bb[2]]);
      children(0);
    };
    translate(txyz) 
    intersection() // create rs
    {
      translate([cx, 0, 0]) translate(tr) cube([bb[0]-cx, bb[1], bb[2]]);
      children(0);
    }
  }
}

// peg & slot demo:
// v = 3;
// matingSlot([10, -17.5, 0])
// pegPlate()
// translate([0, -7.5, 0]) base(40, 40, v);

// *translate([-7.5,-7.5, v+.2]) // color("blue") 
// matingSlot([7.5, 7.5, 0], [0, 10, 0], 3, 5, .5)
//  cube([15, 25, v]);

loc = 0;
gs = 16;
// cut between sheep & brick
cx = 153.5; 
// total x extent
tx = 282; 
// big box for cut:
bby = 220; bbz = 10;
// default fudge amount:
f = .25;

module base_cells() {
  cells()
  // perforate([gs, gs, 0], [gs, gs, 1], [280-gs, 222-gs, 1]) 
  {
    color("lightblue") base(tx, 222, tb);
    // %base(tx, 222, tb);
    // cube([gs/2, gs/2, gs/2+tb], true); // pattern to cut
  }
}

// Demo of zipper/cut
intersection() 
{
  ddx = 14.1; // separate ls & rs
  sz = tb + pp;  // thickness of tab
  fsz = f + .6;
  translate(v = [cx+ddx/2, bby-35, 0])  cube([50, 150, 20], true);
  union() {
  ph = sz+fsz/2+p;
  y0 = 6; // align post with x-wall (9, 5.5)
  // posts(sz+fsz/2+p ,[cx - ta/2 - 1,   9.0, 0], [0, 7, 0], (bby-y0)/7);
  // posts(sz+fsz/2+p ,[cx + ta/2 + ddx, 5.5, 0], [0, 5.5, 0], (bby-y0)/5.5);
  zipper_x([tx, bby, 10], [0, 0, -p], cx, [ddx, 0, 0], z0 = tb/2-p, sy=15, sz = tb, ns = 4, fs = [f, f, fsz])
  base_cells();
  cells([ph, [cx-ta/2, ddx], 5, 5.3]) cube([1,1,1]);
  }
}

atrans(loc, [undef, undef, [0, -2, 6]]) 
 % cube([220, 220, 1]);

// astack(); 
