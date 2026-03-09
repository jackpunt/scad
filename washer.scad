use <mylib.scad>;

p = .001;
pp = 2 * p;
f = .18;            // not sure
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
sample = false;

inch = 25.4;
prad = (3/8 * inch) / 2;

echo("prad=", prad);
// h: height (20)
// crad: corner radius (inch/2)
module spipe(h = 20, crad = inch/2) {
  trr([0, 0, -prad])
  color("white") {

  trr([prad + crad, 0, prad, [90, 0, 0]]) cylinder(h = h, r = prad);
  trr([0, prad + crad, prad, [0, -90, 0]]) cylinder(h = 3*h, r = prad);
  rotate_extrude(angle=90) 
    translate([prad+crad, prad]) circle(r = prad, $fn=20);
  }
  brad = 12;
  color("#dfb80a")
  trr([crad+prad, -h, 0, [90, 0, 0]])
  difference() {
    cylinder(h = 30, r = 12);
   trr([0, 0, h-(10-p)])  cylinder(h = 20, r = 6);
  }

}


spipe();
