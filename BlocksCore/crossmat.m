function [cx, cy, cz] = crossmat(ax, ay, az, bx, by, bz)
% crossmat  Calculates the cross product of matrices of coordinates.
%   [CX, CY, CZ] = crossmat(AX, AY, AZ, BX, BY, BZ) calculates the cross 
%   product components of the 2-dimensional coordinate arrays for A and B.
%

cx = ay.*bz - az.*by;
cy = az.*bx - ax.*bz;
cz = ax.*by - ay.*bx;