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
  rotr = def(rtr[3], [0,0,0]);
  r = def(r, 10);
  translate(as3D(rtr)) rotatet(rotr)
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
module oneCol(col = 0, h2 = h2, dz = 5) {
  rmm = [[-3,3], [-3,2], [-2,2], [-2, 1]];
  let(ac = abs(col), ce = (col % 2 == 0), rm=rmm[ac])
  for (row = [rm[0] : 1 : rm[1]]) 
    let(x = col*r/2, y = (ce) ? row*h2 : (row+.5)*h2)
      color(row == 0 && col == 0 ? "blue" : (row+col)%2 == 0? "green":"yellow")
        hexagon([x, y, 0], h2/sqrt3+p, t = dz );
}

// TODO: add hook to one end, subtract it from other
module frame(h2 = h2, w = 33, oz = -2) {
  // cut the adjacent hexes:
  difference() 
  {
    // make edge piece as trapezoid:
    intersection() 
    {
      w = 33; wt = 2*h2 + w/2;
      dz = 3+pp;
      translate([245, 0, oz])  cube([35, 3.8*h2, dz-pp], true);
      color("cyan") 
      triangle([wt, 0, oz, [0, 0, 180]], wt, 1);
    }
    // the adjacent hexes:
    oneCol(3);
  }
}

// translate(v = [-250, 0, -4]) 
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])

dup([0,0,0], [0, 0, -60])
frame(h2, 33, 0);

// TODO: partition as straight piece & corner piece:

