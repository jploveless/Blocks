function [mcslip, invG] = mctrislip(p, trivel, obsvel, nruns, smooth, edge, invG)
% MCTRISLIP  Monte Carlo estimation of triangular slip
%   MCTRISLIP(P, TRIVEL, OBSVEL, NRUNS) uses the patch structure P
%   and the velocity structures TRIVEL and OBSVEL, containing the 
%   predicted velocities from the triangular slip deficit distribution
%   and the observed velocities (Tri.sta and Obs.sta, respectively) to
%   estimate uncertainties on the triangular slip deficit distribution. 
%   NRUNS simulations are carried out, each with a predicted velocity field 
%   perturbed by noise proportional to the station component uncertainties.
%
%   MCTRISLIP(P, TRIVEL, OBSVEL, NRUNS, INVG) allows for input of a pre-
%   calculated inverse of the partial derivatives relating unit triangular
%   slip to station velocity. 
%
%   SLIP = MCTRISLIP(...) returns the results to a 2*nEl-by-NRUNS matrix.
%
%   [SLIP, INVG] = MCTRISLIP(...) also returns the inverse of the Green's
%   functions matrix, for use as an input argument in a subsequent run.
%

% Process inputs, either as structures or filenames
if ~isstruct(p)
   p = ReadPatches(p);
end
p = PatchCoords(p);

if ~isstruct(trivel)
   trivel = ReadStation(trivel);
end

if ~isstruct(obsvel)
   obsvel = ReadStation(obsvel);
end

% Allocate space for arrays
mcslip = zeros(2*sum(p.nEl), nruns);

% Calculate G and its inverse if need be
if ~exist('invG', 'var')
   % Calculate partials
   G = GetTriCombinedPartials(p, trivel, [1 0]);
   
   % Make the Laplacian smoothing matrix
   share = SideShare(p.v); % For each element, give indices of N <= 3 elements that share sides
   dists = TriDistCalc(share, p.xc, p.yc, p.zc); % calculate distance between element centroids and neighbors
   Gsmooth = MakeTriSmooth(share, dists);

   % Weight by resolution
   stpd = sqrt(G(1:3:end, :).^2 + G(2:3:end, :).^2 + G(3:3:end, :).^2); % Station magnitudes from components
   stpd = sum(stpd); % Sum of station magnitudes
   smooth = smooth(:)./(stpd(:)); % Larger sums    = better resolved    = less reliance on smoothing

   % Do edge constraints
   edgeels = edgeelements(p.c, p.v); % Logical of edge elements
   tops = edge(1)*edgeels.top; % Zero out if no constraint
   bots = edge(2)*edgeels.bot; % Zero out if no constraint
   lats = edge(3)*(edgeels.s1 + edgeels.s2); % Zero out if no constraint
   alls = tops + bots + lats;
   Gedge = zeros(3*sum(alls), size(G, 2));
   lidx1 = (3*(find(alls')-1)+0)*size(Gedge, 1)+(1:3:3*sum(alls));
   lidx2 = (3*(find(alls')-1)+1)*size(Gedge, 1)+(2:3:3*sum(alls));
   lidx3 = (3*(find(alls')-1)+2)*size(Gedge, 1)+(3:3:3*sum(alls));
   Gedge([lidx1(:); lidx2(:); lidx3(:)]) = 1;
   
   % Stack partials
   G = [-G; Gsmooth; Gedge];
   G(3:3:end, :) = []; % Remove vertical rows
   G(:, 3:3:end) = []; % Remove tensile columns
   
   % Make weighting
   wsta = stack2([1./obsvel.eastSig.^2, 1./obsvel.northSig.^2]);
   wsmo = smooth; wsmo(3:3:end) = [];
   wedg = 1e1*ones(2/3*size(Gedge, 1), 1);
   w = [wsta; wsmo; wedg];
   W = diag(w);
keyboard
   invG = (G'*W*G)\eye(size(G, 2))*G'*W;
end
Data = zeros(size(invG, 2), 1);

% Make noise matrices
noisee = repmat(obsvel.eastSig, 1, nruns).*randn(length(obsvel.eastSig), nruns);
noisen = repmat(obsvel.northSig, 1, nruns).*randn(length(obsvel.northSig), nruns);

for i = 1:nruns
   data = stack2([trivel.eastVel + noisee(:, i), trivel.northVel + noisen(:, i)]);
   Data(1:length(data)) = data;
   mcslip(:, i) = invG*Data;
%   fprintf('Done with run %g of %g.\n', i, nruns)
end