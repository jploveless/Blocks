function b = stack3(a)
% stack3   Converts an n-by-3 array to a 3n-by-1 column vector.
%   stack3(A) converts the n-by-3 array A to a 3n-by-1 column vector
%   with order [A(1, 1) A(1, 2) A(1, 3)...A(n, 1) A(n, 2) A(n, 3)]'
%
%   B = stack3(A) returns the output to vector B.
%
%   See also: unstack3, stack2, unstack2
%

b = reshape(a', 3*size(a, 1), 1);