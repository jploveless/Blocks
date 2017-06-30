function [fx1, fy1, fz1,...
          fx2, fy2, fz2,...
          fx3, fy3, fz3,...
          fx, fy, faz, azi] = get_local_xy_coords_om_matlab_tri(lon1, lat1, z1, lon2, lat2, z2, lon3, lat3, z3, slon, slat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                 %%
%%  get_local_xy_coords_om_matlab_tri.m            %%
%%                                                 %%
%%  Oblique Mercator projection                    %%
%%  Zero ellipticity model at this point           %%
%%                                                 %%
%%  Projection is with axis of cyclinder normal    %%
%%  to the triangular element strike.              %%
%%                                                 %%
%%  This version requires the MATLAB mapping       %%
%%  toolbox.                                       %%
%%                                                 %%
%%  All angular arguments should be dimensioned as %%
%%  radians and all linear arguments should be in  %%
%%  kilometers.                                    %%
%%                                                 %%
%%  Returned variables are dimensioned as          %%
%%  kilometers.                                    %%
%%                                                 %%
%%  Arguments:                                     %%
%%    lon1:    Longitude of element vertex one     %%
%%    lat1:    Latitude of element vertex one      %%
%%    z1:      Depth of element vertex one         %%
%%    lon2:    Longitude of element vertex two     %%
%%    lat2:    Latitude of element vertex two      %%
%%    z2:      Depth of element vertex two         %%
%%    lon3:    Longitude of element vertex three   %%
%%    lat3:    Latitude of element vertex three    %%
%%    z3:      Depth of element vertex three       %%
%%    slon:    station longitudes                  %%
%%    slat:    station latitudes                   %%
%%                                                 %%
%%  Returned variables:                            %%
%%    fx1:       projected x coordinate of         %%
%%               vertex one                        %%
%%    fy1:       projected y coordinate of         %%
%%               vertex one                        %%
%%    fz1:       projected z coordinate of         %%
%%               vertex one                        %%
%%    fx1:       projected x coordinate of         %%
%%               vertex two                        %%
%%    fy1:       projected y coordinate of         %%
%%               vertex two                        %%
%%    fz1:       projected z coordinate of         %%
%%               vertex two                        %%
%%    fx1:       projected x coordinate of         %%
%%               vertex three                      %%
%%    fy1:       projected y coordinate of         %%
%%               vertex three                      %%
%%    fz1:       projected z coordinate of         %%
%%               vertex three                      %%
%%    fx:        vector of projected x coordinate  %%
%%               of station locations              %%
%%    fy:        vector of projected y coordinate  %%
%%               of station locations              %%
%%    nvec:      3-component vector defining       %%
%%               element normal                    %%
%%    svec:      3-component vector defining       %%
%%               element strike                    %%
%%    dvec:      3-component vector defining       %%
%%               element dip                       %%
%%                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
R                             = 6371;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Determine strike, dip, and normal of element      %%
%%                                                    %%
%%  First convert spherical to Cartesian coordinates, %%
%%  then take a series of cross products.             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x, y, z]                     = long_lat_to_xyz([lon1 lon2 lon3], [lat1 lat2 lat3], R + [z1 z2 z3]);

% find a point lying along the spherical shell of radius = norm(v2) and on the line (v3 - v1)
v                             = [x(:) y(:) z(:)];
[v, ci]                       = sortrows([v mag(v, 2)], 4);
[v3a, v3b]                    = LineSphInt(v(3, 1:3), v(1, 1:3), [0 0 0], v(2, 4));
v3                            = [v3a; v3b];
dists                         = [norm(v(2, 1:3) - v3a); norm(v(2, 1:3) - v3b)];
[mnd, i]                      = min(dists);
[v3, j]                       = sortrows([v(2, 1:3); v3(i, :)], 1); % points sorted by x coordinate

