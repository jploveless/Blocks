function a = polyareasphere(lonv, latv)
% polyareasphere   Calculates the area of a polygon on a sphere.
%   A = polyareasphere(LON, LAT) returns the area of a polygon comprising
%   the ordered coordinates given by LON and LAT, in units of square degrees.
%

% For each polygon vertex, determine the azimuth to both neighboring vertices
adjaz = sphereazimuth(repmat(lonv(:), 1, 2), repmat(latv(:), 1, 2), lonv([([end, 1:end-1])', ([2:end, 1])']), latv([([end, 1:end-1])', ([2:end, 1])']));

% The difference between these angles is the internal angle at that vertex
intang = diff(adjaz, 1, 2);
intang(intang < 0) = intang(intang < 0) + 360;

% Area is given as the sum of angles minus (n-2)*180
a = sum(intang) - (length(intang)-2).*180;

