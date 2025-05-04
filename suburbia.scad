use<mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

d0 = 2.05;   // mm per cardbord
hr = 26;     // mm on edge
sqrt3=sqrt(3);
sqrt3_2=sqrt(3)/2;


// show actual radius of poly cylinder
module fine_circle(r = 10, g=24){
  children(0);
  $fn = g;
 # circle(r);
}

//
module polycylinder(h, fn = 6, r=10, cz = false) {
  $fn = fn;
  linear_extrude(h )
  circle(r);
}

module hexBox(h=10, r=5, t=t0, cz = false) {
  translate([0, 0, cz ? -h/2 : 0])
  difference() {
    polycylinder(h, 6, r);
    translate([0, 0, -p])  
    polycylinder(h+pp, 6, r-t);
  }
}

function da(a, r) = (sin(60+a)-sin(60))*r;

tl = d0 * 30;
module hexstack(n = 10, c = "blue") {
  a = 30/n;
  for (i = [0 : n-1]) //
    color(i == n-1 ? "blue" : "pink")
    translate([0, da(a * i, hr)+2*t0, i*(d0+.05)]) //
    rotate([0, 0, a * i]) //
    polycylinder(d0, 6, hr);
}

module hextray(tl = tl, size = 2*hr + da(30, hr)) {
  w = size*sqrt3_2;
  echo("hextray: size=", size, "tl=", tl);
  module pos() {
    translate([0, 0, w/2]) rotate ([90, 0, 90]) children();
  }
  // slh = size+hr-size*.3; // slot height: sr at top of box
  slotify2([w, hr, 3*t0], [+tl/2, 0, w*.3], undef, 3)
  slotify2([w, hr, 3*t0], [-tl/2, 0, w*.3], undef, 3)
  // slotify([size, hr, 2*t0])
   box([tl, size, w], [t0,t0,-t0], [2,2,2], true);
  difference()
  {
    pos() hexBox(tl, size/2, t0, true); 
    translate([0,0,w/2+w/4+p]) cube([tl+pp, size, w/2], true);
  }
  pos() hexstack();

}
hextray();
