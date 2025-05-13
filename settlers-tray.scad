use <mylib.scad>;
p = .001;
pp = 2 * p;
t0 = 1;
module dice(tr=[0,0,0], ds = ds) {
  color("#DDDDDD")
  translate(tr) roundedCube([ds,ds,ds], 2, false);
}
module robber(tr = [0,0,0]) {
  color("black") 
  translate(v = tr) rotate([0,90,0]) cylinder(r1 = rs/2, r2 = 3, h = 32);
}
module slotbox(ch = ch, ss = false) {
  r1 = .1; r2 = 5;
  cz = 7; // cut a wide slot
  slotifyY2([boxz, cw-2*t0, 2*t0, r1], [0, -(ch-t0+p)/2, boxz-cz], undef, undef, ss)
  slotifyY2([boxz-cz, 25,   2*t0, r2], [0, -(ch-t0+p)/2,       4], undef,     2, ss)
  children(0);
}
module sidebox(dx = 0, y1 = y1, ss = false) {
  dr = (dx == 0) ? 27/2 : 0;
  cylr = (dx == 0) ? dr + 1.6: 0; // t0 + 1.2/2
  cylz = 16;
  translate([dx, ch/2 - t0, 0]) 
  rc([ -cylr , 2*cylr-t0/2, cylz], 0, 3, 2, t0) // tr, rotid, q, rad, t, ss
  rc([ cylr , 2*cylr-t0/2, cylz], 0, 0, 2, t0)  // tr, rotid, q, rad, t, ss
  rc([ 0 , cylr, cylz], 1, 2, 2, 2*t0)          // tr, rotid, q, rad, t, ss
  slotbox(-2*y1+pp, ss)
  translate([-cw/2, 0, 0]) {
  difference() {
    union() {
      box([cw, y1+t0, boxz]); // dice box
      // add cylinders, maybe 0-radius:
      translate([cylr, cylr, 0]) pipe(rrh = [cylr, cylr, cylz]);
      translate([cw-cylr, cylr, 0]) pipe(rrh = [cylr, cylr, cylz]);
    }
    union() {
      dw = cw - 2*cylr; dy = cylr;
      // cut access slot:
      translate([dw/2, 2*cylr - dy, t0]) cube([cw-dw , cylr, boxz]);
      translate([t0, t0, t0]) cube([cylr, cylr, boxz]);
      translate([cw-cylr, t0, t0]) cube([cylr, cylr, boxz]);
    }
  }
  dskz = 12.5/9; // empirical
  atrans(loc, [[cylr+f, cylr+f, t0+f], undef, undef, undef, undef, 0])
    astack(10, [0,0,dskz])
    color("yellow") disk(dr, dskz-.1)  ;
  }
}
module disk(r, h) {
  linear_extrude(height = h) 
  circle(r);
}

// Stack of Cards
module card(tr = [ (4) / 2, (4) / 2, 0 ], name = "foo")
{
    translate(tr) 
    astack(24, [ -.03, 0, .325 ]) {
    color("pink") roundedCube([ cardw, cardh, .4 ], 3, true);
    translate([cardw/2, cardh/2, 0]) 
    color("black") text(name, halign = "center");
    }
}

module cardbox(name, cutaway = false) {
  echo("cardbox: name=", name);
  cut = cutaway ? [10, ch+f, boxz+f] : [0, 0, 0] ;
  difference() 
  {
  slotbox()
  box([cw, ch, boxz], t0, undef, true);
  translate([(-8-cw)/2, (-f-ch)/2, -p]) # cube(cut);
  }
  // fulcrum:
  rotate([-3, 0, 0]) 
  translate([0, -5, .3]) {
  translate([0, 0, 1]) cube([cw, 10, 2], true);
  difference() {
    translate([0, 0, 1.8]) cube([cw, 7, 2.4], true);
      translate([0, -2, 2.55]) 
      linear_extrude(height = .5) 
      text(name, halign = "center", size=5);
  }
  }

