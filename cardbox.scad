use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1.0;
l0 = 92.4;
w0 = 60.4;
h0 = 27.4 + 3.1; // extend for ramp!
l = l0 + 2 * t0;
w = w0 + 2 * t0;
h = h0 + t0;

loc = 1;

// hypotenuse: given angle * adjacent_base length
function hypa(a, b) = (let(h = b * tan(a)) sqrt(b * b + h * h));
function hypo(a, h) = (let(b = h / tan(a)) sqrt(b * b + h * h));

// poke holes (children(1)) in children(0) through the y axis
// x: [x0, step, xm]
// z: [z0, step, zm]
// tr: [1,0,1] select axiis to translate
module gridify(x, z, tr = [ 1, 0, 1 ])
{
    for (xa = [x[0]:x[1]:x[2]], za = [z[0]:z[1]:z[2]])
    {
        // echo("xz=", [xa, za]);
        translate(amul([ xa, xa, za ], tr)) children(0);
    }
}
module grid(nx, nz, k, tr = [ 1, 0, 1 ])
{
    gridify([ k, 2 * k, nx ], [ 0, 2 * k, nz ], tr) children(0);
    gridify([ 0, 2 * k, nx ], [ k, 2 * k, nz ], tr) children(0);
}
module pat(s = 5, l = 30)
{
    rotatet([ 0, 45, 0 ], [ s / 2, 0, s / 2 ]) translate([ 0, -p, 0 ]) cube([ s, l + pp, s ]);
}

*translate([ 0, -40, 0 ])
{
    nx = 50;
    nz = 30;
    y = 1;
    s = 10;
    difference()
    {
        cube([ nx, y, nz ]);
        grid(nx, nz, s / 2) scale([ 1, 1, .7 ]) translate([ -s / 2, 0, -s / 2 ]) pat(s / 2, y);
    }
}
a = 18;
dz = 6;                 // top of slot
iw = 5.1;               // width of slot_interior
xb = (h - dz) * tan(a); // length of holder after tilt...
lt = l + xb;            // length total
echo("xb, lt, lwh=", [ xb, lt, l, w, h ], "tan(a)=", tan(a), "hyp(a,iw)=", hypa(a, iw));
// TODO: snap-on top!

module holder(a = a)
{
    xb = (h - dz) * tan(a); // length of holder after tilt...
    ha = (h - dz);
    echo();                // top to slot
    fw = iw + 2 * t0;      // full width of slot box
    hb = ha - fw / cos(a); // down from top to rotation point
    hr = ha - hb;
    echo("xb=", xb, "ha=", ha, "hb=", hb, "hr=", hr);
    wb = w0;
    intersection()
    {
        translate([ p - xb, 0, 0 ]) cube([ xb, w, h ]);
        {
            rotatet([ 0, -a, 0 ], [ 0, 0, dz ])
            {
                translate([ fw, 0, 0 ]) cube([ 7, w, 1.2 * h ]); // fill w/ giant block, then intersect
                {
                    bh = t0 + ((a > 1) ? ha / cos(a) : ha);
                    echo("bh=", bh);
                    translate([ 0, 0, dz ]) box([ fw, w, bh ], t0); // main box
                    translate([ 0, 0, bh - 6 ]) rotatet([ 0, -18, 0 ], [ iw, 0, 2 * t0 ])
                        cube([ iw + t0, w, t0 ]); // bottom shelf
                }
            }
        }
    }
    // translate([-t0,0,-bl]) rotate([-90,0,0]) cylinder([iw+2*t0, w, bl]);
}
module holder2(a = a)
{
    iw = 5.1;
    fw = iw + 2 * t0;
    bh = h0 + h0 * tan(a);
    rotatet([ 0, -a, 0 ], [ 0, 0, bh * .5 ]) * % translate([ -iw - t0, 0, t0 ]) box([ fw, w, bh ]);
}
holder2();
module card(tr = [ 2, 2, 4 ])
{
    translate(tr) color("pink") cube([ 88.5, 60.4, 1 ]);
}

