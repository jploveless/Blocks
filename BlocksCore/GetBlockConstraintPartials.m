function G = GetBlockConstraintPartials(b)
% Partials for a priori block motion constraints; essentially a set of eye(3) matrices

nb = numel(b.interiorLon);
ap = find(b.aprioriTog);
G = zeros(3*numel(ap), 3*nb);
sg = size(G);
for i = 1:numel(ap)
   G(3*(i-1) + (1:3), 3*(ap(i)-1) + (1:3)) = eye(3);
end
