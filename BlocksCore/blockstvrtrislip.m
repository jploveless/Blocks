function x = blockstvrtrislip(G, D, W, Diff, lambda)
% blockstvrtrislip  Blocks estimator with TVR on triangular slip.
%   Model.omegaEst = blockstvrtrislip(Rt, dt, Wt, Command.tvrlambda)
%   returns the estimated model parameters using the modified Jacobian
%   Rt, modified data vector dt, and modified data covariance matrix 
%   Wt, as returned from AdjustMatricesTvr. Estimated triangular slip 


A = sparse((W^(1/2))*G); 
b = sparse((W^(1/2))*D);

n = size(A,2);

cvx_begin quiet
variable x(n)
minimize( norm(A*x-b,2) + (lambda)*norm(Diff*x,1) )
subject to
   x >= 0
cvx_end
