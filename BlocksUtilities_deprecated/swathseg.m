function [sx, sy, seg] = swathseg(seg, d)
% SWATHSEG  Produces a polygon bounding a series of segmentseg.
%   [SX, SY] = SWATHSEG(SEG, D) produces a polygon bounding the segments
%   in structure SEG, located +/- D km from the segmentseg.  At each segment
%   endpoint, a line is projected D km at +/- 90 degrees to the mean strike
%   of the 2 adjoining segmentseg.  No error checking is done to ensure non-
%   overlapping normal pointseg.
%
%   [SX, SY, SEG] = SWATHSEG(...) also returns the sorted segment structure.
%

% First sort segments
seg = OrderEndpoints(seg);
sego = ordersegs(seg);
seg = structsubset(seg, sego);

nseg = length(seg.lon1); % number of segments

% Determine azimuths
az = azimuth(seg.lat1(:), seg.lon1(:), seg.lat2(:), seg.lon2(:));

% Allocate space
sx = zeros(2*nseg + 2, 1);
sy = sx;

% Convert d from km to degrees for reckoning
d = rad2deg(d./6371); 

% Start with segment 2; we'll handle the end segments separately
for i = 2:nseg
   idx1 = i;
   idx2 = length(sx) - (i - 1);
   maz = 0.5*(az(i) + az(i-1));
   paz1 = maz + 90;
   paz2 = maz - 90;
   [sy(idx1), sx(idx1)] = reckon(seg.lat1(i), seg.lon1(i), d, paz1);
   [sy(idx2), sx(idx2)] = reckon(seg.lat1(i), seg.lon1(i), d, paz2);
end

% Treat endpoints
[sy(1), sx(1)] = reckon(seg.lat1(1), seg.lon1(1), d, az(1)+90);
[sy(end), sx(end)] = reckon(seg.lat1(1), seg.lon1(1), d, az(1)-90);
[sy(nseg+1), sx(nseg+1)] = reckon(seg.lat2(nseg), seg.lon2(nseg), d, az(nseg)+90);
[sy(nseg+2), sx(nseg+2)] = reckon(seg.lat2(nseg), seg.lon2(nseg), d, az(nseg)-90);

% Finalize for output
sx = wrapTo360(sx);
