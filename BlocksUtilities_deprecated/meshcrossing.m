function crossidx = meshcrossing(c, v)
% MESHCROSSING  Checks to see if mesh elements intersect.
%   MESHCROSSING(c, v) uses the mesh(es) described by 
%   coordinate array c (assuming Cartesian coordiantes) and 
%   vertex connection array v in order to check whether any 
%   elements intersect each other. 
%
%   crossidx = MESHCROSSING(c, v) returns the indices of
%   the crossing elements to crossidx. 
%
%   Based on Paul Bourke's algorithm: 
%   http://paulbourke.net/geometry/polygonmesh/
%

% Equations of elements' planes
x1 = c(v(:, 1), 1);
x2 = c(v(:, 2), 1);
x3 = c(v(:, 3), 1);
y1 = c(v(:, 1), 2);
y2 = c(v(:, 2), 2);
y3 = c(v(:, 3), 2);
z1 = c(v(:, 1), 3);
z2 = c(v(:, 2), 3);
z3 = c(v(:, 3), 3);
A = y1.*(z2 - z3) + y2.*(z3 - z1) + y3.*(z1 - z2); 
B = z1.*(x2 - x3) + z2.*(x3 - x1) + z3.*(x1 - x2);
C = x1.*(y2 - y3) + x2.*(y3 - y1) + x3.*(y1 - y2);
D = -(x1.*(y2.*z3 - y3.*z2) + x2.*(y3.*z1 - y1.*z3) + x3.*(y1.*z2 - y2.*z1));

% Check intersections
share = SideShare(v); % Determine shared edge array
crossidx = zeros(size(v)); % Blank array, with one space for every edge
vv = [v v(:, 1)]; % Replicate first column; easier for looping through
for i = 1:size(v, 1) % For each element,
   for j = 1:3 % For each edge,
      % Check the intersection
      mu = -(D + A.*c(vv(i, j), 1) + B.*c(vv(i, j), 2) + C.*c(vv(i, j), 3))./(A.*(c(vv(i, j+1), 1) - c(vv(i, j), 1)) + B.*(c(vv(i, j+1), 2) - c(vv(i, j), 2)) + C.*(c(vv(i, j+1), 3) - c(vv(i, j), 3)));
      mutest = find(mu > 0 & mu < 1); % Between zero and 1 means the current edge intersects a plane
      % Calculate actual intersection points
      px = c(vv(i, j), 1) + mu.*(c(vv(i, j+1), 1) - c(vv(i, j), 1));
      py = c(vv(i, j), 2) + mu.*(c(vv(i, j+1), 2) - c(vv(i, j), 2));
      pz = c(vv(i, j), 3) + mu.*(c(vv(i, j+1), 3) - c(vv(i, j), 3));
      % Vectors from intersection points to triangle vertices
      pa1 = ([x1 y1 z1] - [px py pz])./mag([x1 y1 z1] - [px py pz], 2);
      pa2 = ([x2 y2 z2] - [px py pz])./mag([x2 y2 z2] - [px py pz], 2);
      pa3 = ([x3 y3 z3] - [px py pz])./mag([x3 y3 z3] - [px py pz], 2);
      ang1 = acos(dot(pa1, pa2, 2)); % Angle 1P2
      ang2 = acos(dot(pa2, pa3, 2)); % Angle 2P3
      ang3 = acos(dot(pa3, pa1, 2)); % Angle 3P1
      sang = sum(abs([ang1, ang2, ang3]), 2); % Sum of angles
      % Only if sum of angles == 2pi does the intersection point lie within the triangle
      mutest = mutest(abs(2*pi - sang(mutest)) < 0.01);
      if ~isempty(mutest)
         if ~ismember(mutest(1), share(i, :)) && mutest(1) ~= i % Check to see that the element isn't a neighbor or itself
            crossidx(i, j) = mutest(1);
         end
      end
   end
end
    