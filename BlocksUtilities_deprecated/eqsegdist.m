function [cd, segidx] = eqsegdist(eo, ea, s, usedip)
% EQSEGDIST  Finds distance between earthquake and closest segment.
%   EQSEGDIST(ELON, ELAT, SEGMENT) uses n-by-1 vectors of earthquake 
%   longitude and latitude (ELON and ELAT), as well as the segment 
%   coordinate information contained in the structure SEGMENT to 
%   determine the distance, in km, between each earthquake and the 
%   closest segment.
% 
%   EQSEGDIST(ELON, ELAT, SEGMENT, USEDIP), where USEDIP = 1, considers
%   the dip of segments, and assigns a zero distance to earthquakes whose
%   epicenters lie within the surface projection of dipping segments.
%   
%   DIST = EQSEGDIST(...) returns an n-by-1 vector of distances in km.
%
%   [DIST, SEGIDX] = EQSEGDIST(...) also returns an n-by-1 vector SEGIDX 
%   giving the index of the nearest segment.
%
%

% Parse optional input
if ~exist('usedip', 'var')
   usedip = 0;
end

% Number of segments...
nseg = length(s.lat1);
% ...and earthquakes
neq = length(eo);

% Order endpoints
s = OrderEndpoints(s);

% Calculate segment interpolation
[sla, slo] = track2(s.lat1, s.lon1, s.lat2, s.lon2);
iidx = repmat(1:nseg, 100, 1);
iidx = iidx(:);

% Calculate segment surface projections
[sboxx, sboxy, dipping] = segsurfproj(s);
dipping = find(dipping);

% Allocate space for earthquake tracks
cd = zeros(neq, 1);

parfor (i = 1:neq)
   dl = distance(ea(i), eo(i), sla, slo, almanac('earth','ellipsoid','kilometers'));
   [cd(i), cdi] = min(dl(:));
   segidx(i) = iidx(cdi);
   if usedip == 1
      if ismember(iidx(cdi), dipping)
         if inpolygon(eo(i), ea(i), sboxx(iidx(cdi), :), sboxy(iidx(cdi), :))
            cd(i) = 0;
         end
      end
   end   
end
   