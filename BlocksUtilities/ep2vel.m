function [ve, vn] = ep2vel(ec, sta)
% EP2VEL calculates the east and north velocities at station coordinates
% given Euler pole coordinates.
%
%   [VE, VN] = EP2VEL(EC, STA) calculates the east and north velocities VE
%   and VN at the locations defined in the n-by-2 array STA given the 
%   Cartesian Euler vector EC.
%


% set up structure for rotation partials calculation
s.lon = sta(:, 1); s.lat = sta(:, 2);
[s.x s.y s.z] = sph2cart(deg2rad(s.lon), deg2rad(s.lat), 6371);
s.blockLabel = ones(size(sta, 1), 1);
[junk.eulerLon, junk.lon1] = deal(1);

% calculate rotation partials
G = GetRotationPartials(junk, s, junk, junk);

% multiply by Euler pole to get velocities
v = G*ec(:);

% extract components
ve = v(1:3:end); vn = v(2:3:end);