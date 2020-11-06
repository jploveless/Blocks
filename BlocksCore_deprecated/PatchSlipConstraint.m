function varargout = PatchSlipConstraint(dslip, s, p, c)
%
% PatchSlipConstraint creates a matrix to be used for imposing constraints on the sign and 
% magnitude of slip resolved on triangular elements.  These constraints are based on the
% kinematic consistency enforced by the block model.  That is, the direction and magnitude
% of slip on the triangular patch boundaries of blocks must be kinematically consistent 
% with the block motion.  
%
% Inputs:
%  dslip    = full matrix of slip partial derivatives (before running ZeroSlipPartials.m)
%  s        = structure containing segment data (centroids already calculated using SegCentroid.m)
%  p        = structure containing patch data (centroids already calculated using PatchCoords.m)
%  c        = command structure
%
% Outputs:
%  w        = weighting matrix that, when augmented to the Jacobian, with an augmented
%             data vector containing all zeros, will force triangular slip magnitudes
%             to be equal to the equivalent slip on the rectangular segment.  OR
%  [ws, wt] = weighting matrices corresponding to the segment part (ws) and triangular (wt)
%

[ws, wt]             = deal(zeros(0, size(dslip, 2)), zeros(0, p.nEl));


if c.triKinCons == 1
   % associate each element with a segment, based on distance between centroids

   % first find which segments have been replaced by a patch
   replSeg           = intersect(find(s.patchFile), find(s.patchTog));
   [xt, xs]          = meshgrid(p.xc, s.centx(replSeg)); % size of these arrays is nSeg-by-nEl
   [yt, ys]          = meshgrid(p.yc, s.centy(replSeg));
   [zt, zs]          = meshgrid(p.zc, s.centz(replSeg));
   cdists            = sqrt((xt-xs).^2 + (yt-ys).^2 + (zt-zs).^2);
   [mdist, mind]     = min(cdists, [], 1); % find the minimum row for each column
   mind              = replSeg(mind); % find the actual index of the segment

   % make the appropriate constraint matrix
   wt                = -eye(3*size(p.xc, 1)); % right half of the matrix, corresponding to tri. slips, is -I
   tripmind          = [3*mind(:) - 2, 3*mind(:) - 1, 3*mind(:)]';
   ws                = dslip(tripmind(:), :);
end

if nargout == 1;
   w              = [ws wt];
   varargout      = w;
else
   varargout{1}   = ws;
   varargout{2}   = wt;
end