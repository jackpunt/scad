use<mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1.0;
p = .001;
pp = 2 * p;

sqrt3 = sqrt(3);
sqrt3_2 = sqrt3/2;
d0 = 2.2;   // mm per cardbord
hr0 = 26;    // mm on edge
hr = hr0+min(hr0,da(30, hr0)); // extend to hold rotated hexes +da(hr0, 30)

// function da(a, r) = (sin(60+a)-sin(60))*r;
function da(a, r, r0 = 60) = (sin(r0+a)-sin(r0))*r;

// show actual radius of poly cylinder
module fine_circle(r = 10, g=24){
  children(0);
  $fn = g;
 # circle(r);
}

//
module polycylinder(h, fn = 6, r=10, cz = false) {
  $fn = fn;
  linear_extrude(h )
  circle(r);
}

// hexagonal tube
module hexBox(h=10, r=5, t=t0, cz = false) {
  translate([0, hr + t0*2, cz ? -h/2 : 0])
  rotate([0, 0, 30])
  difference() {
    polycylinder(h, 6, r);
    translate([0, 0, -p])  
    polycylinder(h+pp, 6, r-t);
  }
}

module hexstack(n = 10, cx=true, c = "blue") {
  a1 = 60/n; tl = n * d0; ctr = cx ? -tl / 2: 0; dx = .05;
  translate([0, 0, ctr, ])
  for (i = [0 : n-1]) //
    let (a = (n-i) * a1 + 0 )
    color(i == n-1 ? "blue" : i==0 ? "grey" : "pink")
    translate([0, hr0 + da(a, 30) + t0*1.05, i * d0]) //
    rotate([0, 0, a + 30]) //
    polycylinder(d0 - dx, 6, hr0);
}


// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s = is_list(size) ? size : [size,size,size]; // tube_size
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0])
 rotate([0, -90, 0])
 roundedTube([s[2], s[1], s[0]], rt, k, t);

 // endcaps
 hw0 = [s[2], s[1], 0];
 hwx = [s[2], s[1], s[0]];
 div(hw0, rc, k);
 div(hwx, rc, k);
}

// 4 littles + blue block
// last round hex
// 
module starterBox(loc = 0) {
  lrbt = [[24, "base", 1 , 2], [1, "", 2]];
  tlen = sum(selectNth(0, lrbt));
  tl = tlen * d0 + 3 * t0; // sum of sizes
  bbh = 30; bbl = 50; bbw = 15+1; // blue block
  sbx = 35 + 2*t0; // short dim of parts box
  bw0 = tl;        // long dim of parts box
  bs = 2*t0 + .7; // shrink the player tray
  bw = bw0-bs;     // long dim of player tray
  bl = sbx-bs;     // short dim of player tray
  bh = 22;         // height of player tray
  bt = ht-(t0+bbw+bh);  // top of player tray, down from parts box
  st = 2; sd = ht-bt;   // thickness of lid to hold player tray & block
  atrans(loc, [[0, -size -5*t0, 0], [], []]) {
  difference() {
    union() {
      // last_round & base tiles:
      translate([t0, 0, 0]) hextray_x(lrbt, 1);
      echo("starterBox: bw=", (bw-3*t0)/4, "tl=", tl);
      // parts box:
      translate([0, -size*0.5 + 0, 0]) 
        rotate([0, 0, -90])
        {
          reveal = false; 
          uhr = reveal ? ht*2 : 10;
          uht = reveal ? 0 : ht;
          slotifyY2([ht, uhr, 3*t0], [sbx/2, bw0, uht*.3], undef, 3)
          slotifyY2([ht, uhr, 3*t0], [sbx/2, 0, uht*.3], undef, 3)
            box([sbx, bw0, ht]);
          // support rail:
          *color("green")
          for (ds = [2*t0 : t0 : 3*t0]) let (bws = bw0 - ds)
            repeat([0, -bws/2, 0], [0, bws, 0], 2)
            translate([0, bw0/2 -ds/2, ht - bh - bt - (4 * t0 -ds)]) cube([sbx, ds, 1]);
          // Player tray:
          atrans(loc, [[sbx, bw0/2, 0], [0, bw0/2, ht - bh - bt], [0, bw0/2, ht+3*t0]]) {
            r0 = 20; r1 = 2; rt=0;
            bhr = bh+r1; // tube @ h+r1, then cut -r1
            rad = [r0, r1, rt, rt];
            rod = [r1, r1, rt, rt];
            translate([1.1*t0, bw/2 + .5* t0, 0])
            rotate([0,0,-90])
              {
              tray([bw, bl, bhr], rad, rod, -r1);
              for (i = [1 : 3]) let (y = i * bw/4)
                translate([-y, 0, 0]) 
                div([bh, bl, bw], rad);
              }
            }
          // blue box:
          atrans(loc, [undef, [t0+(bl-bbh)/2, t0+(bw-bbl)/2, t0+.1]])
          color("BLUE") cube([bbh, bbl, bbw]);
          }
      }
    // Slot for lid:
    translate([t0, -size*.5-sbx-1*t0, sd]) cube([bw, sbx+4*t0, st+.35]);
  }
  // Lid for player tray:
  atrans(loc, [[0, -2*(bl + 4*t0), .35/2], [0,0,sd+.35/2]])
  translate([t0, -size*.5-sbx-2*t0, 0]) color("green") {
    translate([-1*t0, 0,0]) cube([bw0+0*t0, 2*t0, 6*t0]);
    cube([bw, sbx+5*t0, st]);
  }
  }
}

