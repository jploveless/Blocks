function [plon, plat, daz] = swathblockseg(b, d)
% SWATHSEG  Produces a polygon bounding a series of segments.
%   [SX, SY] = SWATHBLOCKSEG(BOC, D) produces a polygon bounding block segments
%   located +/- D km from the segments.  At each segment endpoint, a line is 
%   projected D km at +/- 90 degrees to the mean strike of the 2 adjoining 
%   segments.  BOC is an n-by-2 array containing the ordered 
%   [lon. lat.] coordinates from fields "orderLon" and "orderLat" of the block
%   structure returned from BLOCKLABEL or read in using ReadBlockCoords.
%   Outputs SX, SY can be plotted using, for example:
% 
%   patch(SX, SY, 'b')
%

% Replicate the first block coordinate
b = [b(end, :); b];

% Calculate average azimuths
az = wrapTo180(azimuth(b(1:end-1, 2), b(1:end-1, 1), b(2:end, 2), b(2:end, 1)));
maz = 0.5*(az + az([2:end, 1]));
daz = az - maz;

% Determine distance corrections: use d only when adjacent segments are parallel
d = d./cosd(daz);

% Reckon from endpoints
[late, lone] = reckon(b(2:end, 2), b(2:end, 1), d./6371, maz+90);
[latw, lonw] = reckon(b(2:end, 2), b(2:end, 1), d./6371, maz-90);

plon = [lone, lone([2:end, 1]), lonw([2:end, 1]), lonw]';
plat = [late, late([2:end, 1]), latw([2:end, 1]), latw]';  

% Check for correct ordering
% Convert to Cartesian
[x, y, z] = sph2cart(deg2rad(plon), deg2rad(plat), 1);
% Do cross products of each side of 4 node patch
c1 = cross([x(2, :) - x(1, :); y(2, :) - y(1, :); z(2, :) - z(1, :)], [x(3, :) - x(2, :); y(3, :) - y(2, :); z(3, :) - z(2, :)]);
c2 = cross([x(3, :) - x(2, :); y(3, :) - y(2, :); z(3, :) - z(2, :)], [x(4, :) - x(3, :); y(4, :) - y(3, :); z(4, :) - z(3, :)]); 
c3 = cross([x(4, :) - x(3, :); y(4, :) - y(3, :); z(4, :) - z(3, :)], [x(1, :) - x(4, :); y(1, :) - y(4, :); z(1, :) - z(4, :)]); 
c4 = cross([x(1, :) - x(4, :); y(1, :) - y(4, :); z(1, :) - z(4, :)], [x(2, :) - x(1, :); y(2, :) - y(1, :); z(2, :) - z(1, :)]); 
% Get signs of z component
cs = [sign(c1(3, :)); sign(c2(3, :)); sign(c3(3, :)); sign(c4(3, :))];
% If absolute value of sum of signs is not 4, then there are variable signs
scs = abs(sum(cs)) < 4;

% Copy arrays with rows pairs swapped
plons = plon([1 3 2 4], :);
plats = plat([1 3 2 4], :);

% Insert swapped rows where need be
plon(:, scs) = plons(:, scs);
plat(:, scs) = plats(:, scs);