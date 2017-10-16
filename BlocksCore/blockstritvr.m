function [ssSlip, dsSlip] = tvrslip(G, D, W, Patches, lambda)
%G, calculated using GetTriCombinedPartials
%D, Data vector, the values from Tri.sta
%W, Weighting matrix, from the uncertainties in Tri.sta
%Patches, the set of TDE's, read in using ReadPatches
%lambda, controls the clustering of the slips on triangles


A = sparse((W^(1/2))*G); 
b = sparse((W^(1/2))*D);

Diff = MakeDiffMatrix_mesh2d(Patches);

n = size(A,2);

cvx_begin quiet
variable x(n)
minimize( norm(A*x-b,2) + (lambda)*norm(Diff*x,1) )
subject to 
x(2:2:end) >= 0;
cvx_end

ssSlip = x(1:2:end);
dsSlip = x(2:2:end);