function w = MakeTriSmoothAlt(share)
%
% MakeTriSmoothAlt produces a scale-independent smoothing matrix.
%
% Inputs:
%   share		= n x 3 array of indices of the up to 3 elements sharing a side 
%					  with each of the n elements, from SideShare.m
%
% Outputs:
%   w				= n x n smoothing matrix
%

% 

n = size(share, 1);

% allocate space for the smoothing matrix
w = spalloc(3*n, 3*n, 27*n);

% make a design matrix for Laplacian construction
s = share;
s(find(share)) = 1;

% off diagonals
offdi = -ones(size(share))./repmat(sum(s, 2), 1, 3);

% place the weights into the smoothing operator
for j = 1:3;
	for i = 1:n;
		w(3*i-(3-j), 3*i-(3-j))	= 1;
		if share(i, j) ~= 0;
			k 							= 3*i - [2 1 0];
			m							= 3*share(i, j) - [2 1 0];
			p 							= sub2ind(size(w), k, m);
			w(p)						= offdi(i, j);
		end
	end
end	

