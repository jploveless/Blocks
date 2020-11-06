function varargout = pbpointline(varargin)
%
% PBPOINTLINE finds the shortest distance between a point and a 
% line segment.
%
%    PBPOINTLINE(X1, X2, Y1, Y2, X3, Y3) finds the coordinates
%    (X, Y) of the intersection between the line segment S1 connecting 
%    points P1 = (X1, Y1) and P2 = (X2, Y2) and line segment S2 that is
%    perpendicular to S1 and contains point P3 = (X3, Y3).  The length of 
%    S2 is thus the shortest path between P3 and S1.
%
%    PBPOINTLINE(X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3) carries out the 
%    calculation given three-dimensional coordinates.
%
%    PBPOINTLINE(P1, P2, P3) accepts n-by-2 vectors of [Xi, Yi], or
%    [Xi, Yi, Zi] coordinate arrays.
%
%    D = PBPOINTLINE(...) outputs the length of S2 for either the 2- or 
%    3-dimensional case.
%
%    [X, Y] = PBPOINTLINE(...) outputs the intersection x- and y-coordinates.
%    
%    [X, Y, D] = PBPOINTLINE(...) outputs the intersection coordinates and
%    length of S2 for the 2-dimensional case.
%
%    [X, Y, Z] = PBPOINTLINE(...) outputs the intersection coordinates for
%    the 3-dimensional case.
%
%    [X, Y, Z, D] = PBPOINTLINE(...) outputs the intersection coordinates and
%    length of S2 for the 3-dimensional case.
%
%    After Paul Bourke's "Distance between a Point and a Line" 
%    http://local.wasp.uwa.edu.au/~pbourke/geometry/pointline/
%


% check input arguments
if nargin == 3 % point coordinate pairs were specified
   x1 = varargin{1}(:, 1);
   y1 = varargin{1}(:, 2);
   x2 = varargin{2}(:, 1);
   y2 = varargin{2}(:, 2);
   x3 = varargin{3}(:, 1);
   y3 = varargin{3}(:, 2);
   if size(varargin{1}, 2) == 3
      z1 = varargin{1}(:, 3);
      z2 = varargin{2}(:, 3);
      z3 = varargin{3}(:, 3);
   else
      [z1, z2, z3] = deal(zeros(size(x1)));
   end
elseif nargin == 6 % 2-dimensional coordinates are given
   x1 = varargin{1};
   y1 = varargin{2};
   x2 = varargin{3};
   y2 = varargin{4};
   x3 = varargin{5};
   y3 = varargin{6};
   [z1, z2, z3] = deal(zeros(size(x1)));
elseif nargin == 9 % 3-dimensional coordinates are given
   x1 = varargin{1};
   y1 = varargin{2};
   z1 = varargin{3};
   x2 = varargin{4};
   y2 = varargin{5};
   z2 = varargin{6};
   x3 = varargin{7};
   y3 = varargin{8};
   z3 = varargin{9};
else
   error('\nWrong number of arguments.  Specify:\n   pbpointline(P1, P2, P3),\n   pbpointline(x1, y1, x2, y2, x3, y3), or\n   pbpointline(x1, y1, z1, x2, y2, z2, x3, y3, z3.)\n', 'wrongarg');
end   

% calculate position of intersection along the P1-P2 line segment
u = ((x3 - x1).*(x2 - x1) + (y3 - y1).*(y2 - y1) + (z3 - z1).*(z2 - z1))./mag([x2 y2 z2] - [x1 y1 z1], 2).^2;

% calculate intersection coordinates
x = x1 + u.*(x2 - x1);
y = y1 + u.*(y2 - y1);
z = z1 + u.*(z2 - z1);

% calculate length of intersecting segments
d = mag([x y z] - [x3 y3 z3], 2);

% set up output arguments
if nargout == 1 % just d should be output
   varargout(1) = {d};
elseif nargout == 2 % just x, y should be output
   varargout(1) = {x};
   varargout(2) = {y};
elseif nargout == 3
   if ~sum([z1; z2; z3]) % 2-D, so (x, y, d) must have been requested
      varargout(1) = {x};
      varargout(2) = {y};
      varargout(3) = {d};
   else % 3-D, so (x, y, z) must have been requested
      varargout(1) = {x};
      varargout(2) = {y};
      varargout(3) = {z};
   end
elseif nargout == 4 % 3-D, output (x, y, z, d)
   varargout(1) = {x};
   varargout(2) = {y};
   varargout(3) = {z};
   varargout(4) = {d};
end