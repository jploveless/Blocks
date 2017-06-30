function j = nceil(i,n)
%
% NCEIL rounds a number up to the nearest specifed number.
%
%  J = NCEIL(I,N) rounds I up to the nearest N and returns the result to J.
%
%  See also nround, nfloor, nfix.
%
j = n*ceil(fix(i)/n);