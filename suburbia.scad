use<mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1.0;
p = .001;
pp = 2.2 * p;

sqrt3 = sqrt(3);
sqrt3_2 = sqrt3/2;
d0 = 2.15;   // mm per cardbord (2.15 exact)
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
    translate([0, 0, -p])  
    polycylinder(h+pp, 6, r);
    translate([t0*1., t0*1.5, -t0])  // make thicker on bottom
    polycylinder(h+2*t0, 6, r);
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
module starterBox(loc = loc) {
  lrbt = [[25, ["base", 1 , 2, 0, 0]], [2, ["", 2]]];
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
  f = .35; np = 7; sly = -size*.5-sbx+t0*1; // slot stuff

  atrans(loc, [[20, -size +5 , 0, [0, 0, 90, [bw*.5, -bl*.5, 0]]], 
             [0,-dy,0], []]) 
  {
    difference() {
    union() {
      // hextray_x: last_round & base tiles:
      translate([t0, 0, 0]) hextray_x(lrbt, 1);
      echo("starterBox: bw=", (bw-3*t0)/4, "tl=", tl);
      // parts box:
      translate([0, -size*0.5 + t0*1.0, 0]) 
        rotate([0, 0, -90])
        {
          reveal = false; 
          uhr = reveal ? ht*2 : 10;
          uht = reveal ? 0 : ht;

          slotifyY2([ht, uhr, 3*t0], [sbx/2, bw0, uht*.3], undef, 3)
          slotifyY2([ht, uhr, 3*t0], [sbx/2, 0, uht*.3], undef, 3)
            box([sbx, bw0, ht], t0, [2, 2, 0]); // box for tray & blue cube
          // support rail:
          // color("green")
          // for (ds = [2*t0 : t0 : 3*t0]) let (bws = bw0 - ds)
          //   repeat([0, -bws/2, 0], [0, bws, 0], 2)
          //   translate([0, bw0/2 -ds/2, ht - bh - bt - (4 * t0 -ds)]) cube([sbx, ds, 1]);
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
                div([bh, bl, bw], rad, 0, t0);
              }
            }
          // blue box:
          atrans(loc, [undef, [t0+(bl-bbh)/2, t0+(bw-bbl)/2, t0+.1]])
          color("BLUE") cube([bbh, bbl, bbw]);
          }
      }
    // Cut out Slot for lid:
    translate([t0, sly-t0, sd]) cube([bw, sbx+4*t0, st+f]);
  }
  posts(st+f, [bw/(np*2),sly,sd], [bw/np, 0, 0], np, 1);
  posts(st+f, [bw/(np*2)*2-1.5*t0,sly+sbx-t0,sd], [bw/np, 0, 0], np);
  // Lid for player tray:
  atrans(loc, [[0, -2*(bl + 4*t0), 0], [0,0,sd+.35/2]])
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

hzz = 6;
// add hook & cut slot
// dx: distance to other side
// tr: translate to surface
// dy: offset from center
// t: thickness of hook parts
// yaxis: rotate hook(s) to be on the y-face (false)
// sh: select hooks: 0 -> none, 1: -> tr, 2: -> tr(dx), 3: both
// ambient
// t0: wall thickness, of this and mating part
// hzz: vertical size of hook
module hook(dx, tr = [0,0,0], dy = 20, t = 2, yaxis = false, sh = 3, ctr = [0,0,0]) {
  tr = is_undef(tr) ? [0,0,0] : tr;
  // assuming that target 'box' is centered: [0,0,0] is correct
  // else user can point to center of rotation at z=0 
  ctr = is_undef(ctr) ? [0,0,0] : ctr;
  rotrc = [0,0,180, ctr]; // rotation for 2nd child.
  w = 6;  // width of male plate (incl 2 for stem)
  f = .3;
  // roty is pre-rotation for yaxis:
  roty = yaxis ? [0, 0, 90, [dx/2, 0, 0]] : [0,0,0];
  // echo("hook: dx, tr, dy, t, yaxis, sh, ctr" ,[dx, tr, dy, t, yaxis, sh, ctr]);
  // echo("hook: tr=", tr, "ctr=", ctr, "yaxis=", yaxis, "roty=", roty, "sh=", sh);

  hd = t0 * (1 + 1.5 * f);  // hook depth, size of gap

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
    color("blue")
    // add 0-2 hooks:
    maybe_dup([0, 0, 0], rotrc) {
      translate(tr)
      rotatet(roty)
      translate([-hd-t, -dy - w/2, 0-p]) // fine positioning
      union() {
        cube([hd+t0+t, w, t]);
        cube([      t, w, hzz]);
      }
    }
    // cut 0-2 slots:
    difference() 
    {
    children(0);
    maybe_dup([0, 0, 0], rotrc) // 0, 1 or 2 objects to cut
    translate(tr) 
    rotatet(roty)
    translate([-2 * t0, (dy - w/2 - f) , -p])      //
  #    cube([4*t0, w + 2*f, t + f]);         //
    }
    // support post:
    maybe_dup([0, 0, 0], rotrc)
    translate(tr)
    rotatet(roty)
    posts(t+f+pp, [.0 * t0, (dy - t0/2) , -p]);
  }
}
// hook test:
atrans(0, [undef, [-40, -30, 0]]) {
  dx = 80; dy = 55; ofc = 14; tl = dx; hdy = 3;
  translate([-0, -dy/2, 0])
  hook(dy, [-dy/2+ ofc, 0, 0], hdy, 2, true, 2) 
  hook(dx, [-dx/2, ofc, 0   ], hdy, 2, false, 2) 
   box([dx, dy, 5], [t0, t0, -t0], [2,2,2], true);
}

