function j = nfix(i,n)
%
% NFIX rounds a number up to the nearest specifed number.
%
%  J = NFIX(I,N) rounds I towards zero to the nearest N and returns the result to J.
%
%  See also nround, nfloor, nceil.
%
j = n*fix(fix(i)/n);