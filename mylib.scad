$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

// default value
function def(var, val) = is_undef(var) ? val : var;
// pairwise multiplication
function amul(a, b) = [for (i = [0:len(a) - 1]) a[i] * (is_list(b) ? b[i] : b)];
// pairwise subtraction
function adif(a, b) = [for (i = [0:len(a) - 1]) is_num(a[i]) ? (a[i] - (is_num(b[i]) ? b[i] : 0)) : a[i]];
// select element from array:
function selectNth(n, ary) = [for(elt = ary) elt[n]];
// conjoin elements of subarrays
function flatten(l) = [ for (a = l) for (b = a) b ] ;

// recursive sum of numbers in array
function sum(ary = [], n) = 
  !is_list(ary) ? 0 :
  let(nn = is_undef(n) ? len(ary) - 1 : n)
    (nn < 0) ? 0 : (n == 0) ? ary[0] : ary[nn] + sum(ary, nn-1);


// n: union first n children, subtract the rest (1)
// r: ignore the final r children (0)
module differenceN(n = 1, r = 0) {
  if ($children-1-r >= n) {
    difference() {
      children([0 : n-1]);
      children([n: $children-1-r]);
    }
  } else {
      children([0 : n-1]);
  }
}

// move objects to new location
// ndx: choice of location
// atran: [ [x,y,z {, [rx, ry, rz {, [cx, cy, cz]} ]} ], ... ]
// - undef: do not render children
// - num: use atran[num]
// - []: use atran[0]
// - [x, y, z, rotr]: translate([x,y,z]) rotater(rotr) children(0);
module atrans(ndx = 0, atran = [[ 0, 0, 0 ]]) {
  len = len(atran);
  trann = (ndx >= len || is_undef(atran[ndx])) ? undef : atran[ndx];
  tranr = 
    is_undef(trann) ? undef :
    is_num(trann) ? atran[trann] : 
    is_list(trann) ? (len(trann) == 0 ? atran[0] : trann) :
    undef;
  if (is_undef(tranr)) {
    // *children(); // do nothing
  } else {
    // echo("atrans: ndx=", ndx, "atran=", atran, "tranr=", tranr);
    rot = def(tranr[3], [0, 0, 0]);
    trans = as3D(tranr);
    // echo("trans=", trans, "rot=", rot);
    translate(trans) rotatet(rot) children();
  }
}

// A hollow box:
// lwh: [length_x, width_y, height_z], exterior size
// t: ([t0,t0,t0]) thickness of x_wall, y_wall, z_floor 
// d: ([2, 2, 1-p]) delta --> reduction to create inner box: lwh-d*t 
// cxy: (false) center XY, Z = 0
// -
// diff() { cube(lwh); tr(txyz) cube(adif(lwh, amul(d, txyz))) }
module box(lwh = [ 10, 10, 10 ], t = t0, d, cxy = false) {
  t = is_undef(t) ? t0 : t;             // wall thickness
  txyz = is_list(t) ? t : [ t, t, t ];  // in each direction
  d = is_list(d) ? d : [ 2, 2, .9 ]; // reduce inner_cube by 2*txy (enlarge tz for quickview)
  dxyz = adif(lwh, amul(d, txyz)); // dxyz = lwh - d * txyz;
  // echo("box: lwh=", lwh, "d=", d, "txyz=", txyz, "dxyz=", dxyz);
  dc = cxy ? -.5 : 0;
  txyzc = amul(lwh, [dc,dc,0]);
  translate(txyzc) 
  difference() {
    cube(lwh);
    translate(txyz) cube(dxyz); // -2*bt or +2*p
  }
}


