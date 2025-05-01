$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

// pairwise multiplication
function amul(a, b) = [for (i = [0:len(a) - 1]) a[i] * b[i]];
// pairwise subtraction
function adif(a, b) = [for (i = [0:len(a) - 1]) a[i] - b[i]];

// move objects to new location
// ndx: choice of location
// trans: array of [x,y,z {, [rx, ry, rz]}]
module atrans(ndx = 0, atran = [ 0, 0, 0 ]) {
  ndx = ndx >= len(atran) ? 0 : ndx;
  echo("atrans(ndx=", ndx, "atran=", atran, ")");
  tranr = atran[ndx];
  rot = is_undef(tranr[3]) ? [ 0, 0, 0 ] : tranr[3];
  trans = [ tranr[0], tranr[1], tranr[2] ];
  echo("trans=", trans, "rot=", rot);
  translate(trans) rotate(rot) children();
}

// A hollow box:
// lwh: [length_x, width_y, height_z],
// t: ([t0,t0,t0]) thick 'translate'
// d: delta --> size of box to remove ([2, 2, 1-p])
// -
// diff() { cube(lwh); tr(txyz) cube(adif(lwh, amul(d, txyz))) }
module box(lwh = [ 10, 10, 10 ], t = t0, d) {
  t = is_undef(t) ? t0 : t;             // wall thickness
  txyz = is_list(t) ? t : [ t, t, t ];  // in each direction
  d = is_list(d) ? d : [ 2, 2, 1 - p ]; // reduce inner_cube by txyz
  dxyz = adif(lwh, amul(d, txyz));
  // echo("lwh=", lwh, "d=", d, "txyz=", txyz, "dxyz=", dxyz);
  difference() {
    cube(lwh);
    translate(txyz) cube(dxyz); // -2*bt or +2*p
  }
}
// stack of children()
// n: number
// dxyz: each iteration
// rot: rotate from dx --> dy or dz
module astack(n, d, rot) {
  dxyz = is_list(d) ? d : [ d, 0, 0 ];
  r = is_undef(rot) ? .1 : rot;
  rxyz = is_list(r) ? r : [ 0, 0, 0 ];
  echo("dxyz=", dxyz) for (i = [0:n - 1]) {
    rotate(rxyz) dup([ i * dxyz[0], i * dxyz[1], i * dxyz[2] ]) children();
  }
}

function as3D(ary, a2) = [ ary[0], ary[1], is_undef(ary[2]) ? a2 : ary[2] ];
// shift center of rotation, then rotate, shift back
// rot: [ax, ay, az] the rotation
// cr:  [dx, dy, dz] the center of rotation
module rotatet(rot = [ 0, 0, 0 ], cr = [ 0, 0, 0 ]) {
  rcr = is_undef(rot[3]) ? cr : rot[3];
  translate(rcr) rotate(as3D(rot))
      translate(amul(cr, [ -1, -1, -1 ])) // [-cr[0], -cr[1], -cr[2]]) //
      children();
}

// duplicate, with translate & rotate:
// suitable inside hull() { ... }
// tr: translate (after rotate)
// rott: rotate (with rott[3] as center)
module dup(tr = [ 0, 0, 0 ], rott = [ 0, 0, 0 ]) {
  children(0);
  cr = is_undef(rott[3]) ? [ 0, 0, 0 ] : rott[3];
  translate(tr) rotatet(rott, cr) children(0);
}

