function b = stack2(a)
% stack2   Converts an n-by-2 array to a 2n-by-1 column vector.
%   stack2(A) converts the n-by-2 array A to a 2n-by-1 column vector
%   with order [A(1, 1) A(1, 2)...A(n, 1) A(n, 2)]'
%
%   B = stack2(A) returns the output to vector B.
%
%   See also: stack3, unstack3, unstack2
%

b = reshape(a', 2*size(a, 1), 1);