function w = MakeTriSmoothAll(share)
%
% MakeTriSmoothAll produces a scale-independent smoothing matrix.
%
% This version smooths all slip components simultaneously as opposed to
% independently, with hopes of a smoother coupling distribution.
%
% Inputs:
%   share		= n x 3 array of indices of the up to 3 elements sharing a side 
%					  with each of the n elements, from SideShare.m
%
% Outputs:
%   w				= n x 3n smoothing matrix
%

% 

n = size(share, 1);

% allocate space for the smoothing matrix
w = zeros(n, 3*n);

% make a design matrix for Laplacian construction
s = share;
s(find(share)) = 1;

% off diagonals
offdi = -ones(size(share))./repmat(sum(s, 2), 1, 3);

% place the weights into the smoothing operator
for i = 1:n
	w(i, 3*i-[2 1 0])          = 1;
 	for j = 1:3
	   if share(i, j) ~= 0;
			m							= 3*share(i, j) - [2 1 0];
			w(i, m)					= offdi(i, j);
		end
	end
end