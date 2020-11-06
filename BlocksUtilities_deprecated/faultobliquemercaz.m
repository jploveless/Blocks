function [x, y] = faultobliquemercaz(lambda, phi, lambdac, phic, az)
% faultobliquemercaz   Oblique mercator projection.
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
%   LON1, LAT1, LON2, LAT2: m-by-1 row vectors
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
sproj = size(lambdac); % Size of the projection parameters

% Case 1: Origin and pole are scalars
if prod(sproj) == 1
   lambdac = lambdac*ones(sdata);
   phic = phic*ones(sdata);
   az = az*ones(sdata);
% Case 2: Data is a column vector, projection parameters are row vectors
elseif sproj(2) > 1 && sdata(2) == 1
   lambda        = repmat(lambda, 1, sproj(2));
   phi           = repmat(phi, 1, sproj(2));
   lambdac       = repmat(lambdac, sdata(1), 1);
   phic          = repmat(phic, sdata(1), 1);
   az            = repmat(az, sdata(1), 1);
end

% Trig. functions
cphi = cosd(phi);
sphi = sind(phi);
saz  = sind(az);
caz  = cosd(az);
cphic = cosd(phic);
sphic = sind(phic);

% Pole longitude
den = -sphic.*saz;
lambdap = rad_to_deg(atan2(-caz, den)) + lambdac;
lambdap = lambdap + (den < 0)*180; % If denominator is negative, add 180
% Pole latitude
phip = asind(-cphic.*saz);
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
x = x - (cosd(lambda + 90) < 0)*pi;
k0 = 1;
y = k0.*atanh(A);
