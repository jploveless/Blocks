function crossidx = meshcrossingg(p)
% MESHCROSSING  Checks to see if mesh elements intersect.
%   MESHCROSSING(p) uses the mesh(es) described by Cartesian
%   coordinates in mesh structure p to find whether any 
%   elements intersect each other. 
%
%   crossidx = MESHCROSSING(p) returns the indices of
%   the crossing elements to crossidx. 
%
%   Based on Paul Bourke's algorithm: 
%   http://paulbourke.net/geometry/polygonmesh/
%

% Equations of elements' planes

A = p.y1.*(p.z2 - p.z3) + p.y2.*(p.z3 - p.z1) + p.y3.*(p.z1 - p.z2); 
B = p.z1.*(p.x2 - p.x3) + p.z2.*(p.x3 - p.x1) + p.z3.*(p.x1 - p.x2);
C = p.x1.*(p.y2 - p.y3) + p.x2.*(p.y3 - p.y1) + p.x3.*(p.y1 - p.y2);
D = -(p.x1.*(p.y2.*p.z3 - p.y3.*p.z2) + p.x2.*(p.y3.*p.z1 - p.y1.*p.z3) + p.x3.*(p.y1.*p.z2 - p.y2.*p.z1));

% Check intersections
share = SideShare(p.v); % Determine shared edge array
crossidx = zeros(size(p.v)); % Blank array, with one space for every edge
% Make expanded vector arrays; easier for treating in a loop around each edge
xv = [p.x1 p.x2 p.x3 p.x1];
yv = [p.y1 p.y2 p.y3 p.y1];
zv = [p.z1 p.z2 p.z3 p.z1];

for i = 1:size(p.v, 1) % For each element,
   for j = 1:3 % For each edge,
      % Check the intersection
      mu = -(D + A.*xv(i, j) + B.*yv(i, j) + C.*zv(i, j))./(A.*(xv(i, j+1) - xv(i, j)) + B.*(yv(i, j+1) - yv(i, j)) + C.*(zv(i, j+1) - zv(i, j)));
      mutest = find(mu > 0 & mu < 1); % Between zero and 1 means the current edge intersects a plane
      % Calculate actual intersection points
      px = xv(i, j) + mu.*(xv(i, j+1) - xv(i, j));
      py = yv(i, j) + mu.*(yv(i, j+1) - yv(i, j));
      pz = zv(i, j) + mu.*(zv(i, j+1) - zv(i, j));
      % Vectors from intersection points to triangle vertices
      pa1 = ([p.x1 p.y1 p.z1] - [px py pz])./mag([p.x1 p.y1 p.z1] - [px py pz], 2);
      pa2 = ([p.x2 p.y2 p.z2] - [px py pz])./mag([p.x2 p.y2 p.z2] - [px py pz], 2);
      pa3 = ([p.x3 p.y3 p.z3] - [px py pz])./mag([p.x3 p.y3 p.z3] - [px py pz], 2);
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
    