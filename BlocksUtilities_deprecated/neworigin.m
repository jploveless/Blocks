function [olon, olat, direc] = neworigin(plon, plat)
% NEWORIGIN  Finds new origin of globe given a new north pole location.
%   [OLON, OLAT, DIR] = NEWORIGIN(PLON, PLAT) returns the new origin coordinates
%   OLON, OLAT for the projection specified by the new north pole location
%   with coordinates PLON, PLAT.  The orientation of the pole with respect to the
%   origin is given by DIR, which is 0 for the north pole and -180 for south.
%

% Convert to radians
plon = deg_to_rad(plon);
plat = deg_to_rad(plat);
direc = zeros(size(plon));

% For northern hemisphere,
n = plat >= 0;
olat(n) = pi/2 - plat(n);
olon(n) = modpi(plon(n) + pi, -1);

% For southern hemisphere,
s = plat < 0;
olat(s) = pi/2 + plat(s);
olon(s) = modpi(plon(s), -1);
direc(s) = -pi;

% If already a pole
p = plat == pi/2;
olon(p) = modpi(plon(p), -1);

% Convert to degrees
olon = rad_to_deg(olon);
olat = rad_to_deg(olat);
direc = rad_to_deg(direc);
