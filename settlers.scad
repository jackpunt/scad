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
      echo("perf: x,y,z=", [ x, y, z ]) //
      translate([ x, y, z ]) children(1);
  }
}

tb = 2; // thickness of base
h = 4; // height of 'wall'
tw = 2; // thickness of 'wall' on lid
t0 = 3; // thickness of acrylic walls

module cell(xx, yy, x0=0, y0=0) {
 translate([x0+t0, y0+t0, 0])  box([xx-2*t0, yy-2*t0, t0+h], [2,2,-1.5], [2,2,4]);
}
// translate([0,-222, 0]) 
perforate([10, 10, 0], [30, 30, 0], [80, 90, 0])
color("blue") 
cube([215+64, 222, tb]);

r2 = 220-121;
y2 = 220-118;
w2 = 24;
translate([0,0, tb-p]) {
  cell(67, 121, 0,  0);
  cell(78, 60, 64,  0);
  cell(79, 60, 139, 0);
  cell(78, 64, 64, 57);
  cell(79, 64, 139, 57);

  cell(t0+w2, r2, 0, 118);
  cell(91-w2, r2, w2, 118);
  cell(155-88, r2, 88, 118);
  cell(218-152, r2, 152, 118);

  cell(64, 93, 215);
  cell(64, 118-90+t0, 215, 90);
  cell(64, r2, 215, 118);
}
