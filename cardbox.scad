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

// hypotenuse: given angle * adjacent_base length
function hypa(a, b) = (let (h=b*tan(a)) sqrt(b*b+h*h));
function hypo(a, h) = (let (b=h/tan(a)) sqrt(b*b+h*h));

// poke holes (children(1)) in children(0) through the y axis
// x: [x0, step, xm]
// z: [z0, step, zm]
module gridify(x, z) {
  // difference() 
  // union() {
  for(x = [x[0]: x[1] : x[2]]) 
    for (z = [x[0]: z[1] : z[2]]) 
      echo("xz=", [x, z]);
      translate([x, 0, z]) children(1);

  // }
  children(0);
}

// translate([0, -40, 0]) {
//   gridify([0, 4, 20], [0, 5, 20])
//   cube([20, 20, 20]);
//   translate([0, -5, 0]) cube([3, 30, 3]);
// }
a = 18; 
dz = 6;      // top of slot
iw = 5.1;    // width of slot_interior
xb = (h-dz)*tan(a); // length of holder after tilt...
lt = l+xb;   // length total
echo("xb, lt, lwh=", [xb, lt, l,  w, h], "tan(a)=", tan(a), "hyp(a,iw)=", hypa(a,iw));
 // TODO: snap-on top!

module holder(a=a) {
  xb = (h-dz)*tan(a); // length of holder after tilt...
  ha = (h-dz); echo(); // top to slot
  fw = iw + 2*t0;    // full width of slot box
  hb = ha - fw / cos(a);  // down from top to rotation point
  hr = ha - hb;
  echo("xb=", xb,"ha=", ha, "hb=", hb, "hr=", hr);
  wb = w0;
  intersection() 
  {
  translate([p-xb, 0, 0]) cube([xb, w, h]);
  {
  rotatet([0, -a, 0], [0, 0, dz]) {
  translate([fw,0,0]) cube([7, w, 1.2*h]); // fill w/ giant block, then intersect
  {
  bh = t0+ ((a>1) ? ha/cos(a) : ha); echo("bh=", bh);
  translate([0, 0, dz]) box([fw, w, bh], t0); // main box
  translate([0, 0, bh-6])
    rotatet([0,-18,0], [iw, 0, 2 * t0]) 
    cube([iw+t0, w, t0]);  // bottom shelf
  }
  }
  }
  }
  // translate([-t0,0,-bl]) rotate([-90,0,0]) cylinder([iw+2*t0, w, bl]);
}
module holder2(a = a) {
  iw = 5.1; fw = iw+2*t0; bh = h0 + h0 * tan(a) ;
  rotatet([0, -a, 0], [0, 0, bh*.5])
 * % translate([-iw-t0 ,0, t0])  box([fw, w, bh]);
}
holder2();
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
module hslot(dz=dz, dx = 0) {
  sw = 6; sh = 4;
  difference() 
  {
    union() children();
    translate([dx-sw/2,t0, dz - sh]) cube([sw, w0, sh]);
  }
}
module cutaway(loc=loc) {
  if (loc != 0) {
    difference() {
      children(0);
      translate([-10, -pp, -10]) cube([l+20, 4, h+20]);
    }
  } else {
    children(0);
  }
}

sw = 10; sr = 10; rq = 10; // rq if different from sr
cutaway()
hslot() {
  ds = .1;
  holder();
  slotify([h*(1-ds)+sr,[sw, sr],t0+4*p],[l-t0-2*p,w/2,h*ds], undef, rq)
  box([l, w, h], t0);
}
ramp();

if (loc != 0)
 color("pink") translate([-xb, w+t0, h+0])  cube([lt, 1, 1]);

dy = 10; dr = 5; // rCube test
* translate([0, 0, 0]) roundedCube([dy, dy/2, 3], dr, true);
* roundedRect([dy, dy], 1);

// atan(6/88) = 4;
// atan(7/88) = 4.5;
a2 = 3.2;
if (loc != 0 )
 translate([0, 0, .1]) rotatet([0, a2, 0], [90, 0, 1])
 card([4, 2, 1]);
 

