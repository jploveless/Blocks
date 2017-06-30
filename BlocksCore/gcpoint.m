function [plon, plat] = gcpoint(lon, lat, az, dist)
% gcpoint  Finds coordinates of a point along a great circle.
%   [LON2, LAT2] = gcpoint(LON1, LAT1, AZ, DIST) determines the 
%   coordinates LON2, LAT2 of a point lying along a great circle
%   originating at point LON1, LAT1. The azimuth of the great 
%   circle is given as AZ and the angular distance between the 
%   two points is DIST. All input arguments should be given in 
%   degrees, including the distance.
%

plat = asind(sind(lat).*cosd(dist) + cosd(lat).*sind(dist).*cosd(az));

a = sind(dist).*sind(az).*cosd(lat);
b = cosd(dist) - sind(lat).*sind(plat);

if verLessThan('matlab', '8.0')
   plon = lon + rad2deg(atan2(a, b));
else
   plon = lon + atan2d(a, b);
end
plon(b == 0) = lon(b == 0);