function [plon, plat] = localsegprojection(sta, seg)

nseg = numel(seg.lon1);
nsta = numel(sta.lon);

% Make full arrays of coordinates
lon = [sta.lon(:); seg.lon1(:); seg.lon2(:)];
lat = [sta.lat(:); seg.lat1(:); seg.lat2(:)];
dep = zeros(size(lon));

if isfield(seg, 'name') % If rectangular segments, 
   % Projection pole is based on fault endpoints
   flon1  = deg2rad(seg.lon1);
   flat1  = deg2rad(seg.lat1);
   flon2  = deg2rad(seg.lon2);
   flat1  = deg2rad(seg.lat2);
else % Triangle dislocation element structure
   % Projection pole is based on element centroid and reckoned point along strike
   flon1  = deg2rad(seg.lonc);
   flat1  = deg2rad(seg.latc);
   [flat2, flon2] = reckon(flat1, flon1, 0.01, seg.strike);
   lon = [lon; seg.lon3(:)];
   lat = [lat; seg.lat3(:)];
   dep(nsta+1:end) = -abs([seg.z1(:); seg.z2(:)]);
   dep = [dep; -abs(seg.z3(:))];
end
   
slon = deg_to_rad(sta.lon);
slat = deg_to_rad(sta.lat);

% Allocate space for projected coordinates
px = zeros(numel(lon), nseg);
py = plon;

% Get projection parameters
[pole_lon, pole_lat]          = get_pole_from_gcps(flon1, flat1, flon2, flat2);
oblique_origin                = newpole(rad2deg(pole_lon), rad2deg(pole_lat));

% Loop over each segment to do local projection
parfor (i = 1:nseg)
   mstruct                       = defaultm('mercator');
   mstruct.origin                = oblique_origin;
   mstruct                       = defaultm(mercator(mstruct));
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Do conversion to projected space  (Oblique Mercator)  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   [mx, my]                      = mfwdtran(mstruct, rad_to_deg(lat), rad_to_deg(long));
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Scale to proper distances  %%
   %%  This looks correct         %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   px(:, i)                     = mx .* (R + dep);
   py(:, i)                     = my .* (R + dep);
end

