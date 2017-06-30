function [S, i] = OrderEndpointsSphere(s)
% OrderEndpointsSpher  New endpoint ordering function, placing west point first.
%   OrderEndpointsSphere(S) orders the endpoints of segment structure S. This new 
%   version converts the endpoint coordinates from spherical to Cartesian, 
%   then takes the cross product to test for ordering (i.e., a positive z
%   component of cross(point1, point2) means that point1 is the western 
%   point). This method works for both (-180, 180) and (0, 360) longitude
%   conventions.
%

% Convert to radians
o1 = DegToRad(s.lon1(:));
o2 = DegToRad(s.lon2(:));
a1 = DegToRad(s.lat1(:));
a2 = DegToRad(s.lat2(:));

% Convert to Cartesian
[x1, y1, z1] = sph2cart(o1, a1, 1);
[x2, y2, z2] = sph2cart(o2, a2, 1);

% Cross
cp = cross([x1, y1, z1], [x2, y2, z2], 2);

% Modify segment fields and create an index array, putting the west endpoint first
idx = (cp(:, 3) <= 0);

S = s;
S.lon1(idx) = s.lon2(idx);
S.lat1(idx) = s.lat2(idx);
S.lon2(idx) = s.lon1(idx);
S.lat2(idx) = s.lat1(idx);

% Two column array of values [1 2] denoting which is the western endpoint
i = [double(idx)+1 double(~idx)+1];
