function x = blockstvrtrislip(G, D, W, Diff, Command, Index)
% blockstvrtrislip  Blocks estimator with TVR on triangular slip.
%   Model.omegaEst = blockstvrtrislip(Rt, dt, Wt, Command.tvrlambda)
%   returns the estimated model parameters using the modified Jacobian
%   Rt, modified data vector dt, and modified data covariance matrix 
%   Wt, as returned from AdjustMatricesTvr. Estimated triangular slip
%   is subjected to TVR, while no such regularization is applied to 
%   block motions. 

A = sparse((W^(1/2))*G); 
b = sparse((W^(1/2))*D);

n = size(A,2);


spos = false(n, 1);
sneg = spos;
dpos = spos;
dneg = spos;

if isfield(Command, 'trislipsign')
   for i = 1:size(Command.trislipsign, 1)
      if Command.trislipsign(i, 1) == 1
         spos(Index.cols{1, 2}(1:2:end)) = true;
      elseif Command.trislipsign(i, 1) == -1   
         sneg(Index.cols{1, 2}(1:2:end)) = true;
      end
      if Command.trislipsign(i, 2) == 1
         dpos(Index.cols{1, 2}(2:2:end)) = true;
      elseif Command.trislipsign(i, 2) == -1   
         dneg(Index.cols{1, 2}(2:2:end)) = true;
      end
   end
end

cvx_begin quiet
variable x(n)
minimize( norm(A*x-b,2) + (Command.tvrlambda)*norm(Diff*x,1) )
subject to 
    % Sign constraints
    x(dpos) >= 0;
    x(dneg) <= 0;
    x(spos) >= 0;
    x(sneg) <= 0;
cvx_end
