use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;


// brackets to hold (cylinder) brushes under pool vacuum
br = .2 * inch; // brush radius

bw = 10; // x-width of main block
bh = 8;  // y-height of main block
z0 = 3;  // depth of vac inset
z1 = 2;  // base plate thickness
z2 = 5;  // thick parts of base (screw into here)
z3 = 3.5;  // depth of material for screw (screw len = z2 + z3)
z4 = br;  // height to brush axis
stub = bw;
sr = 1.5; // rod radius
head = 1; // z depth reserved for screw head
scr = 2.1; // screw radius 
shr = 2.3; // screw head radius

axl = 10;
module axel(l = axl, sl = stub) {
  trr([sl-l/2, 0, br, [0, -90, 0]]) 
    cylinder(h = l + 2*sl, r = sr);
}
module brush(l = axl, sl = stub) {
  trr([-sl/2, 0, br, [0, -90, 0]]) {
    cylinder(h = l, r = br);
  }
  color("white") axel(l);
}

// space for the screw, subtracted in difference below
// positioned with join between head & screw @ z=0
module screw(len = z3, head = head ) {
  trr([0, 0, -len]) cylinder(h=len+head, r = scr); // screw part
  trr([0, 0, 0]) cylinder(h = head, r = shr);
}

bt = 2;  // x-thickness of slotted brackets
tz = 1.5;  // top z (& clip top thickness)
bz = br + sr + tz; // bracket z-top

// bracket with side-sliding locking clip
module bracket1(bt = bt) {
  module caxis(r = sr) {
    trr([bw/2, 0, br-z3, [0, -90, 0]]) cylinder(h = bw+pp, r = r);
  }
  sxy = [1, .5]; // scale to shrink
  zh = z4-sr;    // depth of hole for screw head
  difference() {
    trr([0, 0, z3/2]) cube([bw, bh, z3], center = true); // base cube
    trr([0, 0, zh-head]) screw(zh);   // remove hole for screw
     clip1((rd+f)/2, .3);

  }
  trr([0, 0, z3]) 
  differenceN() 
  {
    linear_extrude(height = bz-z3, scale = sxy) 
      difference() {
        square(size = [bw-pp, bh], center = true);
        square(size = [bw-2*bt-pp, bh], center = true);
    }
    trr([0,0,0, [1, 0, 0, [bw/2, 0, br-z3]]])
      hull() {
        caxis();
        dup([0, 0, 3]) caxis(sr*.6);
     }
  }
}

rd = 1.8;
rh = 2;
module clip_rod(r = rd/2, h = rh ){
  trr([0, p, 0, [90, 0, 0]]) cylinder(h = h+pp, r = r);
}
module clip1(r = rd/2, dh = 0) {
  dx = bw/2 - rd/2 - 1;
  dz = z3/2;
  color("blue") {
    trr([dx, bh/2, dz]) clip_rod(r, rh+dh);
    trr([-dx, bh/2, dz]) clip_rod(r, rh+dh);
  }

  clipx = bw - 2*bt;
  clipy = 2;
  clipz = bz;

  trr([0, (bh+clipy)/2, clipz/2]) cube([bw, clipy, clipz], center = true);
  trr([0, (bh/2-sr)/2, bz-tz/2]) cube([clipx, bh/2+2*sr, tz], center = true);
}


cw2 = 1.9;   // x-width of clip slot
ch2 = 2*(sr+1.9); // y-height of clip

bw2 = 8;  // x-width of bracket2
bh2 = ch2+4;  // add screw block later
bz2 = br;

module screwblock2(dx = 2*shr+1) {
  dy = dx;
  dz = z3;
  trr([0, bh2/2+dy/2, dz/2]) 
  difference() {
    cube([dx, dy, dz],center = true);
    trr([0, 0, dz/2+p]) screw(z3+pp);
  }
}

// bracket with down plunging locking clip
module bracket2() {
  wedge();
  trr([0, 0, 0, [0, 0, 180]]) wedge();
  differenceN(1) {
    trr([0, 0, bz2/2]) cube([bw2, bh2, bz2], center = true);
    axel(0);
    clip2i(pp, pp);
  }
  screwblock2(bw2);
}

// wedge added to bracket2, removed from clip2
// dw: grow/shrink width of wedge
// dz: adjust the bottom of wedge
module wedge(dw = pp, dz = 0) {
  cw = cw2 + dw;
  bz = 1;      // thickness of bottom 'foot'
  x1 = z2 - bz;
  y2 = x1 * tan(atan2(.7, x1+dz));
  trr([cw/2+p, -ch2/2-p, 1, [0, -90, 0]])
  linear_extrude(height = cw + pp) 
  polygon(points = [[dz, 0], [x1, 0], [dz, y2]]);
}
// wedge();
// outer block of clip, without hole or slots
// actual blue clip2 will shrink for easier insertion
// 
// dw: grow/shrink width of wedge
// dz: adjust z-height of bottom edge of wedge
// dh: shrink y-height of clip2i
module clip2i(dw = pp, dz = 0, dh=0) {
  cw = cw2 + dw;
  cz = bz2 + sr + 2;  // 2 = thickness above axel
  difference() {
    trr([0, 0, cz/2-p]) cube([cw, ch2+dh, cz], center = true);
    wedge(dw, dz);
    trr([0, 0, 0, [0,  0, 180]]) wedge(dw, dz);
  }
}

cs2 = .15; // clip2 shrinkage
module clip2() {
  cy = sr*2;
  color("blue")
  difference() {
    clip2i(-cs2, -f, -.1);  // lower bottom of wedge
    trr([0, 0, -p]) axel(0, cw2/2 + pp);
    trr([0, 0, br/2-pp]) cube([cw2, cy, br], center = true);
  }
}

// 0: design1, 1: print
// 2: design2, 3: print
loc = 3;
// 0: no brush, 1: brush
bsh = 0;

atrans(loc, [[0, 0, 0], 0])
bracket1();

atrans(loc, [[0, 0, 0], [0, 0, 0, [-90, 0, 0, [0, bh/2+2, 0]]]])
clip1();

atrans(loc, [undef, 0, [0, 0, 0], 2])
bracket2();
atrans(loc, [undef, 0, [0, 0, f/2], [bw/2, 0, (cw2-cs2)/2, [0, 90, 0]]])
clip2();


atrans(bsh, [undef, [0, 0, 0]]) 
brush();
