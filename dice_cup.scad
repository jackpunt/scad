use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
module dice(tr=[0,0,0], ds = ds) {
  color("#DDDDDD")
  translate(tr) roundedCube([ds,ds,ds], 2, false);
}

module cup(t = t0) {
  // roundedRect fustrum:
  // vt: offset of base & walls (thickness)
  module vcup(base_xyc, top_xyz, vt = 0) {
    bx = base_xyc[0] - 2*vt;
    by = base_xyc[1] - 2*vt;
    rc = base_xyc[2] - vt;
    bxy = [bx, by];
    scal = [(top_xyz[0] - 2*vt)/bx, (top_xyz[1] - 2*vt)/by];
    trr([0, 0, vt])
    linear_extrude(height = top_xyz[2], scale = scal) 
    trr([-bx/2, -by/2, 0]) roundedRect(bxy, rc);
  }

  rc = 3;
  dz = 47;
  dx0 = 30;
  dy0 = 47;
  dx1 = 30;
  dy1 = 47;
  vt = 1.3;

intersection() 
{
  // cup:
  difference() {
    vcup([dx0, dy0, rc], [dx1, dy1, dz], 0);
    vcup([dx0, dy0, rc], [dx1, dy1, dz], vt);
  }
  cube(size=[dx1+2*vt, dy1+2*vt, 169], center = true);
}
}

// dice size
ds = 16;
// robber size
rs = 15;

// astack(2, [-ds*1.1, 0, 0]) trr([0, -ds/2, t0]) dice();
cup();
