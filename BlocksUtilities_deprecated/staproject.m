function [pseg, psta] = staproject(seg, sta)
% staproject   Projects stations for each segment or triangle in a specified structure.
%    [PSEG, PSTA] = staproject(SEG, STA) projects the stations in structure STA using an 
%    oblique Mercator projection local to each segment in structure SEG.  The output is 
%    returned to structures PSEG, which contains 1-by-nSEG arrays of the projected fault
%    endpoint coordinates, each based on the local project; and PSTA, which contains 
%    nSTA-by-nSEG arrays of projected coordinates, with each column corresponding to the
%    projection for a particular segment.
%
%    [PTRI, PSTA] = staproject(TRI, STA) carries out the same operation, except returning
%    the projected coordinates based on the triangular dislocation elements in structure TRI.
%

% Determine type of fault structure, which is needed to determine how to calculate the pole
if isfield(seg, 'nEl') % Type is triangles
   z1r             = 1+seg.z1./6371; % Calculate depth as fraction of sphere radius
   z2r             = 1+seg.z2./6371;
   z3r             = 1+seg.z3./6371;
   % Take cross product to find element normals
   normVec         = cross([deg_to_rad(seg.lon2-seg.lon1), deg_to_rad(seg.lat2-seg.lat1), z2r-z1r], [deg_to_rad(seg.lon3-seg.lon1), deg_to_rad(seg.lat3-seg.lat1), z3r-z1r], 2);
   % Create arrays of the fault coordinates for projection
   flon            = [seg.lon1'; seg.lon2'; seg.lon3'];
   flat            = [seg.lat1'; seg.lat2'; seg.lat3'];
else
   % Take cross product to find segment normals
   normVec         = cross([seg.x1 seg.y1 seg.z1], [seg.x2 seg.y2 seg.z2], 2);
   % Create arrays of the fault coordinates for projection
   flon            = [seg.lon1'; seg.lon2'];
   flat            = [seg.lat1'; seg.lat2'];
end

% Normalize normal vectors   
normVec            = normVec./repmat(mag(normVec, 2), 1, 3);

% Convert to spherical coordinates to give pole
[plon, plat]       = cart2sph(normVec(:, 1), normVec(:, 2), normVec(:, 3));
plon               = rad_to_deg(plon(:));
plat               = rad_to_deg(plat(:));

% Determine projection origins; returned in degrees
[olon, olat]       = neworigin(plon, plat);

% Make a big array of coordinates to be projected.  Each column contains
% the full array of station coordinates, augmented with the segment 
% coordinates below
clon               = [repmat(sta.lon, 1, numel(plon)); flon];
clat               = [repmat(sta.lat, 1, numel(plon)); flat];

% Project all coordinates
[psta.x, psta.y]   = omproj(clon, clat, olon(:), olat(:), plon, plat);
if isfield(seg, 'nEl')
   pseg.x1         = psta.x(end-2, :);
   pseg.y1         = psta.y(end-2, :);
   pseg.x2         = psta.x(end-1, :);
   pseg.y2         = psta.y(end-1, :);
   pseg.x3         = psta.x(end-0, :);
   pseg.y3         = psta.y(end-0, :);
   psta.x          = psta.x(1:end-3, :);
   psta.y          = psta.y(1:end-3, :);
else
   pseg.x1         = psta.x(end-1, :);
   pseg.y1         = psta.y(end-1, :);
   pseg.x2         = psta.x(end-0, :);
   pseg.y2         = psta.y(end-0, :);
   psta.x          = psta.x(1:end-2, :);
   psta.y          = psta.y(1:end-2, :);
end