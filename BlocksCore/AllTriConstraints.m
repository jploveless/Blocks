function [partials, data, sig, index]    = AllTriConstraints(p, c, partials, data, sig, index)
%
% SmoothEdges creates the smoothing matrix allowing the mesh edges
% that are adjacent to rectangular patches to be smoothed, as well 
% as the elements wholly within the mesh.
%
%  Inputs:
%
%     p           = patch structure
%     c           = command structure
%     partials    = partials structure
%     data        = data structure
%     sig         = weights structure
%     index       = index structure
%
%  Outputs:
%
%     partials    = updated partials structure
%     data        = updated data structure
%     sig         = updated weights structure
%     index       = updated index structure

% Cumulative element and coordinate indices
elOrd                                           = [0; cumsum(p.nEl)];
coOrd                                           = [0; cumsum(p.nc)];

% make the Laplacian smoothing matrix
index.share                                     = SideShare(p.v); % For each element, give indices of N <= 3 elements that share sides
dists                                           = TriDistCalc(index.share, p.xc, p.yc, p.zc); % calculate distance between element centroids and neighbors
partials.smooth                                 = MakeTriSmooth(index.share, dists);
% partials.smooth                                 = MakeTriSmoothAlt(share);
index.triSmoothkeep                             = index.triColkeep;

% Weight the smoothing matrix by the constant beta, normalized by the square of the average distance between each element's centroid and those of its neighbors
data.smooth                                     = zeros(3*elOrd(end), 1); 
for i = 1:numel(p.nEl)
   sig.smooth(3*(elOrd(i)+1)-2:3*elOrd(i+1))    = c.triSmooth(i);
end

