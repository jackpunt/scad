use <mylib.scad>;
p = .001;
pp = 2 * p;

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

// xx: size on x-axis (outer size)
// yy: size on y-axis
// x0: left of cell
// y0: top of cell
module cell(xx, yy, x0=0, y0=0, card = true) {
  if (card) {
    difference() {
      cw = 2 * (cardw - 3) - xx; dw = (xx - cw) / 2; 
      dh = dw; ch = yy - 2* dh;
      assert(dw + cw < cardw - 2);
      children(0);
      translate([x0+dw, y0+dh, -.5*tb]) cube([cw, ch, 2*tb]);
    }
    translate([x0+ta, y0+ta, 0])
    box([xx-2*ta, yy-2*ta, hw+tb], [tw, tw, -1.5], [2, 2, 4]);
  } else {
    children(0);
  }
}

module cells() {
  r2 = 220-121;
  y2 = 220-118;
  w2 = 24;
  // translate([0,0, tb-p]) {
    cell(67, 121, 0,  0)       // Ore cell
    // parts bins:
    // cell(78, 60, 64,  0, false)       // player A
    // cell(79, 60, 139, 0, false)       // player B
    // cell(78, 64, 64, 57, false)       // player C
    // cell(79, 64, 139, 57, false)      // player D

    // cell(t0+w2, r2, 0, 118)     // dice & robber
    cell(91-w2, r2, w2, 118)    // wheat
    cell(155-88, r2, 88, 118)   // sheep
    cell(218-152, r2, 152, 118) // wood-brick

    cell(64, 93, 215)           // dev cards
    // cell(64, 118-90+t0, 215, 90); // hex markers
    cell(64, r2, 215, 118)      // brick-wood
    children(0);
  // }
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

f = .18;
// cut plate in two; make slots and tabs @ cx
// children(0): base object
// tr: translate bb to base (put z on midline for tabs/slots)
// bb: big block, size of base object
// cx: x-coord to make the cut (through YZ plane)
// txyz: translate rs
// z0: midline to place the tabs/slots
// dsz: differential offset from midline of tabs/slots
// sz: thickness of tab/slot
// sy0: breadth of tab (bb[1]/(4*ns+1))
// sx: insertion depth of tab (10)
// fs, ft: (f) shrinkage of slot & tab applied to sx, sy, sz
// ns: (3) number of tabs per side
// ambient
// f: shrinkage (.35)
module zipper_x(bb, tr, cx, txyz, z0, dsz = 0, sz, sy0, sx, fs = f, ft = f, ns = 3) {
  fs = is_undef(fs) ? f : fs;
  fsxyz = is_list(fs) ? fs : [fs, fs, fs];
  tr = is_undef(tr) ? [0, 0, 0] : tr;
  txyz = is_undef(txyz) ? [cx, 0, 0] : txyz;
  z0 = is_undef(z0) ? bb[2] / 2 : z0;
  // ns = 3;
  sx = is_undef(sx) ? 10 : sx;   // penetration depth of slot/tab
  dy = bb[1] / (4 * ns+1);    // default for sy
  // sy = bb[1] / (4 * ns+1); // sy solid : sy tab : sy solid : sy slot ... sy solid
  sy = is_undef(sy0) ? dy : sy0; // width of slot/tab (+/- f)
  sz = is_undef(sz) ? 1 : sz;
  echo("zipper: bb, tr, cx, txyz, dsz, sz =", bb, tr, cx, txyz, dsz, sz);
  echo("zipper: ns, sx, sy, sz, f =", ns, sx, sy, sz, f);
  // add tabs to children(ch) ch: 0(ls) OR 1(rs)
  module addTabs(cx, ch = 0) {
    union() {
      children(0);
      for (i = [0 : ns - 1]) let (ii = (4 * i + 4.5+ch) % (ns * 4)) 
        translate([cx - ch*(sx - ft)/2 , (ii) * sy, z0 + ch * dsz])
      color("pink")  cube([(sx - ft), sy - ft, sz - ft], true);
    }
  }
  // cut slots in children(0)
  module cutSlots(cx, ch = 0) {
    difference() {
      children(0);
      for (i = [0 : ns - 1])
        translate([cx + ch*(sx - 0*fsxyz[0])/2, (4 * i + 2.5+ch) * sy, z0 - ch * dsz])
      #  cube([(sx - 0*fsxyz[0]) + pp, sy + fsxyz[1], sz + fsxyz[2]], true);
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
cx = 153.5; tx = 282; bby = 220; bbz = 10;

module base_cells() {
  cells()
  // perforate([gs, gs, 0], [gs, gs, 1], [280-gs, 222-gs, 1]) 
  {
    color("lightblue") 
    base(tx, 222, tb);
    // cube([gs/2, gs/2, gs/2+tb], true); // pattern to cut
  }
}

// intersection() 
{
  ddx = 14.1; // separate ls & rs
  sz = tb + pp;  // thickness of tab
  fsz = f + .6;
  // translate(v = [cx+ddx/2, bby-35, 0])  cube([50, 150, 20], true);
  union() {
  ccx = cx - .5; k = 2.; dia = 1.; y0 = 6;
  posts(sz+fsz/2 ,[ccx - k,       y0+2.4, 0], [0, 7, 0], (bby-y0)/7, dia);
  posts(sz+fsz/2 ,[ccx + k + ddx, y0-.5, 0], [0, 5.5, 0], (bby-y0)/5.5, dia);
  zipper_x([tx, bby, 10], [0, 0, -p], cx, [ddx, 0, 0], z0 = 0 + (sz)/2, dsz = 0, sz = sz+f, ns = 3, fs = [f, f, fsz])
  base_cells();
  }
}

atrans(loc, [undef, undef, [0, -2, 6]]) 
 % cube([220, 220, 1]);

// astack(); 