// New implementation: MCAD
// dxyz: [dx, dy, dz]
// r: corner radius
// sidesonly: round xy, flat on z?
// center:
module roundedCube(dxyz, r, sidesonly, center) {
  s = is_list(dxyz) ? dxyz : [ dxyz, dxyz, dxyz ];
  // echo("roundedCube: s=", s, "r=", r);
  translate(center ? -s / 2 : [ 0, 0, 0 ]) {
    if (sidesonly) {
      *linear_extrude(s[2]) roundedRect([ s[0], s[1] ], r);
      hull() {
        translate([ r, r ]) cylinder(r = r, h = s[2]);
        translate([ r, s[1] - r ]) cylinder(r = r, h = s[2]);
        translate([ s[0] - r, r ]) cylinder(r = r, h = s[2]);
        translate([ s[0] - r, s[1] - r ]) cylinder(r = r, h = s[2]);
      }
    } else {
      hull() {
        translate([ r, r, r ]) sphere(r = r);
        translate([ r, r, s[2] - r ]) sphere(r = r);
        translate([ r, s[1] - r, r ]) sphere(r = r);
        translate([ r, s[1] - r, s[2] - r ]) sphere(r = r);
        translate([ s[0] - r, r, r ]) sphere(r = r);
        translate([ s[0] - r, r, s[2] - r ]) sphere(r = r);
        translate([ s[0] - r, s[1] - r, r ]) sphere(r = r);
        translate([ s[0] - r, s[1] - r, s[2] - r ]) sphere(r = r);
      }
    }
  }
}

// translate, maybe mark child with #
// clang-format off
module show(ss=false) {  if (ss)    #children(0);  else    children(0); }
// clang-format on

// replace square corner with a rounded corner
// tr: XYZ of corner;
// rott: orientation of corner ([0,0,0, [0,0,0]]);
// q: quadrant [++, +-, --, -+]
// rad: radius;
// t = t0 (thickness)
// ss: show corner
// ambient: p
module rc0(tr = [ 0, 0, 0 ], rot = [ 0, 0, 0 ], q = 0, rad = 5, t = t0, ss = false) {
  rp = p - rad;

  cs = [ [ 1, 1, 1 ], [ 1, -1, 1 ], [ 1, -1, 1 ], [ 1, 1, 1 ] ][q];
  qs = [ [ 1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ], [ -1, 1, 1 ] ][q];
  org = [ [ -p, -p, -p ], [ -p, rp, -p ], [ rp, rp, -p ], [ rp, -p, -p ] ][q];
  add = amul([ rad, rad, -pp ], qs);

 difference() 
  {
    children(0);
    show(ss) 
    color("blue") 
    translate(tr)
    difference() {
      translate(org) cube([ rad + pp, rad + pp, t + pp ]);
      translate(add) cylinder(t + 2* pp, rad, rad);
    }
  }
}

// tr: position of corner to be rounded
// rotId: [x-axis: [+-90, 0, 0], y-axis: [0, +-90, 0], z-axis: [0, 0, +-90]]
// q: index of orientation of corner to be rounded: [ll, ul, ur, lr]
// t: thickness of wall to remove
// ss: show cut with '#'
module rc(tr = [ 0, 0, 0 ], rotId = 1, q = 0, rad = 5, t = t0, ss = false) {
  rot = [ [ 0, -90, 0 ], [ -90, 0, 0 ], [ 0, 0, -90 ] ][rotId];
  r2 = rad / 2;
  t2 = t / 2;

  qs = [ [ 1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ], [ -1, 1, 1 ] ][q];
  qsr = amul(qs, [ r2, r2, -t ]); // quadrant select cylinder sector

  cs0 = [
     [[ 0, 1, 1 ], [ 0, -1, 1 ], [ 0, -1, -1 ], [ 0, 1, -1 ]], // x-axis
     [[ 1, 0, -1 ], [ 1, 0, 1 ], [ -1, 0, 1 ], [ -1, 0, -1 ]], // y-axis
     [[ 1, -1, 0 ], [ -1, -1, 0 ], [ -1, 1, 0 ], [ 1, 1, 0 ]], // z-axis
   ];
  cs = cs0[rotId][q];                  // offset cyl_cut to corner
  csr = amul([r2,r2,r2], cs);

