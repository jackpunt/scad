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
  trr([crad+prad, -50, 0, [90, 0, 0]]) color("blue") cylinder(h = 85, r = 20);
  trr([crad+prad, -50-85, 0, [90, 0, 0]]) color("grey") cylinder(h = 50, r1 = 5, r2 = 13);
}
// size
s = inch;
tabh = s * 0.25 + p;
fixw = s * 2.8;
fixl = s * 1.5;
fixh = s * 0.5;

module fixhalf(part = 3, s = s) {
  fixl0 = fixw/2 - 26;
  ofy = s * .7;
  difference() {
    trr([fixl0, ofy, 0]) cube([fixw, fixl, fixh], true);
    if (part == 1 || part == 0) trr([fixl0, ofy, fixh/2-p]) cube([fixw+pp, fixl+pp, fixh], true);
    if (part == 2 || part == 0) trr([fixl0, ofy, -fixh/2+p]) cube([fixw+pp, fixl+pp, fixh], true);
    // cut slots for tabs in part==2
    if (part == 2 || part == 3) {
      tabs(false); // with hole for locking dowel
    }
    # trr([fixw - fixl0, fixl/2, 0]) cylinder(h = 4*fixh+pp, r = 1/8 * inch, true);
  }
  // tabs on part==1:
  if (part == 1 || part == 3) {
    tabs(true);
  }

}

module tabline(n = 3, dy = 0, hm) {
  hr = inch/16;
  th = tabh;
  fr = f * .5;
  difference() {
    union() {
      for (dxi = [1: n]) {
        trr([-30+8*dxi, dy, 0]) cube([4, 10, th]);
      }
      if (!hm)
        trr([2+ 8*(n-3), dy+5, s*.125, [0, -90, 0]]) cylinder(h = n * 8 + 6, r = hr+fr); 
    }
    if (hm)
      trr([2+ 8*(n-3), dy + 5, s*.125, [0, -90, 0]]) cylinder(h = n * 8 + 6, r = hr+fr); 
  }
}
module tabs(hm = true) {
  tabline(3, 0, hm);
  tabline(6, 24, hm);
}
module fixture(part = 3, s = inch) {
  fixhalf(1);
  %fixhalf(2);
}

stick_angle = 9;
module stick(yl = yl) {
  sl = yl + 55;
  trr([47+sl/2*sin(stick_angle), 45-sl, 0, [-90, 0, stick_angle]]) cylinder(h = sl, r = inch*1/8);
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
module bracket(nx, ny, dx, dy, dz, sf = [1, 1, 1]) {
  wx = 3 * dx;
  ly = 5 * dy;
  sfa = is_list(sf) ? sf : [(wx+sf)/wx, (ly+sf)/ly, 1];
  ch = 20;
  crad = inch * .25;
  atrans(loc, [[0, 0, 0], [0, 0, 0], [0, 0, 0, [0, 0, 0]]]) 
  // scale(sfa)
  {
    // alignment pegs:
    astack(3, [0, 2*dy, 0], undef, "red") trr([0, -dy*2, -dz-p]) scale(sfa) cylinder(1.51*dz+pp, 3, 3);
    trr([0, 0, p-(ch+dz)]) cylinder(ch, crad, crad); // stick terminus
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
module holder(nx = 6, ny = 10) {
  dx = 10; dy = 10; dz = 5;
  difference() {
    plate(nx, ny, dx, dy, dz);
    holes(nx, ny, dx, dy, dz);
    color("green") trr([0,0,-p]) bracket(nx, ny, dx, dy, dz, 2*f);
  }
  bracket(nx, ny, dx, dy, dz);
}
loc = 2;
yl = 170;

spipe();

fixture();

stick(yl);

atrans(loc, [[80, -yl, 0, [90, 0, 0]], [90, 0, 0], [90, 0, 0, [180, 0, 0]]])
  holder();
