function dists = TriDistCalc(share, xc, yc, zc);
%
% TriDistCalc returns the distances between the centroids of adjacent triangular
% elements, for use in smoothing algorithms.
%
% Inputs:
%	 share			= n x 3 array output from ShareSides, containing the indices
%						  of up to 3 elements that share a side with each of the n elements.
%	 xc				= x coordinates of element centroids
%	 yc				= y coordinates of element centroids
%	 zc				= z coordinates of element centroids
%
% Outputs:
% 	 dists			= n x 3 array containing distance between each of the n elements
%						  and its 3 or fewer neighbors.  A distance of 0 does not imply
%						  collocated elements, but rather implies that there are fewer 
%						  than 3 elements that share a side with the element in that row.
%

dists												= zeros(size(share));

for i = 1:size(dists, 1);
	share(i, find(share(i, :) == 0)) 	= i;
	dists(i, :)									= sqrt((xc(i) - xc(share(i, :))).^2 + ...
															 (yc(i) - yc(share(i, :))).^2 + ...
															 (zc(i) - zc(share(i, :))).^2);
end
														 