function [xi,yi] = pbisectfull(p1,p2,p3,p4);
%
% [XI,YI] = PBISECTFULL(P1,P2,P3,P4) gives (XI,YI) coordinates of the intersection
% between lines described by the (X,Y) pairs contained in P1, P2, P3,and P4.  P1-P4
% should be of the form [x y], of size n-by-2.  The function returns NaN values for
% xi and yi if the two lines are parallel.  The outputs XI and YI are each n-by-1.
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
xi = p1(:, 1) + ua.*(p2(:, 1)-p1(:, 1));
yi = p1(:, 2) + ua.*(p2(:, 2)-p1(:, 2));