// A hollow box:
// lwh: [length_x, width_y, height_z],
// r: corner radius, sidesonly (2)
// t: ([t0,t0,t0]) thick 'translate'
// d: delta --> reduction to create inner box ([2, 2, 1-p])
// cxy: center XY, z = 0
// -
// diff() { cube(lwh); tr(txyz) cube(adif(lwh, amul(d, txyz))) }
module roundedBox(lwh = [ 10, 10, 10 ], r = 2, t = t0, d, cxy = false) {
  t = is_undef(t) ? t0 : t;             // wall thickness
  txyz = is_list(t) ? t : [ t, t, t ];  // in each direction
  d = is_list(d) ? d : [ 2, 2, 1 - pp ]; // reduce inner_cube by txyz
  dxyz = adif(lwh, amul(d, txyz)); // dxyz = lwh - d * txyz;
  // echo("box: lwh=", lwh, "d=", d, "txyz=", txyz, "dxyz=", dxyz);
  dc = cxy ? -.5 : 0;
  txyzc = amul(lwh, [dc,dc,0]);
  translate(txyzc) 
  difference() {
    roundedCube(lwh, r, true, false);
    translate(txyz) roundedCube(dxyz, r, true); // -2*bt or +2*p
  }
}

// repeat children() in a linear pattern:
// xyz: translate to [x, y, z] ([0, 0, 0])
// dxyz: translate each step for multiple posts ([0, 10, 0])
// n: number of posts (1)
module repeat(xyz = [ 0, 0, 0 ], dxyz = [ 0, 10, 0 ], n = 1) {
  xyz = is_undef(xyz) ? [ 0, 0, 10 ] : xyz;
  dxyz = is_undef(dxyz) ? [ 0, 10, 0 ] : dxyz;
  n = is_undef(n) ? 1 : n;
  // echo("repeat: xyz, dxyz, n =", xyz, dxyz, n);
  for (i = [0 : n-1])
    translate([ xyz.x + i * dxyz.x, xyz.y + i * dxyz.y, xyz.z + i * dxyz.y ])  //
      children();
}

// support posts:
// zh: height of post (10)
// xyz: translate to [x, y, z] ([0, 0, 0])
// dxyz: translate each step for multiple posts
// n: number of posts (1)
// dia: diameter of post (t0)
module posts(zh = 10, xyz = [ 0, 0, 10 ], dxyz = [ 0, 10, 0 ], n = 1, dia = t0) {
  zh = is_undef(zh) ? 10 : zh;
  dia = is_undef(dia) ? t0 : dia;
  // echo("posts: xyz, dxyz, n=", xyz, dxyz, n);
  repeat(xyz, dxyz, n) cube([ dia, dia, zh ]);
}

// stack of children()
// n: number
// dxyz: each iteration
// rot: rotate from dx --> dy or dz
module astack(n, d, rot) {
  dxyz = is_list(d) ? d : [ d, 0, 0 ];
  r = is_undef(rot) ? .1 : rot;
  rxyz = is_list(r) ? r : [ 0, 0, 0 ];
  // echo("dxyz=", dxyz) 
  for (i = [0:n - 1]) {
    rotate(rxyz) dup([ i * dxyz.x, i * dxyz.y, i * dxyz.z ]) children(); // amul(dxyz, i)
  }
}

function as2D(ary, a1) = [ ary[0], def(ary[1], a1)];
function as3D(ary, a2) = [ ary[0], ary[1], def(ary[2], a2) ];
// shift center of rotation, then rotate, shift back
// rot: [ax, ay, az {, [cx, cy, cz]}] the rotation
// cr:  [cx, cy, cz] the center of rotation (if not in rot[3])
module rotatet(rot = [ 0, 0, 0 ], cr = [ 0, 0, 0 ]) {
  rcr = is_undef(rot[3]) ? cr : rot[3];
  // echo("rotatet: rot, cr, rcr", rot, cr, rcr);
  translate(rcr) rotate(as3D(rot))
      translate(amul(rcr, [ -1, -1, -1 ])) // [-cr[0], -cr[1], -cr[2]]) //
      children();
}

// translate to [cx, cy, cz]; scale([sx,sy,sz]); translate[-cx,-cy,-cz]
// sv: [sx, sy, sz {, cxyz }] ([0, 0, 0 ])
// - cxyz: [cx, cy, cz] ([0, 0, 0])
module scalet(sv) {
  sv = def(sv, [0, 0, 0]);
  cv = def(sv[3], [0, 0, 0]); // TODO: include inverse rotation
  c1 = amul(as3D(cv), [-1, -1, -1]);
  // echo("scalet: sv, cv, c1 = ", sv, cv, c1);
  translate(c1) scale(as3D(sv)) translate(cv) 
  children();
}

