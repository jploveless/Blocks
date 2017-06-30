function [xi,yi] = pbisect(p1,p2,p3,p4);
%
% [XI,YI] = PBISECT(P1,P2,P3,P4) gives (XI,YI) coordinates of the intersection
% between line segments described by the (X,Y) pairs contained in P1, P2, P3,
% and P4.  P1-P4 should be of the form [x y], of size n-by-2.  The function 
% returns NaN values for xi and yi if the two segments do not intersect.  The
% outputs XI and YI are each n-by-1.
%
% The solution is as described by Paul Bourke.
%

warning('off', 'MATLAB:DivideByZero'); % warning off, because div by zero just means parallel
ua = ((p4(:, 1)-p3(:, 1)).*(p1(:, 2)-p3(:, 2)) - (p4(:, 2)-p3(:, 2)).*(p1(:, 1)-p3(:, 1)))./ ...
     ((p4(:, 2)-p3(:, 2)).*(p2(:, 1)-p1(:, 1)) - (p4(:, 1)-p3(:, 1)).*(p2(:, 2)-p1(:, 2)));
ub = ((p2(:, 1)-p1(:, 1)).*(p1(:, 2)-p3(:, 2)) - (p2(:, 2)-p1(:, 2)).*(p1(:, 1)-p3(:, 1)))./ ...
	  ((p4(:, 2)-p3(:, 2)).*(p2(:, 1)-p1(:, 1)) - (p4(:, 1)-p3(:, 1)).*(p2(:, 2)-p1(:, 2)));
warning('on', 'MATLAB:DivideByZero');

xi = nan(size(p1, 1), 1); % assign NaNs by default
yi = xi;
is = find(ub >= 0 & ub <= 1 & ua >=0 & ua <= 1); % check for intersections
if ~isempty(is) % if there are any intersections, calculate them here.
	xi(is) = p3(is, 1) + ub(is).*(p4(is, 1)-p3(is, 1));
	yi(is) = p3(is, 2) + ub(is).*(p4(is, 2)-p3(is, 2));
end

% check to see whether or not the calculated intersection is actually an endpoint 
% (but potentially different by machine precision)
d1 = find(sum(p1 - p3, 2) == 0);
d2 = find(sum(p1 - p4, 2) == 0);
endpoints = unique([d1; d2]);
if ~isempty(endpoints)
	xi(endpoints) = p1(endpoints, 1);
	yi(endpoints) = p1(endpoints, 2);
end
d1 = find(sum(p2 - p3, 2) == 0); 
d2 = find(sum(p2 - p4, 2) == 0);
endpoints = unique([d1; d2]);
if ~isempty(endpoints)
	xi(endpoints) = p2(endpoints, 1);
	yi(endpoints) = p2(endpoints, 2);
end
