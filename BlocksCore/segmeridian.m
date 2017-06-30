function [S, si] = segmeridian(s)
% segmeridian  Splits segments along the prime meridian.
%   SNEW = segmeridian(S) splits segments that cross the prime
%   meridian into two segments, each with one endpoint on the
%   prime meridian. All other segment properties are taken from
%   the original segment.
%

% Wrap to 360
s.lon1 = wrapTo360(s.lon1);
s.lon2 = wrapTo360(s.lon2);

% Get longitude differences
dlon = abs(s.lon1 - s.lon2);
pmcross = dlon > 180;

% Split those segments crossing the meridian
lat = gclatfind(s.lon1(pmcross), s.lat1(pmcross), s.lon2(pmcross), s.lat2(pmcross), 360*ones(sum(pmcross), 1));

% Replicate split segment properties and assign new endpoints

% Isolate split and whole segments
split = structsubset(s, pmcross);
whole = structsubset(s, ~pmcross);

% Replicate the split array
split = structmath(split, split, 'vertcat');

% Insert the split coordinates
split.lon2(1:sum(pmcross)) = 360;
split.lat2(1:sum(pmcross)) = lat;
split.lon1(sum(pmcross)+1:end) = 0;
split.lat1(sum(pmcross)+1:end) = lat;
[split.midLon, split.midLat] = segmentmidpoint(split.lon1, split.lat1, split.lon2, split.lat2);
[split.x1, split.y1, split.z1] = sph2cart(DegToRad(split.lon1), DegToRad(split.lat1), 6371);
[split.x2, split.y2, split.z2] = sph2cart(DegToRad(split.lon2), DegToRad(split.lat2), 6371);

% Stitch together the whole and split structures
S = structmath(split, whole, 'vertcat');

% Indices of split segments
si = find(pmcross);