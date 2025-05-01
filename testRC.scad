use<mylib.scad>;

// clang-format off
// test rc
module testRC() {
  // rid: plane of corner cut
  // rot: applied to given cube to put in in plane of rid
  module test(idc, rid, rot, cxyz, trans, ss = true) {
    if (idc)
    rc(trans[0], rid, 0, 5, t0, ss)
    rc(trans[1], rid, 1, 5, t0, ss)
    rc(trans[2], rid, 2, 5, t0, ss)
    rc(trans[3], rid, 3, 5, t0, ss)
    rotate(rot) color (idc)  cube(cxyz, true); // Y -> X
  }
  module test0(idc, rid, rot, cxyz, trans, ss= false) {
    rrot = [ [ 0, -90, 0 ], [ -90, 0, 0 ], [ 0, 0, -90 ] ][rid];
    if (idc) 
    rc0(trans[0], rid, 0, 5, t0, ss)
    rc0(trans[1], rid, 1, 5, t0, ss)
    rc0(trans[2], rid, 2, 5, t0, ss)
    rc0(trans[3], rid, 3, 5, t0, ss)
    rotate(rot) color(idc)  cube(cxyz, true); // Y -> X
  }
  t = t0;
  sz = false;
  szx = false;
  szy = false;
  sx = false;
  sy0 = false; //"green";
  syx = false;
  syxc = false;// "#BBBBBB";
  syz = "red";

  // rc() WORKS without test module!
  tt=.5; // offset because cube is rotated but not centered
  color("cyan") translate([20, 5, 0]) 
  rc([0,20,tt], 2, 0, 5, t0,true) 
  rc([20,20,tt], 2, 1, 5,t0,true) 
  rc([20,0,tt], 2, 2, 5, t0,true)
  rc([0,00,tt], 2, 3, 5, t0,true) 
  cube([20, 20, t0]);

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
  test(sy0, 1, [0,0,0], [20, t, 20], [
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
  if (szx) color(szx)
  translate([0, 0, 0]) 
  rc0([0,00,0], [0, -90, 0], 0, 5, 1, szx) 
  rc0([0,20,0], [0, -90, 0], 1, 5, 1, szx) 
  rc0([0,20,20], [0, -90, 0], 2, 5, 1, szx)
  rc0([0,00,20], [0, -90, 0], 3, 5, 1, szx) 
  rotate([0, -90, 0]) cube([20, 20, t0]); 

  // native Z rotated to Y
  if (szy) color(szy)
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