// translate, with offset rotation
// rtr: [dx, dy, dz {, rotr}] ([0, 0, 0])
// - rotr: [rx, ry, rz {, cxyz}] ([0, 0, 0])
// - cxyz: [cx, cy, cz] ([0, 0, 0])
module trr(rtr) {
  rtr = def(rtr, [0, 0, 0]);
  rotr = def(rtr[3], [0, 0, 0]);
  translate(as3D(rtr)) rotatet(rotr) children();
}

// duplicate: insert multiple references to children();
// each instance rotated then translated 
// suitable inside hull() { ... }
// trr: translate (after rotate with offset) ([0, 0, 0])
// nc: number of copies (1)
// c1: color copies
// c0: color original
module dup(trr, nc = 1, c1, c0) {
  trr = def(trr, [0, 0, 0 ]);
  color(c0) children();
  color(c1) 
  for(i = [1:nc])
    trr(amul(trr, i))
      children();
}

// New implementation: MCAD
// dxyz: [dx, dy, dz] (10)
// r: corner radius (1)
// sidesonly: round xy, flat on z (false)
// center: offset by -.5 * dxyz (false)
module roundedCube(dxyz = 10, r = 1, sidesonly = false, center = false) {
  s = is_list(dxyz) ? dxyz : [ dxyz, dxyz, dxyz ];
  // echo("roundedCube: s=", s, "r=", r);
  translate(center ? amul(s, [-.5, -.5, -.5]) : [ 0, 0, 0 ]) {
    if (sidesonly) {
      // linear_extrude(s.z) roundedRect([ s.x, s.y ], r);
      hull() {
        translate([ r, r ]) cylinder(r = r, h = s.z);
        translate([ r, s.y - r ]) cylinder(r = r, h = s.z);
        translate([ s.x - r, r ]) cylinder(r = r, h = s.z);
        translate([ s.x - r, s.y - r ]) cylinder(r = r, h = s.z);
      }
    } else {
      hull() {
        translate([ r, r, r ]) sphere(r = r);
        translate([ r, r, s.z - r ]) sphere(r = r);
        translate([ r, s.y - r, r ]) sphere(r = r);
        translate([ r, s.y - r, s.z - r ]) sphere(r = r);
        translate([ s.x - r, r, r ]) sphere(r = r);
        translate([ s.x - r, r, s.z - r ]) sphere(r = r);
        translate([ s.x - r, s.y - r, r ]) sphere(r = r);
        translate([ s.x - r, s.y - r, s.z - r ]) sphere(r = r);
      }
    }
  }
}

// translate, maybe mark child with #
// clang-format off
module show(ss=false, trr=[0,0,0]) { 
  // echo("show: ss=", ss) ;
  if (ss)
    # trr(trr) children(0);
  else
    trr(trr) children(0); 
}
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

function rotOfId(rid) = [ [ -90, 0, 0 ], [ 0, -90, 0 ], [ 0, 0, -90 ], [0,0,0] ][rid];
// tr: position of corner to be rounded
// rotId: (1) [x-axis: [+-90, 0, 0], y-axis: [0, +-90, 0], z-axis: [0, 0, +-90]]
// q:     (0) index of orientation of corner to be rounded: [ll, ul, ur, lr]
// rad:   (5) corner radius 
// t: thickness of wall to remove (t0)
// ss: show cut with '#'
module rc(tr = [ 0, 0, 0 ], rotId = 1, q = 0, rad = 5, t = t0, ss = false) {
  rid = is_list(rotId) ? rotId[3] : rotId;
  rot = is_list(rotId) ? as3D(rotId) : rotOfId(rotId);
  r2 = rad / 2;
  t2 = t / 2;

  qs = [ [ 1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ], [ -1, 1, 1 ] ][q];
  qsm = [[ r2, r2, -t ], [ r2, -t, r2 ]];
  // echo("rc: q, qs=", q, qs);
  qsr = amul(qs, [ r2, r2, -t ]); // quadrant select cylinder sector

//  [[ 0, 1, 1 ], [ 0, -1, 1 ], [ 0, -1, -1 ], [ 0, 1, -1 ]], // x-axis