// vz: height of ramp @ vx: bump @
vz = 4.;
vx = .4 * l;
fl = 2;
vy = 5.6; // fl: flat length
module ramp(vx = vx, vz = vz, ve = 0)
{
    sa = sin(a2);
    ca = cos(a2);
    vz = (l - vx) * sa;
    vzt = vz + t0; // vz = 3.16
    intersection()
    {
        union()
        {
            rotatet([ 0, -a2, 0 ], [ vx, 0, vz + t0 ]) for (y = [0:(w - vy) / 4:w - vy]) translate([ ve, y, 0 ])
                cube([ vx, vy, vz + t0 ]);
            translate([ vx, 0, 0 ]) cube([ 2.4, w, vz + t0 ]);
        }
        translate([ ve, 0, 0 ]) cube([ vx, w, vz + t0 ]);
    }
    dr = 14;
    intersection()
    {
        translate([ vx + (dr / 2 + .0) * t0, w / 2, vzt / 2 ]) rotate([ -90, 0, 0 ]) cube([ dr, vzt, w ], true);
        color("blue") translate([ vx + (dr / 2 + 0) * t0, w / 2, vzt / 2 ])
            rotatet([ 0, a2, 0 ], [ -dr / 2, 0, vzt / 2 ]) rotate([ -90, 0, 0 ])
                cube([ dr, vzt, w ], true); // no compound rotation!
    }
}

/** try to hold inline cards, also a "lid" to hold cards in box
 @param dx length of tray
 @param dz height of wings
 @ambient w: width of box, t0: thickness
 */
module topTray(dx = 60, dz = 18)
{
    f = .75;
    tw = w + 2 * t0 + 2 * f;
    atrans(loc, [ [ 0, 0, 0 ], [ 0, -tw - 4 * f, 0 ] ])
    {
        box([ dx, tw, 4 ], t0, [ 2, 2, -2 ]);
    }
}
cutaway()
topTray();

// add horizontal slot to children(0)
module hslot(dz = dz, dx = 0)
{
    sw = 6;
    sh = 4;
    difference()
    {
        union() children();
        translate([ dx - sw / 2, t0, dz - sh ]) cube([ sw, w0, sh ]);
    }
}

// cut child(0) in XY plane @ depth: y0..y1
module cutaway0(loc = loc, cxyz=[10,10,10], txyz=[-5, -5, -5])
{
    if (loc != 0)
    {
        difference()
        {
            children(0);
            translate(txyz) #cube(cxyz);
        }
    }
    else
    {
        children(0);
    }
}
module cutaway(loc=loc) {
  cutaway0(loc, [lt+10, 10, h+10], [-5-xb, -5, -5]) children();
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
        translate([ x0, 0, t0 + s ]) grid(l - s - x0, h - s - 5, 5) paty(s, w);
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

sw = 10;
sr = 10;
rq = 10; // rq if different from sr
cutaway()
    // gridawayx(10)
    // gridawayy(10)
    gridaway() hslot()
{
    ds = .1;
    holder();
    slotify([ h * (1 - ds) + sr, [ sw, sr ], t0 + 4 * p ], [ l - t0 - 2 * p, w / 2, h * ds ], undef, rq)
        box([ l, w, h ], t0);
}
ramp();

if (loc != 0)
    color("pink") translate([ -xb, w + t0, h + 0 ]) cube([ lt, 1, 1 ]);

dy = 10;
dr = 5; // rCube test
*translate([ 0, 0, 0 ]) roundedCube([ dy, dy / 2, 3 ], dr, true);
*roundedRect([ dy, dy ], 1);

// atan(6/88) = 4;
// atan(7/88) = 4.5;
a2 = 3.2;
if (loc != 0)
    translate([ 0, 0, .1 ]) rotatet([ 0, a2, 0 ], [ 90, 0, 1 ]) card([ 4, 2, 1 ]);
