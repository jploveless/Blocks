function [lat, lon] = zerosplitsegments(varargin)
% zerosplitsegment  Splits segments at prime meridian.
%   LAT = zerosplitsegment(S) splits segments contained in structure S
%   at the prime meridian (0 degrees longitude). Returned is the latitude
%   of the point where the segment crossed the prime meridian (zero degrees
%   longitude).
%
%   LAT = zerosplitsegment(LON1, LAT1, LON2, LAT2) carries out the 
%   same operations on the specified endpoint coordinate pairs rather
%   than the structure.
%

% Check input arguments
if nargin == 1
   s = varargin{1};
elseif nargin == 2
   s = varargin{1};
   m = varargin{2};
elseif nargin == 4
   [s.lon1, s.lat1, s.lon2, s.lat2] = deal(varargin{:});
elseif nargin == 5
   [s.lon1, s.lat1, s.lon2, s.lat2, m] = deal(varargin{:});
end 

% Make sure Cartesian coordinates have been calculated
if ~isfield(s, 'x1')
   [s.x1, s.y1, s.z1] = sph2cart(deg_to_rad(s.lon1), deg_to_rad(s.lat1), 6371);
   [s.x2, s.y2, s.z2] = sph2cart(deg_to_rad(s.lon2), deg_to_rad(s.lat2), 6371);
end

% Find pole to great circle along which endpoints lie
seggc = cross([s.y1, s.x1, s.z1], [s.y2, s.x2, s.z2], 2);

% Cross this pole with that of the prime meridian to find the intersection
if ~exist('m', 'var')
   m = 1;
end
isect = cross(seggc, repmat([-m 0 0], size(seggc, 1), 1), 2);

% Convert intersections back to long., lat
[lon, lat] = cart2sph(isect(:, 1), isect(:, 2), isect(:, 3));

lon = rad_to_deg(lon);
lat = rad_to_deg(lat);

% Make sure we're getting the correct crossing (0 or 180)
lon = abs(lon - 90);