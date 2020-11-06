function edge = FindNearestEdge(c, v, point)
%
% FindNearestEdge finds the indices of the elements along the edge of a mesh 
% that lies closest to a given point.
%
%  Inputs:
%
%		c		= array of mesh coordinates
%		v		= mesh connection matrix (only x, y are used)
%		point	= [x y] coordinates of given point
%
%  Outputs:
%
%		edge	= indices of elements along the edge nearest the point
%

% define coordinates and calculate element centroids
x1								= [c(v(:, 1), 1)];
y1								= [c(v(:, 1), 2)];
x2								= [c(v(:, 2), 1)];
y2								= [c(v(:, 2), 2)];
x3								= [c(v(:, 3), 1)];
y3								= [c(v(:, 3), 2)];
[xc,yc,zc] 					= centroid3([x1 x2 x3], [y1 y2 y3],	0);

% determine intersections
p1 							= [x1(:) y1(:); x2(:) y2(:); x3(:) y3(:)];
p2 							= [x2(:) y2(:); x3(:) y3(:); x1(:) y1(:)];
p3 							= repmat(point, size(p1, 1), 1);

edge = [];
% determine shared element indices
share 						= SideShare(v);
% determine which elements line the mesh perimeter
[perim, col]				= find(share == 0);
perim 						= unique(perim);
for i = 1:size(perim, 1); % only test perimeter elements
	p4 						= repmat([xc(perim(i)) yc(perim(i))], size(p1, 1), 1); % ...to selected element centroid
	[xi, yi] 				= pbisect(p1, p2, p3, p4);
	if sum(isnan(xi)) == numel(xi)-1; % those elements that lie on the edge have exactly one non-NaN entry in the intersection array
		edge = [edge; perim(i)];
	end
end	
