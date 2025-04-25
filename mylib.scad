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
module roundedRect(sxy = 10, rc = 2, k = 0) {
  s = is_list(sxy) ? sxy : [sxy,sxy];
  dx = s[0]; dy = s[1];
  r = is_list(rc) ? rc : [rc, rc, rc, rc];
  intersection()
  {
    hull() {
      translate([r[0],       r[0]]) circle(r=r[0]);
      translate([r[1],    dy-r[1]]) circle(r=r[1]);
      translate([dx-r[2], dy-r[2]]) circle(r=r[2]);
      translate([dx-r[3],    r[3]]) circle(r=r[3]);
   }
   translate([k-p, -p])  square([s[0]+pp, s[1]+pp]);
  }
}


// A Z-extruded roundedRect: (kut across the YZ plane)
// sxy: [dx, dy, dz]
// r: radius (2), k: keep/cut (0), t = thick (t0)
module roundedTube(sxy=10, r = 2, k, t = t0) {
   s = is_list(sxy) ? sxy : [sxy,sxy,sxy];
   dx = s[0]; dy = s[1];
   rs = [dx, dy];
   linear_extrude(height = s[2]) 
   {
   sx = (dx-2*t)/dx; sy = (dy-2*t)/dy;
   dt = k<0 ? 1 +pp : -(1+pp);
   kd = (k+dt)/sx;
   difference() 
    {
    roundedRect(rs, r, k);
    translate([t, t])
    scale([sx, sy])
    roundedRect(rs, r, kd);
   }
  }
}
// test for k:
*translate([0, -60, 0]) rotate([0, -90, 0])
 roundedTube([40, 40, 8], [15, 4,2,2], -15, 1);

// a roundedRect divider across the YZ plane of a box:
// hw: [z,y]; r: radius ([r,r,r,r])
// t: thick (dx = t0)
// k>0 keep bottom/cut top; k<0 cut bottom/keep top
// k == 0 keep all
module div(hw = 10, r = 2, k, t = t0) { 
 translate([t, 0, 0])
 rotate([0, -90])
 linear_extrude(height = t)
 roundedRect(hw, r, k);
}

// a slot shaped hull; (in YZ plane)
// hrt: [h: height, r: radius, t = t0]
// rottr: rotate & translate ([0, -90, 0, tr=[t+p, 0, 0]]) 
module slot(hrt, rott) {
    h=is_undef(hrt[0]) ? 40 : hrt[0];
    r=is_undef(hrt[1]) ?  5 : hrt[1]; 
    t=is_undef(hrt[2]) ? t0 : hrt[2];
    rott = is_undef(rottr) || is_undef(rottr[0]) ? [0, -90, 0] : rottr;
    tr= is_undef(rott[3]) ? [t+p, 0, 0] : rott[3];
    translate(tr) // align after rotate
    rotate(rott)  // ignore rott[3]
    hull() {
      dup([h, 0, 0]) cylinder(h=t+2*p, r=r);
   }
}

// make a slot in the yz plane
// hrt: [h: dz (40), r: slot_radius (5), t: (t0)]
// tr: translate onto wall ([0,0,0])
// rot: rotate ([0, 90, 0])
// sq: [size: radius (2*t), quad: (1)]
module slotify(hrt, tr=[0,0,0], rot, sq) {
    h=is_undef(hrt[0]) ? 40 : hrt[0];
    r=is_undef(hrt[1]) ?  5 : hrt[1]; 
    t=is_undef(hrt[2]) ? t0 : hrt[2];
    module maybe_rc(sqr) {
      if (!is_undef(sqr)) {
        rad = is_undef(sq[0]) ? 2*t : sq[0];
        quad = is_undef(sq[1]) ? 1 : sq[1]; 
        rcr = is_undef(rot) ? [0,-90,0]: rot;
        rc([tr[0]+t, tr[1]+r, h+tr[2]], rcr, 3, rad)
        rc([tr[0]+t, tr[1]-r, h+tr[2]], rcr, 2, rad)
        children();
      } else {
        children();
      }
    } 
    maybe_rc(sq)
    difference()
    {
        children(0);
        translate(tr) slot(hrt, rot); // TODO: rot[3] = tr
    }
}
