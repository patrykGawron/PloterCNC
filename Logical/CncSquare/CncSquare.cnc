
%001 (CncSquare)

N10 G91     (absolute coordinates)
N20 F1200    (Feed rate in measurements units/min)

N30 G04 2   (dwell time 2s)

N50 G01 X0 Y100  (linear move)

N60 G04 1         

N70 G01 X100 Y0  (linear move)

N80 G04 1         (

N90 G01 X0 Y-100  (linear move)

N100 G04 1         

N110 G01 X-100 Y0  (linear move)

N200 G00 X0 Y0    (rapid move to zero)
N999 M30