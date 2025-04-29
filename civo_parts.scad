use <mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

// outer dimensions of box:
l = 140;
w = 53;
h = 50;
d1 = 52; // div at x = d1;

//
db = 28;
ss = 16;
cr = 3;
r = 2;

/* clang-format off */
loc = 0;
hn = 2.3 * t0;// hook notch
// main box:
slotify([ h - db, ss / 2 ], [ 0, w / 2, db ], undef, cr) 
difference() { 
    box([ l, w, h ]);
    translate([ d1, -t0, h - hn ]) cube([ bl + 2 * t0, 3 * t0, 3 * t0 ]);
}
if (loc == 1) {
    translate([ 1.1 * t0, (w - 45) / 2, t0 ]) cbstack(24, [ 45, 45, 2 ], "lightgrey", .075);
}
/* clang-format on */
bonusTray(loc);
// dice_box(s) inside main box; flush with sites
d = 10;                 // dice size
ds = d + 2 * t0 + 1.15; // shaft size
module dbox(x = 0, y = 0, z = 0)
{
    de = 3;           // edge to hold dice
    sw = ds - 2 * de; // slot radius: dbox
    dz = d * .5;
    r = 2; // tall enough so dice don't fall out top
    translate([ x, y, z ]) rotatet([ 0, 0, 90 ], [ ds / 2, ds / 2, 0 ])
    {
        if (loc == 1)
            translate([ 1.5 * t0, 1.5 * t0, t0 ]) // color("white") roundedCube(d,1); // die
                rotatet([ 0, -90, 0 ], [ d / 2, 0, d / 2 ]) astack(4, d + .01, [ 0, 0, 0 ]) color("white")
                    roundedCube(d, 1);
        difference()
        {
            slotify([ h - sw - dz, sw / 2 ], [ ds - t0, ds / 2, sw ], undef, r) box([ ds, ds, h - dz ]);
        }
    }
}
// interior div for sites:
translate([ d1, -p, 0 ]) slotify([ h - db, ss / 2 ], [ 0, w / 2, db ], undef, cr) div([ h, w - 2 * p ], .2);
div([ ds, w - 2 * p, d1 + 3 * (ds - t0) ]);
cw = 28;
sy = [ t0, w - cw - t0 * 2.2, t0 * 1.5 ];
if (loc != 0)
    translate([ d1 + 3 * (ds - t0) + 1.1 * t0, sy[loc], t0 ]) cbstack(12, [ 28, 28, 2 ], "tan", .1); // score-100 tiles

color("green") div([ bz, w, d1 + 3 * (ds - t0) ], 0);
color("green") div([ bz, w, l - bxx ], 0);
// echo(d1+3*(ds-t0), l-t0-bxx-25.5)

// dbox(d1, p);
dup([ ds - t0, 0, 0 ]) dup([ ds - t0, 0, 0 ]) mirror([ 0, 1, 0 ]) dbox(d1, -w - p, p);

// make boxes for bonus_tokens (18x20) & resource_chips (20x20)
dd = .9; // increase size for patch
bx = 22 + dd;
by = 22 + dd;
bz = 10 + t0; // bz: base_height;
f = .35;      // fudge: slack in holding base (~ nozzle/2)
bxx = bx + 2 * t0 + f;
byy = by + 2 * t0 + f;

ch = h - 1 * t0 - .01;
// cardboard boxes:
module pbox(xyz, t = t0)
{
    rs = by * .125;
    ds = (bz + rs) * .8; // ch*.1; // raise slot

    translate(xyz) atrans(loc, [ [ 0, 0, 0 ], [ -bxx + f / 2, 0, t0 + p ] ]) difference()
    {
        slotify([ ch - ds, rs, 2 * t ], [ bx - 2 * t, by / 2, ds ], undef, 3) box([ bx, by, ch ], t); // top box
        translate([ bx / 2, by / 2, -.5 ]) cylinder(2, r = 5);
    }
}

pbox([ l + t0, t0 + f / 2, 0 ], t0 + p);
// base_lock inside main box:
translate([ l - (bxx)-p, p, 0 ]) box([ bxx, byy, bz ]);

// pipe for hunting tokens:
module hbox()
{
    rp = 11;
    //
    atrans(loc, [ [ 0, 0, 0 ], [ t0 - bxx + f / 2, 0, t0 ] ]) translate([ l + rp + t0 - f / 2, w - t0 - rp - f / 2, p ])
    {
        pipe([ rp, rp, ch ]);         // <-- the pipe
        pipe([ rp, rp, t0 ], rp / 2); // base with hole
    }
    // base for pipe:
    translate([ l - t0 - rp - f / 2 - p, w - t0 - rp - f / 2 - p, -p ]) pipe([ rp + t0 + f / 2, rp + t0 + f / 2, bz ]);
}
hbox();

bl = l - (d1 + t0) - bxx;
bw = ds;
bh = 16;
br = 3;
hh = 6;
module bonusTray(loc = 0)
{
    // tray for bonus cardboard:
    module hook()
    {
        hw = 3.25; // 3*t0 + f
        translate([ 0, t0 - hw, dh + (bh - hh) + t0 ]) rc([ bl, 0, 0 ], [ -90, 0, 0 ], 2, br)
            rc([ 0, 0, 0 ], [ -90, 0, 0 ], 1, br) difference()
        {
            cube([ bl, hw, hh ]);
            translate([ -p, t0, -t0 ]) cube([ bl + pp, hw - 2 * t0 + pp, hh + pp ]);
        }
    }

    dh = 2.9;
    atrans(loc, [
        [ (l + dh + bh + bx - p), -1 * t0, 0, [ 0, -90, 0 ] ], // <-- print loc
        [ (d1 + t0 / 2 - p) + t0, t0, h - dh - bh - hn + .2 ], // <-- on box
        [ d1 - p, -20, 0 ]
    ]) // <-- edit loc
    {
        hook();
        rc([ bl, bw, bh ], [ 90, 0, 0 ], 2, br) rc([ 0, bw, bh ], [ 90, 0, 0 ], 1, br) difference()
        {
            cube([ bl, bw, bh ]);
            translate([ -p, t0, t0 ]) cube([ bl + pp, bw - 2 * t0 + pp, bh + pp ]);
        }
        if (loc == 1)
        {
            translate([ 0, bw - 1.2 * t0, t0 ])
                cbstack(5, [ 20, 18, 2, [ 0, 0, -90 ] ], "brown", .1); // <-- demo cardboard
            translate([ 22 - t0, bw - 1.2 * t0, t0 ])
                cbstack(5, [ 18, 20, 2, [ 0, 0, -90 ] ], "brown", .1); // <-- demo cardboard
        }
    }
}

// stack of children()
// n: number
// dx: each iteration
// rot: rotate from dx --> dy or dz
module astack(n, d, rot)
{
    for (i = [0:n - 1])
    {
        rotate(rot) dup([ i * (d), 0, 0 ]) children();
    }
}
// n: repetitions
// hwt: [h, w, t] or [h, w, t, rot]
// d: space between (.01)
// c: color ("tan")
module cbstack(n = 1, hwt = [ 18, 20, 2 ], c = "tan", d = .01)
{
    h = hwt[0];
    w = hwt[1];
    t = hwt[2];
    rot = is_undef(hwt[3]) ? [ 0, 0, 0 ] : hwt[3];
    astack(n, t + d, rot) color(c) cube([ t, h, w ]);
}
