function Patches = PatchCoordsx(Patches);
% 
% PatchCoords.m
%
% This function creates new arrays of longitude, latitude, and depth
% coordinates for each of the 3 vertices of each triangular element.
%
% Arguments:
%  Patches       : a structure containing Patches.c and Patches.v, as 
%                  extracted by ReadPatches.m (and adjusted by 
%                  PatchEndAdjust.m)
%
% Returned variables:
%      Patches   : an updated structure containing:
%          .x1   : Geocentric x coordinate of all first vertices
%          .y1   : Geocentric y coordinate of all first vertices
%          .z1   : depth of all first vertices
%          .x2   : Geocentric x coordinate of all second vertices
%          .y2   : Geocentric y coordinate of all second vertices
%          .z2   : depth of all second vertices
%          .x3   : Geocentric x coordinate of all third vertices
%          .y3   : Geocentric y coordinate of all third vertices
%          .z3   : depth of all third vertices
%          .zc   : depth of element centroid
%

Patches.z1 = [];
Patches.z2 = [];
Patches.z3 = [];
Patches.zc = [];
Patches.x1 = [];
Patches.y1 = [];
Patches.x2 = [];
Patches.y2 = [];
Patches.x3 = [];
Patches.y3 = [];
Patches.xc = [];
Patches.yc = [];

Patches.x1 = [Patches.x1; Patches.c(Patches.v(:, 1), 1)];
Patches.y1 = [Patches.y1; Patches.c(Patches.v(:, 1), 2)];
Patches.z1 = [Patches.z1  ; Patches.c(Patches.v(:, 1), 3)];
Patches.x2 = [Patches.x2; Patches.c(Patches.v(:, 2), 1)];
Patches.y2 = [Patches.y2; Patches.c(Patches.v(:, 2), 2)];
Patches.z2 = [Patches.z2  ; Patches.c(Patches.v(:, 2), 3)];
Patches.x3 = [Patches.x3; Patches.c(Patches.v(:, 3), 1)];
Patches.y3 = [Patches.y3; Patches.c(Patches.v(:, 3), 2)];
Patches.z3 = [Patches.z3  ; Patches.c(Patches.v(:, 3), 3)];
[cx,cy,cz] = centroid3([Patches.x1 Patches.x2 Patches.x3],...
                          [Patches.y1 Patches.y2 Patches.y3],...
                          [Patches.z1 Patches.z2 Patches.z3]);
Patches.xc = [Patches.xc; cx];
Patches.yc = [Patches.yc; cy];
Patches.zc = [Patches.zc; cz];

[Patches.strike, Patches.dip, Patches.nv] = tristrikedip(Patches.c, Patches.v);
Patches.up = ones(size(Patches.nEl));
