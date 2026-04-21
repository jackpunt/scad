use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
module dice(tr=[0,0,0], ds = ds) {
  color("#DDDDDD")
  translate(tr) roundedCube([ds,ds,ds], 2, false);
}

module cup(t = t0) {
  dx = 40;
  dy = 20;
  dz = 60;
  rc = 3;
  trr([0, 0, -dz *0]) {

  color("red")
  linear_extrude(height = t) 
  trr([-dx/2, -dy/2, 0])     roundedRect([dx, dy], rc);
  linear_extrude(height = dz, scale = [2, 3]) 
  difference() {
    trr([-dx/2, -dy/2, 0])     roundedRect([dx, dy], rc);
    trr([-dx/2+t, -dy/2+t, 0]) roundedRect([dx-2*t, dy-2*t], rc);
  }
  }
}

// dice size
ds = 16;
// robber size
rs = 15;

astack(2, [-ds*1.1, 0, 0]) trr([0, -ds/2, t0]) dice();
cup();
