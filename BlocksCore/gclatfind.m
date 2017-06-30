function lat = gclatfind(lon1, lat1, lon2, lat2, lon)
% gclatfind   Determines latitude as a function of longitude along a great circle.
%   LAT = gclatfind(LON1, LAT1, LON2, LAT2, LON) finds the latitudes of points of 
%   specified LON that lie along the great circle defined by endpoints LON1, LAT1 
%   and LON2, LAT2. Angles should be in degrees. 

lat = atand(tand(lat1).*sind(lon - lon2)./sind(lon1 - lon2) - tand(lat2).*sind(lon - lon1)./sind(lon1 - lon2));