  cs0 = [
     [[ 1, 0, -1 ], [ 1, 0, 1 ], [ -1, 0, 1 ], [ -1, 0, -1 ]], // x-axis
     [[ 0, 1, 1 ], [ 0, -1, 1 ], [ 0, -1, -1 ], [ 0, 1, -1 ]], // y-axis
     [[ 1, -1, 0 ], [ -1, -1, 0 ], [ -1, 1, 0 ], [ 1, 1, 0 ]], // z-axis
   ];
  cs = cs0[rid][q];             // offset cyl_cut to corner
  // echo("rc: rid q, cs=", rid, q, cs);
  csr = amul([r2,r2,r2], cs);

  p=.1; pp = 2*p; p4=p*4;
  difference()
  {
    children(0);
    show(ss, tr) 
    // color("blue")  
    translate(csr) rotatet(rot)
    difference() 
    {
      cube([ rad + pp, rad + pp, t + pp ], true);
      translate(qsr) cylinder(t+t, rad, rad); // z-axis from 0..t
    }
  }
}

// 2D shape:
// sxy: [dx = sxy, dy = sxy]
// rc:  [(0,0), (0,dy), (dx, dy), (dx, 0)] ([2, 2, 2, 2])
// k: k<0 cut k from top (keep bottom) k>0 cut k from bottom (keep top)
module roundedRect(sxy = 10, rc = 2, k = 0) {
  s = is_list(sxy) ? sxy : [ sxy, sxy ];
  k = is_undef(k) ? 0 : k;
  dx = s.x;
  dy = s.y;
  r = is_list(rc) ? rc : [ rc, rc, rc, rc ];
  intersection() {
    hull() {
      translate([ r[0], r[0] ]) circle(r = max(p, r[0]));
      translate([ r[1], dy - r[1] ]) circle(r = max(p, r[1]));
      translate([ dx - r[2], dy - r[2] ]) circle(r = max(p, r[2]));
      translate([ dx - r[3], r[3] ]) circle(r = max(p, r[3]));
    }
    translate([ k - p, -p ]) square([ s.x + pp, s.y + pp ]);
  }
}

// a vertical pipe, centered @ (0,0)
// rrh: [dx, dy, dz] 
module pipe(rrh = 10, t = t0) {
  dx = is_list(rrh) && !is_undef(rrh[0]) ? rrh[0] : rrh;
  dy = is_list(rrh) && !is_undef(rrh[1]) ? rrh[1] : rrh;
  dz = is_list(rrh) && !is_undef(rrh[2]) ? rrh[2] : rrh;
  sx = dx > 0 ? (dx - t) / dx : 0;
  sy = dy > 0 ? (dy - t) / dy : 0;
  linear_extrude(height = dz) difference() {
    circle(dx);
    scale([ sx, sx ]) circle(dx);
  }
}

// A Z-extruded roundedRect: (kut across the YZ plane)
// sxy: [dx, dy, dz] EXTERNAL SIZE
// r: radius (2), k: keep/cut (0), 
// txyz = thick ([t0, t0, t0])
module roundedTube(sxy = 10, r = 2, k = 0, txyz = t0) {
  s = is_list(sxy) ? sxy : [ sxy, sxy, sxy ];
  t = is_list(txyz) ? txyz : [txyz, txyz, txyz];
  dx = s.x;
  dy = s.y;
  rs = [ dx, dy ];
  linear_extrude(height = s.z) {
    sx = (dx - 2 * t.x) / dx; // 
    sy = (dy - 2 * t.y) / dy;
    dt = k < 0 ? t.x + pp : -(t.x + pp);
    kd = (k + dt) / sx;
    difference() {
      roundedRect(rs, r, k);
      translate([ t.x, t.y ]) scale([ sx, sy ]) roundedRect(rs, r, kd);
    }
  }
}
// test for k:
*translate([ 0, -60, 0 ]) rotate([ 0, -90, 0 ])
    roundedTube([ 40, 40, 8 ], [ 15, 4, 2, 2 ], -15, 1);

// in XY plane; endcaps for a roundedTube
// xyz: [dx, dy, dz] (10) x,y size; dz translate
// r: [r,r,r,r] (2)
// k: kut
// t: z-axis extrusion
module divXY(xyz = 10, r = 2, k, tz = t0) {
  dz = is_undef(xyz.z) ? 0 : xyz.z;
  translate([ 0, 0, dz ])    //
      linear_extrude(height = tz) //
      roundedRect([ xyz.x, xyz.y ], r, k);
}

