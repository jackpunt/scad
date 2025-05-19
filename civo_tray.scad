$fa = 1;
$fs = 0.4;
t0 = 1; p=.001; pp=2*p;
use<./mylib.scad>

// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s = is_list(size) ? size : [size,size,size]; // tube_size
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s.z, s.y, s.x], rt, k, t);

 // endcaps
 hw0 = [s.z, s.y, 0];
 hwx = [s.z, s.y, s.x];
 div(hw0, rc, k);
 div(hwx, rc, k);
}

l1 = 57.1; l2 = 57.1; l3 = 55; lt = l1+l2+l3; 
assert(lt <= 171, lt);
w = 53; h = 24.3; r0 = 15; r1 = 4; rt=0;
hr = h+r1; // tube @ h+r1, then cut -r1
rad = [r0, r1, rt, rt];
rod = [r1, r1, rt, rt];

// 3 concatenated trays: l1, l2, l3
module tray3() {
translate([0, 0, 0])     tray([l1, w, hr], rad, rod, -r1);
translate([l1, 0, 0])    tray([l2, w, hr], rod, rod, -r1);
translate([l1+l2, 0, 0]) tray([l3, w, hr], rad, rod, -r1);
}
translate([0, 0, 0]) tray3();
*translate([0, w+2, 0]) tray3();
*translate([0, 2*w+4, 0]) tray3();


// short tube, oriented as tray:
*translate([0, -60, 0]) 
 rotate([0, -90, 0])
 roundedTube([40, 53, 8], [15, 4,2,2], -15, 1);
