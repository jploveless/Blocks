function [mm,varargout] = minmax(array)
%
% MINMAX returns the minimum and maximum of an input array.
%
%  MM = MINMAX(ARRAY) returns the minimum and maximum of ARRAY to a 2-element 
%  vector MM.
% 
%  [MM,ML] = MINMAX(ARRAY) also returns the location of the minimum and maximum
%  values of ARRAY to the 2 x 1 or 2 x 2 array ML.  The first row gives the index
%  of the minimum value and the second row gives the index to the maximum.
%

[mn, i] = min(array(:));
[mx, j] = max(array(:));

mm = full([mn mx]);
if nargout == 2;
	varargout(1) = {[i j]};
end