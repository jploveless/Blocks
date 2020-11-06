function [sl, nb] = geomstats(s, b, range)
% GEOMSTATS  Outputs simple geometric statistics for a block geometry.
%    [SL, NB] = GEOMSTATS(S, B) returns the total segment length, SL, and
%    number of blocks, NB, of the block geometry given by the segment file
%    or structure S and the block file or structure B.
%    
%    [SL, NB] = GEOMSTATS(S, B, RANGE) returns the geometry statistics 
%    within the 4 element vector RANGE defining the longitude and latitude
%    bounds of interest ([minLon, maxLon, minLat, maxLat]).  Segments are
%    considered to lie within the range of interest only if both of their
%    endpoints are interior to the polygon.  Blocks are considered to be
%    in-range if the interior points are located within the bounds.
%

% Parse inputs
if ~isstruct(s)
   s = ReadSegmentTri(s);
end

if ~isstruct(b)
   b = ReadBlock(b);
end

if ~exist('range', 'var')
   range = [0 360 -90 90];
end

% Find segments and blocks within the range
is1 = inpolygon(s.lon1, s.lat1, [range(1) range(2) range(2) range(1)], [range(3) range(3) range(4) range(4)]);
is2 = inpolygon(s.lon2, s.lat2, [range(1) range(2) range(2) range(1)], [range(3) range(3) range(4) range(4)]);
is = intersect(find(is1), find(is2));

ib = inpolygon(b.interiorLon, b.interiorLat, [range(1) range(2) range(2) range(1)], [range(3) range(3) range(4) range(4)]);
nb = sum(ib);

% Determine total length of segments in range
ss = structsubset(s, is);
lengs = distance(ss.lat1, ss.lon1, ss.lat2, ss.lon2, almanac('earth','ellipsoid','kilometers'));
sl = sum(lengs);
