function [long, lat] = xyz_to_long_lat(x, y, z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                 %%
%%  xyz_to_long_lat.m                              %%
%%                                                 %%
%%  Convert xyz coordinates to longitude and       %%
%%  latitude on a sphere.                          %%
%%                                                 %%
%%  Results are returned in radians.               %%
%%                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Convert to longitdue and latitude  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
long                       = atan2(y, x);
lat                        = atan(z ./ sqrt(x.^2 + y.^2));