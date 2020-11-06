function [r, lengths] = ZeroTriEdges(p, c, tol)
%
% ZeroTriEdges enforces a zero-slip constraint on the updip, and optionally,
% the downdip edges of a triangular mesh.  This is carried out by zeroing the
% triangular partials corresponding to the edge elements.
%
% Inputs:
%  p = Patch structure
%  c = Command structure
%
% Returns:
%  r = zero edge matrix
%

% See if a depth tolerance exists
if ~exist('tol', 'var')
   tol = [0 0];
end
if numel(tol) == 1
   tol = tol*[1 1];
end

% determine which constraints apply to which patches
nPatches                                     = numel(p.nEl);
nCons                                        = numel(c.triEdge);
if nCons == 3
   c.triEdge                                 = repmat(c.triEdge, 1, nPatches); % replicate options for all patches;
elseif nCons == 3*nPatches
   c.triEdge                                 = c.triEdge;
else   
   error('Blocks:NtriZero', 'Invalid number of triangle edge constraints.')
end

% set up some indexing arrays
elOrd                                        = [0 cumsum(p.nEl)];
coOrd                                        = [0 cumsum(p.nc)];
%coOrd                                        = coOrd(min(p.up):max(p.up)+1);

updips                                       = [];
downdips                                     = [];
latedges                                     = [];

for i = 1:numel(p.nEl);
   elRange                                   = elOrd(i)+1:elOrd(i+1);
   coRange                                   = coOrd(i)+1:coOrd(i+1);
   % find all edge coordinates
   edge                                      = OrderedEdges(p.c, p.v(elRange, :));
   % find all edge elements
   edgeEls                                   = elOrd(i) + find(sum(ismember(p.v(elRange, :), edge), 2) == 2);
   % find the zero depth coordinates
   if c.triEdge(3*i-2) == 1
      zeroTest                               = abs(p.c(coRange, 3)) <= (min(abs(p.c(coRange, 3))) + tol(1));
      zeroZ                                  = coOrd(i) + find(zeroTest);
      % find those elements having two zero-depth coordinates
      updip                                  = elOrd(i) + find(sum(ismember(p.v(elRange, :), zeroZ), 2) >= 2);
      updip                                  = intersect(updip, edgeEls);
      updips                                 = [updips; updip];
   end
   if c.triEdge(3*i-1) == 1
      % find the deepest coordinates
      maxTest                                = abs(p.c(coRange, 3)) >= (max(abs(p.c(coRange, 3))) - tol(2));
      maxZ                                   = coOrd(i) + find(maxTest);
      % find those elements having two max. depth coordinates
      downdip                                = elOrd(i) + find(sum(ismember(p.v(elRange, :), maxZ), 2) >= 2);
      downdip                                = intersect(downdip, edgeEls);
      downdips                               = [downdips; downdip];
   end
   if c.triEdge(3*i-0) == 1
      % separate out those that aren't on the up- or downdip extent
      zeroTest                               = abs(p.c(coRange, 3)) <= (min(abs(p.c(coRange, 3))) + tol(1));
      zeroZ                                  = coOrd(i) + find(zeroTest);
      % find those elements having two zero-depth coordinates
      updip                                  = elOrd(i) + find(sum(ismember(p.v(elRange, :), zeroZ), 2) >= 2);
      updip                                  = intersect(updip, edgeEls);
      
      % find the deepest coordinates
      maxTest                                = abs(p.c(coRange, 3)) >= (max(abs(p.c(coRange, 3))) - tol(2));
      maxZ                                   = coOrd(i) + find(maxTest);
      % find those elements having two max. depth coordinates
      downdip                                = elOrd(i) + find(sum(ismember(p.v(elRange, :), maxZ), 2) >= 2);
      downdip                                = intersect(downdip, edgeEls);
      
      latedge                                = setdiff(edgeEls, [updip(:); downdip(:)]);
      latedges                               = [latedges; latedge];
   end
end
nzs                                          = [updips; downdips; latedges];
lengths                                      = [length(updips); length(downdips); length(latedges)];
r                                            = zeros(2*length(nzs), 2*elOrd(end));
for i = 1:length(nzs)
   r(2*i-1, 2*nzs(i)-1)                      = 1;
   r(2*i-0, 2*nzs(i)-0)                      = 1;
end
