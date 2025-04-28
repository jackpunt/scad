use <mylib.scad>;
p = .001; pp = 2*p;
t0 = 1.0;
l0 = 92.4;
w0 = 60.4;
h0 = 27.4 + 3.1; // extend for ramp!
l = l0 + 2*t0;
w = w0 + 2*t0;
h = h0 + t0;

loc = 0;

a = 20.15; 
sa = sin(a); // .425
lb = 5.1;
xb = lb/sin(a)-t0; // length of top opening after tilt...
module holder() {
  wb = w0;
  hb = 9;
  hi = h*.9;
  intersection() 
  {
  translate([p-xb, 0, h-hi]) cube([xb, w, hi]); // TODO: snap-on top!
  { // hole:
  rotatet([0, -a, 0], [0, 0, h-hb+t0]) {
  cube([7, w, 1.2*h]); // fill w/ giant block, then intersect
  translate([-lb, 0, h-hb])
  union(){
  bl = 16;
  rotatet([0, -23, 0], [lb+2, 0, t0])
  translate([-.5, 0, 1]) cube([lb+1, w, t0]);  // bottom shelf
  translate([-t0,0,-bl]) box([lb+2*t0, w, bl/sa]); // main box
  }
  }
  }
  }
}
module card(tr = [2, 2, 4]) {
  translate(tr) color("pink") cube([88.5, 60.4, 1]);
}

// vz: height of ramp @ vx: bump @ 
vz = 4.; vx = .4*l; fl = 2; vy = 5.6; // fl: flat length
module ramp(vx = vx, vz = vz, ve = 0) {
  sa = sin(a2); ca = cos(a2);
  vz = (l-vx)*sa ; vzt = vz+t0; // vz = 3.16
  intersection() { union() {
  rotatet([0, -a2, 0], [vx, 0, vz+t0])
  for (y = [0: (w-vy)/4: w-vy])
    translate([ve,y,0]) cube([vx, vy, vz+t0]);
  translate([vx, 0, 0]) cube([2.4, w, vz+t0]);
  }
  translate([ve,0,0]) cube([vx, w, vz+t0]);
  }
  dr = 14; 
  intersection() {
   translate([vx+(dr/2+.0)*t0, w/2, vzt/2]) rotate([-90, 0, 0]) cube([dr, vzt, w], true);
  color("blue")
   translate([vx+(dr/2+0)*t0, w/2, vzt/2]) 
   rotatet([0, a2, 0], [-dr/2, 0, vzt/2]) 
   rotate([-90,0,0]) cube([dr, vzt, w], true); // no compound rotation!
  }

}

// add horizontal slot to children(0)
module hslot(dz=4, dx = 0) {
  difference() 
  {
    union() children();
    translate([dx-3,t0,t0+1]) cube([6, w0, dz]);
  }
}
module cutaway(loc=loc) {
  if (loc != 0) {
    difference() {
      children(0);
      translate([-10, -pp, 0]) cube([l+10, 4, h]);
    }
  } else {
    children(0);
  }
}

sw = 10; sr = 10; dz=3; rq = 10; // rq if different from sr
cutaway()
hslot() {
  ds = .1;
  holder();
  slotify([h*(1-ds)+sr,[sw, sr],t0+4*p],[l-t0-2*p,w/2,h*ds], undef, rq)
  box([l, w, h], t0);
}
ramp();

if (loc != 0)
 color("pink") translate([t0-xb, -t0, h])  cube([105, 1, 1]);

dy = 10; dr = 5;
* translate([0, 0, 0]) roundedCube([dy, dy/2, 3], dr, true);
*roundedRect([dy, dy], 1);

// atan(6/88) = 4;
// atan(7/88) = 4.5;
a2 = 3.2;
if (loc != 0 )
 translate([0, 0, .1]) rotatet([0, a2, 0], [90, 0, 1])
 card([4, 2, 1]);
 

