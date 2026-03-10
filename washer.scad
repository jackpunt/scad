use <mylib.scad>;

p = .001;
pp = 2 * p;
f = .18;            // not sure
sqrt3 = sqrt(3);    // 1.732
sqrt3_2 = sqrt3/2;  // .866
sample = false;

inch = 25.4;
// h: height (20)
// crad: corner radius (inch/2)
module spipe(scal = 1, h = 20, crad = inch/2) {
  prad = scal * (3/8 * inch) / 2;

  echo("prad=", prad);
  trr([0, 0, -prad])
  color("white") {

  trr([prad + crad, 0, prad, [90, 0, 0]]) cylinder(h = h, r = prad);
  trr([0, prad + crad, prad, [0, -90, 0]]) cylinder(h = 3*h, r = prad);
  trr([0, 0, 0, [0, 0, -p]]) rotate_extrude(angle=90+pp) 
    translate([prad+crad, prad]) circle(r = prad+.5, $fn=20);
  }
  brad = 12;
  color("#dfb80a")
  trr([crad+prad, -h, 0, [90, 0, 0]])
  difference() {
    cylinder(h = 30, r = 12);
    trr([0, 0, h-(10-p)])  cylinder(h = 20, r = 6);
  }
  trr([crad+prad, -50, 0, [90, 0, 0]]) color("blue") cylinder(h = 85, r = 20);
  trr([crad+prad, -50-85, 0, [90, 0, 0]]) color("grey") cylinder(h = 50, r1 = 5, r2 = 13);
}
// size
s = inch;
tabh = s * 0.25 + p;
fixw = s * 2.85;
fixl = s * 1.5;
fixh = s * 0.5;
pz = .08;   // remove center plane
l00 = -26;

// fixtue split into half
module fixhalf(part = 3, s = s) {
  fixl0 = fixw/2 +l00;
  ofy = s * .7;
  trr([fixl0, ofy, 0])
  differenceN(1) 
  {
    cube([fixw, fixl, fixh], true);
     trr([-fixl0, -ofy, 0]) {
      stick(yl);
      spipe(1.04);
    }
    if (part == 1 || part == 0) trr([0, 0, fixh/2-p]) cube([fixw+pp, fixl+pp, fixh], true);
    if (part == 2 || part == 0) trr([0, 0, -fixh/2+p]) cube([fixw+pp, fixl+pp, fixh], true);
    // cut slots for tabs in part==2
    if (part == 2 || part == 3) {
      trr([-fixl0, -ofy, 0]) tabs(false); // with hole for locking dowel
    }
    // trim the center plane:
    cube([fixw+pp, fixl+pp, 2 * pz], true);
    // try make hole for squeeze bolt:
    trr([fixw/2-fixl0+4, 9, 0]) 
      cylinder(h = 2*fixh+pp, r = 1/12 * inch, center = true);
    trr([fixw/2-fixl0-9, -9, 0]) 
      cylinder(h = 2*fixh+pp, r = 1/12 * inch, center = true);
  }
  // tabs on part==1:
  if (part == 1 || part == 3) {
    tabs(true);
  }

}

module tabline(n = 3, dy = 0, hm, di = 1, dxm = 8) {
  hr = inch/16;
  tw = 4;   // tab width(x)
  tl = 10;  // tab length(y)
  th = tabh + pz;
  fr = f * .9;
  ff = hm ? -fr : fr;
  trr([0, 0, -pz]) // drop into pz
  difference() 
  {
    union() {
      for (dxi = [1 : di : n]) {
        trr([(l00-tw)+(tw/2)+dxm*dxi, dy+tl/2, th/2]) cube([tw+ff, tl+ff, th], true);
      }
      if (!hm)
        trr([tw/2 + l00 + dxm*(n/2), dy+5, s*.125, [0, -90, 0]]) cylinder(h = dxm * (n + 1), r = hr+fr, center = true); 
    }
    // add cyl for key rod:
    if (hm)
      trr([tw/2 + l00 + dxm*(n/2), dy + 5, s*.125, [0, -90, 0]]) cylinder(h = dxm * n, r = hr+fr, center = true); 
  }
}
module tabs(hm = true) {
  // tabline(5, 0, hm, 2, 6);
  tabline(3, 0, hm, 1, 9);
  tabline(7, 24, hm, 2, 7);
}
module fixture(part = 3, s = inch) {
  fixhalf(1);     // bottom half, with tabs
 % fixhalf(2);     // top half, with slots
}

