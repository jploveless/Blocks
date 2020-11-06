function locked = CoupledEls(p, s, thresh)
%
% COUPLEDELS identifies the most coupled elements in a mesh.
%  LOCKED = COUPLEDELS(P, S, THRESH) finds the indices of the elements defined
%  by the full patch structure P whose slip values, contained in S (as
%  loaded using PATCHDATA), are in the top THRESH percent of slips 
%  throughout that mesh.  The indices of these elements are returned to LOCKED,
%  which is a n-element cell array of vectors, where n is NUMEL(P.nEl), i.e.,
%  a vector containing the indices for each mesh contained in P.
%  

% Calculate slip magnitude
smag = sign(s(:, 2)).*mag(s(:, 1:2), 2);

% Loop through each unique entity
cnel = cumsum([0 p.nEl]);

for i = 1:numel(p.nEl)
   % Extract the slip magnitudes on this mesh
   mags = smag(cnel(i)+1:cnel(i+1));
   locked{i} = cnel(i) + find(mags >= (100-thresh)/100*max(mags));
end