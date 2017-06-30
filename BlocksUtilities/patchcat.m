function pn = patchcat(p1, p2)
% PATCHCAT  Concatenates two patch structures.
%   PN = PATCHCAT(P1, P2) concatenates patch structures 
%   P1 and P2 and returns the combined structure to PN.
%

% Concatenate all fields
pn = structmath(p1, p2, 'vertcat');

% Adjust the vertex ordering
pn.v(sum(p1.nEl)+1:end, :) = p2.v + sum(p1.nc);