// a roundedRect divider (@x) across the YZ plane of a box:
// hwx: [z,y,x] --> z-height, y-depth, x-translation
// r: radius ([r,r,r,r])
// k: (0) k<0 cut k from top; k>0 cut k from bottom (keep top)
// - k == 0 --> keep all
// t: thick (dx = t0)
module div(zyx = 10, r = 2, k, tx = t0) {
  dx = is_undef(zyx[2]) ? 0 : zyx[2];
  translate([ dx + tx, 0, 0 ])    //
      rotate([ 0, -90 ])         //
      linear_extrude(height = tx) //
      roundedRect([ zyx[0], zyx[1] ], r, k);
}

// on the XZ plane, displaced by y
// zxy -> z-height, x-width, y-translation
// t: thickness of extrusion
// zyx: [dz, dy, dx] (10) z,y size; dx translate
// r: [r,r,r,r] (2)
// k: kut
// t: z-axis extrusion
module divXZ(zxy = 10, r = 2, k, ty = t0) {
  dy = is_undef(zxy[2]) ? 0 : zxy[2];
  translate([ zxy[1], dy + ty, 0 ])    //
      translate([zxy[2], 0, 0])
      rotate([ 90, 0, 0 ])       //
      rotate([ 0, 0, 90 ])       //
      linear_extrude(height = ty) //
      roundedRect([ zxy[0], zxy[1] ], r, k);
}

// a slot shaped hull; (in XY plane -> rot(-Y) -> ZY)
// hwtr: [h: height, w: width, t = t0, r: radius (w/2)]
// rot: rotate|rid ([0, 0, 0]: XY) 0: YZ or 1: XZ or 2: XY (hw->wh)
module slot(hwtr, rot) {
  h = is_undef(hwtr[0]) ? 40 : hwtr[0]; // slot height
  w = is_undef(hwtr[1]) ? 5 : hwtr[1];  // slot width
  t = is_undef(hwtr[2]) ? t0 : hwtr[2]; // thick
  r0 = is_undef(hwtr[3]) ? w/2 : hwtr[3];// inner radius
  r = r0;// min(r0, w/2, h/2);
  rot0 = is_undef(rot) ? [ 0, 0, 0 ] : rot;
  rota = is_list(rot0) ? as3D(rot0) : rotOfId(rot0);
    rotate(rota)
    roundedCube([ h, w, t ], r, true, true);
}
module slotifyY(hwtr, tr = [ 0, 0, 0 ], rot, riq, ss = false) {
  tr = is_undef(tr) ? [0,0,0] : tr;
  h = is_undef(hwtr[0]) ? 40 : hwtr[0];
  w = is_undef(hwtr[1]) ? 5 : hwtr[1];
  t = is_undef(hwtr[2]) ? t0 : hwtr[2];
  r = is_undef(hwtr[3]) ? min(h, w)/2 : hwtr[3]; // main radius
  rot0 = is_undef(rot) ? [0,90,90] : rot; // flip XY to XZ plane
  rott = is_list(rot0) ? rot0 : rotOfId(rot0);
  // echo("slotify: hwtr=", [ h, w, t, r ], "rott=", rott);
  module maybe_rc0(ss = ss, riq = riq) {
    if (!is_undef(riq)) {
      riq = is_list(riq) ? riq : [riq]; // riq as simple radius
      rad = is_undef(riq[0]) ? 2 * t : riq[0]; // corner radius
      rid = is_undef(riq[1]) ? 0 : riq[1];
      q1 = is_undef(riq[2]) ? 0 : riq[2];
      q2 = is_undef(riq[3]) ? 3 : riq[3];
      rm = rad;

      // echo("[tr, w, h, riq, r, rm, rid, rad, rott]", [ tr, w, h, riq, r, rm, rid, rad, rott ]);
      cr1 = [-(w/2), -0, -(h/2 - r) ];
      cr2 = [+(w/2), -0, -(h/2 - r) ];
      // echo("cr1=", cr1, "cr2=", cr2);
      if (ss) translate(tr) translate(cr1) color("cyan") cube([1,1,1]);
      rottr = [rott[0], rott[1], rott[2], rid];
      // trt1 = tr;
      trt1 = adif(tr, cr1 );
      trt2 = adif(tr, cr2);
      // translate(trt1) translate(amul(cr1, [-1,-1,-1])) rotatet(rott, cr1) color("blue") cube([ 1, 1, 1 ], true);
      if (ss) translate(trt1) color("blue") cube([ 1, 1, 1 ], true);
      if (ss) translate(trt2) color("red")  cube([ 1, 1, 1 ], true);
      // echo("rc: ", trt1, rott, q1, rad, t, ss);
      // rc(trt1, rottr, q1, rad, t, ss)
      rc(trt1, rid, q1, rad, t, ss)
      rc(trt2, rid, q2, rad, t, ss)
      children();
    } else {
      children();
    }
  }
  maybe_rc0(ss, riq) 
  difference() 
  {
    children(0);
    show(ss, tr)
    slot([ h, w, t, r ], rott);
  }
}

