% gc = gcdist(lat1,lon1,lat2,lon2);
% Input: 
%    - lat1,lon1 Coordinate pair for first point(s)
%    - lat1,lon1 Coordinate pair for second point(s)
%  Output:
%    - gcdist Great circle distance between first point(s) and second point(s).
% Usage:
% These coordinate pairs can in fact be vectors, as long as the lengths are identical, 
% or one of the pairs is a scalar point.
function gc = gcdist(lat1,lon1,lat2,lon2)
  R = 6367*1e3; %radius of the earth in meters, assuming spheroid
%   t1 = sind((lat1-lat2)./2).^2;
%   t2 = cosd(lat1)*cosd(lat2);
%   t3 = sind((lon1-lon2)/2)^2;
%   gcdist = 2*R * asind(sqrt( t1 + t2 .* t3 ));

  dlon = lon1-lon2;
  t1 = (cosd(lat2).*sind(dlon)).^2;
  t2 = (cosd(lat1).*sind(lat2) - sind(lat1).*cosd(lat2).*cosd(dlon)).^2;
  t3 = sind(lat1).*sind(lat2) + cosd(lat1).*cosd(lat2).*cosd(dlon);
  
  dsig = atan2(sqrt(t1+t2),t3);
    
  gc = R.*dsig;
  
end