hr2 = hr + 2 * t0;  // radius of hex (extended)
size = hr2 * sqrt3; // width of box (hex with twist)
ht = hr + hr0 + t0; // height of box

// generic hexagonal tray
// n: number of hextiles to hold
// parms: [name, shx, shy]
// - name: text to engrave on bottom
// - shx: hook selector for x-axis
// - shy: hook selector for y-axis
// - ofcx: offset from center x-axis
// - ofcy: offset from center y-axis
// size: [interior] width to hold hex (ambient size)
// @ambient
// hr: width of tray (hexrad + sin(a))
// ht: height of all hextray
module hextray(n = 10, parms, size = size) {
  dx = n * d0;      // interior length
  tl = dx + 2 * t0; // n*d0 interior + 2*t0 endcaps
  echo("hextray: n=",n, "parms=", parms, "hr=", hr, " size=", size, "ht=", ht, "tl=", tl);
  module pos() {
    translate([0, 0, -.18]) rotate ([90, 0, 90]) children();
  }
  // slots on side walls:
  sw = min(tl - 10, 18);
  riq = dx < 5 ? .01 : 4;

  reveal = false; 
  uhr = reveal ? ht : sw;
  uht = reveal ? 0 : ht;
  bz = uht*.4;

  // hooks:
  name = is_undef(parms[0]) ? "" : parms[0];
  shx = is_undef(parms[1]) ? 0 : parms[1]; // select for x-axis
  shy = is_undef(parms[2]) ? 0 : parms[2]; // select for y-axis
  ofcx = is_undef(parms[3]) ? 0 : parms[3]; // offset from center
  ofcy = is_undef(parms[4]) ? 0 : parms[4]; // offset from center
  tx = shx == 0 ? 0 : 2;    // thickness: enable x-axis hook(s)
  ty = shy == 0 ? 0 : 2;    // thickness: enable y-axis hook(s)
  hdy = 14; // spread hooks from center
  dy = size; // interior width

  echo("hextray: name, tl, shx, shy, ofcx, ofcy, dy, dx =", name, tl, shx, shy, ofcx, ofcy, dy, dx);

  // translate along ortho axis to center of box:
  hook(dy, [-size/2+ofcy, 0, 0], hdy, ty, true, shy) 
  hook(tl, [-tl/2,  ofcx, 0   ], hdy, tx, false, shx)

  // Slots on side walls:
  slotifyY2([ht, sw, 8*t0], [0, t0-dy/2, bz], undef, riq, false)
  slotifyY2([ht, sw, 8*t0], [0, t0+dy/2, bz], undef, riq, false)
  // Slots on end-caps:
  slotify2([ht, uhr, 3*t0], [+tl/2, 0, bz], undef, riq)
  slotify2([ht, uhr, 3*t0], [-tl/2, 0, bz], undef, riq)
  union() {
    // outer square box:
    box([tl, size, ht], [t0, t0, -t0], [2,2,2], true); // funky rotation...
    // include hexBox:
    difference()
    {
      pos() hexBox(tl, hr2, t0, true); 
      // cut top section:
      translate([0,0,ht+p]) cube([tl+t0, size+t0, ht/2 +pp], true);
      // cut below plate
      translate([0,0,-t0/2]) cube([tl+t0, size+t0, t0], true);
      // engrave text:
      hexText(name, [0, 6, 4], 30, 1);
      hexText(name, [0, 6, 4], -30, 1);
    }
  }
  //  pos() hexstack(n);

}

// make a series of hextrays:
// parma: [[ n, [name, hookp]], ... ]
module hextray_x(parma, dt = 1) {
  hn = selectNth(0, parma);
  // echo("hextray_x: hn=", hn, "parma=", parma);
  for (i = [0: len(parma)-1]) 
    let(n = hn[i], params = parma[i][1], trx = d0 * (n / 2 + sum(hn, i-1)) + i * dt)
    translate([trx, 0, 0])
    hextray(n, params); // ambient size
}
echo("toplevel: size=", size, (size-88)/2);
loc = 0;
hexText = false;
//        [ n, [name, shx, shy, ofc]]
// ofc = tl/2 - size/2;
// Add 1 extra slot to each stack:
trA = [44, ["A", 3, 2, 0, 21.0]];
trB = [47, ["B", 3, 2]];
trC = [40, ["C", 3, 2, 0, -16.8]];
trayA = [trA];
trayB = [trB];
trayC = [trC];
trayABC  = [trA, trB, trC];
trayAB = [trA, trB];
trayBC = [trB, trC];
goals  = [[25, ["goals", 1, 2, ]], [10, ["b"]], [10, ["b", 2]]];  // goals, bonus, challenge
goalx = goals[0][0]*d0/2;
dy = size + 5*t0; // was layout spacing...
tdt = (loc == 2) ? 2.25 : 6.5;
translate ([t0, dy*0, 0])  hextray_x(trayA, tdt);
translate ([t0, dy*0, 0])  hextray_x(trayAB, tdt);
translate ([t0+ 4*goalx, 1*dy, 0])
  // translate([123.3, -(119.25), 0]) // align hooks on "C" with "B"
  // translate([-81.22, -31, 0])    // align hooks on "A" with "C"
  // rotate([0, 0, 90])
  hextray_x(trayC, tdt);
translate ([t0, dy*1, 0]) 
  slotifyY2([ht, 18, 4*t0], [goalx, +(size - t0)/2, 22.3], undef, 2)
  slotifyY2([ht, 18, 4*t0], [goalx, -(size - t0)/2, 22.3], undef, 2)
  hextray_x(goals, 1); // conjoin 3 boxes
starterBox();


// echo("total:", sum(selectNth(0, trays)));
