$fa = 1;
$fs = 0.4;
t0 = 1; p=.001; pp = 2*p;

// A hollow box:
// x: length, y: width, z: height, bt: thick
module box(x, y, z, t = t0) {
  difference()
  {
    cube([x, y, z]);
    translate([t,t,t])
    cube([x-2*t, y-2*t, z+p]); // -2*bt or +2*p
  }
}

// alternatively: make a 2D 'ring' and extrude it; see roundedTube()
// then add end cap; see tray()

// duplicate, with translate & rotate:
// suitable inside hull() { ... }
module dup(tr=[0,0,0], rot=[0,0,0]) {
    children(0);
    translate(tr) rotate(rot) children(0);
}

// New implementation: MCAD
module roundedCube(size, r, sidesonly, center) {
  s = is_list(size) ? size : [size,size,size];
  translate(center ? -s/2 : [0,0,0]) {
    if (sidesonly) {
      hull() {
        translate([     r,     r]) cylinder(r=r, h=s[2]);
        translate([     r,s[1]-r]) cylinder(r=r, h=s[2]);
        translate([s[0]-r,     r]) cylinder(r=r, h=s[2]);
        translate([s[0]-r,s[1]-r]) cylinder(r=r, h=s[2]);
      }
    }
    else {
      hull() {
        translate([     r,     r,     r]) sphere(r=r);
        translate([     r,     r,s[2]-r]) sphere(r=r);
        translate([     r,s[1]-r,     r]) sphere(r=r);
        translate([     r,s[1]-r,s[2]-r]) sphere(r=r);
        translate([s[0]-r,     r,     r]) sphere(r=r);
        translate([s[0]-r,     r,s[2]-r]) sphere(r=r);
        translate([s[0]-r,s[1]-r,     r]) sphere(r=r);
        translate([s[0]-r,s[1]-r,s[2]-r]) sphere(r=r);
      }
    }
  }
}

// replace square corner with a rounded corner
// tr: XYZ of corner; rot: orientation of corner;
// rad: radius; e: eccentricity = scale of y;
// t = t0 (thickness) ambient: p
module rc(tr=[0,0,0], rot=[0, 0, 0], q=0, rad=5, t = t0) {
    module pos() {
        translate(tr) rotate(rot) children(0);
    }
    org = [[-p,-p,-p], [-p,p-rad,-p], [-rad+p,-rad+p,-p], [-rad+p,-p,-p]][q];
    add = 
    [[rad, rad, -p], [rad, -rad, -p], [-rad,-rad,-p], [-rad,rad,-p]][q];

    difference() 
    {
        children(0);
        pos() difference() 
        {
        translate(org) cube([rad+pp, rad+pp, t+pp]);
        translate(add) cylinder(t+pp, rad, rad);
        }
    }
}

// test rc
*translate([0, -50, 0]) 
rc([0,00,0], [0, 0, 0], 0, 5) 
rc([0,20,0], [0, 0, 0], 1, 5) 
rc([20,20,0], [0, 0, 0], 2)
rc([20,00,0], [0, 0, 0], 3) 
cube([20, 20, t0]);


// 2D shape: 
// sxy: [dx = sxy, dy = sxy]
// rc:  [(0,0), (0,dy), (dx, dy), (dx, 0)] 
// k: keep/cut across X @ k
module roundedRect(sxy = 10, rc = 2, k = 0) {
  s = is_list(sxy) ? sxy : [sxy,sxy];
  dx = s[0]; dy = s[1];
  r = is_list(rc) ? rc : [rc, rc, rc, rc];
  intersection() 
  {
    translate([k, 0])
      square(s);
    hull() {
      translate([r[0],       r[0]]) circle(r=r[0]);
      translate([r[1],    dy-r[1]]) circle(r=r[1]);
      translate([dx-r[2], dy-r[2]]) circle(r=r[2]);
      translate([dx-r[3],    r[3]]) circle(r=r[3]);
   }
  }
}


// A Z-extruded roundedRect: (kut across the YZ plane)
// sxy: [dx, dy, dz]
// r: radius, k: keep/cut, t = thick
module roundedTube(sxy=10, r = 2, k, t = t0) {
   s = is_list(sxy) ? sxy : [sxy,sxy,sxy];
   dx = s[0]; dy = s[1];
   rs = [dx, dy];
   linear_extrude(height = s[2]) 
   {
   sx = (dx-1*t)/dx; sy = (dy-2*t)/dy;
   difference() 
    {
    roundedRect(rs, r, k);
    scale([sx, sy])
    translate([t, t])
    roundedRect(rs, r, k);
   }
  }
}

// a roundedRect divider across the YZ plane of a box:
// hw: [z,y]; r: radius ([r,r,r,r])
// k: keep/cut; t: thick (dx = t0)
module div(hw = 10, r = 2, k, t = t0) { 
 translate([t, 0, 0])
 rotate([0, -90])
 linear_extrude(height = t)
 roundedRect(hw, r, is_undef(k) ? -r : k);
}

// a slot shaped hull; (in YZ plane)
// hrt: [h: height, r: radius, t = t0]
// rot: rotate & translate ([0, -90, 0, tr=[t+p, 0, 0]]) 
module slot(hrt, rot) {
    h=is_undef(hrt[0]) ? 40 : hrt[0];
    r=is_undef(hrt[1]) ?  5 : hrt[1]; 
    t=is_undef(hrt[2]) ? t0 : hrt[2];
    rott = is_undef(rot) || is_undef(rot[0]) ? [0, -90, 0] : rot;
    tr= is_undef(rott[3]) ? [t+p, 0, 0] : rott[3];
    translate(tr) // align after rotate
    rotate(rott)
    hull() {
      dup([h, 0, 0])# cylinder(h=t+2*p, r=r);
   }
}

// make a slot in the yz plane
// hrt: [h: dz, r: slot_radius, t=t0]
// tr: translate onto wall ([0,0,0])
// rcs: [rot, quad, rad]
module slotify(hrt, tr=[0,0,0], rcs) {
    h=is_undef(hrt[0]) ? 40 : hrt[0];
    r=is_undef(hrt[1]) ?  5 : hrt[1]; 
    t=is_undef(hrt[2]) ? t0 : hrt[2];
    module maybe_rc(rcs) {
      if (!is_undef(rcs)) {
        rot = rcs[0]; q = rcs[1]; rad = rcs[2];
        rc(tr, rot, q, rad)
        children();
      } else {
        children();
      }
    } 
    // maybe_rc()
    difference()
    {
        children(0);
        translate(tr) slot(hrt, []);
    }
}
