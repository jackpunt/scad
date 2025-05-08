use <mylib.scad>;
p = .001;
pp = 2 * p;

module box2(lwh = [ 10, 10, 10 ], t = t0, d, cxy = false) {
  t = is_undef(t) ? t0 : t;             // wall thickness
  txyz = is_list(t) ? t : [ t, t, t ];  // in each direction
  d = is_list(d) ? d : [ 2, 2, 1-p ]; // reduce inner_cube by txyz
  dxyz = adif(adif(lwh, amul(d, txyz)), [0,0,-pp]); // dxyz = lwh - d * txyz;
  // dxyz = adif(adif(lwh, amul(d, txyz)), [0,0,-pp]); // dxyz = lwh - d * txyz;
  echo("box: lwh=", lwh, "d=", d, "txyz=", txyz, "dxyz=", dxyz);
  dc = cxy ? -.5 : 0;
  txyzc = amul(lwh, [dc,dc,0]);
  translate(txyzc) 
  difference() {
    cube(lwh);
    translate(txyz) cube(dxyz); // -2*bt or +2*p
  }
}


module pat(s = 5, l = 30)
{
    rotatet([ 0, 45, 0 ], [ s / 2, 0, s / 2 ]) translate([ 0, -p, 0 ]) cube([ s, l + pp, s ]);
}

module paty(s = 5, l = w)
{
    scale([ 1, 1, .7 ]) translate([ -s / 4, 0, -s / 2.8 ]) pat(s / 2, l);
}
module patx(s = 5, l = w)
{
    scale([ 1, 1, .7 ]) translate([ 0, -s / 4, -s / 2.8 ]) rotatet([ 45, 0, 0 ], [ 0, s / 2, s / 2 ])
        translate([ -p, 0, 0 ]) cube([ l + pp, s, s ]);
}

module gridaway(x0 = 40, l = l * .65, h = 25)
{
    s = 10;
    difference()
    {
        children(0);
        translate([ x0, 0, t0 + s * .8 ]) grid(l - s - x0, h - s - 5, 5) paty(s, w);
    }
}
module gridawayy(x0 = 20, l = l)
{
    s = 10;
    difference()
    {
        children(0);
        translate([ x0, 0, t0 + s ]) grid(l - s - x0, h - s - 5, 5) paty(s, w);
    }
}
module gridawayx(x0 = 20, w = w)
{
    s = 10;
    difference()
    {
        children(0);
        translate([ -10, x0, t0 + s ])
            // rotatet([0, 0, -90], [-20, 0, 20])
            grid(w - s - x0, h - s - 5, 5, [ 0, 1, 1 ]) patx(s / 2, 20);
    }
}

// children(0) - base plate
// children(1) - motif to subtract 
// txyz: [x, y, z] initial offset
// dxyz: [dx, dy, dz] delta per iteration
// mxyz: [mx, my, mz] max value of iteration
module perforate(txyz, dxyz, mxyz) {
  echo("perf: x,y,z=", [ txyz, dxyz, mxyz ]) //
  difference() {
    children(0);
    for (x = [txyz[0]:dxyz[0]:mxyz[0]], //
         y = [txyz[1]:dxyz[1]:mxyz[1]], //
         z = [txyz[2]:dxyz[2]:mxyz[2]]) //
      translate([ x, y, z ]) children(1);
  }
}

tb = 5; // thickness of base
h = 4; // height of 'wall'
tw = 2; // thickness of 'wall' on lid
t0 = 3; // thickness of acrylic walls

module cell(xx, yy, x0=0, y0=0, card = true) {
  if (card) {
    translate([x0+t0, y0+t0, 0])
    box([xx-2*t0, yy-2*t0, t0+h], [2,2,-1.5], [2,2,4]);
  } else {

  }
}

r2 = 220-121;
y2 = 220-118;
w2 = 24;
module cells() {
  translate([0,0, tb-p]) {
    cell(67, 121, 0,  0);       // Ore cell
    // parts bins:
    cell(78, 60, 64,  0);       // player A
    cell(79, 60, 139, 0);       // player B
    cell(78, 64, 64, 57);       // player C
    cell(79, 64, 139, 57);      // player D

    // cell(t0+w2, r2, 0, 118);     // dice & robber
    cell(91-w2, r2, w2, 118);    // wheat
    cell(155-88, r2, 88, 118);   // sheep
    cell(218-152, r2, 152, 118); // wood-brick

    cell(64, 93, 215);           // dev cards
    // cell(64, 118-90+t0, 215, 90); // hex markers
    cell(64, r2, 215, 118);      // brick-wood
  }
}

loc = 0;
gs = 10;
// translate([0,-222, 0]) 
 perforate([gs, gs, 0], [gs, gs, 1], [280-gs, 222-gs, 1]) 
{
  color("blue") 
  cube([215+64, 222, tb]);
  cube([gs/2,gs/2,gs/2+tb], true);
}
atrans(loc, [undef, [0,0,0]]) cube([220, 220, 1]);
cells();

module base(dx = 20, dy = 20, dz = 3) {
  translate([0, 0, dz/2]) cube([dx, dy, dz], true);
}
// v: depth of underlying plate (dist between peg and top disk)
// d: thickness of top disk
// r: radius of top disk
module pegPlate(v = 3, d = 2, r = 5, f = .5) {
  r0 = 2.5; // peg radius
  children(0);
  cylinder(h = v+v+p, r = r0, $fn = 30); // post
  dr = .6; dzr = .33; dzz = .6 * dr*dzr; // start the enlarge a bit below the top plate
 % for (rp = [r0 : dr : r]) let ( dz = (rp - r0)*dzr) 
    // echo("r, rp, dr, dz=", r, rp, dr, dz )
    translate([0, 0, v+v+dz-dzz]) cylinder(h = d-dz+dzz, r = rp, $fn = 30); // collar
    rp = r; dz = (rp - r0)*dzr;
    translate([0, 0, v+v+dz-dzz]) cylinder(h = d-dz+dzz, r = rp, $fn = 30); // collar
}
// cut a circle and slot
// tr: translate to center of circle ([0, 0, 0])
// ds: translate from post to extend slot ([-2*r, 0, 0])
// v: thickness of plate 
module matingSlot(tr = [0,0,0], ds, v = 3, r = 5, f = .5, r0 = 2.5) {
  ds = is_undef(ds) ? [-(r+r), 0, 0] : ds;
  difference() {
    children(0);
    translate(adif(tr, [0,0,p])) {
      cylinder(h = v * 2, r = r+f);  // hole
      hull() {
        cylinder(h = v+pp, r = r0, $fn=30); // post
        translate(ds)  cylinder(h = v+pp, r = r0+f, $fn=30);
      }
    }
  }
}

// peg & slot demo:
// v = 3;
// matingSlot([10, -17.5, 0])
// pegPlate()
// translate([0, -7.5, 0]) base(40, 40, v);

// *translate([-7.5,-7.5, v+.2]) // color("blue") 
// matingSlot([7.5, 7.5, 0], [0, 10, 0], 3, 5, .5)
//  cube([15, 25, v]);
