use<mylib.scad>;

t0 = 1;
// clang-format off
// test rc

  // idc?: color
  // rid: plane of corner cut (rotates the cut segment)
  // ---- 0: [-90,0,0] 1: [0, -90, 0] 2: [0, 0, -90]
  // rot: applied to given cube to put in in plane of rid
  // cxyz: cube to rotate
  // trans: for each corner; +/- cube radius
  // ss: show segment (false)
  module test(idc, rid, rot, cxyz, trans, ss = true) {
    if (idc) {
    translate(trans[0]) color("blue") cube([ 1, 1, 1 ], true);
    rc(trans[0], rid, 0, 5, t0, ss)
    rc(trans[1], rid, 1, 5, t0, ss)
    rc(trans[2], rid, 2, 5, t0, ss)
    rc(trans[3], rid, 3, 5, t0, ss)
    rotate(rot) color (idc)  cube(cxyz, true); // Y -> X
    }
  }
  module test0(idc, rid, rot, cxyz, trans, ss= false) {
    rrot = [ [ 0, -90, 0 ], [ -90, 0, 0 ], [ 0, 0, -90 ] ][rid];
    if (idc) {
    translate(trans[0]) color("blue") cube([ 1, 1, 1 ], true);
    rc0(trans[0], rid, 0, 5, t0, ss)
    rc0(trans[1], rid, 1, 5, t0, ss)
    rc0(trans[2], rid, 2, 5, t0, ss)
    rc0(trans[3], rid, 3, 5, t0, ss)
    rotate(rot) color(idc)  cube(cxyz, true); // Y -> X
    }
  }

module testRC() {
  t = t0;
  sz = false;
  szx = "tan";
  szy = "cyan";
  sx = false;
  sy0 = "green";//false; //
  syx = false;
  syxc = "#BBBBBB";// "#BBBBBB";
  syz = false;// "red";

  // rc() WORKS without test module!
  tt=t0/2; // offset because cube is rotated but not centered
  translate([20, 5, 0]) {
  translate([0,20,tt]) color("blue") cube([ 1, 1, 1 ], true);
  color("cyan") 
  rc([0,20,tt], 2, 0, 5, t0,true) 
  rc([20,20,tt], 2, 1, 5,t0,true) 
  rc([20,0,tt], 2, 2, 5, t0,true)
  rc([0,00,tt], 2, 3, 5, t0,true) 
  cube([20, 20, t0]);
  }

  // original test with rc0() [implicit gold]
  translate([-10, -30, 0]) 
  rc0([0,00,0], [0, 0, 0], 0, 5, t0,true) 
  rc0([0,20,0], [0, 0, 0], 1, 5,t0,true) 
  rc0([20,20,0], [0, 0, 0], 2, 5, t0,true)
  rc0([20,00,0], [0, 0, 0], 3, 5, t0,true) 
  cube([20, 20, t0]);

  gold = "gold";
  // z-axis test: using test0; fails because of module!
  translate([25, -20, 0]) 
  test0(gold, 2, [0, 0, 0], [20, 20, t0], [
    [-10,-10,-tt], [-10,10,-tt],[10,10,-tt], [10,-10,-tt]
  ], true) 

  // native Y -> X [green] (first test)
  test(syxc, 0, [0,0,-90], [20, t, 20], [
    [00,-10,-10],
    [00, 10,-10],
    [00, 10, 10],
    [00, -10,10]
    ]);
  // native Y -> Y [grey]
  translate([20,20,20])
  test(sy0, 0, [0,0,0], [20, t, 20], [
    [-10,00,10],
    [-10,00,-10],
    [10,00,-10],
    [10,00,10],
  ]);

  // native Y -> Z [red]
  test(syz, 2, [-90,0,0], [20, t, 20], [
    [-10,10,00],
    [10,10,00],
    [10,-10,00],
    [-10,-10,00],
  ]);

  // native Y -> Z [red]
  *if (syz) color (syz) 
  translate([0, 0, 0]) 
  rc0([00,20,0], [0, 0, -90], 0, 5, 1, syz) 
  rc0([20,20,00], [0, 0, -90], 1, 5, 1, syz) 
  rc0([20,00,00], [0, 0, -90], 2, 5, 1, syz)
  rc0([0,0,0], [0, 0, -90], 3, 5, 1, syz) 
  rotate([-90,0,0]) cube([20, t0, 20]); // y -> Z

  // native Z:
  if (sz) color(sz)
  translate([0, 0, 0]) 
  rc0([0,00,0], [0, 0, 0], 0, 5, 1, sz) 
  rc0([0,20,0], [0, 0, 0], 1, 5, 1, sz) 
  rc0([20,20,0], [0, 0, 0], 2, 5, 1, sz)
  rc0([20,00,0], [0, 0, 0], 3, 5, 1, sz) 
  cube([20, 20, t0]); // native: normal to Z

  // native Z rotated to X
  // if (szx) color(szx)
  // translate([0, 0, 0])
  // amul(csr, -rad)
  translate([-10, -20, -10]) 
  test(szx, 1, [0, -90, 0], [20, 20, t0], [
    [0,  -10, -10], [0, 10, -10], [0, 10, 10], [0, -10, 10], 
  ], true);

  // native Z rotated to Y
  test(szy, 0, [-90, 0, 0], [20, 20, t0], [
    [-10, 0,  10], [-10, 0, -10], [10, 0, -10], [10, 0, 10], 
  ])

*  if (szy) color(szy)
  translate([0, 0, 0]) 
  rc0([0,00,0], [-90, 0, 0], 0, 5, 1, szy) 
  rc0([0,0,-20], [-90, 0, 0], 1, 5, 1, szy) 
  rc0([20,0,-20], [-90, 0, 0], 2, 5, 1, szy)
  rc0([20,00,0], [-90, 0, 0], 3, 5, 1, szy) 
  rotate([-90, 0, 0]) cube([20, 20, t0]);

  // if (sy0) color (sy0) 
  // translate([0, 0, 0]) 
  // rc0([00,00,20], [-90, 0, 0], 0, 5, 1, sy0) 
  // rc0([00,00,00], [-90, 0, 0], 1, 5, 1, sy0) 
  // rc0([20,00,00], [-90, 0, 0], 2, 5, 1, sy0)
  // rc0([20,00,20], [-90, 0, 0], 3, 5, 1, sy0) 
  // cube([20, t0, 20]); // native normal = y

  // native Y -> X [green]
  if (syx) color (syx) 
  translate([0, 0, 0]) 
  rc0([00,-20,00], [0, -90, 0], 0, 5, 1, syx) 
  rc0([00,00,00], [0, -90, 0], 1, 5, 1, syx) 
  rc0([0,00,20], [0, -90, 0], 2, 5, 1, syx)
  rc0([0,-20,20], [0, -90, 0], 3, 5, 1, syx) 
  rotate([0,0,-90]) cube([20, t0, 20]); // Y -> X


}
// clang-format on