// name: text
// tr: translate onto surface
// rx: rotate on x-axis
// t: height of text
module hexText(name= "hex", tr, rx = 30, t = t0) {
  rxx = (rx >= 0) ? [rx, 0, 0] : [-rx, 0, 180];
  trr = (rx >= 0) ? tr : [tr[0], -tr[1], tr[2]];
  echo("hexText: name=", name );
  translate(trr)
  rotate(rxx)
  linear_extrude(t)
  text(name, size=hr*.4, halign = "center");
}

hzz = 8;
// add hook & cut slot
// dx: distance to other side
// tr: translate to surface
// dy: offset from center
// t: thickness of hook parts
// yaxis: rotate hook(s) to be on the y-face (false)
// sh: select hooks: 0 -> none, 1: -> tr, 2: -> tr(dx), 3: both
// ambient
// t0: size of mating plate
// hzz: vertical size of hook
module hook(dx, tr = [0,0,0], dy = 20, t = 2, yaxis = false, sh = 3) {
  tr = is_undef(tr) ? [0,0,0] : tr;
  rotrc = [0,0,180,adif([dx/2, 0, 0], amul([-1,-1,-1],tr))];
  w = 6;  // width of male plate (incl 2 for stem)
  f = .3;
  rot = yaxis ? [0, 0, 90, [dx/2, 0, 0]] : [0,0,0];

  module maybe_dup(tr, rott, sh = sh) {
    if (sh == 3) {
      dup(tr, rott) children(0);
    } else if (sh == 1) {
      children(0);
    } else if (sh == 2) {
      translate(tr) rotatet(rott) children(0);
    }
  }
  if (t == 0) {
    children();
  } else {
    // color("blue")
    // add 0-2 hooks:
    maybe_dup([0, 0, 0], rotrc) {
      translate(tr)
      rotatet(rot)
      union() {
        translate([-2 * t0, -dy, 0]) cube([3.*t0+pp, w, t]);
        translate([-(3.5)*t0, -dy, 0]) cube([t, w, hzz]);
      }
    }
    // cut 0-2 slots:
    difference() {
    children(0);
    maybe_dup([0, 0, 0], rotrc)
    translate(tr) 
    rotatet(rot)
    translate([-2 * t0, (dy - w - f/2) , -p])      //
      cube([3.5 * t0 + pp, w + f, t + f]);         //
  }
  }
}
// hook test:
atrans(loc, [undef, [-40, 0, 0]])
hook(80, [0, 0, 0], 20, 2, false, 3) 
hook(55, [10, 0, 0], 20, 2, true, 0) 
translate([-0, -55/2, 0]) box([80, 55, 20], [t0, t0, -t0], [2,2,2], false);

size = 2 * (hr + 2 * t0) * sqrt3_2; // width of box (hex with twist)
ht = hr + hr0 + t0;                 // height of box

