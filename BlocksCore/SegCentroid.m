function s = SegCentroid(s)
%
% SegCentroid calculates the coordinates of a segment's centroid.
%
% 	Inputs:
%		s = segment structure
%
%	Outputs:
%		s = segment structure, updated with fields s.centLon, s.centLat, s.centz
%

% calculate midpoint coordinates, if necessary
if isfield(s, 'midLon') == 0;
	[s.midLon, s.midLat] = segmentmidpoint(s.lon1, s.lat1, s.lon2, s.lat2);
end

if isfield(s, 'midX') == 0;
	[s.midX s.midY s.midZ] = sph2cart(DegToRad(s.midLon), DegToRad(s.midLat), 6371);
end

if isfield(s, 'x1') == 0;
	[s.x1 s.y1 s.z1]               = sph2cart(DegToRad(s.lon1), DegToRad(s.lat1), 6371);
	[s.x2 s.y2 s.z2]               = sph2cart(DegToRad(s.lon2), DegToRad(s.lat2), 6371);
end

% determine segment strikes
az = azimuth(s.lat1(:), s.lon1(:), s.lat2(:), s.lon2(:));
azx = (s.y2 - s.y1)./(s.x2 - s.x1);

% calculate corrected strikes
az = az + sign(cosd(s.dip)).*90;
azx = atan(-1./azx);

% calculate horizontal distance to mid-depth
s.centz = (s.lDep - s.bDep)./2;
dist = s.centz./abs(tand(s.dip));

% reckon centroid lat, lon
[s.centLat s.centLon] = reckon(s.midLat(:), s.midLon(:), rad2deg(dist/6371), az);
s.centLon = wrapTo360(s.centLon);
% ...and x, y
s.centx = s.midX(:) + sign(cosd(s.dip)).*dist.*cos(azx);
s.centy = s.midY(:) + sign(cosd(s.dip)).*dist.*sin(azx);