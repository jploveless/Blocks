function [mx, my, lx, ly] = compareobliquemerctri(p, s)

R = 6371;
% Matlab
[x, y, z]                     = long_lat_to_xyz(deg2rad([p.lon1 p.lon2 p.lon3]), deg2rad([p.lat1 p.lat2 p.lat3]), R + [p.z1 p.z2 p.z3]);

% find a point lying along the spherical shell of radius = norm(v2) and on the line (v3 - v1)
v                             = [x(:) y(:) z(:)];
[v, ci]                       = sortrows([v mag(v, 2)], 4);
[v3a, v3b]                    = LineSphInt(v(3, 1:3), v(1, 1:3), [0 0 0], v(2, 4));
v3                            = [v3a; v3b];
dists                         = [norm(v(2, 1:3) - v3a); norm(v(2, 1:3) - v3b)];
[mnd, i]                      = min(dists);
[v3, j]                       = sortrows([v(2, 1:3); v3(i, :)], 1); % points sorted by x coordinate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Convert all coordinates to Cartesian      %%
%%  This is done via an oblique Mercator      %%
%%  projection locally tangent to the         %%
%%  element.                                  %%
%%                                            %%
%%  First a point along strike from the first %%
%%  element vertex is found, then the cross   %%
%%  product between this point and the first  %%
%%  vertex is found.  This quantity defines   %%
%%  the pole that is locally tangent to the   %%
%%  element strike.  This pole is used in     %%
%%  the projection.                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pole                          = cross(v3(1, :), v3(2, :));
pole                          = pole./sqrt(sum(pole.^2));
[pole_lon, pole_lat]          = xyz_to_long_lat(pole(1), pole(2), pole(3));
oblique_origin                = newpole(rad_to_deg(pole_lat), rad_to_deg(pole_lon));
mstruct                       = defaultm('mercator');
mstruct.origin                = oblique_origin;
mstruct                       = defaultm(mercator(mstruct));

[rad2deg(pole_lon) rad2deg(pole_lat)]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do conversion to projected space  (Oblique Mercator)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[mx, my]                      = mfwdtran(mstruct, s.lat, s.lon);

% Mine





R                             = 6371;

if ~isstruct(p)
   p = struct('lon1', p(:, 1), 'lat1', p(:, 2), 'z1', p(:, 3),...
              'lon2', p(:, 4), 'lat2', p(:, 5), 'z2', p(:, 6),...
              'lon3', p(:, 7), 'lat3', p(:, 8), 'z3', p(:, 9));
end
if ~isstruct(s)
   s = struct('lon', s(:, 1), 'lat', s(:, 2));
end
              
% If no depth is defined for stations, assume they're at the surface
if ~isfield(s, 'z')
   s.z                        = 0*s.lon;
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
[~, xi]                       = sort([intx; x(2, :)], 'descend'); % points sorted by x coordinate
idx                           = sub2ind([2, size(int1, 1)], xi, repmat(1:size(v, 2), 2, 1)); % Get indices of minimum x coordinate

[ilon, ilat]                  = xyz_to_long_lat(intx', inty', intz'); % Convert intersection points to spherical
intlon                        = [rad_to_deg(ilon'); lon(2, :)]; % Stack on top of mid-depth vertices
intlat                        = [rad_to_deg(ilat'); lat(2, :)];
polem                         = cross([deg_to_rad(intlon(idx(1, :)))' deg_to_rad(intlat(idx(1, :)))' ones(size(idx, 2), 1)], [deg_to_rad(intlon(idx(2, :)))' deg_to_rad(intlat(idx(2, :)))' ones(size(idx, 2), 1)], 2);
%polem                         = sign(polem(:, 3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do conversion to projected space  (Oblique Mercator)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lx, ly]                      = faultobliquemerc([s.lon(:)], [s.lat(:)], intlon(idx(1, :)), intlat(idx(1, :)), intlon(idx(2, :)), intlat(idx(2, :)));
% Calculate exact strike used for projection, for unprojection later

minmax(lx - mx)
minmax(ly - my)

keyboard