function b = modpi(a, n)
% MODPI  Wraps values in radians to a given angular range.
%   B = MODPI(A, N) wraps the angles A to the range [0, 2*pi] 
%   if N = 0 (default) or [-pi, pi] if N = -1 and returns the
%   wrapped values to B.
%


if ~exist('n', 'var')
   n = 0;
end

A = a;

% Do we need to wrap?
if n == -1
   w = a < -pi | pi < a;
else
   w = a < 0 | a > 2*pi; 
end

% If wrapping to 2*pi, add 2*pi to negative values
neg = a < 0;
a(neg) = a(neg) + (n+1)*2*pi;

% Add pi if wrapping to -pi, pi
a = a - n*pi;

% Wrap
a = mod(a, 2*pi);
a((a == 0) & ~neg) = 2*pi;
a = a + n*pi;

% Full output
b = A; b(find(w)) = a(find(w));