  p=.1; pp = 2*p; p4=p*4;
  difference()
  {
    children(0);
    show(ss) 
    // color("blue")  
    translate(tr)  translate(csr) rotate(rot) 
    difference() 
    {
      cube([ rad + pp, rad + pp, t + pp ], true);
      translate(qsr) cylinder(t+t, rad, rad); // z-axis from 0..t
    }
  }
}

// 2D shape:
// sxy: [dx = sxy, dy = sxy]
// rc:  [(0,0), (0,dy), (dx, dy), (dx, 0)]
module roundedRect(sxy = 10, rc = 2, k = 0) {
  s = is_list(sxy) ? sxy : [ sxy, sxy ];
  k = is_undef(k) ? 0 : k;
  dx = s[0];
  dy = s[1];
  r = is_list(rc) ? rc : [ rc, rc, rc, rc ];
  intersection() {
    hull() {
      translate([ r[0], r[0] ]) circle(r = max(p, r[0]));
      translate([ r[1], dy - r[1] ]) circle(r = max(p, r[1]));
      translate([ dx - r[2], dy - r[2] ]) circle(r = max(p, r[2]));
      translate([ dx - r[3], r[3] ]) circle(r = max(p, r[3]));
    }
    translate([ k - p, -p ]) square([ s[0] + pp, s[1] + pp ]);
  }
}
module pipe(rrh = 10, t = t0) {
  dx = is_list(rrh) && !is_undef(rrh[0]) ? rrh[0] : rrh;
  dy = is_list(rrh) && !is_undef(rrh[1]) ? rrh[1] : rrh;
  dz = is_list(rrh) && !is_undef(rrh[2]) ? rrh[2] : rrh;
  sx = (dx - t) / dx;
  sy = (dy - t) / dy;
  linear_extrude(height = dz) difference() {
    circle(dx);
    scale([ sx, sx ]) circle(dx);
  }
}

// A Z-extruded roundedRect: (kut across the YZ plane)
// sxy: [dx, dy, dz]
// r: radius (2), k: keep/cut (0), t = thick (t0)
module roundedTube(sxy = 10, r = 2, k = 0, t = t0) {
  s = is_list(sxy) ? sxy : [ sxy, sxy, sxy ];
  dx = s[0];
  dy = s[1];
  rs = [ dx, dy ];
  linear_extrude(height = s[2]) {
    sx = (dx - 2 * t) / dx;
    sy = (dy - 2 * t) / dy;
    dt = k < 0 ? 1 + pp : -(1 + pp);
    kd = (k + dt) / sx;
    difference() {
      roundedRect(rs, r, k);
      translate([ t, t ]) scale([ sx, sy ]) roundedRect(rs, r, kd);
    }
  }
}
// test for k:
*translate([ 0, -60, 0 ]) rotate([ 0, -90, 0 ])
    roundedTube([ 40, 40, 8 ], [ 15, 4, 2, 2 ], -15, 1);

// a roundedRect divider across the YZ plane of a box:
// hwx: [z,y,x];
// r: radius ([r,r,r,r])
// t: thick (dx = t0)
// k: (0) k>0 keep bottom/cut top; k<0 cut bottom/keep top
// k == 0 keep all
module div(hwx = 10, r = 2, k, t = t0) {
  dx = is_undef(hwx[2]) ? 0 : hwx[2];
  translate([ dx + t, 0, 0 ]) rotate([ 0, -90 ]) linear_extrude(height = t)
      roundedRect([ hwx[0], hwx[1] ], r, k);
}

// a slot shaped hull; (in YZ plane)
// hrt: [h: height, r: radius [width, rad], t = t0]
// rottr: rotate & translate ([0, -90, 0, tr=[t+p, 0, 0]])
module slot(hrt, rottr) {
  h = is_undef(hrt[0]) ? 40 : hrt[0];
  r = is_undef(hrt[1]) ? 5 : hrt[1];
  t = is_undef(hrt[2]) ? t0 : hrt[2];
  rott = is_undef(rottr) || is_undef(rottr[0]) ? [ 0, -90, 0 ] : rottr;
  tr = is_undef(rott[3]) ? [ t + p, 0, 0 ] : rott[3];
  rw = is_list(r) ? r[0] : r; // slot radius: width/2
  rr = is_list(r) ? r[1] : r; // corner radius
  rm = min(rw / 2, rr);
  translate(tr)          // align after rotate
      rotate(as3D(rott)) // include rott[3]
      translate([ -h / 2, -rw, -t / 2 ]) roundedCube(
          [ h, 2 * rw, t ], rr, true); // transpose coords so 'sides only' works
}
module align(tr, rott) {
  // rott = is_undef(rottr) || is_undef(rottr[0]) ? [0, -90, 0] : rottr;
  // tr= is_undef(rott[3]) ? [t+p, 0, 0] : rott[3];
  translate(tr)     // align after rotate
      rotatet(rott) // include rott[3]
      children(0);
}

// make a slot in the yz plane
// hrt: [h: dz (40), r: slot_radius|[w, r] (5), t: (t0)]
// tr: translate onto wall ([0,0,0])
// rot: rotate ([0, -90, 0]) [rx, ry, rz, [cx, cy, cz]]
// rq: [radius: (2*t), q1: (3), q2: (2)]; for yz plane
module slotify(hrt, tr = [ 0, 0, 0 ], rot, rq, ss = false) {
  h = is_undef(hrt[0]) ? 40 : hrt[0];
  r = is_undef(hrt[1]) ? 5 : hrt[1];
  t = is_undef(hrt[2]) ? t0 : hrt[2];
  rott = is_undef(rot) ? [ 0, -90, 0 ] : rot;
  echo("slotify: hrt=", [ h, r, t ]);
  module maybe_rc0(rqq, ss = ss) {
    if (!is_undef(rqq)) {
      rq = is_list(rqq) ? rqq : [rq]; // rq as simple radius
      rad = is_undef(rq[0]) ? 2 * t0 : rq[0];
      q1 = is_undef(rq[1]) ? 3 : rq[1];
      q2 = is_undef(rq[2]) ? 2 : rq[2];
      rcr = is_undef(rot) ? [ 0, -90, 0 ] : rot;
      rw = is_list(r) ? r[0] : r; // slot width/2
      rr = is_list(r) ? r[1] : r; // corner radius
      rm = rr;                    // min(rw, rr);         // limit radius
      // echo ("[rq, rw, rr, rm]", [rq, rw, rr, rm])
      echo("[tr, rq, rw, rr, rm, rcr]", [ tr, rq, rw, rr, rm, rcr ]);
      // rc0([tr[0]+t, tr[1]+(rw-p*6), h+tr[2]-rm], rcr, q1, rad, t)
      // rc0([tr[0]+t, tr[1]-(rw-p*5), h+tr[2]-rm], rcr, q2, rad, t)
      // [0,-90,0]:[-t/2,...]; [0,90,0]:[+t/2, ...];
      trt1 = adif(tr, [ -t, -(rw - p * 6), rm - h ]);
      trt2 = adif(tr, [ -t, +(rw - p * 5), rm - h ]);
      // trt2 = [tr[0]+t/2, tr[1]-(rw-p*5), tr[2]+h-rm-rw-rr+t];
      translate(trt1) color("blue") cube([ 1, 1, 1 ], true);
      translate(trt2) color("red") cube([ 1, 1, 1 ], true);
      rc0(trt1, rcr, q1, rad, t, ss) rc0(trt2, rcr, q2, rad, t, ss) children();
    } else {
      children();
    }
  }
  maybe_rc0(rq) difference() {
    children(0);
    if (ss) {
# translate(tr) slot([ h, r, t ], rot);
    } else {
      translate(tr) slot([ h, r, t ], rot);
    }
  }
}
