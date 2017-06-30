function [Plon, Plat] = smoothblockcline(direc, wid, col, bidx)
% SMOOTHBLOCKCLINE  Plots smooth colored "lines" as series of polygons.
%    SMOOTHBLOCKCLINE(DIREC, WID, COL) uses information in the results directory
%    DIREC to plot colored polygons of width WID (km), colored by 
%    COL around a block. COL can be a valid field from a segment structure,
%    or a nSegments-by-1 vector. For example, to plot segments colored by strike 
%    slip rate, 10 km wide, call:
%   
%    >> smoothblockcline('0000000001', 10, 'ssRate');
%
%    SMOOTHBLOCKCLINE(DIREC, WID, COL, IDX) plots only the blocks specified
%    by vector IDX. By default, the exterior block is not plotted, as its 
%    coordinates are not included in Block.coords. 
%
%    [PLON, PLAT] = SMOOTHBLOCKCLINE(...) returns longitude and latitude 
%    coordinates to the 4-by-nSegments arrays PLON and PLAT, which can 
%    be plotted using:
%
%    patch(PLON, PLAT, color_vector)
%
%    where color_vector is any 1-by-nSegments vector. 
% 

% Read in necessary files
seg = ReadSegmentTri([direc '/Mod.segment']);
lab = ReadSegmentTri([direc '/Label.segment']); lab.eastBlock = lab.ssRate; lab.westBlock = lab.ssRateSig;


b   = ReadBlockCoords([direc '/Block.coords']);
% Check to see if final coordinate has been repeated
for i = 1:length(b)
   if sum(b{i}(1, :) == b{i}(end, :)) ~= 2
      b{i} = [b{i}; b{i}(1, :)];
   end
end

% Define subset of blocks
if ~exist('bidx', 'var')
   bidx = 1:length(b);
end
%
%% Construct ordered block coordinates from labeled segments so that matching is perfect
%for i = bidx
%  bidx = logical(sum([lab.eastBlock == i, lab.westBlock == i], 2));
%  ssub = structsubset(seg, bidx);
%  oidx = ordersegs(ssub);
%  ssub = structsubset(ssub, oidx);
%  ssub = OrderEndpointsSphere(ssub);
%  b{i} = [ssub.lon1, ssub.lat1; ssub.lon2(end), ssub.lat2(end)];
%end

% Calculate segment midpoint coordinates   
[mlon, mlat] = segmentmidpoint(seg.lon1, seg.lat1, seg.lon2, seg.lat2);

% Big arrays to hold all polygon coordinates 
[Plon, Plat] = deal(zeros(4, length(seg.lon1)));

% Define the polygons for each block
for i = bidx
   [plon, plat] = swathblockseg(b{i}(1:end-1, :), wid);
   % Match the polygon coordinates to segments

   % Calculate ordered block midpoints
   [bmlon, bmlat] = segmentmidpoint(b{i}(1:end-1, 1), b{i}(1:end-1, 2), b{i}(2:end, 1), b{i}(2:end, 2));
   % Find coordinates within ordered block coordinates
   [~, loc] = ismember([bmlon, bmlat], [mlon, mlat], 'rows');
   Loc = loc;
   % Need to check for some midpoints that weren't matched exactly, with incremental tolerance
   tol = 0.0001;
   while sum(loc == 0) > 0
      [~, loc] = ismembertol([bmlon(loc == 0), bmlat(loc == 0)], [mlon, mlat], tol, 'byrows', true);
      Loc(Loc == 0) = loc;
      tol = tol + 0.0001;
   end
   % Reorder columns of polygon coordinates
   Plon(:, Loc) = plon;
   Plat(:, Loc) = plat;
end

% Correct any negative longitudes
Plon(Plon < 0) = Plon(Plon < 0) + 360;

% Eliminate any globe-spanning segments
difflon = max(Plon) - min(Plon);
globespan = difflon > 350;
Plon(:, globespan) = NaN(4, sum(globespan));

% Make the plot

% Determine color variable
if ischar(col)
   if isfield(seg, col)
      col = getfield(seg, col);
   end
end
figure
h = patch(Plon, Plat, col(:)');
shading flat;