  a2 = -3.; 
  trt = [0, 0, 0, [ a2, 0, 0, [0, cardh/2, 1 ]]];
  // Stack of cards:
  atrans(loc, [trt, undef, undef, undef, undef, 0])
  card([1-cardw/2, 0-cardh/2, 1.2], name);
}

module cardboxes(i0, i1, cut = false) {
  locs = [[1, 0, "sheep"], [1, 1, "wheat"], [1, 2, "ore"],
          [0, 0, "wood"], [0, 1, "brick"], [0, 2, "dev"], 
          ];
  i0 = def(i0, 0);
  i1 = def(i1, len(locs)-1);
  for (i = [i0: i1]) let (rc = locs[i]) 
    let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1, name = rc[2])
  translate([c*(cw-t0), r*(ch-t0)+ry, 0])
  cardbox(name, cut);
}
function cutb(cw3 = cardw-11) = (cw - cw3)/2;
// hole to cut from big lid
module cutTop(t = tb) {
  // cut a viewport hole:
  // difference() 
  {
    cw3 = (cardw - 11);       // width of cutout
    dw = (cw - cw3) / 2;      // border around cutout
    dh = dw;                  // same border for height
    ch3 = ch - 2 * dh;        // height of cutout
    assert(dw + cw3 < cardw - 2 );
    echo("cutTop: ", [dw, dh, -.5*tb], [cw, ch, t]);
    translate([dw, dh, -.5*tb])
     cube([cw3, ch3, t]);
  }
}
module addTop() {
  ta = 1; hw = 10;
  // short walls to keep cards from sliding out
  translate([ta, ta, p])
  box([-2*ta, -2*ta, hw+tb], [tw, tw, -1.5], [2, 2, 4]);
}

module cardtops(i0, i1, cut = false) {
  locs = [[1, 0, "sheep"], [1, 1, "wheat"], [1, 2, "ore"],
          [0, 0, "wood"], [0, 1, "brick"], [0, 2, "dev"], 
          ];
  i0 = def(i0, 0);
  i1 = def(i1, len(locs)-1);
  difference() 
  {
    children(0); // the big lid
    for (i = [i0: i1]) let (rc = locs[i]) 
      let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1)
      // echo("cardtops: ", [c*(cw-t0), r*(ch-t0)+ry, 0])
      translate([c*(cw-t0), r*(ch-t0)+ry, boxz+1])
        cutTop(2);
    // cutout grid above sideboxes:
    // nc * xi - cs = total width = (3*(cw-1)+1 - 2*cutb())
    nc = 3*6; cs = 6; 
    x0 = cutb()-cs/2-1.5*t0;
    xi = (3*(cw-1)+1 - 2*x0 - cs)/(nc-1); // xi?
    xm = (3*(cw-1)+1) - x0;
    translate([0, 0, boxz-t0])
      gridify([x0+xi, xi, xm-xi], [ch, (y1-2*t0-cs)/3, ch+y1-cs], 2 ) cube([cs, cs, cs]);
  }
  tw = 1; 
  // add retainer walls at end of  cardbox:
  for (i = [i0: i1]) let (rc = locs[i]) 
    let(r = rc[0], c = rc[1], ry = r == 0 ? 0 : y1, cz = 11)
    translate([c*(cw-t0), r*(ch-t0)+ry, 0])
    translate([1.5*t0, 1.5*t0, boxz-cz+t0-p]) 
    box([cw - 3*t0, ch-3*t0, 3], [tw, tw, -1.5], [2, 2, 4]);

  // retainer bar for disks
  dr = (true) ? 27/2 : 0; // disk radius
  cylr = (true) ? dr + 1.6: 0; // t0 + 1.2/2
  rr = 3; // reduce radius
  cylz = 16; kz = 1; cylz2 = boxz-cylz+kz;
  translate([ cylr/2, ch + t0 + cylr, cylz-kz]) 
  cube([cw-cylr, 1.5* t0, cylz2]);
}

