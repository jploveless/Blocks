function az = sphereazimuth(lon1, lat1, lon2, lat2)
% sphereazimuth   Calculates azimuth between sets of points on a sphere.
%   AZ = sphereazimuth(LON1, LAT1, LON2, LAT2) calculates the azimuth, AZ,
%   between points defined by coordinates (LON1, LAT1) and (LON2, LAT2).  
%   The coordinate arrays must all be the same size, or any pair can be 
%   scalars.
%

% Check inputs
slon1 = size(lon1);
slat1 = size(lat1);
slon2 = size(lon2);
slat2 = size(lat2);
if prod(slon1) == 1 % If lon1 is a scalar,
   if prod(slat1) ~= 1 
      error('Coordinate arrays for points must be the same size.')
   else
      lon1 = repmat(lon1, slon2);
      lat1 = repmat(lat1, slat2);
   end
elseif prod(slon2) == 1
   if prod(slat2) ~= 1 
      error('Coordinate arrays for points must be the same size.')
   else
      lon2 = repmat(lon2, slon1);
      lat2 = repmat(lat2, slat1);
   end
end

% From https://en.wikipedia.org/wiki/Azimuth
% Differs from Mapping Toolbox by 1e-11
num = sind(lon2 - lon1);
den = cosd(lat1).*tand(lat2) - sind(lat1).*cosd(lon2 - lon1);
az = rad_to_deg(atan2(num, den));