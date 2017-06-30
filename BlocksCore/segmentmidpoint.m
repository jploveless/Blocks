function [lon, lat] = segmentmidpoint(lon1, lat1, lon2, lat2);
% segmentmidpoint  Calculates segment midpoints along great circles.
%   [LON, LAT] = segmentmidpoint(LON1, LAT1, LON2, LAT2) calculates the 
%   coordinates of the midpoints of great circle segments defined by 
%   endpoint coordinates LON1, LAT1 and LON2, LAT2.
%

% Half longitudes
lon = 0.5*(lon1 + lon2);


% Correspondinging latitudes
lat = gclatfind(lon1, lat1, lon2, lat2, lon);

% Make sure latitude is of same sign as at least one of the endpoints; some short segments near PM can have it flipped
slats = sum([sign(lat1(:)), sign(lat2(:))], 2);
slat = sign(lat(:));
flip = slats ~= 0 & sign(slats) ~= slat;
lat(flip) = -lat(flip);
lon(flip) = lon(flip) + 180; 

lon(lon > 360) = lon(lon > 360) - 360;

% Correction for N-S segments
lat(isnan(lat)) = 0.5*(lat1(isnan(lat)) + lat2(isnan(lat)));