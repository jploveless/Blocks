function p = PatchCoords(p);
% 
% PatchCoords.m
%
% This function creates new arrays of longitude, latitude, and depth
% coordinates for each of the 3 vertices of each triangular element.
%
% Arguments:
%  p       : a structure containing p.c and p.v, as 
%                  extracted by Readp.m (and adjusted by 
%                  PatchEndAdjust.m)
%
% Returned variables:
%      p   : an updated structure containing:
%          .lon1 : longitude of all first vertices
%          .lat1 : latitude of all first vertices
%          .x1   : Geocentric x coordinate of all first vertices
%          .y1   : Geocentric y coordinate of all first vertices
%          .z1   : depth of all first vertices
%          .lon2 : longitude of all second vertices
%          .lat2 : latitude of all second vertices
%          .x2   : Geocentric x coordinate of all second vertices
%          .y2   : Geocentric y coordinate of all second vertices
%          .z2   : depth of all second vertices
%          .lon3 : longitude of all third vertices
%          .lat3 : latitude of all third vertices
%          .x3   : Geocentric x coordinate of all third vertices
%          .y3   : Geocentric y coordinate of all third vertices
%          .z3   : depth of all third vertices
%          .lonc : longitude of element centroid
%          .latc : latitude of element centroid
%          .zc   : depth of element centroid
%

p.lon1                    = p.c(p.v(:, 1), 1);
p.lat1                    = p.c(p.v(:, 1), 2);
p.z1                      = p.c(p.v(:, 1), 3);
p.lon2                    = p.c(p.v(:, 2), 1);
p.lat2                    = p.c(p.v(:, 2), 2);
p.z2                      = p.c(p.v(:, 2), 3);
p.lon3                    = p.c(p.v(:, 3), 1);
p.lat3                    = p.c(p.v(:, 3), 2);
p.z3                      = p.c(p.v(:, 3), 3);
[p.lonc, p.latc, p.zc]    = centroid3([p.lon1 p.lon2 p.lon3],...
                                      [p.lat1 p.lat2 p.lat3],...
                                      [p.z1 p.z2 p.z3]);
[p.x1, p.y1, dep]         = long_lat_to_xyz(deg_to_rad(p.lon1), deg_to_rad(p.lat1));
[p.x2, p.y2, dep]         = long_lat_to_xyz(deg_to_rad(p.lon2), deg_to_rad(p.lat2));
[p.x3, p.y3, dep]         = long_lat_to_xyz(deg_to_rad(p.lon3), deg_to_rad(p.lat3));
[p.xc, p.yc]              = centroid3([p.x1 p.x2 p.x3],...
                                      [p.y1 p.y2 p.y3],...
                                      [p.z1 p.z2 p.z3]);
z1r                       = 1+p.z1./6371;
z2r                       = 1+p.z2./6371;
z3r                       = 1+p.z3./6371;
p.nv                        = cross([deg2rad(p.lon2-p.lon1), deg2rad(p.lat2-p.lat1), z2r-z1r], [deg2rad(p.lon3-p.lon1), deg2rad(p.lat3-p.lat1), z3r-z1r], 2);
% Enforce clockwise circulation
p.nv(p.nv(:, 3) < 0, :)   = -p.nv(p.nv(:, 3) < 0, :);
[s, d]                    = cart2sph(p.nv(:, 1), p.nv(:, 2), p.nv(:, 3));
p.strike                  = wrapTo360(-rad2deg(s));
p.dip                     = 90 - rad2deg(d);
p.tz                      = zeros(size(p.dip));
p.tz(abs(p.dip - 90) > 1) = 2;
p.tz(p.tz == 0)           = 3;