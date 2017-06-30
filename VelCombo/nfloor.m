function j = nfloor(i,n)
%
% NFLOOR rounds a number down to the nearest specifed number.
%
%  J = NFLOOR(I,N) rounds I down to the nearest N and returns the result to J.
%
%  See also nround, nceil, nfix.
%
j = n*floor(fix(i)/n);