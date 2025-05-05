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

module hexText(name= "hex", tr, rx = 30, t = t0) {
  echo("hexText: name=", name );
  translate(tr)
  rotate([rx, 0, 0])
  linear_extrude(t)
  text(name, size=hr*.4, halign = "center");
}


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
      *hexText(name, [0, 6, 4], 30, 1);
    }
  }
   pos() hexstack(n);

}
function sum(ary = [], n) = 
  let(nn = is_undef(n) ? len(ary) - 1 : n)
    (nn < 0) ? 0 : (n == 0) ? ary[0] : ary[nn] + sum(ary, nn-1);

module series_x(hn = [4, 5, 6], dt = 1, names) {
  for (i = [0: len(hn)-1]) 
    let( n = hn[i], dx = d0 * (n / 2 + sum(hn, i-1)) + i * dt) {
      translate([dx, 0, 0]) hextray(n, size, names[i]);
    }
}

loc = 0;
//     A   B   C Y gr gy goal bon chal;
names = ["A", "B", "C", "base"];
separ = [43, 46, 39];
join2 = [25, 10, 10]; // goals, bonus, challenge
dy = size + t0;
*translate ([t0, dy*0, 0]) series_x(separ, 3, names);
*translate ([t0, dy*1, 0]) 
slotifyY2([ht, 18, 8*t0], [join2[0]*d0/2, t0+dy/2, 22.3], undef, 2)
slotifyY2([ht, 18, 8*t0], [join2[0]*d0/2, t0-dy/2, 22.3], undef, 2)
series_x(join2, 1, ["goals", "", ""]); // conjoin 3 boxes


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
module starterBox(loc = 1) {
  lrbt = [24,1];
  tl = sum(lrbt) * d0 + 3 * t0;
  sbx = 35 + 2*t0; // short dim of parts box
  bw0 = tl;        // long dim of parts box
  bw = bw0-2.5*t0; // long dim of player tray
  bl = sbx-2.5*t0; // short dim of player tray
  bh = 22;         // height of player tray
  bt = 23;         // top of player tray, down from parts box
  st = 2.3; sd = ht-(bt-15);// slot for lid to hold player tray & block
  atrans(loc, [[0, -size-t0, 0], [], []]) {
  difference() {
    union() {
      // last_round & base tiles:
      translate([t0, 0, 0]) series_x(lrbt, 1, ["", "base", "", ""]);
      echo("starterBox: bw=", (bw-3*t0)/4, "tl=", tl);
      // parts box:
      translate([0, -size*0.5 + 0, 0]) 
        rotate([0, 0, -90])
        {
          bw2= bw0-2*t0; bw3 = bw0 -3*t0;
          slotifyY2([ht, 10, 3*t0], [sbx/2, bw0, ht*.3], undef, 3)
          slotifyY2([ht, 10, 3*t0], [sbx/2, 0, ht*.3], undef, 3)
        %    box([sbx, bw0, ht]);
          // support rail:
          color("green")
          for (ds = [2*t0 : t0 : 3*t0]) let (bws = bw0 - ds)
            repeat([0, -bws/2, 0], [0, bws, 0], 2)
            translate([0, bw0/2 -ds/2, ht - bh - bt - (4 * t0 -ds)]) cube([sbx, ds, 1]);
          // Player tray:
          atrans(loc, [[sbx + t0, bw0/2, 0], [0, bw0/2, ht - bh - bt], [0, bw0/2, ht+3*t0]]) {
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
            atrans(loc, [undef, [t0+(bl-30)/2, t0+(bw-50)/2, ht - bt]])
            color("BLUE") cube([30, 50, 15]);
          }
      }
    translate([t0, -size*.5-sbx-1*t0, sd]) cube([bw, sbx+4*t0, st]);
  }
  atrans(loc, [[0, -2*(bl + 3*t0), .35/2], [0,0,sd+.35/2]])
  translate([t0, -size*.5-sbx-1*t0, 0]) color("green") {
    cube([bw, 2*t0, 6*t0]);
    cube([bw, sbx+2.5*t0, st-.35]);
  }
  }
}
starterBox();


echo("total:", sum(separ));
// hextray();
