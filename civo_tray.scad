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
 roundedTube([s[2], s[1], s[0]], rt, k, t);

 // endcaps
 hr = s[2];
 hw = [hr, s[1]];  // 2D
 translate([0, 0, 0])      div(hw, rc, k);
 translate([s[0]-t, 0, 0]) div(hw, rc, k);
}

l1 = 57; l2 = 57; l3 = 55; lt = l1+l2+l3; 
assert(lt <= 170, lt);
w = 53; h = 25; r = 15; r2 = 4;
hr = h+r;
hw = [hr, w]; 
rad = [r, r2, r2, r2];
rod = [r2, r2, r2, r2];

// 3 concatenated trays: l1, l2, l3
module tray3() {
translate([0, 0, 0])     tray([l1 + t0, w, hr], rad, rod, -r);
translate([l1, 0, 0])    tray([l2 + t0, w, hr], rod, rod, -r);
translate([l1+l2, 0, 0]) tray([l3 + t0, w, hr], rad, rod, -r);
}
translate([0, 0, 0]) tray3();
*translate([0, w+2, 0]) tray3();
*translate([0, 2*w+4, 0]) tray3();


// short tube, oriented as tray:
*translate([0, -60, 0]) 
 rotate([0, -90, 0])
 roundedTube([40, 53, 8], [15, 4,2,2], -15, 1);