// generic hexagonal tray
// n: number of hextiles to hold
// size: width to hold hex [ambient size]
// name: text to engrave on bottom
// @ambient
// ht: height of all hextray
module hextray(n = 10, size = size, name) {
  tl = n * d0 + 2 * t0; // n*d0 interio + 2*t0 endcaps
  echo("hextray: hr=", hr, " size=", size, "ht=", ht, "tl=", tl);
  module pos() {
    translate([0, 0, 0]) rotate ([90, 0, 90]) children();
  }
  reveal = false; 
  uhr = reveal ? ht : hr;
  uht = reveal ? 0 : ht;
  // slots on side walls:
  sw = min(tl - 10, 18);
  // slotifyY2([ht, sw, 8*t0], [0, t0-dy/2, 22.3], undef, 2, false)
  // slotifyY2([ht, sw, 8*t0], [0, t0+dy/2, 20], undef, 2, false)
  // Slots on end-caps:
  slotify2([ht, uhr, 3*t0], [+tl/2, 0, uht*.3], undef, 3)
  slotify2([ht, uhr, 3*t0], [-tl/2, 0, uht*.3], undef, 3)
  union() {
    box([tl, size, ht], [t0, t0, -t0], [2,2,2], true); // funky rotation...
    difference()
    {
      pos() hexBox(tl, hr+2*t0, t0, true); 
      translate([0,0,ht+p]) cube([tl+pp, size, ht/2 +p], true);
      if (doText && !(is_undef(name) || name == "")) {
        hexText(name, [0, 6, 4], 30, 1);
        hexText(name, [0, 6, 4], -30, 1);
      }
    }
  }
  * pos() hexstack(n);

}
function sum(ary = [], n) = 
  let(nn = is_undef(n) ? len(ary) - 1 : n)
    (nn < 0) ? 0 : (n == 0) ? ary[0] : ary[nn] + sum(ary, nn-1);

function selectNth(n, ary) = [for(elt = ary) elt[n]];

echo("selectNth: ", selectNth(1, [ [1, "a"], [2, "b"], [3, "c"] ]));


// make a series of hextrays:
// parma: [[ n, name, hookp], ... ]
module hextray_x(parma, dt = 1) {
  hn = selectNth(0, parma);
  dy = size + t0;
  echo("hextray_x: hn=", hn, "parma=", parma);
  for (i = [0: len(parma)-1]) 
    let( parms = parma[i],
         n = is_list(parms) ? parms[0] : parms, 
         dx = n*d0, 
         name = is_undef(parms[1]) ? "" : parms[1],
         shx = is_undef(parms[2]) ? 0 : parms[2],
         shy = is_undef(parms[3]) ? 0 : parms[3],
         tx = shx == 0 ? 0 : 2,    // enable x-axis hook(s)
         ty = shy == 0 ? 0 : 2,    // enable y-axis hook(s)
         trx = d0 * (n / 2 + sum(hn, i-1)) + i * dt
       ) {
      translate([trx, 0, 0])
      hook(dy,      [-t0-dy/2, 0, 0], 15, ty, true, shy) 
      hook(dx+2*t0, [-t0-dx/2, 0, 0], 15, tx, false, shx)
      hextray(n, size, name);
    }
}

loc = 2;
doText = false;
//        A    B    C    goal bon chal;
trays = [[43, "A", 3, 2], [46, "B", 3, 2], [39, "C", 3, 2]];
joins = [[25, "goals", 1, 2], [10], [10, "", 2]];  // goals, bonus, challenge
dy = size + 5*t0; // was layout spacing...
translate ([t0, dy*0, 0])
  hextray_x(trays, 6.5);
goalx = joins[0][0]*d0/2;
translate ([t0, dy*1, 0]) 
  slotifyY2([ht, 18, 4*t0], [goalx, +(size - t0)/2, 22.3], undef, 2)
  slotifyY2([ht, 18, 4*t0], [goalx, -(size - t0)/2, 22.3], undef, 2)
  hextray_x(joins, 1); // conjoin 3 boxes
starterBox();


echo("total:", sum(selectNth(0, trays)));
// hextray();