stick_angle = 11;
stick_ofx = 38; // right side of bracket

module stick(yl = yl) {
  sl = yl + 55;
  trr([stick_ofx, 0, 0, [90, 0, stick_angle]]) 
    trr([0, 0, -55]) cylinder(h = sl, r = inch*1/8);
}

module holes(nx, ny, dx, dy, dz) {
  trr([dx/2 * (-nx), dy/2* (-ny), 0])
  astack(5, [0, 20, 0], undef, undef, 1)
  astack(4, 20)
  cube([4.2, 5.1, 20], true);
}

// spiked plate to hold sponge
module plate(nx, ny, dx, dy, dz) {
  cube([nx*dx, ny* dy, dz], true);
  trr([dx/2 * (1-nx), dy/2* (1-ny), dz*.5])
    astack(n = ny, d = [0, dy, 0])
    astack(n = nx, d = [dx, 0, 0], rot = []) 
    cylinder(4, 2, 0);  
}

// bracket hold stick to plate
// peg scale radius
module bracket(nx, ny, dx, dy, dz, pf = 0) {
  wx = 3 * dx;
  ly = 5 * dy;
  ch = 20;
  crad = inch * .25;
  srad = inch * .125;
  pr = (1/4 * inch + pf)/2;   // peg radius
  atrans(loc, [[0, 0, 0], [0, 0, 0], [0, 0, 0, [0, 0, 0]]]) 
  {
    // alignment pegs:
    astack(3, [0, 2*dy, 0], undef, "red") trr([0, -dy*2, -dz-p]) cylinder(1.51*dz+pp, pr, pr);
    trr([0, 0, p-(ch/2+dz), [0, stick_angle, 0, [0, 0, ch/2]]]) 
      difference() {
      cylinder(ch, crad, crad, true); // stick terminus
      trr([0,0,-p]) cylinder(ch+pp, srad, srad, true); // stick terminus
    }
    color("tan")
    difference() {
      trr([0, 0, -dz]) cube([wx, ly, dz], true);
      holes(nx, ny, dx, dy, dz);
    }
  }
}

// sponge holder, with attachment holes
// nx: number of spikes
// ny: number of spikes
// dx: incr-x for spikes
// dy: incr-y for spikes
// dz: thickness of plate
module holder(part = 0) {
  nx = 6; ny = 10;
  dx = 10; dy = 10; dz = 5;
  if (part == 0 || part ==1)
  difference() {
    plate(nx, ny, dx, dy, dz);
    holes(nx, ny, dx, dy, dz);
    bracket(nx, ny, dx, dy, dz+p, f); // enlarge peg radius
  }
  if (part == 0 || part == 2)
  bracket(nx, ny, dx, dy, dz);
}

loc = 0;
yl = 170;

atrans(loc, [[0,0,0]]) spipe();

// fixture();
atrans(loc, [[0,0,0], 0, 0]) fixhalf(1);
%atrans(loc, [[0,0,0], [0, -5, 0, [180, 0, 0]], 1]) fixhalf(2);

*atrans(loc, [[0,0,0]]) stick(yl);

bracket_ofy = -yl;
bracket_ofx = stick_ofx + tan(-stick_angle) * (bracket_ofy + 5);
echo("bracket: ofx, ofy =", [bracket_ofx, bracket_ofy], 60.56+2.5);
atrans(loc, [[bracket_ofx, -yl, 0, [90, 0, 0]], undef, [90, 0, 0, [180, 0, 0]]])
  holder(1);
atrans(loc, [[bracket_ofx, -yl, 0, [90, 0, 0]], undef, [190, 0, 0, [180, 0, 0]]])
  holder(2);
