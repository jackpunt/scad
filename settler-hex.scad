use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
sqrt3 = sqrt(3);
sqrt3_2 = sqrt3/2;

h2 = 3.125*25.4; // 2H; H = 15.625

// 3.125 = 2H; R, H=sqrt3*R/2; R = H*2/sqrt3

// hex frame for settlers
r = h2/2 *2 * sqrt3;
module hexagon(tr=[0,0,0], r = h2/sqrt3, t = t0) {
  translate(tr) cylinder(h = t, r=r, $fn=6);
}

// TODO: add hook to one end, subtract it from other
oz = -0;
translate(v = [-250, 0, -4]) 
dup([0,0,0], [0, 0, -60])
difference() {
intersection() {
translate([245, 0, oz])  cube([35, 3.8*h2, 3], true);
translate([3.5*h2, 0, oz-1.5-p])  rotate([0,0,180]) 
 color("cyan") cylinder(h = 3+pp, r = 3.5*h2, $fn=3);
}

// 3 + 1/8
rmm0 = [[-2,2], [-2,1], [-1,1]];
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
