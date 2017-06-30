function [sboxx, sboxy, dipping] = segsurfproj(s)
% SEGSURFPROJ  Calculates coordinates of segment surface projection
%   [SBOXX, SBOXY] = SEGSURFPROJ(SEG) uses the segment structure SEG to 
%   determine the coordinates of a box defining the surface projection 
%   of each segment, returning the lon., lat. coordinates to SBOXX and 
%   SBOXY.  For all segments, the columns of the box coordinates circulate
%   in an ordered manner, so that the rows can be used as inputs to INPOLYGON
%   and other functions.  For vertical faults, the 3rd and 4th columns are 
%   simply repeats of the given segment endpoints.
%
%   [SBOXX, SBOXY, DIPPING] = SEGSURFPROJ(...) also outputs a logical array 
%   indicating whether or not each segment is dipping.

% Number of segments
nseg = length(s.lon1);

% Order endpoints
s = OrderEndpoints(s);

% Calculate segment azimuths
segaz = azimuth(s.lat1, s.lon1, s.lat2, s.lon2);

% Find dipping segments
dipping = s.dip ~= 90;

% Calculate dipping segment surface projections
sboxx = [s.lon1, s.lon2, s.lon2, s.lon1];
sboxy = [s.lat1, s.lat2, s.lat2, s.lat1];
[dd1a, dd1o] = reckon(s.lat1(dipping), s.lon1(dipping), s.lDep(dipping)./sind(s.dip(dipping)), segaz(dipping) + sign(90-s.dip(dipping)).*90, almanac('earth','ellipsoid','kilometers'));
[dd2a, dd2o] = reckon(s.lat2(dipping), s.lon2(dipping), s.lDep(dipping)./sind(s.dip(dipping)), segaz(dipping) + sign(90-s.dip(dipping)).*90, almanac('earth','ellipsoid','kilometers'));
sboxx(dipping, 3) = dd2o;
sboxx(dipping, 4) = dd1o;
sboxy(dipping, 3) = dd2a;
sboxy(dipping, 4) = dd1a;