% for i = 1:numel(p.nEl)
%    dist                                         = dists(elOrd(i)+1:elOrd(i+1), :);
%    distScale                                    = repmat((sum(dist, 2)./sum(dist ~= 0, 2))', 3, 1);
%    sig.smooth(3*(elOrd(i)+1)-2:3*elOrd(i+1))    = distScale(:)*c.triSmooth(i);
% end

% Optionally weight beta by magnitude of partial derivatives
if c.pmagTriSmooth > 0
   stpd                                         = sqrt(partials.tri(1:3:end, :).^2 + partials.tri(2:3:end, :).^2 + partials.tri(3:3:end, :).^2); % Station magnitudes from components
   stpd                                         = sum(stpd); % Sum of station magnitudes
   sig.smooth                                   = sig.smooth(:)./(stpd(:).^c.pmagTriSmooth); % Larger sums    = better resolved    = less reliance on smoothing
end

% Slip estimation constraints, with several options.  Each patch should have three values specified:
% [updip downdip lateral] edge lining elements, each of of which can be:
% 0: No constraint
% 1: Constrain to creep (estimated slip is zero)
% 2: Constrain to be fully locked (estimated slip is set to equal the projected relative block motion rates)
%
   
% See if a depth c.triDepthTolerance exists.  Right now it must be the same for all meshes.
if numel(c.triDepthTol) == 1
   c.triDepthTol                               = c.triDepthTol*[1 1];
end

% Determine which constraints apply to which patches
nPatches                                       = numel(p.nEl);
nCons                                          = numel(c.triEdge);
if nCons == 3
   c.triEdge                                   = repmat(c.triEdge, 1, nPatches); % replicate options for all patches;
elseif nCons == 3*nPatches
   c.triEdge                                   = c.triEdge;
else   
   error('Blocks:NtriZero', 'Invalid number of triangle edge constraints.')
end

% Initialize arrays.  Blank because we don't know how many elements line the edges.

% Element index arrays
updips                                         = [];
downdips                                       = [];
latedges                                       = [];

% Constraint type arrays
updipsc                                        = [];
downdipsc                                      = [];
latedgesc                                      = [];

% Loop through each patch separately
for i    = 1:numel(p.nEl);
   elRange                                     = elOrd(i)+1:elOrd(i+1);
   coRange                                     = coOrd(i)+1:coOrd(i+1);
   
   if c.triEdge(3*i-2) > 0
      % Find the zero depth coordinates
%     zeroTest                                 = abs(p.c(coRange, 3) - max(p.c(coRange, 3))) <= c.triDepthTol(1);
%     zeroZ                                    = coOrd(i) + find(zeroTest);
      % find those elements having two zero-depth coordinates
     edgeels                                  = edgeelements(p.c, p.v(elRange, :));
     updip                                    = elOrd(i) + find(edgeels.top);
%      updip                                    = elOrd(i) + find(sum(ismember(p.v(elRange, :), zeroZ), 2) == 2);
      updips                                   = [updips; updip];
      updipsc                                  = [updipsc; c.triEdge(3*i-2)*ones(size(updip))];
   end
  
   if c.triEdge(3*i-1) > 0
      % Find the deepest coordinates
%     maxTest                                  = abs(p.c(coRange, 3) - min(p.c(coRange, 3))) <= c.triDepthTol(2);
%     maxZ                                     = coOrd(i) + find(maxTest);
      % Find those elements having two max. depth coordinates
     edgeels                                  = edgeelements(p.c, p.v(elRange, :));  
     downdip                                  = elOrd(i) + find(edgeels.bot);  
%      downdip                                  = elOrd(i) + find(sum(ismember(p.v(elRange, :), maxZ), 2) == 2);
      downdips                                 = [downdips; downdip];
      downdipsc                                = [downdipsc; c.triEdge(3*i-1)*ones(size(downdip))];
   end
  
   if c.triEdge(3*i-0) > 0
%
%      % Find all edge coordinates
%      edge                                     = OrderedEdges(p.c, p.v(elRange, :));
%      % find all edge elements
%      edgeEls                                  = elOrd(i) + find(sum(ismember(p.v(elRange, :), edge), 2) == 2);
%      % separate out those that aren't on the up- or downdip extent
%      zeroTest                                 = abs(p.c(coRange, 3) - max(p.c(coRange, 3))) <= c.triDepthTol(1);
%      zeroZ                                    = coOrd(i) + find(zeroTest);
%      % find those elements having two zero-depth coordinates
%      updip                                    = elOrd(i) + find(sum(ismember(p.v(elRange, :), zeroZ), 2) == 2);
%     
%      % find the deepest coordinates
%      maxTest                                  = abs(p.c(coRange, 3) - min(p.c(coRange, 3))) <= c.triDepthTol(2);
%      maxZ                                     = coOrd(i) + find(maxTest);
%      % find those elements having two max. depth coordinates
%      downdip                                  = elOrd(i) + find(sum(ismember(p.v(elRange, :), maxZ), 2) == 2);

     edgeels                                  = edgeelements(p.c, p.v(elRange, :));
     latedge                                  = elOrd(i) + find(edgeels.s1+edgeels.s2);
%      latedge                                  = setdiff(edgeEls, [updip(:); downdip(:)]);
      latedges                                 = [latedges; latedge];
      latedgesc                                = [latedgesc; c.triEdge(3*i-0)*ones(size(latedge))];
   end
end

% Read in any files containing arrays of a priori coupling fractions
if c.triSlipConstraintType == 1 % Slip values are specified
   triapcons                                   = ReadTriSlipFiles(c.slipFileNames, p);
   triapidx                                    = triapcons(:, 1);
   triapmag                                    = triapcons(:, 2:end);
   napt                                        = size(triapidx, 1);
elseif c.triSlipConstraintType == 2 % Coupling fraction is specified
   triapcons                                   = ReadTriSlipFiles(c.slipFileNames, p);
   triapidx                                    = triapcons(:, 1);
   triapmag                                    = triapcons(:, 2);
elseif c.triSlipConstraintType == 3 % slip rake is specified
   triapcons                                   = ReadTriSlipFiles(c.slipFileNames, p);
   triapidx                                    = triapcons(:, 1);
   triapmag                                    = triapcons(:, 2);
else
   [triapidx, triapmag]                        = deal([]);
end

% Indices of all constrained elements
idx                                            = [updips; downdips; latedges; triapidx];
con                                            = [updipsc; downdipsc; latedgesc; c.triSlipConstraintType*ones(length(triapidx), 1)];
partials.triSlipCon                            = zeros(3*length(idx), 3*elOrd(end));
for i = 1:length(idx)
   partials.triSlipCon(3*i-2, 3*idx(i)-2)      = 1;
   partials.triSlipCon(3*i-1, 3*idx(i)-1)      = 1;
   partials.triSlipCon(3*i-0, 3*idx(i)-0)      = 1;
end

% Make an adjacent matrix for estimating the block rotation rates.
% For rows corresponding to creeping elements, this matrix contains all zeros.
% For rows corresponding to fully coupled elements, this matrix contains the triangular slip partials
% For rows corresponding to partially coupled elements, this matrix contains the scaled triangular slip partials
% (Values are negative so that they cancel the estimated slip when set to zero).
partials.triBlockCon                           = zeros(3*length(idx), size(partials.rotation, 2));
lidx                                           = find(con == 2); % Indices of locked elements
coupmagall                                     = ones(size(lidx));
if c.triSlipConstraintType == 2
   coupmagall(end-length(triapidx)+1:end)      = triapmag;
end

for i = 1:length(lidx)
   partials.triBlockCon(3*lidx(i)-2, :)        = -coupmagall(i).*partials.trislip(3*idx(lidx(i))-2, :);
   partials.triBlockCon(3*lidx(i)-1, :)        = -coupmagall(i).*partials.trislip(3*idx(lidx(i))-1, :);
   partials.triBlockCon(3*lidx(i)-0, :)        = -coupmagall(i).*partials.trislip(3*idx(lidx(i))-0, :);
end
% Set up data vector as all zeros
data.triSlipCon                                = zeros(3*length(idx), 1);
% If a priori slip rates are specified, place those rates in the data vector
if c.triSlipConstraintType == 1
   % Place dip vs. tensile constraints in the correct column
   apnan                                       = true(napt, 3);
   apnan(1:napt, 1)                            = ~isnan(triapmag(:, 1));
   apnan((p.tz(triapidx)-1).*napt+(1:napt)')   = ~isnan(triapmag(:, 2));
   apnan                                       = stack3(apnan);
   apmag                                       = [triapmag(:, 1) zeros(size(triapmag, 1), 2)];
   apmag((p.tz(triapidx)-1).*napt+(1:napt)')   = triapmag(:, 2); 
   data.triSlipCon(end-3*napt+1:end)           = stack3(apmag);
end
%keyboard
% Applying slip rake constraints
 rakeIdx = con == 3;
if c.triSlipConstraintType == 3
    rakeTriCon                                 = partials.triSlipCon(end-3*length(triapidx)+1:end,:);
    rakeTriCon                                 = rakeTriCon(1:3:end,:).*sind(triapmag) + rakeTriCon(2:3:end,:).*cosd(triapmag);
    partials.triSlipCon(end-3*length(triapidx)+1:end,:) = [];
    partials.triSlipCon                        = [partials.triSlipCon; rakeTriCon];
    data.triSlipCon                            = data.triSlipCon(1:end-2*length(triapidx));  
%%%%%     % need to modify the triblockcon portions too
end
% Set up weighting for slip rate constraints
sig.triSlipCon                                 = c.triConWgt*ones(size(data.triSlipCon));
index.triConkeep                               = sort([3*idx(~rakeIdx)-2; 3*idx(~rakeIdx)-1; 3*idx(~rakeIdx)]);
[~, keep]                                      = ismember(index.triColkeep, index.triConkeep);
index.triConkeep                               = keep(keep > 0);
% keyboard
% Eliminate extra row entries related to slip rake constraints
if c.triSlipConstraintType == 3
   index.triConkeep = [index.triConkeep find(rakeIdx,1,'first')*3-2:length(data.triSlipCon)]; 
    %index.triConkeep = [index.triConkeep length(data.triSlipCon)-(sum(rakeIdx)-1:-1:0)]; 
end

% Eliminate any NaN a priori slip constraints
if c.triSlipConstraintType == 1
   [~, apnan]                                  = ismember(index.triConkeep, find(isnan(data.triSlipCon)));
   index.triConkeep                            = index.triConkeep(~apnan);
end
