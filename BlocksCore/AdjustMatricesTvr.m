function [Rt, dt, Wt, Difft, Rg, dg, Wg] = AdjustMatricesTvr(R, d, W, Patches, Index)
% AdjustMatricesTvr  Modifies the combined Blocks Jacobian for TVR. 
%   [R, d, W, Diff] = AdjustMatricesTvr(R, d, W, Patches, Index) uses
%   the Partials, Data, Sigma, Patches, and Index structures to modify the Jacobian R,
%   data vector d, and weighting matrix W for use in a total variation regularization
%   estimation of slip on triangular patches. The Patches structure is used to construct
%   the discrete difference matrix, Diff. 
%

% Find rows not corresponding to smoothing matrix
keep = setdiff(1:size(R, 1), Index.rows{5, 2});

% Extract subsets of arrays for TVR as *t
Rt = R(keep, :);
dt = d(keep, :);
Wt = W(keep, :);
Wt = Wt(:, keep);

% Keep just Green's functions arrays as *g
keep = [Index.rows{1, 1}, Index.rows{2, 1}];
Rg = R(keep, :);
dg = d(keep);
Wg = W(keep, :);
Wg = Wg(:, keep);

% Make difference operator
difft = MakeDiffMatrix_mesh2d(Patches);
% Adjust size
%difft = difft(Index.triSmoothkeep, Index.triColkeep);
% Place into larger penalty array augmented with zeros
Difft = zeros(size(difft, 1), size(R, 2));
Difft(:, Index.cols{5, 2}) = difft; % Essentially replacing smoothing matrix from classic
