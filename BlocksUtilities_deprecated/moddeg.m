function b = moddeg(a, n)
% MODDEG  Wraps values in degrees to a given angular range.
%   B = MODPI(A, N) wraps the angles A to the range [0, 360] 
%   if N = 0 (default) or [-180, 180] if N = -1 and returns the
%   wrapped values to B.
%

if ~exist('n', 'var')
   n = 0;
end

A = a;

% Do we need to wrap?
if n == -1
   w = a < -180 | 180 < a;
else
   w = a < 0 | a > 360; 
end

% If wrap180ng to 360, add 360 to negative values
neg = a < 0;
a(neg) = a(neg) + (n+1)*360;

% Add 180 if wrap180ng to -180, 180
a = a - n*180;

% Wrap
a = mod(a, 360);
a((a == 0) & ~neg) = 360;
a = a + n*180;

% Full output
b = A; b(find(w)) = a(find(w));
