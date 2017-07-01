function [x, y, lambda0] = faultobliquemerc(lambda, phi, lambda1, phi1, lambda2, phi2)
% obliquemerc   Oblique mercator projection.
%   [X, Y] = OBLIQUEMERC(LON, LAT, LON1, LAT1, LON2, LAT2) carries out 
%   oblique Mercator projection of the data contained in arrays LON and 
%   LAT, such that the x-axis is parallel to a fault trace and the y-axis
%   is perpendicular.  The fault trace is defi using endpoint coordinates
%   LON1, LAT1, LON2, LAT2.  Multiple projection parameters can be handled, 
%   based on the following input array sizing:
%
%   For a single oblique projection (project all coordinates based on a single fault):
%   LON, LAT: n-by-1 column vector
%   LON1, LAT1, LON2, LAT2: Scalars
%
%   For multiple oblique projections (project all coordinates based on each fault):
%   LON, LAT: n-by-1 column vector
%   LON1, LAT1, LON2, LAT2: 1-by-m row vectors
%   or input all arguments as n-by-m arrays.  Outputs will be n-by-m.
%
%   Values should be entered in degrees.  
%
%   From USGS "Map Projections --- A Working Manual", p. 69

% Convert to radians
% lambda        = deg_to_rad(lambda);
% phi           = deg_to_rad(phi);
% lambda1       = deg_to_rad(lambda1);
% phi1          = deg_to_rad(phi1);
% lambda2       = deg_to_rad(lambda2);
% phi2          = deg_to_rad(phi2);

% Check array sizes
sdata = size(lambda); % Size of the data array
sproj = size(lambda1); % Size of the projection parameters

% Case 1: Origin and pole are scalars
if prod(sproj) == 1
   lambda1 = lambda1*ones(sdata);
   phi1 = phi1*ones(sdata);
   lambda2 = lambda2*ones(sdata);
   phi2 = phi2*ones(sdata);
% Case 2: Data is a column vector, projection parameters are row vectors
elseif sproj(2) > 1 && sdata(2) == 1
   lambda        = repmat(lambda, 1, sproj(2));
   phi           = repmat(phi, 1, sproj(2));
   lambda1       = repmat(lambda1, sdata(1), 1);
   phi1          = repmat(phi1, sdata(1), 1);
   lambda2       = repmat(lambda2, sdata(1), 1);
   phi2          = repmat(phi2, sdata(1), 1);
end

% Calculate fault midpoints
[lambdam, phim] = segmentmidpoint(lambda1, phi1, lambda2, phi2);

% Trig. functions
cphi = cosd(phi);
sphi = sind(phi);
cphi1 = cosd(phi1);
sphi1 = sind(phi1);
cphi2 = cosd(phi2);
sphi2 = sind(phi2);
clam1 = cosd(lambda1);
slam1 = sind(lambda1);
clam2 = cosd(lambda2);
slam2 = sind(lambda2);

% Pole longitude
num = cphi1.*sphi2.*clam1 - sphi1.*cphi2.*clam2;
den = sphi1.*cphi2.*slam2 - cphi1.*sphi2.*slam1;
lambdap = rad_to_deg(atan2(num, den));
%lambdap = lambdap + (den < 0)*180; % If denominator is negative, add 180
% Pole latitude
phip = atand(-cosd(lambdap - lambda1)./tand(phi1));
sp = sign(phip);
% Choose northern hemisphere pole
lambdap(phip < 0) = lambdap(phip < 0) + 180;
phip(phip < 0) = -phip(phip < 0);

% Find origin longitude
lambda0 = lambdap + 90; % Origin longitude is pole + 90 degrees
lambda0(lambda0 > 180) = lambda0(lambda0 > 180) - 360; % Wrap to 180

cphip = cosd(phip);
sphip = sind(phip);
dlamb = lambda - lambda0;
A = sphip.*sphi - cphip.*cphi.*sind(dlamb);

% Projection
x = atan((tand(phi).*cphip + sphip.*sind(dlamb))./cosd(dlamb));
x(phip < 80) = x(phip < 80) - (cosd(dlamb(phip < 80)) > 0)*pi + pi/2; % This is different from the reference but agrees with Mapping Toolbox
x(phip >= 80) = x(phip >= 80) - (cosd(dlamb(phip >= 80)) < 0)*pi + pi/2; % This prevents low-latitude, E-W elements from spanning the globe rather than being near origin of projected coordinates
y = atanh(A);

x = -sp.*x;
y = -sp.*y;
