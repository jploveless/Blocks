function [w, strength] = trismoothmp(p, s, G, beta)
% trismoothmp   Creates resolution-based Laplacian smoothing matrix.
%    [W, STRENGTH] = trismoothmp(P, S, G, BETA) creates a Laplacian
%    smoothing matrix that takes into account several characteristics
%    of a mesh of triangular dislocation elements, P, and constraining 
%    data, including station displacement uncertainties, contained in 
%    station structure S; the partial derivatives relating station 
%    displacement to .  W represents the 2*nEl-by-2*nEl generic smoothing matrix, 
%    while STRENGTH is a 2*nEl-by-2*nEl matrix defining the weighting
%    of the smoothing matrix to be used in an inversion.
%
%    The entries of WEIGHT are determined by:
%    - Inter-element distance (larger elements are smoothed less)
%    - Magnitude of the partial derivatives relating slip to displacement 
%      (elements less well resolved are smoothed more)
%    - Uncertainty of constraining stations (noisier stations weight the
%      summed partial derivatives less)
%    - Mesh-wide smoothing factor, BETA.
%    
%    The final value of WEIGHT is given as:
%    (1/DIST^2)*(MP/SS^2)*BETA
%    where DIST is the mean distance between an element and its neighbors,
%    MP is the sum of the rows of the partial derivatives relating station
%    displacement to each component of slip, SS is the station displacement
%    uncertainty, and BETA is the mesh-wide smoothing factor.
%

% Find neighbors
share = SideShare(p.v);

% Find intercentroid distances
dists = TriDistCalc(share, p.xc, p.yc, p.zc);

% Make the smoothing matrix
w = MakeTriSmoothAlt(share);

% Distance based smoothing
distScale = (sum(dists, 2)./sum(dists ~= 0, 2)).^2;

% Find sum of partials, weighted by uncertainties

% First trim verticals, if necessary
if size(G, 1) == 3*numel(s.eastVel) 
   GU = G./repmat(stack3([s.eastSig.^2 s.northSig.^2 s.upSig.^2]), 1, size(G, 2));
   GUm = sqrt(GU(1:3:end, :).^2 + GU(2:3:end, :).^2 + GU(3:3:end, :).^2);
else
   GU = G./repmat(stack2([s.eastSig.^2 s.northSig.^2]), 1, size(G, 2));
   GUm = sqrt(GU(1:2:end, :).^2 + GU(2:2:end, :).^2);
end
sGUm = sum(GUm);

% Trim one slip component, if necessary
if size(w, 2) > size(G, 2)
   triS = [1:sum(p.nEl)]'; % All include strike
   triD = find(abs(p.dip - 90) > 1); % Find those with dip-slip
   triT = find(abs(p.dip - 90) <= 1); % Find those with tensile slip
   colkeep = setdiff(1:numel(p.v), [3*triD-0; 3*triT-1]);
   w = w(colkeep, :); 
   w = w(:, colkeep);
end

if size(sGUm, 2) > size(G, 2)
   sGUm = sGUm(colkeep);
end

% Weight smoothing by distance, partials strength, and smoothing factor
strength = stack2(repmat(distScale(:), 1, 2)).*2.^sGUm(:);

% Smoothing factor
if numel(beta) == 1
   beta = repmat(beta, 2*sum(p.nEl), 1);
elseif numel(beta) == numel(p.nEl)
   pidx = zeros(sum(p.nEl), 1);
   pidx(1+[0; p.nEl(1:end-1)]) = 1;
   pidx = cumsum(pidx);
   beta = stack2(repmat(beta(pidx), 1, 2));
else
   error('BETA must be a scalar or a vector equal in size to p.nEl.')
end

% Full product
strength = beta./strength;