// hwtr: [h, w, t, r]
// - h: height of box (40) [z]
// - w: width of slot (5) [y]
// - t: thickness of slot (t0) [x]
// - r: radius of slot (min(h,w)/2)
// tr: translate to wall [+- l/2, offset from center, bz: z-from bottom]
// rid: rotate (1 = [0, -90, 0]) flip to YZ plane
// riq: [radius: (2*t), rid: (1) , q1: (3), q2: (2)]; for YX plane
// ss: show
module slotifyY2(hwtr, tr, rot, riq, ss) {
  h = is_undef(hwtr[0]) ? 40 : hwtr[0];
  w = is_undef(hwtr[1]) ? 5 : hwtr[1];
  t = is_undef(hwtr[2]) ? t0 : hwtr[2];
  r = is_undef(hwtr[3]) ? min(h, w)/2 : hwtr[3]; // main radius
  bz = tr[2];
  slh = h-(bz-r); // TODO: subtract (bz-r) from correct axis
  tz = bz + slh/2;

  tru = is_undef(tr[3]) ? [tr[0], tr[1], tz]: rm[tr[3]];
  slotifyY([slh, w, t, r], tru, rot, riq, ss)
  // echo("slotify2: hwtr=", [ slh, w, t, r ], "rot=", rot);
  children();
}


// cut a slot in child object:
// difference() { child(0); trans(tr) slot(hwtr); }
// hwtr: [h: dz (40), w: 5, t: (t0), r: slot_radius (w/2)]
// tr: translate onto wall ([0,0,0])
// rid: rotate (1 = [0, -90, 0]) flip to YZ plane
// riq: [radius: (2*t), rid: (1) , q1: (3), q2: (2)]; for YZ plane
module slotify(hwtr, tr = [ 0, 0, 0 ], rot, riq, ss = false) {
  h = is_undef(hwtr[0]) ? 40 : hwtr[0];
  w = is_undef(hwtr[1]) ? 5 : hwtr[1];
  t = is_undef(hwtr[2]) ? t0 : hwtr[2];
  r = is_undef(hwtr[3]) ? min(h, w)/2 : hwtr[3]; // main radius
  rot0 = is_undef(rot) ? 1 : rot; // flip XY to YZ plane
  rott = is_list(rot0) ? rot0 : rotOfId(rot0);
  // echo("slotify: hwtr=", [ h, w, t, r ], "rott=", rott);
  module maybe_rc0(ss = ss, riq = riq) {
    if (!is_undef(riq)) {
      riq = is_list(riq) ? riq : [riq]; // riq as simple radius
      rad = is_undef(riq[0]) ? 2 * t : riq[0]; // corner radius
      rid = is_undef(riq[1]) ? 1 : riq[1];
      q1 = is_undef(riq[2]) ? 3 : riq[2];
      q2 = is_undef(riq[3]) ? 2 : riq[3];
      rm = rad;

      // echo("[tr, w, h, riq, r, rm, rid, rad, rott]", [ tr, w, h, riq, r, rm, rid, rad, rott ]);
      cr1 = [ -0, -(w/2), -(h/2 - r) ];
      cr2 = [ -0, +(w/2), -(h/2 - r) ];
      // echo("cr1=", cr1, "cr2=", cr2);
      if (ss) translate(tr) translate(cr1) color("cyan") cube([1,1,1]);
      rottr = [rott[0], rott[1], rott[2], rid];
      // trt1 = tr;
      trt1 = adif(tr, cr1 );
      trt2 = adif(tr, cr2);
      // translate(trt1) translate(amul(cr1, [-1,-1,-1])) rotatet(rott, cr1) color("blue") cube([ 1, 1, 1 ], true);
      if (ss) translate(trt1) color("blue") cube([ 1, 1, 1 ], true);
      if (ss) translate(trt2) color("red")  cube([ 1, 1, 1 ], true);
      // echo("rc: ", trt1, rott, q1, rad, t, ss);
      // rc(trt1, rottr, q1, rad, t, ss)
      rc(trt1, rid, q1, rad, t, ss)
      rc(trt2, rid, q2, rad, t, ss)
      children();
    } else {
      children();
    }
  }
  maybe_rc0(ss, riq) 
  difference() 
  {
    children(0);
    show(ss, tr)
    slot([ h, w, t, r ], rott);
  }
}

