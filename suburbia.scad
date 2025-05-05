use<mylib.scad>;
$fa = 1;
$fs = 0.4;
t0 = 1;
p = .001;
pp = 2 * p;

d0 = 2.05;   // mm per cardbord
hr = 26;     // mm on edge
sqrt3=sqrt(3);
sqrt3_2=sqrt(3)/2;


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

module hexBox(h=10, r=5, t=t0, cz = false) {
  translate([0, 0, cz ? -h/2 : 0])
  difference() {
    polycylinder(h, 6, r);
    translate([0, 0, -p])  
    polycylinder(h+pp, 6, r-t);
  }
}

function da(a, r) = (sin(60+a)-sin(60))*r;

module hexstack(n = 10, cx=true, c = "blue") {
  a = 30/n; tl = n * d0; ctr = cx ? -tl / 2: 0; dx = .05;
  translate([0, 0, ctr, ])
  // render()
  for (i = [0 : n-1]) //
    color(i == n-1 ? "blue" : "pink")
    translate([0, da(a * i, hr)+2*t0, i * d0]) //
    rotate([0, 0, a * i]) //
    polycylinder(d0 - dx, 6, hr);
}
size = 2*hr + da(30, hr);

module hextray(n = 10, size = size, name) {
  w = size*sqrt3_2; tl = n * d0 + 2 * t0; // n*d0 interio + 2*t0 endcaps
  echo("hextray: size=", size, "tl=", tl);
  module pos(dx=0) {
    translate([0, 0, w/2]) rotate ([90, 0, 90]) children();
  }
  // slh = size+hr-size*.3; // slot height: sr at top of box
  slotify2([w, hr, 3*t0], [+tl/2, 0, w*.3], undef, 3)
  slotify2([w, hr, 3*t0], [-tl/2, 0, w*.3], undef, 3)
    box([tl, size, w], undef, undef, true);
  difference()
  {
    pos() hexBox(tl, size/2, t0, true); 
    translate([0,0,w/2+w/4+p]) cube([tl+pp, size, w/2 +p], true);
  }
   pos() hexstack(n);

}
function sum(ary = [], n) = 
  let(nn = is_undef(n) ? len(ary) - 1 : n)
    (nn < 0) ? 0 : (n == 0) ? ary[0] : ary[nn] + sum(ary, nn-1);

module series_x(hn = [4, 5, 6], dt = 1) {
  for (i = [0: len(hn)-1]) 
    let( n = hn[i], dx = d0 * (n / 2 + sum(hn, i-1)) + i * dt) {
      translate([dx, 0, 0]) hextray(n);
    }
}

//     A   B   C Y gr gy goal bon chal;
separ = [43, 46, 39];
join1 = [8, 8, 8];
join2 = [25, 10, 10];
dy = size + t0;
translate ([0, -dy*0, 0]) series_x(separ, 3);
translate ([0, -dy*1, 0]) series_x(join1, 1);
translate ([0, -dy*2, 0]) series_x(join2, 1);

echo("total:", sum(separ));
// hextray();
