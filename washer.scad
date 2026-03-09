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
    translate([prad+crad, prad]) circle(r = prad+.5, $fn=20);
  }
  brad = 12;
  color("#dfb80a")
  trr([crad+prad, -h, 0, [90, 0, 0]])
  difference() {
    cylinder(h = 30, r = 12);
   trr([0, 0, h-(10-p)])  cylinder(h = 20, r = 6);
  }
}
s = inch;
tabh = s*.25+p;
module fixhalf(part = 3, s = s) {
  ofy = s * .6;
  difference() {
    trr([0, ofy, 0]) cube([2*s, 1.5*s, s * .5], true);
    if (part == 1 || part == 0) trr([0, ofy, s*.25-p]) cube([2*s+pp, 1.5*s+pp, s*.5], true);
    if (part == 2 || part == 0) trr([0, ofy, -s*.25+p]) cube([2*s+pp, 1.5*s+pp, s*.5], true);
    // cut slots for tabs in part==2
    if (part == 2 || part == 3) {
      tabs(false); // with hole for locking dowel
    }
  }
  // tabs on part==1:
  if (part == 1 || part == 3) {
    tabs(true);
  }

}

module tabline(n = 3, dy = 0) {
  hr = inch/16;
  th = tabh;
  fr = f * .5;
  differenceN(2) {
    union() {
      for (dxi = [1: n]) {
        trr([4-8*dxi, 0, 0]) cube([4, 10, th]);
      }
      if (!hm)
        trr([3, 5, s*.125, [0, -90, 0]]) cylinder(h = n * 8 + 6, r = hr+fr); 
    }
    if (hm)
      trr([3, 5, s*.125, [0, -90, 0]]) cylinder(h = n * 8 + 6, r = hr+fr); 
  }
}
module tabs(hm = true) {
  hr = inch/16;
  th = tabh;
  fr = f * .5;
  difference() {
    union() {
      trr([-4, 0, 0]) cube([4, 10, th]);
      trr([-12, 0, 0]) cube([4, 10, th]);
      trr([-20, 0, 0]) cube([4, 10, th]);
      if (!hm)
        trr([3, 5, s*.125, [0, -90, 0]]) cylinder(h = 30, r = hr+fr); 
    }
    if (hm)
      trr([3, 5, s*.125, [0, -90, 0]]) cylinder(h = 30, r = hr+fr); 
  }
}
module fixture(part = 3, s = inch) {
  fixhalf(1);
  %fixhalf(2);
}

spipe();

fixture();