// hwtr: [h, w, t, r]
// - h: height of box (40) [z]
// - w: width of slot (5) [y]
// - t: thickness of slot (t0) [x]
// - r: radius of slot (min(h,w)/2)
// tr: translate to wall [+- l/2, offset from center, bz: z-from bottom]
// rid: (1) 0 -> XZ plane; 1 -> YZ plane; 2 -> XY plane 
// riq: [radius: (2*t), rid: (1) , q1: (3), q2: (2)]; for YZ plane
// ss: show
module slotify2(hwtr, tr, rid, riq, ss) {
  h = is_undef(hwtr[0]) ? 40 : hwtr[0];
  w = is_undef(hwtr[1]) ? 5 : hwtr[1];
  t = is_undef(hwtr[2]) ? t0 : hwtr[2];
  r = is_undef(hwtr[3]) ? min(h, w)/2 : hwtr[3]; // main radius
  bz = tr[2];
  slh = h-(bz-r); // TODO: subtract (bz-r) from correct axis
  tz = bz + slh/2;

  tru = is_undef(tr[3]) ? [tr[0], tr[1], tz]: rm[tr[3]];
  slotify([slh, w, t, r], tru, rid, riq, ss)
  // echo("slotify2: hwtr=", [ slh, w, t, r ], "rot=", rot);
  children();
}


// see also: show(ss, tr) rotatet(rottr)
// tr: position ([0,0,0])
// rottr: rotate (around offset) = ([rotOfId(rottr=1), [0,0,0]])
module align(tr = [0,0,0], rottr = [0,0,0], ss = false) {
  rottr0 = is_undef(rottr) ? 1 : rottr;
  rottr1 = is_list(rottr0) ? rottr0 : rotOfId(rottr0);
  show(ss, tr)
  rotatet(rottr1)
  children(0);
}


// array of children(0) suitable for poking holes.
// d1: [a0, ainc, alimit]
// d2: [b0, binc, blimit]
// rid: translation plane -> zy | xz | xy | 00
// children() the item(s) to be placed at each grid point
module gridify(d1, d2, rid = 0)
{
  for (a = [d1[0]:d1[1]:d1[2]], b = [d2[0]:d2[1]:d2[2]])
    let (tr = rid == 0 ? [0, a, b] 
            : rid == 1 ? [a, 0, b]
            : rid == 2 ? [a, b, 0]
            : [0, 0, 0])
    translate(tr) children();
}

// diagonal grid on XZ for civ0_cardbox sidewall
module gridDXZ(nx, nz, k, tr = [ 1, 0, 1 ])
{
    gridify([ k, 2 * k, nx ], [ 0, 2 * k, nz ], 1) children(0);
    gridify([ 0, 2 * k, nx ], [ k, 2 * k, nz ], 1) children(0);
}

