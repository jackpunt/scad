use <mylib.scad>;
p = .001; pp = 2*p;
t0 = 1.0;
l0 = 92.4;
w0 = 60.4;
h0 = 27.4;
l = l0 + 2*t0;
w = w0 + 2*t0;
h = h0 + t0;

loc = 0;

a = 25.15; 
sa = sin(a); // .425
lb = 5.1;
xb = lb/sin(a)-t0; // length of top opening after tilt...
module holder() {
  wb = w0;
  hb = 9;
  hi = h*.9;
  echo("xb=", xb);
  intersection() 
  {
  translate([p-xb, 0, h-hi]) cube([xb, w, hi]); // TODO: snap-on top!
  { // hole:
  rotatet([0, -a, 0], [0, 0, h-hb+t0]) {
  cube([7, w, 1.3*h]); // fill
  translate([-lb, 0, h-hb])
  {
  bl = 12;
  cube([lb, w, t0]);  // bottom shelf
  translate([-t0,0,-bl]) box([lb+2*t0, w, bl/sa]); // main box
  }
  }
  }
  }
}

vz = 2; vx = 60; fl = 3; vy = 5;
module ramp(vx = 40, ve = 0) {
div([vz, w, vx], 0, 0, fl);
intersection() 
{
// translate([ve, 0, 0])  rotatet([0, 0, 0], [0, 0, vz]) 

union() {
for (y = [0: (w-vy)/4: w-vy])
  translate([ve,y,0]) cube([vx, vy, vz]);
}
cube([l, w, h]);
}
}
// add horizontal slot to children(0)
module hslot(dz=5, dx = l0) {
   difference() 
  {
    children(0);
    translate([dx-3,t0,t0+vz+1]) 
     cube([6, w0, dz]);
  }
}
holder();

sw = 10; sr = 10; dz=.3; rq = 10; // rq if different from sr
hslot(3, 0) 
slotify([h*(1-dz)+sr,[sw, sr],t0+4*p],[l-t0-2*p,w/2,h*dz], undef, rq)
box([l, w, h], t0);
ramp();

if (loc != 0)
 color("pink") translate([t0-xb, -t0, h])  cube([105, 1, 1]);

dy = 10; dr = 5;
* translate([0, 0, 0]) roundedCube([dy, dy/2, 3], dr, true);
*roundedRect([dy, dy], 1);
