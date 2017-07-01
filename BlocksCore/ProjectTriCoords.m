function [p, s]               = ProjectTriCoords(p, s)
% ProjectTriCoords   Calculates Cartesian coordinates based on a local oblique Mercator projection. 
%   [P, S] = ProjectTriCoords(P, S) uses an oblique Mercator projection local to each 
%   fault element defined in structure P to project both element vertex coordinates
%   and station coordinates defined in structure S.  The resulting Cartesian coordinates
%   are stored in fields in the updated structures:
%
%   S:
%      tpx
%      tpy
%      (nSta-by-nTri arrays, with each column containing projected coordinates for a single segment)
%
%   F:
%      px1
%      py1
%      px2
%      py2
%      px3
%      py3
%      (nTri-by-1 arrays giving projected vertex coordinates for each element)
%

%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
R                             = 6371;

if ~isstruct(p)
   p = struct('lon1', p(:, 1), 'lat1', p(:, 2), 'z1', p(:, 3),...
              'lon2', p(:, 4), 'lat2', p(:, 5), 'z2', p(:, 6),...
              'lon3', p(:, 7), 'lat3', p(:, 8), 'z3', p(:, 9));
end
if ~isstruct(s)
   if size(s, 2) == 3
      s = struct('lon', s(:, 1), 'lat', s(:, 2), 'dep', s(:, 3));
   elseif size(s, 2) == 2
      s = struct('lon', s(:, 1), 'lat', s(:, 2));
   end
end
              
% If no depth is defined for stations, assume they're at the surface
if ~isfield(s, 'dep')
   if isfield(s, 'z') && ~isfield(s, 'x')
      s.dep                   = -abs(s.z);
   else
      s.dep                   = 0*s.lon;
   end
end
nsta                          = numel(s.lon);
ntri                          = numel(p.lon1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  First convert spherical to Cartesian coordinates, %%
%%  then take a series of cross products.             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lon                           = [p.lon1'; p.lon2'; p.lon3'];
lat                           = [p.lat1'; p.lat2'; p.lat3'];
dep                           = R + -abs([p.z1'; p.z2'; p.z3']);
[x, y, z]                     = long_lat_to_xyz(deg_to_rad(lon), deg_to_rad(lat), dep);

% find a point lying along the spherical shell of radius = norm(v2) and on the line (v3 - v1)
v                             = sqrt(x.^2 + y.^2 + z.^2); % Vertex radii
[v, ci]                       = sort(v); % Sorted
idx                           = sub2ind(size(v), ci, repmat(1:size(v, 2), 3, 1));
x                             = x(idx); % Rearrange Cartesian coordinates in order of radius
y                             = y(idx); 
z                             = z(idx);
lon                           = lon(idx); % Rearrange spherical coordinates in order of radius
lat                           = lat(idx);
dep                           = dep(idx);

% Find the intersections
[int1, int2]                  = LineSphInt([x(1, :)' y(1, :)' z(1, :)'], [x(3, :)' y(3, :)' z(3, :)'], zeros(size(v))', v(2, :)');
% Isolate intersections' coordinates
intx                          = [int1(:, 1)'; int2(:, 1)'];
inty                          = [int1(:, 2)'; int2(:, 2)'];
intz                          = [int1(:, 3)'; int2(:, 3)'];
% Determine which intersection is closest to the mid-depth point
dists                         = [mag(int1' - [x(2, :); y(2, :); z(2, :)]); mag(int2' - [x(2, :); y(2, :); z(2, :)])];
[~, mi]                       = min(dists);
idx                           = sub2ind(size(intx), mi, 1:size(v, 2));
% Extract the coordinates for that closest intersection point
intx                          = intx(idx);
inty                          = inty(idx);
intz                          = intz(idx);
[~, xi]                       = sort([intx; x(2, :)]); % points sorted by x coordinate
idx                           = sub2ind([2, size(int1, 1)], xi, repmat(1:size(v, 2), 2, 1)); % Get indices of minimum x coordinate

[ilon, ilat]                  = xyz_to_long_lat(intx', inty', intz'); % Convert intersection points to spherical
intlon                        = [rad_to_deg(ilon'); lon(2, :)]; % Stack on top of mid-depth vertices
intlat                        = [rad_to_deg(ilat'); lat(2, :)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do conversion to projected space  (Oblique Mercator)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[mx, my]                      = faultobliquemerc([s.lon(:); p.lon1; p.lon2; p.lon3], [s.lat(:); p.lat1; p.lat2; p.lat3], intlon(idx(1, :)), intlat(idx(1, :)), intlon(idx(2, :)), intlat(idx(2, :)));

% Calculate exact strike used for projection, for unprojection later
p.Strike                      = sphereazimuth(intlon(idx(1, :)), intlat(idx(1, :)), intlon(idx(2, :)), intlat(idx(2, :)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Separate station arrays and triangle element vectors  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.tpx                         = mx(1:nsta, :);
s.tpy                         = my(1:nsta, :);
p.px1                         = diag(mx(nsta+0*ntri + (1:ntri), :));
p.py1                         = diag(my(nsta+0*ntri + (1:ntri), :));
p.px2                         = diag(mx(nsta+1*ntri + (1:ntri), :));
p.py2                         = diag(my(nsta+1*ntri + (1:ntri), :));
p.px3                         = diag(mx(nsta+2*ntri + (1:ntri), :));
p.py3                         = diag(my(nsta+2*ntri + (1:ntri), :));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Scale to proper distances by multiplying by Earth's radius  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% s.tpx                         = s.tpx.*repmat(R, nsta, ntri);
% s.tpy                         = s.tpy.*repmat(R, nsta, ntri);
% p.px1                         = p.px1.*R;
% p.py1                         = p.py1.*R;
% p.px2                         = p.px2.*R;
% p.py2                         = p.py2.*R;
% p.px3                         = p.px3.*R;
% p.py3                         = p.py3.*R; 

s.tpx                         = s.tpx.*repmat(R - abs(s.dep), 1, ntri);
s.tpy                         = s.tpy.*repmat(R - abs(s.dep), 1, ntri);
p.px1                         = p.px1.*(R - abs(p.z1));
p.py1                         = p.py1.*(R - abs(p.z1));
p.px2                         = p.px2.*(R - abs(p.z2));
p.py2                         = p.py2.*(R - abs(p.z2));
p.px3                         = p.px3.*(R - abs(p.z3));
p.py3                         = p.py3.*(R - abs(p.z3)); 
