function s = SineSlip(x, y, cx, cy, a, t, b)
%
% SINESLIP generates a 2-d sinusoidal slip distribution.
%
%   S = SINESLIP(X, Y, CX, CY, A, T, B) generates a 2-d sinusoidal slip
%   distribution of the form:
%
%      S = A*SIN(R/T)./R + B, where
%      R = SQRT((X - CX).^2 + (Y - CY).^2).
%
%   X and Y should be n-by-1 vectors containing the locations at which
%   S should be calculated, CX and CY are the center coordinates (where
%   S reaches its maximum value), A should be that value (i.e., the 
%   amplitude of the sinusoid), T should be the frequency (cycles/, and B should be
%   a static offset of S.  B can either be a numeric value or, if specified
%   as '+mean', the mean value of S will be added to all S values, while 
%   B = '-mean' indicates that the mean value should be subtracted.
%

% calculate radii
r = sqrt((x - cx).^2 + (y - cy).^2);

% calculate slip
s = t*a*sin(r/t)./r;

if ischar(b)
   if strmatch(b, '-mean');
      s = s - mean(s);
   elseif strmatch(b, '+mean');
      s = s + mean(s);
   end
else
   s = s + b;
end