module cardsLid() {
  clw = 3 * (cw) + t0 + 2*f;
  clh = 2 * (ch) + t0 + y1 + t0 + 2*f; // bh + 2*t0 + 2*f
  lz = 11; // == boxz/2 !!
  sd = 7;
  r180 = [0, 180, 0, [clw/2, clh/2, boxz/2]];
  atrans(loc, [[-clw-6*t0, 0, t0, r180], 
               undef,
               undef,
               undef,
               [0, 0, 0, r180],
               [0, 0, 0],
               ])
  cardtops()
  atrans(0, [[-t0-f, -t0-f, +t0, r180]])
    box([clw, clh, lz]);
}

// size: [x: length, y: width_curved, z: height_curved]
// rt: radii of tray [bl, tl, tr, br]
// rc: radii of caps
// k0: cut_end default: cut max(top radii) -> k
module tray(size = 10, rt = 2, rc = 2, k0, t = t0) {
 s = is_list(size) ? size : [size,size,size]; // tube_size
 rm = is_list(rt) ? max(rt[1], rt[2]) : rt;   // round_max
 k = is_undef(k0) ? -rm : k0;
 translate([s[0], 0, 0+p])
 rotate([0, -90, 0])
 roundedTube([s[2], s[1], s[0]], rt, k, t);

 // endcaps
 hw0 = [s[2], s[1], 0];
 hwx = [s[2], s[1], s[0]];
 div(hw0, rc, k);
 div(hwx, rc, k);
}

// nx: columns of partTrays
// ny: rows of partTrays
nx = 1; ny = 4; 
module partTrays(mr = ny-1, mc = nx-1) {
  mx = t0 / nx; my = t0 / ny;
  tw2 = bw - 2 * t0 - mx;
  th2 = bh - 2 * t0 - my;
  tw = tw2/nx;
  th = th2/ny;
  px0 = (bw - nx * tw) / 2;
  py0 = (bh - ny * th) / 2;
  echo("partsTray: ls=", (1+3/8) * 25.4, "rs=", th-my-3*t0);
  module partstray(tr=[0,0,0]) {
    // old tray: 85,500 mm^3, now: 85,868.5 mm^3 (less for radius)
    // echo("partstray: tw, th, boxz-1=", tw, th, boxz-2.1, tw*th*(boxz-2.1) );
    rt = 10;
    trayz = boxz - 2.1 * t0;
    translate(tr) {
      tray([tw - mx, th - my,  trayz + rt], rt, 2 );
      div([trayz + rt, th-my, (1+3/8) * 25.4 + t0], rt, -rt);
    } 
  }
  for (ptr = [0 : mr], ptc = [0 : mc]) 
    let(x = px0 + ptc * tw, y = py0 + ptr * th)
      partstray([x, y, t0+p]); // above the blue box
}

module partsGrid() {
  cs = 5; nc = 10; nr = 20;
  x0 = cs;
  xi = (bw - cs) / nc;
  xm = bw - cs;
  y0 = cs + 1;
  yi = (bh - cs) / nr;
  ym = bh - cs;
  translate([0, 0, -t0])
  gridify([x0, xi, xm], [y0, yi, ym], 2) cube([cs, cs, cs]);
}
module partsLid() {
  lz = 11;
  sd = 7;
  union() {
  translate([f/2, -f/2, 0])
    difference() {
    box([lw, lh, lz]); // partslid
    partsGrid();
    }
  // clips
  translate([00+1.5*t0, (lh-f)/2, t0 +  sd + 2/2 ]) 
    cube([2*t0, 4, 2], true);
  translate([lw-1.5*t0, (lh-f)/2, t0 +  sd + 2/2 ]) 
    cube([2*t0, 4, 2], true);
  }
}

