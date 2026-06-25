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
z4 = br-2;  // height to brush axis
stub = bw;
sr = 1.5; // rod radius
head = 1.2; // z depth reserved for screw1 head
scr = 2.1; // screw radius 
s2r = 3.45; // height & radius of screw2 head


axl = 10;
module axel(l = axl, sl = stub) {
  trr([sl-l/2, 0, z4, [0, -90, 0]]) 
    cylinder(h = l + 2*sl, r = sr);
}
module brush(l = axl, sl = stub) {
  trr([-sl/2, 0, z4, [0, -90, 0]]) {
    cylinder(h = l, r = br);
  }
  color("white") axel(l);
}

// space for panhead screw, subtracted in difference below
// positioned with join between head & screw @ z=0
// head: z-height of head
module screw1(scr = scr, len = 15+s2r/2, head = head ) {
  trr([0, 0, -len]) cylinder(h = len+head, r = scr); // screw part
  trr([0, 0, 0]) cylinder(h = head, r = s2r); // tapered head
}

// space for the screw, subtracted in difference below
// positioned with top of head & screw @ z=0
// rad: radius of head
module screw2(scr = scr, len = 15+s2r/2, rad = s2r ) {
  sink = .3;
  trr([0, 0, -len]) cylinder(h = len, r = scr); // screw part
  trr([0, 0, -rad-sink+p]) cylinder(h = rad, r1 = 0, r2 = rad);
  trr([0, 0, -sink]) cylinder(h = sink+pp, r = rad);

}

bt = 2;  // x-thickness of slotted brackets
tz = 1.5;  // top z (& clip top thickness)
bz = z4 + sr + tz; // bracket z-top

cw2 = 2;   // x-width of clip slot & wedge
ch2 = 2*(sr+1.9); // y-height of clip

bw2 = 9;  // x-width of base of bracket2
bw2a = cw2 + 2.5; // x-width at top of bracket2
bh2 = ch2+4;  // add screw block later
bz2 = z4;  // z4 = z-height to axel

ty = 20;   // y-length of block
ly = 5;    // left of axel;

btop = br + sr + 2;

module screwblock2(dz = bz, bz2 = z4) {
  trr([0, p, p])
  difference() {
  intersection() {
    block();
    cutblock();
  }
  axel(0);
  }
}

// bx0, bxz, by, bz = top of bracket
module block() {
  bx0 = bw2; bxz = bw2a; by = ty; dy = ly; // dy: left of axel
  difference() {
  trr([0, by/2-dy, 0])
  linear_extrude(height = bz, scale = [bxz/bx0, 1])
    square([bx0, by], true);
    trr([0, 10, bz+p]) screw2();
  }
}
cutz = z4 - (sr + .5);
// the block that is differenced & intersected with the main block:
module cutblock(f = pp) {
  x = bw2;
  y = (ty - ly) + f;
  or = sr * 3;
  echo("cutblock:", y, bh2 );
  trr([-x/2, 0-(f)/2, cutz-f/2]) cube([x, y, bz - cutz + f]);
  trr([0, -or-(f)/2, z4+sr-f/2, [-35, 0, 0, [0, or, 0]]]) cube([x/2, or, bz - sr - cutz + f]);
 * trr([-x*.28, .66 -or-(f)/2, z4-f/2, [-35, 0, -35, [x/2, or, 0]]]) cube([x/2, or, bz - sr - cutz + f]);
}
// bracket with down plunging locking clip
module bracket2() {
  color("green")
  difference() {
    block();
    axel(0);
    cutblock();
  }
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
  module mainblock1(cx, cy, cz) {
    trr([0, 0, cz/2-p]) cube([cx, cy, cz], center = true);
  }
  module mainblock2(cx, cy, cz) {
    trr([-cx/2, -cy/2, -p, [0, -90, 0, [cx/2, 0, cx/2]]])
      linear_extrude(height = cx) 
      roundedRect([cz, cy], [rc, rc, 0, 0]);
  }
  cx = cw2 + dw;      // x-wide
  cy = ch2 + dh;      // y-height
  cz = bz2 + sr + 3;  // 3 = thickness above axel
  difference() {
    mainblock2(cx, cy, cz);
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

astack(8,[10, 0, 0] )
{
atrans(loc, [undef, 0, [0, 0, 0], 2])
bracket2();
atrans(loc, [undef, 0, [0, 0, 0], [0, -ty-1, -cutz, [0, 0, 0]]])
screwblock2();
}

atrans(bsh, [undef, [0, 0, 0]]) 
brush();
