use<mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

sqrt3 = sqrt(3);
sqrt3_2 = sqrt3/2;
d0 = 2.05;   // mm per cardbord
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
  translate([0, hr+t0*2, cz ? -h/2 : 0])
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
  // render()
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

size = 2*(hr+2*t0) * sqrt3_2; // width of box
ht = hr + hr0;  // height of box
module hextray(n = 10, size = size, name) {
  tl = n * d0 + 2 * t0; // n*d0 interio + 2*t0 endcaps
  echo("hextray: hr=", hr, " size=", size, "ht=", ht, "tl=", tl);
  module pos() {
    translate([0, 0, 0]) rotate ([90, 0, 90]) children();
  }
  // slots on side walls:
  sw = min(tl - 10, 18);
  // slotifyY2([ht, sw, 8*t0], [0, t0-dy/2, 22.3], undef, 2, false)
  // slotifyY2([ht, sw, 8*t0], [0, t0+dy/2, 20], undef, 2, false)
  // Slots on end-caps:
  slotify2([ht, hr, 3*t0], [+tl/2, 0, ht*.3], undef, 3)
  slotify2([ht, hr, 3*t0], [-tl/2, 0, ht*.3], undef, 3)
  union() {
    box([tl, size, ht], [t0, t0, -t0], [2,2,2], true); // funky rotation...
  difference()
  {
    pos() hexBox(tl, hr+2*t0, t0, true); 
    translate([0,0,ht+p]) cube([tl+pp, size, ht/2 +p], true);
    hexText(name, [0, 6, 4], 30, 1);
  }
  }
  * pos() hexstack(n);

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

//     A   B   C Y gr gy goal bon chal;
names = ["A", "B", "C", "base"];
separ = [43, 46, 39, 24];
join1 = [8, 8, 8];
join2 = [25, 10, 10];
dy = size + t0;
translate ([0, dy*0, 0]) series_x(separ, 3, names);
// translate ([0, dy*1, 0]) series_x(join1, 1);
translate ([0, dy*2, 0]) 
slotifyY2([ht, 18, 8*t0], [join2[0]*d0/2, t0+dy/2, 22.3], undef, 2)
slotifyY2([ht, 18, 8*t0], [join2[0]*d0/2, t0-dy/2, 22.3], undef, 2)
series_x(join2, 1, ["bonus", "", ""]);



echo("total:", sum(separ));
// hextray();
