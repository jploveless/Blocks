function [pole_lon, pole_lat] = get_pole_from_gcps(lon1, lat1, lon2, lat2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                              %%
%%  get_pole_from_gcps.m                        %%
%%                                              %%
%%  This returns the poles relative to a great  %%
%%  circle that is defined by the two lon, lat  %%
%%  arguments.  This is very useful for doing   %%
%%  oblique Mercator projections that are       %%
%%  locally tangent to some line.               %%
%%                                              %%
%%  We'll try to do this using Eric's clever    %%
%%  cross product method.                       %%
%%                                              %%
%%  Arguments should be dimensioned as          %%
%%  radians.                                    %%
%%  Returned variables are dimensioned as       %%
%%  radians.                                    %%
%%                                              %%
%%  Arguments:                                  %%
%%     lon1:  longitude of 1st GC point         %%
%%     lat1:  latitude of 1st GC point          %%
%%     lon2:  longitude of 2nd GC point         %%
%%     lat2:  latitude of 2nd GC point          %%
%%                                              %%
%%  Returned variables :                        %%
%%     pole_lon:  longitude of pole             %%
%%     pole_lat:  latitude of pole              %%
%%                                              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Transform lon, lat to xyz coordinates  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x1, y1, z1]            = long_lat_to_xyz(lon1(:), lat1(:));
[x2, y2, z2]            = long_lat_to_xyz(lon2(:), lat2(:));


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Take cross product  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
vec3                    = cross([x1, y1, z1], [x2, y2, z2]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Normalize new vector  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vec3                    = vec3 ./ repmat(sqrt(sum(vec3.^2, 2)), 1, 3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Tranform xyz to lon, lat coordinates  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pole_lon, pole_lat]    = xyz_to_long_lat(vec3(:, 1), vec3(:, 2), vec3(:, 3));
