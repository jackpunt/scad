use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
f = .18;
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
// w: x_width of frame piece (h2*33/80)
// oz: offset_z
module frame(h2 = h2, w = 33, oz = -2) {
  w = def(w, h2*33/80);
  dz = 3+pp;       // thickness of frame
  col = 3;         // placement of frame
  // cut the adjacent hexes:
  difference() 
  {
    // make edge piece as trapezoid:
    intersection() 
    {
      H = h2/2; R = h2/sqrt3;
      k =  R * (3 * col + 1) / 2; // R/2 + col * 1.5 * R;
      wt = (k + w)/1.5;
      // echo("frame: col, H, R, k, wt=", [col, H, R, k, wt]);
      fh = 4*h2;
      translate([k, -fh/2, oz-dz/2+p])
        cube([w, fh, dz-pp], false);
      // color("cyan") 
      triangle([wt, 0, oz, [0, 0, 180]], wt, t=dz, center = true);
    }
    // the adjacent hexes:
    translate([0, 0, oz]) oneCol(col, h2, dz+pp);
  }
}
module color1(cname) {
  color(name) children(0);
  for (i = [1 : $children]) children(i);
}

// translate(v = [-250, 0, -4]) 
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])
// dup([0,0,0], [0, 0, -60])

// dup([0,0,.1], [0, 0, 60], c2="red")
frame(h2, 38);

// TODO: partition as straight piece & corner piece:

