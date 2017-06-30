function out = cleansarfield(in, minv, maxv, anomv)
% CLEANSARFIELD   Cleans a SAR velocity field
%   OUT = CLEANSARFIELD(IN, MINV, MAXV, ANOMV) cleans a SAR LOS velocity field
%   described by the n-by-3 array IN ([LON LAT LOS]) based on the thesholds 
%   MINV, MAXV, and ANOMV.  MINV and MAXV are scalars giving the minimum and 
%   maximum LOS velocities, respectively.  Velocities below MINV and above MAXV 
%   will be discarded.  ANOMV is a 2-element vector, the first element giving an
%   anomaly distance and the second giving an anomaly magnitude.  For each point,
%   all points within the anomaly distance will be averaged.  If the point differs
%   from that average by greater than the anomaly magnitude, the point will be 
%   deleted.  For example, if you wish to discard a point if it differs from the 
%   average velocity at neighbors within 5 km by greater than 10 mm/yr, specify
%   ANOMV = [5 10].  The resulting cleaned velocity field is returned to OUT.  If
%   you do not want to filter based on minimum and maximum velocities, just set
%   MINV and MAXV to be absurdly large negative and postitive numbers.
%

% Isolate velocities
v = in(:, 3);

% Find min. and max. anomalies
delmin = find(v < minv);
delmax = find(v > maxv);

[vanom, vmed, vmean] = deal(zeros(size(v)));
parfor (i = 1:length(v))
   dis = distance(in(i, 2), in(i, 1), in(:, 2), in(:, 1), almanac('earth', 'wgs84', 'kilometers'));
   near = find(dis < anomv(1));
   vmed(i) = median(v(near));
   vmean = mean(v(near));
   vanom(i) = abs(v(i) - vmean) > anomv(2);
end
delanom = find(vanom);
del = unique([delmin; delmax; delanom]);
keyboard
out = in;
out(del, :) = [];