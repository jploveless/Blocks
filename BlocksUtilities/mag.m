function m = mag(x,varargin);
%
% MAG calculates the magnitude of a vector.
%
% M = MAG(X) determines the magnitude of the vector X.  X is one
% dimensional, either a row or column vector.
% 
% M = MAG(X,DIM) determines the magnitude along the dimension DIM.
% To calculate the magnitude of the vectors whose components are
% contained in the columns of X, prescribe DIM = 2.  To calculate
% the magnitude of the vectors whose components are in the rows of 
% X, DIM = 1.
%

if nargin == 2;
	dim = varargin{1};
else
	dim = 1;
end

m = sqrt(sum(x.^2,dim));