module bluebox() {
  sd = 7; hm = .8;
  difference() {
    color("lightblue")
    box([bw, bh, boxz]);
    translate([(bw+t0)/2, bh/2, boxz-sd]) 
    cube([bw + 2*t0 + f, 4+1.5*f, 2+1.5*f], true); // lid clip
    for (ix = [0 : nx-1], iy = [0 : ny-1]) 
      let(hw = hm*bw/nx, hh = hm*bh/ny)
      translate([ix * bw/nx +hw/2+ hw*(1-hm)/2, iy*bh/ny + hh/2 + hh*(1-hm)/2  , -t0])
      cube([hw, hh, 5], true); // open bottom
  }
}

f = .18;

// trays for cards, player-bits, dice, robber, disks
tb = 3; // thickness of base

// depth of boxes: city=19; 8-10-cards, 3-lever, 2-holding
boxz = 22;
cardw = 54; cw = cardw + 2 + 2 + 2*t0; // cw = cardw + sleeve + gap + box wall
cardh = 81; ch = cardh + 2 + 6 + 2*t0; // ch = cardh + sleeve + GAP + box wall
// dice size
ds = 15;
// robber size
rs = 15;

// size of gap between two rows of boxes:
y1 = 218 - 2*(ch)-t0;
// tw = total width - t0;
tw = 3 * (cw - t0);
// bluebox width:
bw = (282-20) - tw - 2; // inset by 2mm
// bluebox height:
bh = 2 * ch + y1 - t0;  // 220 - 2*t0
// partsLid:
lw = bw + 2*t0 + f;
lh = bh + 2*t0 + f;

echo("y1=", y1, "bh=", bh, "tw=", tw);
echo("parts vol: bw*bh*(boxz-2*t0)", (bw-4)*(bh-4)*(boxz-2)/4);


// 0: all, 1: main, 2: blue & lid, 3: partsTrays, 4: cardsLid, 5: packed
loc = 5;

// intersection() // render disk box
// {
//   translate([0, ch-t0, -t0]) cube([cw+t0, y1+2*t0, boxz+2*t0]);
atrans(loc, [[cw/2, ch/2, 0], 0, undef, undef, undef, 0])
{
  cardboxes();
  for (i = [0 : 2]) sidebox((cw-1)*i);
}
// }

cardsLid();

atrans(loc, [[cw+t0, ch+t0, t0], undef, undef, undef, undef, 0]) {
  dice([0, 0, 0]); dice([ds+f, 0, 0]);
  robber([0, ds + t0 + rs/2, rs/2]);
}

bbx0 = tw + 6; bby0 = 0;
atrans(loc, [[bbx0, bby0, 0], undef, [0, 0, 0], undef, undef, 0, 0]) 
  bluebox();

atrans(loc, [[bbx0 + (bw + 2), -t0, 0], undef, [bw + 2, -t0, 0], undef, undef, 
             [bbx0-t0, -t0, -t0, [0, 180, 0, [lw/2, lh/2, (boxz+2*t0)/2]]],
             ])
  partsLid(); // partslid

atrans(loc, [[bbx0 + (bw + 2) * 2, bby0, -t0], 
             undef, undef, 
             [ (bw + 2) * 0, bby0, -t0],
             undef, 
             [bbx0, bby0, t0], 0])
  partTrays();                    // partsTrays
// Roads: 1 X 3/16 X 3/16
// City: 3/4 X 3/4 X 10mm
// House: 9 X 14 X 12 mm
// rl = 25.4; rw = rl * 3/16; rh = rw;
// translate([cw-1, 7, t0]) rotate([0,0,90]) partTrays(0,0);


// show printer plate:
*atrans(loc, [undef, undef, undef, undef, undef, [-1, -1, -2]]) 
 color("tan") cube([220, 220, 1]);
// show packing box:
*atrans(loc, [undef, undef, undef, undef, undef, [-10, -4, -1]]) 
 color("brown") cube([282, 228, 1]);