%v                            = [v mag(v, 2)];
%[v3a, v3b]                      = LineSphInt(v(3, 1:3), v(2, 1:3), [0 0 0], v(1, 4));
%v3                           = [v3a; v3b];
%dists                           = [norm(v(1, 1:3) - v3a); norm(v(1, 1:3) - v3b)];
%[mnd, i]                        = min(dists);
%[v3, j]                      = sortrows([v(1, 1:3); v3(i, :)], 1); % points sorted by x coordinate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Incorporate element vertex information into      %%
%%  longitude, latitude, and depth (radius) vectors  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lon                           = [slon(:); lon1; lon2; lon3];
lat                           = [slat(:); lat1; lat2; lat3];

%%  M_MAP version
pole                          = cross(v3(1, :), v3(2, :));
pole                          = pole./sqrt(sum(pole.^2));
[pole_lon, pole_lat]          = xyz_to_long_lat(pole(1), pole(2), pole(3)); 
[oo_lon, oo_lat, oo_direc]    = neworigin(rad_to_deg(pole_lon), rad_to_deg(pole_lat));
m_proj('Oblique Mercator', 'lon', [oo_lon, rad_to_deg(flong2)], 'lat', [oo_lat, rad_to_deg(flat2)], 'direction', 'horizontal');
[mx, my]                      = m_ll2xy(rad_to_deg(long), rad_to_deg(lat), 'clip', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Scale to proper distances  %%
%%  This looks correct         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mx                            = mx .*R;
my                            = my .*R;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Seperate fault endpoint information from station locations  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fx1                           = mx(length(mx) - 2);
fy1                           = my(length(my) - 2);
fz1                           = z1;
fx2                           = mx(length(mx) - 1);
fy2                           = my(length(my) - 1);
fz2                           = z2;
fx3                           = mx(length(mx));
fy3                           = my(length(my));
fz3                           = z3;

fx                            = mx(1 : length(mx) - 3);
fy                            = my(1 : length(my) - 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate fault dip and azimuth  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the intersection between the line defining the strike and the vertex farthest away
[junk, far]                   = max(abs(v(:, 4) - mag(v3(1, :), 2)));
[xii, yii, zii, dii]          = pbpointline(v3(1, :), v3(2, :), v(far, 1:3));
% Convert the intersection points to long, lat.
[ilon, ilat]                  = xyz_to_long_lat([xii v(far, 1)], [yii v(far, 2)], [zii v(far, 3)]);
% calculate the dip
dip                           = asind(abs(v3(1, 3) - v(far, 3)) / dii);
% now convert back to geographic coordinates for the azimuth calculation, which is done using the mapping toolbox function
[stlon, stlat]                = xyz_to_long_lat(v3(:, 1), v3(:, 2), v3(:, 3));
faz1                          = azimuth(stlat(1), stlon(1), stlat(2), stlon(2), 'radians');
faz2                          = azimuth(stlat(2), stlon(2), stlat(1), stlon(1), 'radians');
fazs                          = [faz1; faz2];
faz                           = fazs(1); % the strike used for rotation
fazs                          = sort(fazs);
% Decide which azimuth to take, based on right hand rule.  This is only for geometry, not for partials.
cp = cross([xii, yii, zii]-v3(1, 1:3), v3(1, 1:3) - [v(far, 1:3)]);
connaz = deg2rad(azimuth(ilat(1), ilon(1), ilat(2), ilon(2))) - sign(mag([xii yii zii], 2) - v(far, 4))*pi/2;
[junk, appraz] = min(abs(fazs - wrapTo2Pi(connaz)));
azi = fazs(appraz);

%[junk, maxdev] = max(abs(cooruse));
%cooruse = cooruse(maxdev);
%if cooruse*(zii - v(far, 3)) > 0 
%   azi = fazs((fazs) > pi/2 & (fazs) <= 3*pi/2);
%else
%   azi = fazs((fazs) > 3*pi/2 | (fazs) <= pi/2);
%end

rad2deg(faz);
%faz                          = min([faz1 faz2]);
% azimuth is calculated and therefore returned in radians
