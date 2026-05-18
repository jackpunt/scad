use <mylib.scad>;

f = .18;  // fudge
p = .001;
pp = 2 * p;
t0 = 1;
inch = 25.4;


// brackets to hold (cylinder) brushes under pool vacuum
br = 7; // .2 * inch; // brush radius

bw = 10; // x-width of main block
bh = 8;  // y-height of main block
z0 = 3;  // depth of vac inset
z1 = 2;  // base plate thickness
z2 = 5;  // thick parts of base (screw into here)
z3 = 3.5;  // depth of material for screw (screw len = z2 + z3)
z4 = br;  // height to brush axis
stub = bw;
sr = 1.5; // rod radius
head = 1.2; // z depth reserved for screw head
scr = 2.1; // screw radius 
shr = 2.3; // screw head radius
s2r = 3.25; // height & radius of screw2 head


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

// space for panhead screw, subtracted in difference below
// positioned with join between head & screw @ z=0
module screw1(mr = 1, len = 15+s2r/2, head = head ) {
  trr([0, 0, -len]) cylinder(h = len+head, r = scr*mr); // screw part
  trr([0, 0, 0]) cylinder(h = head, r = s2r);
}

// space for the screw, subtracted in difference below
// positioned with top of head & screw @ z=0
module screw2(mr = 1, len = 15+s2r/2, rad = s2r ) {
  trr([0, 0, -len]) cylinder(h = len, r = scr*mr); // screw part
  trr([0, 0, -rad]) cylinder(h = rad, r1 = 0, r2 = rad);
}

bt = 2;  // x-thickness of slotted brackets
tz = 1.5;  // top z (& clip top thickness)
bz = br + sr + tz; // bracket z-top

cw2 = 2;   // x-width of clip slot & wedge
ch2 = 2*(sr+1.9); // y-height of clip

bw2 = 9;  // x-width of base of bracket2
bw2a = cw2 + 2.5; // x-width at top of bracket2
bh2 = ch2+4;  // add screw block later
bz2 = br;

sbx = bw2;       // x-wdith of base of screwblock;  2*s2r + 1;
sby = 2*s2r + 1; // y-height of screwblock

// called with sbx = bw2 to match clip2i width at base
module screwblock2(dx = sbx) {
  dy = sby;
  dz = z2;  // bz2 = 7, z2 = 5
  // triangle similarity:
  d = bw2a + (bz2-dz)*(bw2-bw2a)/bz2;
  s2 =  d / bw2;
  trr([0, bh2/2+dy/2, dz/2]) 
  difference() {
    trr([0, 0, -dz/2]) linear_extrude(height = dz, scale = [s2, 1]) 
      square([dx, dy], center = true);
    trr([0, 0, dz/2+p]) screw2(.9);  // tighter screw hole
  }
}

// bracket with down plunging locking clip
module bracket2() {
  module block() {
    linear_extrude(height = bz2, scale = [bw2a/bw2, 1]) 
      square([bw2, bh2], center = true);
  }
  wedge();
  trr([0, 0, 0, [0, 0, 180]]) wedge();
  differenceN(1) {
    block();
    axel(0);
    clip2i(pp, pp);
  }
  screwblock2();
}

// wedge added to bracket2, removed from clip2
// dw: grow/shrink width of wedge
// dz: adjust the bottom of wedge
module wedge(dw = pp, dz = 0) {
  cw = cw2 + dw;  // height of extrusion before y-axis rotation
  bz = 1;      // thickness of bottom 'foot'
  x1 = z4 - bz;
  y2 = x1 * tan(atan2(.99, x1+dz));
  trr([cw/2+p, -ch2/2-p, 1, [0, -90, 0]])
  linear_extrude(height = cw + pp) 
  polygon(points = [[dz, 0], [x1, 0], [dz, y2]]);
}

// outer block of clip, with wedges, without hole or slots
// actual blue clip2 will shrink for easier insertion
// 
// dw: grow/shrink width of wedge (from cw2, the x-wdith)
// dz: adjust z-height of bottom edge of wedge
// dh: shrink y-height of clip2i
// rc: corner radii for roundedRect [rc, rc, 0, 0] (rc = 0)
module clip2i(dw = pp, dz = 0, dh = 0, rc = 0) {
  module mainblock1(cw, ch, cz) {
    trr([0, 0, cz/2-p]) cube([cw, ch, cz], center = true);
  }
  module mainblock2(cw, ch, cz) {
    trr([-cw/2, -ch/2, -p, [0, -90, 0, [cw/2, 0, cw/2]]])
      linear_extrude(height = cw) 
      roundedRect([cz, ch], [rc, rc, 0, 0]);
  }
  cw = cw2 + dw;      // x-wide
  ch = ch2 + dh;      // y-height
  cz = bz2 + sr + 3;  // 3 = thickness above axel
  difference() {
    mainblock2(cw, ch, cz);
    astack(2, [0, 0, 0, [0,  0, 180]]) wedge(dw, dz);
  }
}

cs2 = .15; // clip2 shrinkage
module clip2() {
  cy = sr*2;
  color("blue")
  difference() {
    clip2i(-cs2, -f, -.1, .6);  // lower bottom of wedge
    trr([0, 0, -p]) axel(0, cw2/2 + pp);
    trr([0, 0, br/2-pp]) cube([cw2, cy, br], center = true);
  }
}

// 0: design1, 1: print
// 2: design2, 3: print
loc = 3;
// 0: no brush, 1: brush
bsh = 0;

astack(4,[0, sby + bh2 + 1, 0] ) astack(2, [22, 0, 0])
{
atrans(loc, [undef, 0, [0, 0, 0], 2])
bracket2();
atrans(loc, [undef, 0, [0, 0, f/2], [bw/2, 0, (cw2-cs2)/2, [0, 90, 0]]])
clip2();
}

atrans(bsh, [undef, [0, 0, 0]]) 
brush();
