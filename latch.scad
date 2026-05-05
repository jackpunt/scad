use <mylib.scad>;

p = .001;
pp = 2 * p;
t0 = 2;
inch = 25.4;

ch = 21/16 * inch; // clip height
cr = 3/8 * inch; // clip radius
wx = 5/8 * inch;


module wing() {
  p0x = cr;
  p0y = 3;
  wa1 = 30;
  p1x = p0x - 14;
  p1y = p0y + wx * sin(wa1);
  p2x = p1x;
  p2y = p1y + 10;
  d3r = 11.5;
  d3xy = d3r * sin(45); // d3x = sin(45), d3y = cos(45)
  p3m = 1 * sin(45);  // a short delta down 45
  ka = 45;
  kx = 2 * sin(ka);   // a short delta up at 45 for fillet
  ky = 2 * cos(ka);
  p3x = p2x + d3xy;
  p3y = p2y + d3xy;
  p4x = p0x;
  p4y = p2y+ 2;
  pts = [
    [p0x, p0y], 
    [p1x, p1y], 
    [p2x, p2y], 
    [p3x-p3m, p3y-p3m], 
    [p3x - kx, p3y + ky], 
    [p3x, p3y], 
    [p4x, p4y]];
  sr = 4 ;
  cco = sr;
  cxy = cco * sin(45);
  linear_extrude(height = t0) 
  {
    polygon(pts);
    trr([p3x-cxy-cxy*.5, p3y-cxy+.5*cxy , 0]) 
    difference() {
      circle(r = sr);
      circle(r = sr-t0);
      trr([-sr*.707/2, -sr*.707/2, 0, [0, 0, 45]]) square([sr, sr], true);
  }
  } 
}

trr([t0/2-cr, 0, 0]) cylinder(h = ch, r = t0/2);

difference() {
  trr([0, 0, ch/2]) cylinder(h = ch, r = cr, center = true);
  trr([0, -p, ch/2]) cylinder(h = ch+pp, r = cr - t0, center = true);
  trr([-cr, 0 , -p, [0, 0, 0, [cr, 0 ,0]]]) cube([cr * 1.5, cr, ch+pp]);
  trr([0, 0, -p]) cube([cr, cl, ch+pp]);
}
cl = 20; // clip length
// trr([cr-t0, 0, 0]) cube([t0, cl, ch]);
// wing();
// trr([0, 0, ch-t0]) wing();

trr([cr, 0, 0]) cube([t0, cl, ch]);
trr([cr-t0, -t0, 0]) cube([2*t0, 2*t0, ch]);
trr([cr-1.85*t0, -2.375*t0, 0, [0, 0, -45.8]]) cube([t0, 3*t0, ch]);