// grid test:
module gridTest() {
  translate([ 0, -40, 0 ])
  {
    nx = 50;
    nz = 30;
    y = 1;
    s = 10;
    s2 = s / 2;
    difference()
    {
      cube([ nx, y, nz ]);
      gridDXZ(nx, nz, s / 2) 
      scale([ 1, 1, .7 ]) 
      translate([ -s / 2, 0, -s2 ]) 
      // scale([1, 1, .7])
      rotatet([ 0, 45, 0 ], [ s2/2, 0, s2/2 ]) 
      translate([ 0, -p, 0 ])
      cube([s2, y + pp, s2])
      ;
    }
  }
}

// sumi computes sum of ary[i] (i = 0..n)
// ary: array of length > n
// n: number of elements to sum
// j: if is_list(ary[i]) sum ary[i][j] (the j-th column)
function sumi(ary, n = 0, j = 0) 
  = (is_list(ary[n]) ? ary[n][j] : ary[n]) + (n > 0 ? sumi(ary, n-1, j) : 0);
  // = (n >= 0 ? (ary[n] + sumi(ary, n-1)) : 0);

// two pieces: ball & socket
// socket on bottom, ball on top
// square blocks 2*r + dxy
// hh: height of bottom-socket, top-cone mounting blocks (3 or [3, 3])
// hr: radius (& height) of hinge/cone (hr = 1.5) 
// dr: incremental thickness around cone (2)
// mnt: extend a mounting block (1.5) 
// -- [len-socket (hr), angle-socket (0), angle-cone (mnt[1]), len-cone (len-socket)]
// sep: gap between socket & ball (.2)
module hinge(hh = 3, hr = 1.5, dr = 2, mnts = 1.5, sep = .2) {
  hh = def(hh, 3); 
  h0 = is_list(hh) ? hh[0] : hh;
  h1 = is_list(hh) ? hh[1] : hh;
  hr = def(hr, 1.5);
  dr = def(dr, 2.0);
  rt = hr + dr;               // total radius of hinge
  mnts = is_list(mnts) ? mnts : [mnts];
  mnt0 = def(mnts[0], hr);    // mount length (block)
  mnta = def(mnts[1], 0);     // rotation around z-axis (block)
  mntb = def(mnts[2], mnta);  // rotation around z-axis (cone)
  mntc = def(mnts[3], mnt0);  // mount length (cone)
  sep = def(sep, .2);
  mntt = mnt0 + mntc + sep;

  // echo("hinge: [zh, hh, hr, dr, mnts, sep] =", [zh, hh, hr, dr, mnts, sep]);
  fn = 30;

  // cube on the side of cyl, z-length to attach to other parts
  module mountblock(h = h0, z = 0, mntd = mnt0, mnta = mnta) {
    if (mntd > 0) {
      rt = hr + dr; 
      my = (rt + mntd);
      color("red")
      trr([0, my/2, z+h/2, [0, 0, mnta, [0, -my/2, 0]]]) cube([2 * rt, my, h], true);
    }
  }
  // hr: hinge radius @ wide of cone
  module coneblock(hr = hr) {
    rr = hr * .68;
    trr([0, 0, h1/2, [180, 0, 0]]) {
      cylinder(h = h1, r = hr + dr, center = true, $fn = fn);
      trr([0, 0, h1/2-p]) {
        cylinder(hr*.7, hr, hr*.56, $fn = fn); // frustrum of cone QQQ: hr*.7 vs rr=hr*.68
        trr([0, 0, hr-rr]) sphere(rr, $fn = fn); // sphere on top
      }
    }
  }
  // Diff to see cross section of gap between cone & mount/socket.
  module section() {
    color("cyan") intersection() { 
      cube([rt + dr, rt + dr, h0+h1]); 
      difference() { 
        cylinder(h = h0+h1, r = rt);
        children();
      }
    }
  }
  // section() {
  differenceN(2) // bottom socket - scaled coneblock
  {
    mountblock(h0, 0, mnt0, mnta); // bottom mounting block (if mnta>0)
    trr([0, 0, h0/2]) cylinder(h = h0, r = rt, center = true, $fn = fn);
    // remove scaled coneblock:
    trr([0,0,h0+p]) scale([(hr+sep)/hr, (hr+sep)/hr, 1]) coneblock(hr); // or +cos(30)*sep?
  }
  mountblock(h1, h0+sep, mntc, mntb); // top ball block
  trr([0,0,h0+sep]) coneblock(hr);    // top ball cone
// }
}

