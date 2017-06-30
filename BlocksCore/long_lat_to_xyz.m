function [x, y, z] = long_lat_to_xyz(long, lat, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                 %%
%%  long_lat_to_xyz.m                              %%
%%                                                 %%
%%  Convert longitude and latitude to xyz          %%
%%  coordinates on a sphere with a radius of       %%
%%  6371 km.                                       %%
%%                                                 %%
%%  Arguments are assumed to be in radians and     %%
%%  given in east longitude.                       %%
%%                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare mean radius of earth  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 3;
	R 								  = varargin{1};
else
	R                         = 6371;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate x, y, z coordinates (on sphere) for each site  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x                         = R .* cos(lat) .* cos(long);
y                         = R .* cos(lat) .* sin(long);
z                         = R .* sin(lat);