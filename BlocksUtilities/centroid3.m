function [cx, cy, cz] = centroid3(x, y, z, varargin)
%
% [cx, cy, cz] = centroid3(x, y, z)
%
% Function centroid3 calculates the three-dimensional centroid (center of
% mass) coordinates of an n-sided polygon given the x,y,z coordinates of
% its vertices, assuming equal masses located at each vertex.  x, y, and z
% can either be 1 x n or k x n arrays of coordinates.
%
% [cx, cy, cz] = centroid3(x, y, z, m)
%
% Function centroid3 calculates the centroid coordinates as above, but
% considering different masses at each vertex.  m should be the same
% size as x, y, and z.
%
if nargin == 4;
    m = varargin{:};
else
    m = ones(size(x));
end

cc = [sum(m.*x, 2) sum(m.*y, 2) sum(m.*z, 2)]./repmat(sum(m, 2), 1, 3);
cx = cc(:, 1); cy = cc(:, 2); cz = cc(:, 3);